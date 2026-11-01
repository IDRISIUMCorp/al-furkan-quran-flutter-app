import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  Eye,
  EyeOff,
  Sparkles,
  Play,
  Pause,
  Square,
  ZoomIn,
  ZoomOut,
  ChevronRight,
  ChevronLeft,
  Mic,
  Maximize2,
  Minimize2,
  CheckCircle2,
  Info,
} from 'lucide-react';
import { Ayah } from '../types/quran';
import { HifzSessionConfig, HifzPlaybackState, MaskingMode } from '../types/hifz';
import { getSurahAyahs } from '../services/quranService';
import { SURAH_LIST } from '../data/surahList';
import { hifzAudioEngine } from '../services/hifzAudioEngine';

interface ZenHifzViewProps {
  sessionConfig: HifzSessionConfig;
  onUpdateConfig: (newConfig: HifzSessionConfig) => void;
  onOpenSetup: () => void;
  onOpenSurahPicker: () => void;
  isFocusModeActive: boolean;
  setIsFocusModeActive: (active: boolean) => void;
}

export const ZenHifzView: React.FC<ZenHifzViewProps> = ({
  sessionConfig,
  onUpdateConfig,
  onOpenSetup,
  onOpenSurahPicker,
  isFocusModeActive,
  setIsFocusModeActive,
}) => {
  const [ayahs, setAyahs] = useState<Ayah[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [playbackState, setPlaybackState] = useState<HifzPlaybackState>({
    isActive: false,
    isPaused: false,
    isFocusMode: false,
    currentAyahNumber: sessionConfig.startAyah,
    currentLoopIndex: 0,
    totalLoopsForCurrentStage: 0,
    currentStageDescription: '',
    isSilencePause: false,
    silenceRemainingSeconds: 0,
  });

  // Tap to peek state (tracks which verses are temporarily revealed in hidden/blurred mode)
  const [peekedAyahs, setPeekedAyahs] = useState<Record<number, boolean>>({});
  const peekTimeoutsRef = useRef<Map<number, NodeJS.Timeout>>(new Map());

  const currentSurahMeta =
    SURAH_LIST.find((s) => s.number === sessionConfig.surahNumber) || SURAH_LIST[0];

  // Clean up all peek timers on unmount
  useEffect(() => {
    return () => {
      peekTimeoutsRef.current.forEach((timeout) => clearTimeout(timeout));
      peekTimeoutsRef.current.clear();
    };
  }, []);

  // Load Ayahs
  useEffect(() => {
    let isMounted = true;
    setLoading(true);
    getSurahAyahs(sessionConfig.surahNumber).then((data) => {
      if (isMounted) {
        setAyahs(data);
        setLoading(false);
      }
    });
    return () => {
      isMounted = false;
    };
  }, [sessionConfig.surahNumber]);

  // Connect Audio Engine Callbacks
  useEffect(() => {
    hifzAudioEngine.setCallbacks(
      (newState) => {
        setPlaybackState(newState);
        setIsFocusModeActive(newState.isFocusMode && newState.isActive);
      },
      () => {
        setIsFocusModeActive(false);
      },
      (error) => {
        console.warn('Hifz audio engine error:', error);
      }
    );

    return () => {
      hifzAudioEngine.stopSession();
    };
  }, [setIsFocusModeActive]);

  // Filter Target Ayahs
  const targetAyahs = ayahs.filter(
    (a) =>
      a.numberInSurah >= sessionConfig.startAyah &&
      a.numberInSurah <= sessionConfig.endAyah
  );

  // Masking Mode Switcher
  const handleSetMaskingMode = useCallback(
    (mode: MaskingMode) => {
      // Clear any peeked states on mode switch
      peekTimeoutsRef.current.forEach((t) => clearTimeout(t));
      peekTimeoutsRef.current.clear();
      setPeekedAyahs({});

      onUpdateConfig({
        ...sessionConfig,
        maskingMode: mode,
      });
    },
    [sessionConfig, onUpdateConfig]
  );

  const cycleMaskingMode = useCallback(() => {
    const modes: MaskingMode[] = ['visible', 'blurred', 'hidden'];
    const nextIndex = (modes.indexOf(sessionConfig.maskingMode) + 1) % modes.length;
    handleSetMaskingMode(modes[nextIndex]);
  }, [sessionConfig.maskingMode, handleSetMaskingMode]);

  // Tap-to-peek handler: triggers 2.5s temporary reveal for blurred and hidden modes
  const handleAyahTap = useCallback(
    (ayahNumber: number) => {
      if (sessionConfig.maskingMode === 'visible') return;

      // Clear existing timeout for this ayah if already active
      const existingTimeout = peekTimeoutsRef.current.get(ayahNumber);
      if (existingTimeout) {
        clearTimeout(existingTimeout);
      }

      setPeekedAyahs((prev) => ({ ...prev, [ayahNumber]: true }));

      // Automatically re-hide after 2500ms
      const timeout = setTimeout(() => {
        setPeekedAyahs((prev) => {
          const next = { ...prev };
          delete next[ayahNumber];
          return next;
        });
        peekTimeoutsRef.current.delete(ayahNumber);
      }, 2500);

      peekTimeoutsRef.current.set(ayahNumber, timeout);
    },
    [sessionConfig.maskingMode]
  );

  // Playback controls
  const handleStartPlayback = () => {
    hifzAudioEngine.startSession(sessionConfig);
    setIsFocusModeActive(true);
  };

  const handlePausePlayback = () => {
    hifzAudioEngine.pause();
  };

  const handleResumePlayback = () => {
    hifzAudioEngine.resume();
  };

  const handleStopPlayback = () => {
    hifzAudioEngine.stopSession();
    setIsFocusModeActive(false);
  };

  // Font Size adjustments
  const handleFontSizeChange = (delta: number) => {
    const newSize = Math.max(22, Math.min(46, sessionConfig.fontSize + delta));
    onUpdateConfig({ ...sessionConfig, fontSize: newSize });
  };

  // Navigate to previous/next batch of verses
  const handleShiftRange = (direction: 'next' | 'prev') => {
    const span = sessionConfig.endAyah - sessionConfig.startAyah + 1;
    const max = currentSurahMeta.versesCount;

    if (direction === 'next') {
      const newStart = Math.min(max, sessionConfig.endAyah + 1);
      const newEnd = Math.min(max, newStart + span - 1);
      onUpdateConfig({ ...sessionConfig, startAyah: newStart, endAyah: newEnd });
    } else {
      const newEnd = Math.max(1, sessionConfig.startAyah - 1);
      const newStart = Math.max(1, newEnd - span + 1);
      onUpdateConfig({ ...sessionConfig, startAyah: newStart, endAyah: newEnd });
    }
  };

  return (
    <div
      dir="rtl"
      className="relative min-h-[calc(100vh-4rem)] flex flex-col justify-between pb-28 pt-4 px-4 sm:px-8 max-w-3xl mx-auto transition-all"
    >
      {/* Top Quick Control Bar (Visible when not actively locked into full Zen Focus Mode) */}
      {!isFocusModeActive && (
        <div className="flex flex-wrap items-center justify-between gap-2 py-2 border-b border-[#E8E2D7]/60 dark:border-[#222B27]/60 mb-6 text-xs text-[#6F7B75] dark:text-[#8D9F96]">
          {/* Verses Range Shift Navigation */}
          <div className="flex items-center gap-1.5">
            <button
              onClick={() => handleShiftRange('prev')}
              disabled={sessionConfig.startAyah <= 1}
              className="p-1 rounded-lg hover:bg-[#F2ECE1] dark:hover:bg-[#1E2521] disabled:opacity-30 transition-all flex items-center gap-1"
            >
              <ChevronRight className="w-4 h-4" />
              <span className="hidden sm:inline">المقطع السابق</span>
            </button>
            <span className="text-[#A2B0A8] dark:text-[#4F5F57]">•</span>
            <button
              onClick={() => handleShiftRange('next')}
              disabled={sessionConfig.endAyah >= currentSurahMeta.versesCount}
              className="p-1 rounded-lg hover:bg-[#F2ECE1] dark:hover:bg-[#1E2521] disabled:opacity-30 transition-all flex items-center gap-1"
            >
              <span className="hidden sm:inline">المقطع التالي</span>
              <ChevronLeft className="w-4 h-4" />
            </button>
          </div>

          <div className="flex items-center gap-2">
            {/* Font size stepper */}
            <div className="flex items-center bg-[#F2ECE1] dark:bg-[#1C2520] rounded-lg p-0.5 border border-[#E2D9CC] dark:border-[#28352E]">
              <button
                onClick={() => handleFontSizeChange(-2)}
                className="p-1 hover:bg-[#E2D9CC] dark:hover:bg-[#28352E] rounded-md transition-colors"
                title="تصغير الخط"
              >
                <ZoomOut className="w-3.5 h-3.5" />
              </button>
              <span className="px-1.5 font-mono text-[11px] font-bold">
                {sessionConfig.fontSize}
              </span>
              <button
                onClick={() => handleFontSizeChange(2)}
                className="p-1 hover:bg-[#E2D9CC] dark:hover:bg-[#28352E] rounded-md transition-colors"
                title="تكبير الخط"
              >
                <ZoomIn className="w-3.5 h-3.5" />
              </button>
            </div>

            {/* 3-Tier Masking Segmented Control */}
            <div className="flex items-center bg-[#F2ECE1] dark:bg-[#1C2520] rounded-xl p-0.5 border border-[#E2D9CC] dark:border-[#28352E]">
              <button
                onClick={() => handleSetMaskingMode('visible')}
                className={`px-2 py-1 rounded-lg text-xs font-semibold transition-all flex items-center gap-1 ${
                  sessionConfig.maskingMode === 'visible'
                    ? 'bg-[#4A6B5D] text-white shadow-xs'
                    : 'text-[#6F7B75] dark:text-[#8D9F96] hover:text-[#1E201D] dark:hover:text-[#E6D5B8]'
                }`}
                title="عرض النص القرآني كاملاً"
              >
                <Eye className="w-3.5 h-3.5" />
                <span>ظاهر</span>
              </button>

              <button
                onClick={() => handleSetMaskingMode('blurred')}
                className={`px-2 py-1 rounded-lg text-xs font-semibold transition-all flex items-center gap-1 ${
                  sessionConfig.maskingMode === 'blurred'
                    ? 'bg-[#4A6B5D] text-white shadow-xs'
                    : 'text-[#6F7B75] dark:text-[#8D9F96] hover:text-[#1E201D] dark:hover:text-[#E6D5B8]'
                }`}
                title="تمويه النص القرآني مع إمكانية النقر للكشف"
              >
                <EyeOff className="w-3.5 h-3.5" />
                <span>مموه</span>
              </button>

              <button
                onClick={() => handleSetMaskingMode('hidden')}
                className={`px-2 py-1 rounded-lg text-xs font-semibold transition-all flex items-center gap-1 ${
                  sessionConfig.maskingMode === 'hidden'
                    ? 'bg-[#4A6B5D] text-white shadow-xs'
                    : 'text-[#6F7B75] dark:text-[#8D9F96] hover:text-[#1E201D] dark:hover:text-[#E6D5B8]'
                }`}
                title="إخفاء النص تماماً بالنقاط مع التلصص بالنقر"
              >
                <span className="font-mono text-sm leading-none">•</span>
                <span>مخفي</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Surah Header in Zen Mode */}
      <div className="text-center my-3 space-y-1">
        <h1 className="text-xl sm:text-2xl font-bold font-cairo text-[#1E201D] dark:text-[#E6D5B8]">
          سورة {currentSurahMeta.nameAr}
        </h1>
        <p className="text-xs text-[#7F8D87] dark:text-[#8D9F96] font-mono">
          الآيات {sessionConfig.startAyah} - {sessionConfig.endAyah} • رواية {sessionConfig.riwayah === 'hafs' ? 'حفص' : sessionConfig.riwayah === 'qalun' ? 'قالون' : 'ورش'}
        </p>

        {sessionConfig.surahNumber !== 1 &&
          sessionConfig.surahNumber !== 9 &&
          sessionConfig.startAyah === 1 && (
            <p className="font-amiri text-lg text-[#5A6861] dark:text-[#A7BAAE] pt-2">
              بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ
            </p>
          )}

        {/* Masking Mode Hint Banner */}
        {sessionConfig.maskingMode !== 'visible' && (
          <div className="inline-flex items-center gap-1.5 px-3 py-1 mt-1 rounded-full bg-[#4A6B5D]/10 dark:bg-[#7FA695]/10 text-[#4A6B5D] dark:text-[#7FA695] text-[11px] font-medium">
            <Info className="w-3.5 h-3.5" />
            <span>
              {sessionConfig.maskingMode === 'hidden'
                ? 'وضع الإخفاء: انقر على أي آية للتلصص المؤقت (2.5 ث)'
                : 'وضع التمويه: انقر على أي آية لإزالة التمويه مؤقتاً'}
            </span>
          </div>
        )}
      </div>

      {/* Target Ayahs Container with generous whitespace & adjustable font size */}
      <div className="my-auto py-4 space-y-4 sm:space-y-6">
        {loading ? (
          <div className="py-20 text-center text-sm text-[#7F8D87] dark:text-[#8D9F96] animate-pulse">
            جاري تحضير آيات الحفظ المباركة...
          </div>
        ) : targetAyahs.length === 0 ? (
          <div className="py-20 text-center text-sm text-[#7F8D87] dark:text-[#8D9F96]">
            لا توجد آيات في هذا النطاق المختار.
          </div>
        ) : (
          targetAyahs.map((ayah) => {
            const isPlayingThisAyah =
              playbackState.isActive &&
              playbackState.currentAyahNumber === ayah.numberInSurah;
            const isMaskedHidden = sessionConfig.maskingMode === 'hidden';
            const isMaskedBlurred = sessionConfig.maskingMode === 'blurred';
            const isPeeked = Boolean(peekedAyahs[ayah.numberInSurah]);

            // An ayah is rendered clearly if:
            // 1. maskingMode is 'visible'
            // 2. Or the ayah is actively being recited by the audio player
            // 3. Or the ayah was tapped for temporary peek
            const isFullyRevealed =
              sessionConfig.maskingMode === 'visible' || isPlayingThisAyah || isPeeked;

            return (
              <div
                key={ayah.numberInSurah}
                id={`zen-ayah-${ayah.numberInSurah}`}
                onClick={() => handleAyahTap(ayah.numberInSurah)}
                className={`relative p-5 sm:p-6 rounded-2xl transition-all duration-300 select-none border cursor-pointer ${
                  isPlayingThisAyah
                    ? 'bg-[#4A6B5D]/10 dark:bg-[#7FA695]/15 border-[#4A6B5D] dark:border-[#7FA695] shadow-xs'
                    : isPeeked
                    ? 'bg-emerald-500/10 dark:bg-emerald-500/15 border-emerald-500 shadow-sm'
                    : 'bg-[#FBF8F3] dark:bg-[#151C18]/60 border-transparent hover:border-[#E2D9CC] dark:hover:border-[#222E27]'
                } active:scale-[0.99]`}
              >
                {/* Header Row: Ayah Number + Peek Status */}
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span
                      className={`inline-flex items-center justify-center w-7 h-7 rounded-full text-xs font-bold font-mono transition-colors ${
                        isPlayingThisAyah
                          ? 'bg-[#4A6B5D] text-white'
                          : isPeeked
                          ? 'bg-emerald-600 text-white'
                          : 'bg-[#F2ECE1] dark:bg-[#1E2722] text-[#5A6861] dark:text-[#A7BAAE]'
                      }`}
                    >
                      {ayah.numberInSurah}
                    </span>

                    {isPlayingThisAyah && (
                      <span className="text-[10px] font-bold text-[#4A6B5D] dark:text-[#7FA695] flex items-center gap-1">
                        <span className="w-2 h-2 rounded-full bg-[#4A6B5D] dark:bg-[#7FA695] animate-ping" />
                        <span>يتلى الآن</span>
                      </span>
                    )}
                  </div>

                  {/* Tap-to-peek feedback tag */}
                  {sessionConfig.maskingMode !== 'visible' && (
                    <div>
                      {isPeeked ? (
                        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold bg-emerald-600 text-white animate-pulse">
                          <CheckCircle2 className="w-3 h-3" />
                          <span>كشف مؤقت (2.5ث)</span>
                        </span>
                      ) : !isPlayingThisAyah ? (
                        <span className="text-[10px] text-[#8C9B93] dark:text-[#6E8077] hover:text-[#4A6B5D] dark:hover:text-[#7FA695] transition-colors">
                          انقر للكشف
                        </span>
                      ) : null}
                    </div>
                  )}
                </div>

                {/* Arabic Quranic Verse Content */}
                <div
                  style={{
                    fontSize: `${sessionConfig.fontSize}px`,
                    lineHeight: '2.1',
                  }}
                  className="font-amiri text-right transition-all duration-300"
                >
                  {isMaskedHidden && !isFullyRevealed ? (
                    // Tier 3: Hidden with discrete mask glyphs
                    <div className="tracking-widest text-[#8F9E96] dark:text-[#5B6D64] select-none py-3 text-center text-xl sm:text-2xl">
                      ••••••••••••••••••••••••••••••••••••
                    </div>
                  ) : (
                    // Tier 1 (Visible) or Tier 2 (Blurred) or Revealed
                    <span
                      className={`transition-all duration-300 inline-block w-full ${
                        isPlayingThisAyah
                          ? 'text-[#1E201D] dark:text-[#F3E7D3] font-semibold'
                          : isPeeked
                          ? 'text-emerald-900 dark:text-emerald-200 font-medium'
                          : 'text-[#2D332F] dark:text-[#E6D5B8]'
                      } ${
                        isMaskedBlurred && !isFullyRevealed
                          ? 'filter blur-[8px] opacity-70 select-none'
                          : 'filter-none opacity-100'
                      }`}
                    >
                      {ayah.textUthmani}
                    </span>
                  )}
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Floating Translucent Zen Bottom Pill */}
      <div className="fixed bottom-6 left-4 right-4 z-40 max-w-md mx-auto">
        <div className="backdrop-blur-md bg-[#FBF8F3]/90 dark:bg-[#151B18]/90 border border-[#4A6B5D]/30 dark:border-[#7FA695]/30 rounded-2xl p-3 shadow-xl flex items-center justify-between gap-3 text-[#1E201D] dark:text-[#E6D5B8]">
          {/* Status & Loop Counter */}
          <div className="flex-1 min-w-0 pr-2">
            {playbackState.isActive ? (
              <div className="space-y-0.5">
                <p className="text-xs font-bold text-[#4A6B5D] dark:text-[#7FA695] truncate">
                  {playbackState.currentStageDescription || 'جلسة التكرار جارية'}
                </p>
                {playbackState.isSilencePause ? (
                  <p className="text-[11px] font-medium text-amber-600 dark:text-amber-400 flex items-center gap-1 animate-pulse">
                    <Mic className="w-3 h-3" />
                    <span>ردد بصوتك الآن ({playbackState.silenceRemainingSeconds} ث)</span>
                  </p>
                ) : (
                  <p className="text-[10px] text-[#76857E] dark:text-[#8D9F96]">
                    استمع بخشوع وأنصت
                  </p>
                )}
              </div>
            ) : (
              <div>
                <p className="text-xs font-bold truncate">
                  سورة {currentSurahMeta.nameAr} ({sessionConfig.startAyah}-{sessionConfig.endAyah})
                </p>
                <p className="text-[10px] text-[#76857E] dark:text-[#8D9F96]">
                  الوضع: {sessionConfig.maskingMode === 'visible' ? 'ظاهر' : sessionConfig.maskingMode === 'blurred' ? 'مموه' : 'مخفي'} • جاهز للتكرار
                </p>
              </div>
            )}
          </div>

          {/* Right Action Icons */}
          <div className="flex items-center gap-1.5 shrink-0">
            {/* 3-Tier Eye toggle button */}
            <button
              onClick={cycleMaskingMode}
              className={`p-2 rounded-xl transition-all relative ${
                sessionConfig.maskingMode === 'visible'
                  ? 'bg-[#F2ECE1] dark:bg-[#1F2924] text-[#4A6B5D] dark:text-[#7FA695]'
                  : sessionConfig.maskingMode === 'blurred'
                  ? 'bg-amber-100 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400'
                  : 'bg-rose-100 dark:bg-rose-950/40 text-rose-600 dark:text-rose-400'
              }`}
              title={`وضع الحجب: ${
                sessionConfig.maskingMode === 'visible'
                  ? 'ظاهر (انقر للتبديل)'
                  : sessionConfig.maskingMode === 'blurred'
                  ? 'مموه (انقر للتبديل)'
                  : 'مخفي (انقر للتبديل)'
              }`}
            >
              {sessionConfig.maskingMode === 'visible' ? (
                <Eye className="w-4 h-4" />
              ) : sessionConfig.maskingMode === 'blurred' ? (
                <EyeOff className="w-4 h-4" />
              ) : (
                <EyeOff className="w-4 h-4 text-rose-500" />
              )}
            </button>

            {/* Play / Pause / Stop buttons */}
            {playbackState.isActive ? (
              <>
                <button
                  onClick={playbackState.isPaused ? handleResumePlayback : handlePausePlayback}
                  className="p-2 rounded-xl bg-[#4A6B5D] text-white hover:bg-[#3D5A4E] transition-transform active:scale-95"
                  title={playbackState.isPaused ? 'استئناف' : 'إيقاف مؤقت'}
                >
                  {playbackState.isPaused ? (
                    <Play className="w-4 h-4 fill-current" />
                  ) : (
                    <Pause className="w-4 h-4 fill-current" />
                  )}
                </button>
                <button
                  onClick={handleStopPlayback}
                  className="p-2 rounded-xl bg-[#F2ECE1] dark:bg-[#1F2924] text-rose-500 hover:bg-rose-100 dark:hover:bg-rose-950/40 transition-colors"
                  title="إنهاء الجلسة والخروج من التركيز"
                >
                  <Square className="w-4 h-4 fill-current" />
                </button>
              </>
            ) : (
              <button
                onClick={handleStartPlayback}
                className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-[#4A6B5D] text-white text-xs font-bold hover:bg-[#3D5A4E] shadow-sm transition-transform active:scale-95"
              >
                <Play className="w-4 h-4 fill-current" />
                <span>بدء التكرار</span>
              </button>
            )}

            {/* Focus mode toggle */}
            <button
              onClick={() => setIsFocusModeActive(!isFocusModeActive)}
              className="p-2 rounded-xl bg-[#F2ECE1] dark:bg-[#1F2924] text-[#76857E] dark:text-[#8D9F96] hover:bg-[#E5DCD0] dark:hover:bg-[#28362F] transition-colors"
              title={isFocusModeActive ? 'إلغاء وضع ملء الشاشة' : 'تفعيل التركيز الكامل'}
            >
              {isFocusModeActive ? (
                <Minimize2 className="w-4 h-4" />
              ) : (
                <Maximize2 className="w-4 h-4" />
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
