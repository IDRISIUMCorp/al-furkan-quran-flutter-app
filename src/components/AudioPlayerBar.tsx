import React, { useEffect, useRef, useState } from 'react';
import { Play, Pause, SkipBack, SkipForward, Volume2, RotateCcw, X, User, Timer } from 'lucide-react';
import { Reciter } from '../types/quran';
import { RECITERS, getAyahAudioUrl } from '../data/reciters';
import { SURAH_LIST } from '../data/surahList';

interface AudioPlayerBarProps {
  currentSurah: number;
  currentAyah: number;
  isPlaying: boolean;
  onTogglePlay: () => void;
  onNextAyah: () => void;
  onPrevAyah: () => void;
  onClose: () => void;
  onAyahEnded: () => void;
  repeatMode: 'off' | '3x' | 'infinity';
  setRepeatMode: (mode: 'off' | '3x' | 'infinity') => void;
  selectedReciter: Reciter;
  setSelectedReciter: (r: Reciter) => void;
}

export const AudioPlayerBar: React.FC<AudioPlayerBarProps> = ({
  currentSurah,
  currentAyah,
  isPlaying,
  onTogglePlay,
  onNextAyah,
  onPrevAyah,
  onClose,
  onAyahEnded,
  repeatMode,
  setRepeatMode,
  selectedReciter,
  setSelectedReciter,
}) => {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [playbackSpeed, setPlaybackSpeed] = useState<number>(1.0);
  const [showReciterModal, setShowReciterModal] = useState<boolean>(false);
  const [repeatCountRemaining, setRepeatCountRemaining] = useState<number>(0);
  const [progress, setProgress] = useState<number>(0);
  const [duration, setDuration] = useState<number>(0);
  const [isBuffering, setIsBuffering] = useState<boolean>(false);
  const [sleepTimerMinutes, setSleepTimerMinutes] = useState<number | null>(null);
  const sleepTimerRef = useRef<any>(null);

  const surahMeta = SURAH_LIST.find((s) => s.number === currentSurah) || SURAH_LIST[0];
  const audioUrl = getAyahAudioUrl(selectedReciter.subfolder, currentSurah, currentAyah);

  // When Ayah changes or repeat changes, reset repeat count
  useEffect(() => {
    if (repeatMode === '3x') {
      setRepeatCountRemaining(2); // will repeat 2 more times (total 3)
    } else {
      setRepeatCountRemaining(0);
    }
  }, [currentSurah, currentAyah, repeatMode]);

  // Handle sleep timer
  useEffect(() => {
    if (sleepTimerRef.current) clearTimeout(sleepTimerRef.current);
    if (sleepTimerMinutes && sleepTimerMinutes > 0) {
      sleepTimerRef.current = setTimeout(() => {
        if (audioRef.current) {
          audioRef.current.pause();
        }
        if (isPlaying) onTogglePlay();
        setSleepTimerMinutes(null);
      }, sleepTimerMinutes * 60 * 1000);
    }
    return () => {
      if (sleepTimerRef.current) clearTimeout(sleepTimerRef.current);
    };
  }, [sleepTimerMinutes, isPlaying, onTogglePlay]);

  // Handle Play/Pause
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    audio.playbackRate = playbackSpeed;

    if (isPlaying) {
      audio.play().catch((err) => {
        console.warn('Audio play request interrupted or requires user gesture:', err);
      });
    } else {
      audio.pause();
    }
  }, [isPlaying, audioUrl, playbackSpeed]);

  const handleEnded = () => {
    if (repeatMode === 'infinity') {
      if (audioRef.current) {
        audioRef.current.currentTime = 0;
        audioRef.current.play();
      }
      return;
    }

    if (repeatMode === '3x' && repeatCountRemaining > 0) {
      setRepeatCountRemaining((prev) => prev - 1);
      if (audioRef.current) {
        audioRef.current.currentTime = 0;
        audioRef.current.play();
      }
      return;
    }

    onAyahEnded();
  };

  const handleSeek = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = parseFloat(e.target.value);
    if (audioRef.current && duration > 0) {
      audioRef.current.currentTime = (val / 100) * duration;
      setProgress(val);
    }
  };

  const cycleRepeat = () => {
    if (repeatMode === 'off') setRepeatMode('3x');
    else if (repeatMode === '3x') setRepeatMode('infinity');
    else setRepeatMode('off');
  };

  const cycleSpeed = () => {
    const speeds = [0.75, 1.0, 1.25, 1.5];
    const nextIdx = (speeds.indexOf(playbackSpeed) + 1) % speeds.length;
    setPlaybackSpeed(speeds[nextIdx]);
  };

  return (
    <>
      <audio
        ref={audioRef}
        src={audioUrl}
        onTimeUpdate={() => {
          if (audioRef.current && audioRef.current.duration) {
            setProgress((audioRef.current.currentTime / audioRef.current.duration) * 100);
            setDuration(audioRef.current.duration);
          }
        }}
        onWaiting={() => setIsBuffering(true)}
        onCanPlay={() => setIsBuffering(false)}
        onEnded={handleEnded}
      />

      {/* Floating Bottom Bar */}
      <div className="fixed bottom-0 inset-x-0 z-40 bg-[#FAF7F2]/95 dark:bg-[#151B17]/95 backdrop-blur-md border-t border-[#E8E2D7] dark:border-[#242E28] shadow-2xl px-4 py-2.5 transition-colors">
        <div className="max-w-4xl mx-auto flex flex-col gap-1.5">
          {/* Progress bar */}
          <div className="w-full flex items-center gap-2">
            <input
              type="range"
              min="0"
              max="100"
              value={progress || 0}
              onChange={handleSeek}
              className="w-full h-1 bg-[#E8E2D7] dark:bg-[#28342D] accent-[#5D7263] rounded-lg cursor-pointer"
            />
          </div>

          <div className="flex items-center justify-between gap-3">
            {/* Surah & Ayah info */}
            <div className="flex items-center gap-2 min-w-0">
              <div className="w-9 h-9 rounded-xl bg-[#5D7263]/15 dark:bg-[#5D7263]/25 flex items-center justify-center text-[#3B5249] dark:text-[#A7BFAC] font-bold text-sm shrink-0">
                {currentSurah}
              </div>
              <div className="truncate">
                <div className="flex items-center gap-1.5">
                  <span className="font-bold text-sm text-[#2D3748] dark:text-[#E2E8F0] truncate">
                    سورة {surahMeta.nameAr}
                  </span>
                  <span className="text-xs px-1.5 py-0.5 rounded bg-[#5D7263]/10 text-[#5D7263] dark:text-[#A7BFAC] font-medium">
                    آية {currentAyah}
                  </span>
                </div>
                <button
                  onClick={() => setShowReciterModal(true)}
                  className="text-[11px] text-[#718096] dark:text-[#94A3B8] hover:text-[#5D7263] dark:hover:text-[#A7BFAC] flex items-center gap-1 truncate text-right"
                >
                  <User className="w-3 h-3 inline" />
                  <span>{selectedReciter.nameAr} ({selectedReciter.style})</span>
                </button>
              </div>
            </div>

            {/* Playback Controls */}
            <div className="flex items-center gap-2 sm:gap-3">
              {/* Prev verse */}
              <button
                onClick={onPrevAyah}
                className="p-2 rounded-lg text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28] transition"
                title="الآية السابقة"
              >
                <SkipForward className="w-4 h-4" />
              </button>

              {/* Play / Pause */}
              <button
                onClick={onTogglePlay}
                className="w-10 h-10 rounded-full bg-[#5D7263] hover:bg-[#4B5E51] text-white flex items-center justify-center shadow-md transition transform active:scale-95"
                title={isPlaying ? 'إيقاف مؤقت' : 'تشغيل'}
              >
                {isBuffering ? (
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                ) : isPlaying ? (
                  <Pause className="w-5 h-5 fill-current" />
                ) : (
                  <Play className="w-5 h-5 fill-current mr-0.5" />
                )}
              </button>

              {/* Next verse */}
              <button
                onClick={onNextAyah}
                className="p-2 rounded-lg text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28] transition"
                title="الآية التالية"
              >
                <SkipBack className="w-4 h-4" />
              </button>
            </div>

            {/* Extra Controls */}
            <div className="flex items-center gap-1.5 sm:gap-2">
              {/* Repeat button */}
              <button
                onClick={cycleRepeat}
                className={`px-2 py-1 rounded-lg text-xs font-semibold flex items-center gap-1 transition ${
                  repeatMode !== 'off'
                    ? 'bg-[#5D7263]/20 text-[#3B5249] dark:text-[#A7BFAC]'
                    : 'text-[#718096] dark:text-[#94A3B8] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28]'
                }`}
                title="تكرار الآية للحفظ"
              >
                <RotateCcw className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">
                  {repeatMode === 'off' ? 'تكرار' : repeatMode === '3x' ? '٣ مرات' : 'مستمر'}
                </span>
              </button>

              {/* Speed button */}
              <button
                onClick={cycleSpeed}
                className="px-2 py-1 rounded-lg text-xs font-semibold text-[#718096] dark:text-[#94A3B8] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28] transition"
                title="سرعة التلاوة"
              >
                {playbackSpeed}x
              </button>

              {/* Sleep timer */}
              <button
                onClick={() => {
                  if (!sleepTimerMinutes) setSleepTimerMinutes(15);
                  else if (sleepTimerMinutes === 15) setSleepTimerMinutes(30);
                  else if (sleepTimerMinutes === 30) setSleepTimerMinutes(60);
                  else setSleepTimerMinutes(null);
                }}
                className={`p-1.5 rounded-lg transition ${
                  sleepTimerMinutes
                    ? 'bg-amber-100 text-amber-800 dark:bg-amber-950/40 dark:text-amber-300'
                    : 'text-[#718096] dark:text-[#94A3B8] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28]'
                }`}
                title={sleepTimerMinutes ? `مؤقت النوم: ${sleepTimerMinutes} دقيقة` : 'مؤقت النوم'}
              >
                <Timer className="w-4 h-4" />
              </button>

              {/* Close Bar */}
              <button
                onClick={onClose}
                className="p-1.5 rounded-lg text-[#718096] dark:text-[#94A3B8] hover:bg-rose-100 dark:hover:bg-rose-950/40 hover:text-rose-600 transition"
                title="إغلاق المشغل"
              >
                <X className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Reciter Picker Modal */}
      {showReciterModal && (
        <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-[#FAF7F2] dark:bg-[#1A221E] w-full max-w-md rounded-2xl p-5 border border-[#E8E2D7] dark:border-[#2D3A32] shadow-2xl space-y-4 max-h-[85vh] flex flex-col">
            <div className="flex items-center justify-between border-b border-[#E8E2D7] dark:border-[#2D3A32] pb-3">
              <div className="flex items-center gap-2">
                <Volume2 className="w-5 h-5 text-[#5D7263]" />
                <h3 className="font-bold text-base text-[#2D3748] dark:text-[#E2E8F0]">
                  اختيار القارئ
                </h3>
              </div>
              <button
                onClick={() => setShowReciterModal(false)}
                className="p-1.5 rounded-lg text-[#718096] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28]"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="overflow-y-auto space-y-2 flex-1 pr-1">
              {RECITERS.map((r) => {
                const isSelected = r.id === selectedReciter.id;
                return (
                  <button
                    key={r.id}
                    onClick={() => {
                      setSelectedReciter(r);
                      setShowReciterModal(false);
                    }}
                    className={`w-full flex items-center justify-between p-3 rounded-xl border text-right transition ${
                      isSelected
                        ? 'border-[#5D7263] bg-[#5D7263]/10 dark:bg-[#5D7263]/20 text-[#2D3748] dark:text-[#E2E8F0]'
                        : 'border-[#E8E2D7] dark:border-[#2D3A32] hover:bg-[#EFE9DF]/60 dark:hover:bg-[#242E28]/60 text-[#4A5568] dark:text-[#CBD5E1]'
                    }`}
                  >
                    <div>
                      <div className="font-bold text-sm text-[#2D3748] dark:text-[#E2E8F0]">{r.nameAr}</div>
                      <div className="text-xs text-[#718096] dark:text-[#94A3B8]">{r.nameEn} • {r.style}</div>
                    </div>
                    {isSelected && (
                      <span className="text-xs font-bold text-[#5D7263] bg-[#5D7263]/15 px-2 py-0.5 rounded-full">
                        محدد
                      </span>
                    )}
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      )}
    </>
  );
};
