import { HifzSessionConfig, HifzPlaybackState } from '../types/hifz';
import { HIFZ_RECITERS, buildAudioUrl, getFallbackAudioUrl } from '../data/hifzReciters';

export type HifzStateCallback = (state: HifzPlaybackState) => void;
export type HifzCompleteCallback = () => void;
export type HifzErrorCallback = (error: string) => void;

interface PlaylistItem {
  surah: number;
  ayah: number;
  type: 'single' | 'link' | 'block';
  loopIndex: number;
  totalLoops: number;
  description: string;
  isEndOfPassage: boolean;
}

export class HifzAudioEngine {
  private audio: HTMLAudioElement | null = null;
  private config: HifzSessionConfig | null = null;
  private isRunning: boolean = false;
  private isPaused: boolean = false;
  private playlist: PlaylistItem[] = [];
  private currentIndex: number = 0;
  private silenceTimer: ReturnType<typeof setInterval> | null = null;
  private onStateChange: HifzStateCallback | null = null;
  private onComplete: HifzCompleteCallback | null = null;
  private onError: HifzErrorCallback | null = null;
  private isFallbackAttempted: boolean = false;

  constructor() {
    if (typeof window !== 'undefined') {
      this.initAudioElement();
    }
  }

  private initAudioElement() {
    if (!this.audio) {
      this.audio = new Audio();
    }
    this.audio.preload = 'auto';
    this.audio.onended = () => this.handleAudioEnded();
    this.audio.onerror = (e) => this.handleAudioError(e);
  }

  private resetAudioElement() {
    if (!this.audio) return;
    // Detach handlers before removing source to prevent unwanted error events
    this.audio.onended = null;
    this.audio.onerror = null;
    this.audio.pause();
    this.audio.currentTime = 0;
    this.audio.removeAttribute('src');
    this.audio.load();

    // Re-attach handlers cleanly
    this.audio.onended = () => this.handleAudioEnded();
    this.audio.onerror = (e) => this.handleAudioError(e);
  }

  public setCallbacks(
    onStateChange: HifzStateCallback,
    onComplete: HifzCompleteCallback,
    onError: HifzErrorCallback
  ) {
    this.onStateChange = onStateChange;
    this.onComplete = onComplete;
    this.onError = onError;
  }

  public startSession(config: HifzSessionConfig) {
    this.stopSession();
    this.config = config;
    this.isRunning = true;
    this.isPaused = false;
    this.isFallbackAttempted = false;
    this.buildPlaylist();

    if (this.playlist.length === 0) {
      this.onError?.('قائمة التكرار فارغة');
      return;
    }

    this.currentIndex = 0;
    this.playCurrentItem();
  }

  public pause() {
    if (!this.isRunning || this.isPaused) return;
    this.isPaused = true;
    if (this.audio) {
      this.audio.pause();
    }
    if (this.silenceTimer) {
      clearInterval(this.silenceTimer);
      this.silenceTimer = null;
    }
    this.emitState(false, 0);
  }

  public resume() {
    if (!this.isRunning || !this.isPaused) return;
    this.isPaused = false;
    if (this.audio && this.audio.getAttribute('src')) {
      const p = this.audio.play();
      if (p !== undefined) {
        p.catch((err) => {
          if (err?.name === 'AbortError') return;
          console.warn('Resume notice:', err);
        });
      }
    } else {
      this.playCurrentItem();
    }
    this.emitState(false, 0);
  }

  public setPlaybackRate(rate: number) {
    if (this.config) {
      this.config.playbackRate = rate;
    }
    if (this.audio) {
      this.audio.playbackRate = rate;
      this.audio.defaultPlaybackRate = rate;
    }
  }

  public stopSession() {
    this.isRunning = false;
    this.isPaused = false;
    this.isFallbackAttempted = false;
    this.resetAudioElement();

    if (this.silenceTimer) {
      clearInterval(this.silenceTimer);
      this.silenceTimer = null;
    }
    this.playlist = [];
    this.currentIndex = 0;

    this.onStateChange?.({
      isActive: false,
      isPaused: false,
      isFocusMode: false,
      currentAyahNumber: 1,
      currentLoopIndex: 0,
      totalLoopsForCurrentStage: 0,
      currentStageDescription: '',
      isSilencePause: false,
      silenceRemainingSeconds: 0,
    });
  }

  private buildPlaylist() {
    if (!this.config) return;
    const {
      surahNumber,
      startAyah,
      endAyah,
      repetitionMode,
      blockRepeatCount,
      singleRepeatCount,
      linkGroupSize,
      linkGroupRepeatCount,
    } = this.config;

    this.playlist = [];
    const verses: number[] = [];
    for (let a = startAyah; a <= endAyah; a++) {
      verses.push(a);
    }
    if (verses.length === 0) return;

    // Mode 1: Combined Block Repetition (Loops entire passage together)
    if (repetitionMode === 'combined_block') {
      const loops = Math.max(1, blockRepeatCount || singleRepeatCount || 5);
      const blockLabel = `${startAyah}-${endAyah}`;

      for (let r = 1; r <= loops; r++) {
        verses.forEach((v, idx) => {
          const isEndOfBlock = idx === verses.length - 1;
          this.playlist.push({
            surah: surahNumber,
            ayah: v,
            type: 'block',
            loopIndex: r,
            totalLoops: loops,
            description: `المقطع المجمع (${blockLabel}) • دورة ${r} من ${loops} • آية ${v}`,
            isEndOfPassage: isEndOfBlock,
          });
        });
      }
    } else {
      // Mode 2: Verse-by-Verse (Single loops then linked groups)
      // Step 1: For each verse, repeat N times
      for (const v of verses) {
        for (let r = 1; r <= singleRepeatCount; r++) {
          this.playlist.push({
            surah: surahNumber,
            ayah: v,
            type: 'single',
            loopIndex: r,
            totalLoops: singleRepeatCount,
            description: `آية ${v} • تكرار ${r} من ${singleRepeatCount}`,
            isEndOfPassage: true,
          });
        }
      }

      // Step 2: Linked groups repetition (if more than 1 verse and linkGroupRepeatCount > 0)
      if (verses.length > 1 && linkGroupRepeatCount > 0) {
        const gSize = Math.max(2, linkGroupSize);
        for (let i = 0; i < verses.length; i += gSize) {
          const group = verses.slice(i, i + gSize);
          if (group.length > 1) {
            const groupLabel = `${group[0]} - ${group[group.length - 1]}`;
            for (let lr = 1; lr <= linkGroupRepeatCount; lr++) {
              group.forEach((gv, gIdx) => {
                const isEndOfGroup = gIdx === group.length - 1;
                this.playlist.push({
                  surah: surahNumber,
                  ayah: gv,
                  type: 'link',
                  loopIndex: lr,
                  totalLoops: linkGroupRepeatCount,
                  description: `ربط الآيات (${groupLabel}) • دورة ${lr} من ${linkGroupRepeatCount} • آية ${gv}`,
                  isEndOfPassage: isEndOfGroup,
                });
              });
            }
          }
        }
      }
    }
  }

  private playCurrentItem(isFallback: boolean = false) {
    if (!this.isRunning || !this.config) return;
    if (this.currentIndex >= this.playlist.length) {
      this.isRunning = false;
      this.stopSession();
      this.onComplete?.();
      return;
    }

    const item = this.playlist[this.currentIndex];
    const reciter =
      HIFZ_RECITERS.find((r) => r.id === this.config?.reciterId) || HIFZ_RECITERS[0];

    const audioUrl = isFallback
      ? getFallbackAudioUrl(item.surah, item.ayah)
      : buildAudioUrl(reciter, item.surah, item.ayah);

    if (this.audio) {
      this.audio.src = audioUrl;
      const rate = this.config?.playbackRate || 1.0;
      this.audio.playbackRate = rate;
      this.audio.defaultPlaybackRate = rate;
      const playPromise = this.audio.play();

      if (playPromise !== undefined) {
        playPromise
          .then(() => {
            if (this.isRunning) {
              this.emitState(false, 0);
            }
          })
          .catch((err) => {
            if (err?.name === 'AbortError') return;
            console.warn('Playback notice:', err?.message || err);

            if (!isFallback) {
              this.isFallbackAttempted = true;
              this.playCurrentItem(true);
            } else {
              this.handleAudioEnded();
            }
          });
      }
    }
  }

  private handleAudioEnded() {
    if (!this.isRunning || !this.config) return;
    this.isFallbackAttempted = false;

    const currentItem = this.playlist[this.currentIndex];
    const delay = this.config.pauseDelaySeconds;

    // Apply recitation pause only if at the end of the passage/block
    if (currentItem?.isEndOfPassage && delay > 0) {
      this.startSilenceCountdown(delay, () => {
        this.currentIndex++;
        this.playCurrentItem();
      });
    } else {
      this.currentIndex++;
      this.playCurrentItem();
    }
  }

  private startSilenceCountdown(seconds: number, onDone: () => void) {
    let remaining = seconds;
    this.emitState(true, remaining);

    if (this.silenceTimer) {
      clearInterval(this.silenceTimer);
    }

    this.silenceTimer = setInterval(() => {
      if (this.isPaused) return;
      remaining -= 1;
      if (remaining <= 0) {
        if (this.silenceTimer) {
          clearInterval(this.silenceTimer);
          this.silenceTimer = null;
        }
        this.emitState(false, 0);
        onDone();
      } else {
        this.emitState(true, remaining);
      }
    }, 1000);
  }

  private handleAudioError(e: string | Event) {
    // If audio element is reset, paused, or no longer has a source, ignore
    if (!this.isRunning || !this.audio || !this.audio.getAttribute('src')) {
      return;
    }

    // Ignore aborted requests (e.g. user pressed pause or skipped)
    if (this.audio.error && this.audio.error.code === 1) {
      return;
    }

    console.warn('Audio notice:', e);

    if (!this.isFallbackAttempted && this.config) {
      this.isFallbackAttempted = true;
      this.playCurrentItem(true);
      return;
    }

    // Gracefully advance to next item after small delay without breaking the user session
    setTimeout(() => {
      if (this.isRunning) {
        this.currentIndex++;
        this.isFallbackAttempted = false;
        this.playCurrentItem();
      }
    }, 1000);
  }

  private emitState(isSilence: boolean, silenceRemaining: number) {
    if (!this.isRunning) return;
    const currentItem = this.playlist[this.currentIndex];
    if (!currentItem) return;

    this.onStateChange?.({
      isActive: true,
      isPaused: this.isPaused,
      isFocusMode: true,
      currentAyahNumber: currentItem.ayah,
      currentLoopIndex: currentItem.loopIndex,
      totalLoopsForCurrentStage: currentItem.totalLoops,
      currentStageDescription: currentItem.description,
      isSilencePause: isSilence,
      silenceRemainingSeconds: silenceRemaining,
    });
  }
}

export const hifzAudioEngine = new HifzAudioEngine();
