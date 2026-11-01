export type Riwayah = 'hafs' | 'qalun' | 'warsh';
export type MaskingMode = 'visible' | 'blurred' | 'hidden';
export type RepetitionMode = 'verse_by_verse' | 'combined_block';

export interface HifzReciter {
  id: string;
  nameAr: string;
  nameEn: string;
  riwayah: Riwayah;
  style: string;
  cdnPattern: string; // URL template or subfolder
  isFullSurahSliced?: boolean;
  timingUrl?: string;
}

export interface HifzSessionConfig {
  surahNumber: number;
  startAyah: number;
  endAyah: number;
  repetitionMode: RepetitionMode; // 'verse_by_verse' | 'combined_block'
  blockRepeatCount: number;       // Number of times to loop the entire combined block
  singleRepeatCount: number; // N
  linkGroupSize: number;     // G
  linkGroupRepeatCount: number; // M
  pauseDelaySeconds: number; // X
  riwayah: Riwayah;
  reciterId: string;
  maskingMode: MaskingMode;
  fontSize: number;
  playbackRate: number; // 0.75, 1.0, 1.25, 1.5
}

export interface HifzPlaybackState {
  isActive: boolean;
  isPaused: boolean;
  isFocusMode: boolean; // Auto-hides UI navigation
  currentAyahNumber: number;
  currentLoopIndex: number;
  totalLoopsForCurrentStage: number;
  currentStageDescription: string; // e.g. "آية 255 • تكرار 3 من 5" or "ربط مجموعة (1-3) • تكرار 2 من 3"
  isSilencePause: boolean;
  silenceRemainingSeconds: number;
}

export interface HalaqaParticipant {
  id: string;
  name: string;
  isSpeaking: boolean;
  isMuted: boolean;
  isCurrentTurn: boolean;
}

export interface HalaqaRoomState {
  roomId: string;
  isConnected: boolean;
  isAudioMuted: boolean;
  activeSurah: number;
  activeStartAyah: number;
  activeEndAyah: number;
  activeRiwayah: Riwayah;
  currentTurnSpeakerId: string;
  participants: HalaqaParticipant[];
}

export interface PrayerAlarmItem {
  id: string;
  prayerNameAr: string;
  prayerNameEn: string;
  time: string;
  timestamp: Date;
  isAlarmEnabled: boolean;
  targetVersesDescription: string;
  escalationIds: number[]; // 101, 102, 103, 104
}
