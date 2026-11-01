import { HalaqaParticipant, HalaqaRoomState, Riwayah } from '../types/hifz';

// Helper to base64url encode strings/buffers
function base64UrlEncode(str: string): string {
  return btoa(str)
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}

function arrayBufferToBase64Url(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return base64UrlEncode(binary);
}

/**
 * Generate a standard LiveKit AccessToken entirely client-side using Web Crypto HMAC-SHA256
 */
export async function generateLiveKitToken(
  apiKey: string,
  apiSecret: string,
  roomName: string,
  participantIdentity: string,
  participantName: string
): Promise<string> {
  const header = {
    alg: 'HS256',
    typ: 'JWT',
  };

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    exp: now + 6 * 3600, // 6 hours
    nbf: now - 5,
    iss: apiKey,
    sub: participantIdentity,
    name: participantName,
    video: {
      room: roomName,
      roomJoin: true,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    },
  };

  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const dataToSign = `${encodedHeader}.${encodedPayload}`;

  // Use Web Crypto API to sign with HS256
  const enc = new TextEncoder();
  const key = await window.crypto.subtle.importKey(
    'raw',
    enc.encode(apiSecret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const signature = await window.crypto.subtle.sign(
    'HMAC',
    key,
    enc.encode(dataToSign)
  );

  const encodedSignature = arrayBufferToBase64Url(signature);
  return `${dataToSign}.${encodedSignature}`;
}

export class HalaqaRoomService {
  private state: HalaqaRoomState = {
    roomId: '',
    isConnected: false,
    isAudioMuted: false,
    activeSurah: 1,
    activeStartAyah: 1,
    activeEndAyah: 7,
    activeRiwayah: 'hafs',
    currentTurnSpeakerId: 'me',
    participants: [],
  };

  private listeners: ((state: HalaqaRoomState) => void)[] = [];
  private mediaStream: MediaStream | null = null;
  private audioContext: AudioContext | null = null;
  private analyser: AnalyserNode | null = null;
  private volumeCheckInterval: ReturnType<typeof setInterval> | null = null;

  public subscribe(listener: (state: HalaqaRoomState) => void) {
    this.listeners.push(listener);
    listener(this.state);
    return () => {
      this.listeners = this.listeners.filter((l) => l !== listener);
    };
  }

  private notify() {
    this.listeners.forEach((l) => l({ ...this.state }));
  }

  public async joinRoom(
    roomId: string,
    userName: string,
    surahNumber: number = 1,
    startAyah: number = 1,
    endAyah: number = 7,
    riwayah: Riwayah = 'hafs'
  ) {
    this.state = {
      roomId,
      isConnected: true,
      isAudioMuted: false,
      activeSurah: surahNumber,
      activeStartAyah: startAyah,
      activeEndAyah: endAyah,
      activeRiwayah: riwayah,
      currentTurnSpeakerId: 'me',
      participants: [
        {
          id: 'me',
          name: userName || 'أنت (الحافظ)',
          isSpeaking: false,
          isMuted: false,
          isCurrentTurn: true,
        },
        // Simulated companion learners in the room
        {
          id: 'p2',
          name: 'عبد الرحمن',
          isSpeaking: false,
          isMuted: false,
          isCurrentTurn: false,
        },
        {
          id: 'p3',
          name: 'طارق الزيتوني',
          isSpeaking: false,
          isMuted: true,
          isCurrentTurn: false,
        },
      ],
    };
    this.notify();

    // Start real microphone access if permitted
    try {
      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        this.mediaStream = await navigator.mediaDevices.getUserMedia({
          audio: { echoCancellation: true, noiseSuppression: true },
        });

        const AudioCtx = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
        this.audioContext = new AudioCtx();
        const source = this.audioContext.createMediaStreamSource(this.mediaStream);
        this.analyser = this.audioContext.createAnalyser();
        this.analyser.fftSize = 256;
        source.connect(this.analyser);

        const dataArray = new Uint8Array(this.analyser.frequencyBinCount);

        this.volumeCheckInterval = setInterval(() => {
          if (!this.state.isConnected || this.state.isAudioMuted || !this.analyser) {
            this.setParticipantSpeaking('me', false);
            return;
          }
          this.analyser.getByteFrequencyData(dataArray);
          let sum = 0;
          for (let i = 0; i < dataArray.length; i++) {
            sum += dataArray[i];
          }
          const avg = sum / dataArray.length;
          const isSpeaking = avg > 25; // threshold
          this.setParticipantSpeaking('me', isSpeaking);
        }, 150);
      }
    } catch (err) {
      console.warn('Microphone permission not granted or available in preview:', err);
    }
  }

  public leaveRoom() {
    if (this.mediaStream) {
      this.mediaStream.getTracks().forEach((t) => t.stop());
      this.mediaStream = null;
    }
    if (this.audioContext) {
      this.audioContext.close();
      this.audioContext = null;
    }
    if (this.volumeCheckInterval) {
      clearInterval(this.volumeCheckInterval);
      this.volumeCheckInterval = null;
    }

    this.state = {
      roomId: '',
      isConnected: false,
      isAudioMuted: false,
      activeSurah: 1,
      activeStartAyah: 1,
      activeEndAyah: 7,
      activeRiwayah: 'hafs',
      currentTurnSpeakerId: '',
      participants: [],
    };
    this.notify();
  }

  public toggleMute() {
    const nextMuted = !this.state.isAudioMuted;
    this.state.isAudioMuted = nextMuted;
    if (this.mediaStream) {
      this.mediaStream.getAudioTracks().forEach((track) => {
        track.enabled = !nextMuted;
      });
    }
    this.setParticipantMuted('me', nextMuted);
    this.notify();
  }

  public setTurn(participantId: string) {
    this.state.currentTurnSpeakerId = participantId;
    this.state.participants = this.state.participants.map((p) => ({
      ...p,
      isCurrentTurn: p.id === participantId,
    }));
    this.notify();
  }

  public syncVerseRange(surah: number, start: number, end: number, riwayah: Riwayah) {
    this.state.activeSurah = surah;
    this.state.activeStartAyah = start;
    this.state.activeEndAyah = end;
    this.state.activeRiwayah = riwayah;
    this.notify();
  }

  private setParticipantSpeaking(id: string, isSpeaking: boolean) {
    let changed = false;
    this.state.participants = this.state.participants.map((p) => {
      if (p.id === id && p.isSpeaking !== isSpeaking) {
        changed = true;
        return { ...p, isSpeaking };
      }
      return p;
    });
    if (changed) {
      this.notify();
    }
  }

  private setParticipantMuted(id: string, isMuted: boolean) {
    this.state.participants = this.state.participants.map((p) =>
      p.id === id ? { ...p, isMuted } : p
    );
    this.notify();
  }
}

export const halaqaRoomService = new HalaqaRoomService();
