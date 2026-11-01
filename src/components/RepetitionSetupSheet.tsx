import React, { useState } from 'react';
import { X, Play, RefreshCw, Layers, Clock, Volume2, Sparkles, Gauge } from 'lucide-react';
import { HifzSessionConfig, Riwayah, MaskingMode } from '../types/hifz';
import { getRecitersByRiwayah } from '../data/hifzReciters';
import { SURAH_LIST } from '../data/surahList';

interface RepetitionSetupSheetProps {
  isOpen: boolean;
  onClose: () => void;
  currentConfig: HifzSessionConfig;
  onStartSession: (config: HifzSessionConfig) => void;
}

export const RepetitionSetupSheet: React.FC<RepetitionSetupSheetProps> = ({
  isOpen,
  onClose,
  currentConfig,
  onStartSession,
}) => {
  const [riwayah, setRiwayah] = useState<Riwayah>(currentConfig.riwayah);
  const availableReciters = getRecitersByRiwayah(riwayah);
  const [selectedReciterId, setSelectedReciterId] = useState<string>(
    availableReciters.find((r) => r.id === currentConfig.reciterId)?.id ||
      availableReciters[0]?.id ||
      'husary_muallim'
  );

  const [surahNumber, setSurahNumber] = useState<number>(currentConfig.surahNumber);
  const currentSurahMeta = SURAH_LIST.find((s) => s.number === surahNumber) || SURAH_LIST[0];
  const maxVerses = currentSurahMeta.versesCount;

  const [startAyah, setStartAyah] = useState<number>(
    Math.min(currentConfig.startAyah, maxVerses)
  );
  const [endAyah, setEndAyah] = useState<number>(
    Math.min(currentConfig.endAyah, maxVerses)
  );

  const [singleRepeat, setSingleRepeat] = useState<number>(currentConfig.singleRepeatCount);
  const [linkGroupSize, setLinkGroupSize] = useState<number>(currentConfig.linkGroupSize);
  const [linkGroupRepeat, setLinkGroupRepeat] = useState<number>(
    currentConfig.linkGroupRepeatCount
  );
  const [pauseDelay, setPauseDelay] = useState<number>(currentConfig.pauseDelaySeconds);
  const [maskingMode, setMaskingMode] = useState<MaskingMode>(currentConfig.maskingMode || 'visible');
  const [playbackRate, setPlaybackRate] = useState<number>(currentConfig.playbackRate || 1.0);

  if (!isOpen) return null;

  const handleRiwayahChange = (r: Riwayah) => {
    setRiwayah(r);
    const reciters = getRecitersByRiwayah(r);
    if (reciters.length > 0) {
      setSelectedReciterId(reciters[0].id);
    }
  };

  const handleSurahChange = (sNum: number) => {
    setSurahNumber(sNum);
    const meta = SURAH_LIST.find((s) => s.number === sNum);
    const count = meta ? meta.versesCount : 7;
    setStartAyah(1);
    setEndAyah(Math.min(5, count));
  };

  const applyPreset = (preset: 'intensive' | 'review' | 'listen') => {
    if (preset === 'intensive') {
      setSingleRepeat(10);
      setLinkGroupSize(3);
      setLinkGroupRepeat(3);
      setPauseDelay(4);
    } else if (preset === 'review') {
      setSingleRepeat(3);
      setLinkGroupSize(5);
      setLinkGroupRepeat(5);
      setPauseDelay(2);
    } else if (preset === 'listen') {
      setSingleRepeat(1);
      setLinkGroupSize(0);
      setLinkGroupRepeat(0);
      setPauseDelay(0);
    }
  };

  const handleStart = () => {
    const finalStart = Math.min(startAyah, endAyah);
    const finalEnd = Math.max(startAyah, endAyah);

    onStartSession({
      ...currentConfig,
      riwayah,
      reciterId: selectedReciterId,
      surahNumber,
      startAyah: finalStart,
      endAyah: finalEnd,
      singleRepeatCount: singleRepeat,
      linkGroupSize,
      linkGroupRepeatCount: linkGroupRepeat,
      pauseDelaySeconds: pauseDelay,
      maskingMode,
      playbackRate,
    });
    onClose();
  };

  return (
    <div
      dir="rtl"
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-xs transition-opacity p-0 sm:p-4"
      onClick={onClose}
    >
      <div
        className="w-full max-w-lg max-h-[92vh] overflow-y-auto rounded-t-3xl sm:rounded-3xl bg-[#FBF8F3] dark:bg-[#151B18] text-[#1E201D] dark:text-[#E6D5B8] shadow-2xl border border-[#E8E2D7] dark:border-[#243029] p-5 sm:p-6 space-y-5 animate-in slide-in-from-bottom duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between border-b border-[#E8E2D7] dark:border-[#222B27] pb-3">
          <div className="flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-[#4A6B5D] dark:text-[#7FA695]" />
            <h2 className="text-base font-bold text-[#1E201D] dark:text-[#E6D5B8]">
              إعداد جلسة الحفظ والتكرار
            </h2>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-full hover:bg-[#EAE2D4] dark:hover:bg-[#1E2722] text-[#85928C] transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Quick Presets */}
        <div className="flex gap-2">
          <button
            type="button"
            onClick={() => applyPreset('intensive')}
            className="flex-1 py-1.5 px-2 rounded-xl text-xs font-semibold bg-[#F2ECE1] dark:bg-[#1C2520] hover:bg-[#4A6B5D] hover:text-white dark:hover:bg-[#4A6B5D] dark:hover:text-white transition-all border border-[#E2D9CC] dark:border-[#2A3730]"
          >
            حفظ جديد (10×)
          </button>
          <button
            type="button"
            onClick={() => applyPreset('review')}
            className="flex-1 py-1.5 px-2 rounded-xl text-xs font-semibold bg-[#F2ECE1] dark:bg-[#1C2520] hover:bg-[#4A6B5D] hover:text-white dark:hover:bg-[#4A6B5D] dark:hover:text-white transition-all border border-[#E2D9CC] dark:border-[#2A3730]"
          >
            تثبيت ومراجعة
          </button>
          <button
            type="button"
            onClick={() => applyPreset('listen')}
            className="flex-1 py-1.5 px-2 rounded-xl text-xs font-semibold bg-[#F2ECE1] dark:bg-[#1C2520] hover:bg-[#4A6B5D] hover:text-white dark:hover:bg-[#4A6B5D] dark:hover:text-white transition-all border border-[#E2D9CC] dark:border-[#2A3730]"
          >
            استماع متصل
          </button>
        </div>

        {/* Riwayah Selector (Hafs | Qalun | Warsh) */}
        <div className="space-y-1.5">
          <label className="text-xs font-semibold text-[#5A6861] dark:text-[#9FB1A8]">
            الرواية القرآنية
          </label>
          <div className="grid grid-cols-3 gap-2">
            {(
              [
                { id: 'hafs', label: 'حفص عن عاصم' },
                { id: 'qalun', label: 'قالون عن نافع' },
                { id: 'warsh', label: 'ورش عن نافع' },
              ] as const
            ).map((item) => (
              <button
                key={item.id}
                type="button"
                onClick={() => handleRiwayahChange(item.id)}
                className={`py-2 px-1 rounded-xl text-xs font-bold transition-all border ${
                  riwayah === item.id
                    ? 'bg-[#4A6B5D] text-white border-[#4A6B5D] shadow-xs'
                    : 'bg-[#F2ECE1] dark:bg-[#1C2520] text-[#1E201D] dark:text-[#C5D5CC] border-[#E2D9CC] dark:border-[#2A3730]'
                }`}
              >
                {item.label}
              </button>
            ))}
          </div>
        </div>

        {/* Reciter Dropdown */}
        <div className="space-y-1.5">
          <label className="text-xs font-semibold text-[#5A6861] dark:text-[#9FB1A8] flex items-center gap-1.5">
            <Volume2 className="w-3.5 h-3.5 text-[#4A6B5D] dark:text-[#7FA695]" />
            <span>القارئ المعتمد</span>
          </label>
          <select
            value={selectedReciterId}
            onChange={(e) => setSelectedReciterId(e.target.value)}
            className="w-full px-3 py-2 rounded-xl bg-[#F2ECE1] dark:bg-[#1C2520] border border-[#E2D9CC] dark:border-[#2A3730] text-sm font-medium text-[#1E201D] dark:text-[#E6D5B8] focus:outline-hidden focus:ring-2 focus:ring-[#4A6B5D]"
          >
            {availableReciters.map((r) => (
              <option key={r.id} value={r.id}>
                {r.nameAr} — ({r.style})
              </option>
            ))}
          </select>
        </div>

        {/* Surah & Range Selector */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
          <div className="space-y-1">
            <label className="text-xs font-semibold text-[#5A6861] dark:text-[#9FB1A8]">
              السورة
            </label>
            <select
              value={surahNumber}
              onChange={(e) => handleSurahChange(Number(e.target.value))}
              className="w-full px-2.5 py-2 rounded-xl bg-[#F2ECE1] dark:bg-[#1C2520] border border-[#E2D9CC] dark:border-[#2A3730] text-xs font-bold text-[#1E201D] dark:text-[#E6D5B8]"
            >
              {SURAH_LIST.map((s) => (
                <option key={s.number} value={s.number}>
                  {s.number}. سورة {s.nameAr} ({s.versesCount} آية)
                </option>
              ))}
            </select>
          </div>

          <div className="space-y-1">
            <label className="text-xs font-semibold text-[#5A6861] dark:text-[#9FB1A8]">
              من الآية
            </label>
            <input
              type="number"
              min={1}
              max={maxVerses}
              value={startAyah}
              onChange={(e) =>
                setStartAyah(Math.max(1, Math.min(Number(e.target.value), maxVerses)))
              }
              className="w-full px-2.5 py-2 rounded-xl bg-[#F2ECE1] dark:bg-[#1C2520] border border-[#E2D9CC] dark:border-[#2A3730] text-xs font-bold text-[#1E201D] dark:text-[#E6D5B8] text-center"
            />
          </div>

          <div className="space-y-1">
            <label className="text-xs font-semibold text-[#5A6861] dark:text-[#9FB1A8]">
              إلى الآية
            </label>
            <input
              type="number"
              min={startAyah}
              max={maxVerses}
              value={endAyah}
              onChange={(e) =>
                setEndAyah(Math.max(startAyah, Math.min(Number(e.target.value), maxVerses)))
              }
              className="w-full px-2.5 py-2 rounded-xl bg-[#F2ECE1] dark:bg-[#1C2520] border border-[#E2D9CC] dark:border-[#2A3730] text-xs font-bold text-[#1E201D] dark:text-[#E6D5B8] text-center"
            />
          </div>
        </div>

        {/* Steppers: Single Repeat (N), Linking (M), Silence Pause (X) */}
        <div className="space-y-3 pt-1">
          {/* Single Repeat N */}
          <div className="flex items-center justify-between p-3 rounded-2xl bg-[#F2ECE1]/70 dark:bg-[#1A221E]/70 border border-[#E2D9CC] dark:border-[#25332B]">
            <div className="flex items-center gap-2">
              <RefreshCw className="w-4 h-4 text-[#4A6B5D] dark:text-[#7FA695]" />
              <div>
                <p className="text-xs font-bold text-[#1E201D] dark:text-[#E6D5B8]">
                  تكرار الآية الواحدة (N)
                </p>
                <p className="text-[10px] text-[#6E7D76] dark:text-[#889B91]">
                  تكرر كل آية منفردة قبل الانتقال للتالية
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setSingleRepeat((v) => Math.max(1, v - 1))}
                className="w-8 h-8 rounded-lg bg-[#E2D9CC] dark:bg-[#28352F] text-sm font-bold flex items-center justify-center active:scale-95"
              >
                -
              </button>
              <span className="w-8 text-center text-sm font-mono font-bold text-[#4A6B5D] dark:text-[#7FA695]">
                {singleRepeat}×
              </span>
              <button
                type="button"
                onClick={() => setSingleRepeat((v) => Math.min(50, v + 1))}
                className="w-8 h-8 rounded-lg bg-[#E2D9CC] dark:bg-[#28352F] text-sm font-bold flex items-center justify-center active:scale-95"
              >
                +
              </button>
            </div>
          </div>

          {/* Link Group Repeat M */}
          <div className="flex items-center justify-between p-3 rounded-2xl bg-[#F2ECE1]/70 dark:bg-[#1A221E]/70 border border-[#E2D9CC] dark:border-[#25332B]">
            <div className="flex items-center gap-2">
              <Layers className="w-4 h-4 text-[#4A6B5D] dark:text-[#7FA695]" />
              <div>
                <p className="text-xs font-bold text-[#1E201D] dark:text-[#E6D5B8]">
                  ربط وتثبيت الآيات (M)
                </p>
                <p className="text-[10px] text-[#6E7D76] dark:text-[#889B91]">
                  قراءة المقاطع مجمعة (حجم المجموعة: {linkGroupSize})
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setLinkGroupRepeat((v) => Math.max(0, v - 1))}
                className="w-8 h-8 rounded-lg bg-[#E2D9CC] dark:bg-[#28352F] text-sm font-bold flex items-center justify-center active:scale-95"
              >
                -
              </button>
              <span className="w-8 text-center text-sm font-mono font-bold text-[#4A6B5D] dark:text-[#7FA695]">
                {linkGroupRepeat}×
              </span>
              <button
                type="button"
                onClick={() => setLinkGroupRepeat((v) => Math.min(20, v + 1))}
                className="w-8 h-8 rounded-lg bg-[#E2D9CC] dark:bg-[#28352F] text-sm font-bold flex items-center justify-center active:scale-95"
              >
                +
              </button>
            </div>
          </div>

          {/* Pause Delay X */}
          <div className="flex items-center justify-between p-3 rounded-2xl bg-[#F2ECE1]/70 dark:bg-[#1A221E]/70 border border-[#E2D9CC] dark:border-[#25332B]">
            <div className="flex items-center gap-2">
              <Clock className="w-4 h-4 text-[#4A6B5D] dark:text-[#7FA695]" />
              <div>
                <p className="text-xs font-bold text-[#1E201D] dark:text-[#E6D5B8]">
                  فترة الصمت للترديد (X ثوانٍ)
                </p>
                <p className="text-[10px] text-[#6E7D76] dark:text-[#889B91]">
                  وقت صامت مخصص لتردد الآية بصوتك قبل الإعادة
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setPauseDelay((v) => Math.max(0, v - 1))}
                className="w-8 h-8 rounded-lg bg-[#E2D9CC] dark:bg-[#28352F] text-sm font-bold flex items-center justify-center active:scale-95"
              >
                -
              </button>
              <span className="w-10 text-center text-sm font-mono font-bold text-[#4A6B5D] dark:text-[#7FA695]">
                {pauseDelay} ث
              </span>
              <button
                type="button"
                onClick={() => setPauseDelay((v) => Math.min(15, v + 1))}
                className="w-8 h-8 rounded-lg bg-[#E2D9CC] dark:bg-[#28352F] text-sm font-bold flex items-center justify-center active:scale-95"
              >
                +
              </button>
            </div>
          </div>
        </div>

        {/* Playback Voice Speed */}
        <div className="space-y-1.5 pt-1">
          <label className="text-xs font-semibold text-[#5A6861] dark:text-[#9FB1A8] flex items-center justify-between">
            <span className="flex items-center gap-1.5">
              <Gauge className="w-3.5 h-3.5 text-[#4A6B5D] dark:text-[#7FA695]" />
              <span>سرعة التلاوة والصوت (Voice Speed)</span>
            </span>
            <span className="text-[10px] text-[#7F8D87]">
              {playbackRate === 0.75 && '0.75× • متأنٍ وتجويد'}
              {playbackRate === 1.0 && '1.0× • سرعة طبيعية (افتراضي)'}
              {playbackRate === 1.25 && '1.25× • مراجعة سريعة'}
              {playbackRate === 1.5 && '1.5× • حدر سريع'}
            </span>
          </label>
          <div className="grid grid-cols-4 gap-2">
            {[
              { rate: 0.75, label: '0.75×', desc: 'متأنٍ' },
              { rate: 1.0, label: '1.0×', desc: 'عادي' },
              { rate: 1.25, label: '1.25×', desc: 'سريع' },
              { rate: 1.5, label: '1.5×', desc: 'حدر' },
            ].map((item) => (
              <button
                key={item.rate}
                type="button"
                onClick={() => setPlaybackRate(item.rate)}
                className={`py-2 px-1 rounded-xl text-xs font-bold transition-all border flex flex-col items-center justify-center gap-0.5 ${
                  playbackRate === item.rate
                    ? 'bg-[#4A6B5D] text-white border-[#4A6B5D] shadow-xs'
                    : 'bg-[#F2ECE1] dark:bg-[#1C2520] text-[#1E201D] dark:text-[#C5D5CC] border-[#E2D9CC] dark:border-[#2A3730] hover:bg-[#E8E0D2] dark:hover:bg-[#25332B]'
                }`}
              >
                <span className="font-mono text-xs">{item.label}</span>
                <span className="text-[10px] opacity-80">{item.desc}</span>
              </button>
            ))}
          </div>
        </div>

        {/* 3-Tier Masking Mode Selector */}
        <div className="space-y-1.5 pt-1">
          <label className="text-xs font-semibold text-[#5A6861] dark:text-[#9FB1A8] flex items-center justify-between">
            <span>وضع حجب الآيات القرآني (Zen Masking)</span>
            <span className="text-[10px] text-[#7F8D87]">
              {maskingMode === 'visible' && 'النص ظاهر بالكامل'}
              {maskingMode === 'blurred' && 'النص مموه • انقر للكشف'}
              {maskingMode === 'hidden' && 'النص مخفي بالنقاط • انقر للتلصص'}
            </span>
          </label>
          <div className="grid grid-cols-3 gap-2">
            <button
              type="button"
              onClick={() => setMaskingMode('visible')}
              className={`py-2 px-2 rounded-xl text-xs font-bold transition-all border flex flex-col items-center gap-1 ${
                maskingMode === 'visible'
                  ? 'bg-[#4A6B5D] text-white border-[#4A6B5D] shadow-xs'
                  : 'bg-[#F2ECE1] dark:bg-[#1C2520] text-[#1E201D] dark:text-[#C5D5CC] border-[#E2D9CC] dark:border-[#2A3730]'
              }`}
            >
              <span>ظاهر</span>
              <span className="text-[10px] opacity-80">Visible</span>
            </button>
            <button
              type="button"
              onClick={() => setMaskingMode('blurred')}
              className={`py-2 px-2 rounded-xl text-xs font-bold transition-all border flex flex-col items-center gap-1 ${
                maskingMode === 'blurred'
                  ? 'bg-[#4A6B5D] text-white border-[#4A6B5D] shadow-xs'
                  : 'bg-[#F2ECE1] dark:bg-[#1C2520] text-[#1E201D] dark:text-[#C5D5CC] border-[#E2D9CC] dark:border-[#2A3730]'
              }`}
            >
              <span>مموه</span>
              <span className="text-[10px] opacity-80">Blurred</span>
            </button>
            <button
              type="button"
              onClick={() => setMaskingMode('hidden')}
              className={`py-2 px-2 rounded-xl text-xs font-bold transition-all border flex flex-col items-center gap-1 ${
                maskingMode === 'hidden'
                  ? 'bg-[#4A6B5D] text-white border-[#4A6B5D] shadow-xs'
                  : 'bg-[#F2ECE1] dark:bg-[#1C2520] text-[#1E201D] dark:text-[#C5D5CC] border-[#E2D9CC] dark:border-[#2A3730]'
              }`}
            >
              <span>مخفي</span>
              <span className="text-[10px] opacity-80">••••• Hidden</span>
            </button>
          </div>
        </div>

        {/* Start Session Action */}
        <button
          type="button"
          onClick={handleStart}
          className="w-full py-3.5 rounded-2xl bg-[#4A6B5D] hover:bg-[#3E5C4F] text-white font-bold text-sm shadow-md flex items-center justify-center gap-2 transition-transform active:scale-98"
        >
          <Play className="w-4 h-4 fill-current" />
          <span>بدء جلسة الحفظ (Zen Hifz)</span>
        </button>
      </div>
    </div>
  );
};
