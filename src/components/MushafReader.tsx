import React, { useEffect, useState } from 'react';
import {
  Play,
  BookOpen,
  Bookmark,
  Share2,
  Copy,
  Check,
  ChevronRight,
  ChevronLeft,
  Settings,
  Eye,
  Sliders,
  Sparkles,
} from 'lucide-react';
import { Ayah, SurahMeta } from '../types/quran';
import { SURAH_LIST } from '../data/surahList';
import { getSurahAyahs } from '../services/quranService';

interface MushafReaderProps {
  currentSurahNumber: number;
  onSelectSurah: (num: number) => void;
  playingAyah: { surah: number; ayah: number } | null;
  isPlaying: boolean;
  onPlayAyah: (surah: number, ayah: number) => void;
  onOpenTafseer: (surah: number, ayah: number, text: string, translation?: string) => void;
  onOpenShare: (surah: number, ayah: number, text: string) => void;
  bookmarks: Array<{ surahNumber: number; ayahNumber: number }>;
  onToggleBookmark: (surah: number, ayah: number, text: string) => void;
  nightModeAmber: boolean;
}

export const MushafReader: React.FC<MushafReaderProps> = ({
  currentSurahNumber,
  onSelectSurah,
  playingAyah,
  isPlaying,
  onPlayAyah,
  onOpenTafseer,
  onOpenShare,
  bookmarks,
  onToggleBookmark,
  nightModeAmber,
}) => {
  const [ayahs, setAyahs] = useState<Ayah[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [fontSize, setFontSize] = useState<number>(28);
  const [viewMode, setViewMode] = useState<'verseByVerse' | 'continuous'>('verseByVerse');
  const [hifzMode, setHifzMode] = useState<'visible' | 'blurred' | 'hidden'>('visible');
  const [revealedAyahs, setRevealedAyahs] = useState<Record<number, boolean>>({});
  const [showTranslation, setShowTranslation] = useState<boolean>(true);
  const [showSettingsDrawer, setShowSettingsDrawer] = useState<boolean>(false);
  const [copiedAyah, setCopiedAyah] = useState<number | null>(null);

  const currentSurah = SURAH_LIST.find((s) => s.number === currentSurahNumber) || SURAH_LIST[0];

  useEffect(() => {
    let active = true;
    setIsLoading(true);
    setRevealedAyahs({});

    getSurahAyahs(currentSurahNumber)
      .then((data) => {
        if (active) {
          setAyahs(data);
          setIsLoading(false);
        }
      })
      .catch((err) => {
        console.error('Error fetching ayahs:', err);
        if (active) setIsLoading(false);
      });

    return () => {
      active = false;
    };
  }, [currentSurahNumber]);

  const toggleReveal = (ayahNum: number) => {
    setRevealedAyahs((prev) => ({
      ...prev,
      [ayahNum]: !prev[ayahNum],
    }));
  };

  const handleCopy = (ayahNum: number, text: string) => {
    navigator.clipboard.writeText(`﴿ ${text} ﴾ [سورة ${currentSurah.nameAr} - ${ayahNum}]`);
    setCopiedAyah(ayahNum);
    setTimeout(() => setCopiedAyah(null), 2000);
  };

  const isBookmarked = (ayahNum: number) => {
    return bookmarks.some((b) => b.surahNumber === currentSurahNumber && b.ayahNumber === ayahNum);
  };

  const isAyahActive = (ayahNum: number) => {
    return isPlaying && playingAyah?.surah === currentSurahNumber && playingAyah?.ayah === ayahNum;
  };

  return (
    <div className={`min-h-[calc(100vh-4rem)] pb-28 transition-colors ${nightModeAmber ? 'bg-[#FFFBF5] text-[#2C2318] dark:bg-[#1C160F] dark:text-[#E8DCCB]' : ''}`}>
      {/* Top Controls Bar */}
      <div className="bg-[#FAF7F2]/80 dark:bg-[#161D19]/80 backdrop-blur border-b border-[#E8E2D7] dark:border-[#242E28] sticky top-16 z-30 px-4 py-2.5">
        <div className="max-w-4xl mx-auto flex items-center justify-between gap-2">
          {/* Prev / Next Surah */}
          <div className="flex items-center gap-1">
            <button
              onClick={() => onSelectSurah(Math.max(1, currentSurahNumber - 1))}
              disabled={currentSurahNumber <= 1}
              className="p-1.5 rounded-lg text-[#5D7263] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28] disabled:opacity-30 disabled:pointer-events-none transition"
              title="السورة السابقة"
            >
              <ChevronRight className="w-5 h-5" />
            </button>

            {/* Surah Dropdown Selector */}
            <select
              value={currentSurahNumber}
              onChange={(e) => onSelectSurah(Number(e.target.value))}
              className="bg-[#EFE9DF]/80 dark:bg-[#222C26] border border-[#E0D7C9] dark:border-[#2D3931] text-[#2D3748] dark:text-[#E2E8F0] font-bold text-xs sm:text-sm rounded-xl px-2.5 py-1.5 cursor-pointer focus:outline-none focus:ring-1 focus:ring-[#5D7263]"
            >
              {SURAH_LIST.map((s) => (
                <option key={s.number} value={s.number}>
                  {s.number}. {s.nameAr} ({s.versesCount} آية)
                </option>
              ))}
            </select>

            <button
              onClick={() => onSelectSurah(Math.min(114, currentSurahNumber + 1))}
              disabled={currentSurahNumber >= 114}
              className="p-1.5 rounded-lg text-[#5D7263] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28] disabled:opacity-30 disabled:pointer-events-none transition"
              title="السورة التالية"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
          </div>

          {/* Quick Info Badge */}
          <div className="hidden sm:flex items-center gap-2 text-xs text-[#718096] dark:text-[#94A3B8]">
            <span className="px-2 py-0.5 rounded-md bg-[#5D7263]/10 text-[#3B5249] dark:text-[#A7BFAC] font-medium">
              الجزء {currentSurah.juzStart}
            </span>
            <span className="px-2 py-0.5 rounded-md bg-[#5D7263]/10 text-[#3B5249] dark:text-[#A7BFAC] font-medium">
              صفحة {currentSurah.pageStart}
            </span>
            <span>{currentSurah.revelationType === 'Meccan' ? 'مكية' : 'مدنية'}</span>
          </div>

          {/* Settings Trigger */}
          <div className="flex items-center gap-1.5">
            {/* View Mode Toggle */}
            <div className="flex items-center bg-[#EFE9DF] dark:bg-[#222C26] p-0.5 rounded-xl text-xs font-semibold">
              <button
                onClick={() => setViewMode('verseByVerse')}
                className={`px-2.5 py-1 rounded-lg transition ${
                  viewMode === 'verseByVerse'
                    ? 'bg-[#5D7263] text-white shadow-sm'
                    : 'text-[#718096] dark:text-[#A0AEC0]'
                }`}
              >
                آية بآية
              </button>
              <button
                onClick={() => setViewMode('continuous')}
                className={`px-2.5 py-1 rounded-lg transition ${
                  viewMode === 'continuous'
                    ? 'bg-[#5D7263] text-white shadow-sm'
                    : 'text-[#718096] dark:text-[#A0AEC0]'
                }`}
              >
                المصحف
              </button>
            </div>

            <button
              onClick={() => setShowSettingsDrawer((prev) => !prev)}
              className={`p-2 rounded-xl border transition ${
                showSettingsDrawer
                  ? 'bg-[#5D7263] text-white border-[#5D7263]'
                  : 'bg-[#FAF7F2] dark:bg-[#1E2722] text-[#5D7263] border-[#E8E2D7] dark:border-[#2A362F] hover:bg-[#EFE9DF]'
              }`}
              title="إعدادات القراءة والخط ووضع الحفظ"
            >
              <Sliders className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Quick Settings Panel (Collapsible) */}
        {showSettingsDrawer && (
          <div className="max-w-4xl mx-auto mt-3 pt-3 border-t border-[#E8E2D7] dark:border-[#242E28] grid grid-cols-1 sm:grid-cols-3 gap-3 animate-in fade-in">
            {/* Font size control */}
            <div className="flex items-center justify-between bg-[#EFE9DF]/60 dark:bg-[#202923] p-2.5 rounded-xl">
              <span className="text-xs font-semibold text-[#4A5568] dark:text-[#CBD5E1]">حجم الخط:</span>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setFontSize((s) => Math.max(20, s - 2))}
                  className="w-7 h-7 rounded-lg bg-white dark:bg-[#2D3931] flex items-center justify-center font-bold text-xs"
                >
                  -
                </button>
                <span className="text-xs font-bold w-6 text-center">{fontSize}</span>
                <button
                  onClick={() => setFontSize((s) => Math.min(44, s + 2))}
                  className="w-7 h-7 rounded-lg bg-white dark:bg-[#2D3931] flex items-center justify-center font-bold text-xs"
                >
                  +
                </button>
              </div>
            </div>

            {/* Hifz Mode Selector */}
            <div className="flex items-center justify-between bg-[#EFE9DF]/60 dark:bg-[#202923] p-2.5 rounded-xl">
              <div className="flex items-center gap-1.5 text-xs font-semibold text-[#4A5568] dark:text-[#CBD5E1]">
                <Eye className="w-3.5 h-3.5 text-[#5D7263]" />
                <span>وضع الحفظ:</span>
              </div>
              <select
                value={hifzMode}
                onChange={(e) => setHifzMode(e.target.value as any)}
                className="bg-white dark:bg-[#2D3931] border border-[#E0D7C9] dark:border-[#38483E] text-xs rounded-lg px-2 py-1 font-semibold focus:outline-none"
              >
                <option value="visible">مرئي عادي</option>
                <option value="blurred">مضبب (اضغط للكشف)</option>
                <option value="hidden">مخفي بالكامل</option>
              </select>
            </div>

            {/* Translation toggle */}
            <div className="flex items-center justify-between bg-[#EFE9DF]/60 dark:bg-[#202923] p-2.5 rounded-xl">
              <span className="text-xs font-semibold text-[#4A5568] dark:text-[#CBD5E1]">عرض الترجمة الإنجليزية:</span>
              <button
                onClick={() => setShowTranslation((prev) => !prev)}
                className={`w-10 h-6 flex items-center rounded-full p-1 transition-colors ${
                  showTranslation ? 'bg-[#5D7263] justify-start' : 'bg-gray-300 dark:bg-gray-700 justify-end'
                }`}
              >
                <div className="w-4 h-4 rounded-full bg-white shadow-md transform" />
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Main Reading Surface */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 pt-6">
        {/* Decorative Surah Banner */}
        <div className="mb-8 text-center relative overflow-hidden rounded-3xl bg-gradient-to-b from-[#FAF5EE] to-[#EFE7D8] dark:from-[#1D2621] dark:to-[#151C17] border border-[#E0D6C5] dark:border-[#2C3831] p-6 sm:p-8 shadow-sm">
          <div className="inline-block px-3 py-1 rounded-full bg-[#5D7263]/15 text-[#3B5249] dark:text-[#A7BFAC] text-xs font-bold mb-2">
            سورة رقم {currentSurah.number} • {currentSurah.revelationType === 'Meccan' ? 'مكية' : 'مدنية'} • {currentSurah.versesCount} آيات
          </div>

          <h1 className="font-quran text-4xl sm:text-5xl text-[#2D3748] dark:text-[#F7FAFC] my-2">
            سُورَةُ {currentSurah.nameAr}
          </h1>

          <p className="text-xs sm:text-sm text-[#718096] dark:text-[#A0AEC0] font-medium">
            {currentSurah.nameTranslation} ({currentSurah.nameEn})
          </p>

          {/* Bismillah (except Surah At-Tawbah #9) */}
          {currentSurahNumber !== 9 && (
            <div className="mt-6 pt-4 border-t border-[#E0D6C5]/60 dark:border-[#2C3831]/60">
              <p className="font-quran text-2xl sm:text-3xl text-[#3B5249] dark:text-[#B4CABA]">
                بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ
              </p>
            </div>
          )}
        </div>

        {/* Loading Spinner */}
        {isLoading ? (
          <div className="py-20 flex flex-col items-center justify-center gap-4">
            <div className="w-10 h-10 border-3 border-[#5D7263] border-t-transparent rounded-full animate-spin" />
            <p className="text-sm font-semibold text-[#718096] dark:text-[#94A3B8]">
              جاري فتح السورة المباركة...
            </p>
          </div>
        ) : viewMode === 'verseByVerse' ? (
          /* ========================================================== */
          /* VERSE-BY-VERSE MODE                                        */
          /* ========================================================== */
          <div className="space-y-4">
            {ayahs.map((ayah) => {
              const active = isAyahActive(ayah.numberInSurah);
              const bookmarked = isBookmarked(ayah.numberInSurah);
              const isRevealed = revealedAyahs[ayah.numberInSurah];

              let textBlurClass = '';
              if (hifzMode === 'blurred' && !isRevealed) {
                textBlurClass = 'blur-sm select-none hover:blur-none transition duration-300';
              } else if (hifzMode === 'hidden' && !isRevealed) {
                textBlurClass = 'invisible select-none';
              }

              return (
                <div
                  key={ayah.numberInSurah}
                  id={`ayah-${ayah.numberInSurah}`}
                  className={`p-5 sm:p-6 rounded-2xl border transition-all duration-200 ${
                    active
                      ? 'bg-[#5D7263]/10 dark:bg-[#5D7263]/20 border-[#5D7263] shadow-md ring-1 ring-[#5D7263]/40'
                      : 'bg-[#FAF7F2] dark:bg-[#1A221E] border-[#E8E2D7] dark:border-[#27322B] hover:border-[#D5CDBD] dark:hover:border-[#35433B]'
                  }`}
                >
                  {/* Top Ayah Badge & Actions */}
                  <div className="flex items-center justify-between pb-3 border-b border-[#E8E2D7]/60 dark:border-[#27322B]/60 text-xs">
                    <div className="flex items-center gap-2">
                      <span className="w-7 h-7 rounded-lg bg-[#5D7263]/15 text-[#3B5249] dark:text-[#A7BFAC] font-bold flex items-center justify-center">
                        {ayah.numberInSurah}
                      </span>
                      {ayah.sajda && (
                        <span className="text-[11px] px-2 py-0.5 rounded bg-amber-100 text-amber-800 dark:bg-amber-950/60 dark:text-amber-300 font-semibold">
                          سجدة ۩
                        </span>
                      )}
                    </div>

                    <div className="flex items-center gap-1">
                      {/* Play Ayah Audio */}
                      <button
                        onClick={() => onPlayAyah(currentSurahNumber, ayah.numberInSurah)}
                        className={`p-1.5 rounded-lg transition ${
                          active
                            ? 'bg-[#5D7263] text-white shadow-sm'
                            : 'text-[#5D7263] hover:bg-[#EFE9DF] dark:hover:bg-[#28342D]'
                        }`}
                        title="استماع للآية"
                      >
                        <Play className="w-3.5 h-3.5 fill-current" />
                      </button>

                      {/* Tafseer */}
                      <button
                        onClick={() =>
                          onOpenTafseer(
                            currentSurahNumber,
                            ayah.numberInSurah,
                            ayah.textUthmani,
                            ayah.translationEn
                          )
                        }
                        className="p-1.5 rounded-lg text-[#5D7263] hover:bg-[#EFE9DF] dark:hover:bg-[#28342D] transition"
                        title="تفسير السعدي"
                      >
                        <BookOpen className="w-3.5 h-3.5" />
                      </button>

                      {/* Bookmark */}
                      <button
                        onClick={() =>
                          onToggleBookmark(
                            currentSurahNumber,
                            ayah.numberInSurah,
                            ayah.textUthmani
                          )
                        }
                        className={`p-1.5 rounded-lg transition ${
                          bookmarked
                            ? 'text-amber-600 bg-amber-100 dark:bg-amber-950/40 dark:text-amber-400'
                            : 'text-[#718096] hover:bg-[#EFE9DF] dark:hover:bg-[#28342D]'
                        }`}
                        title={bookmarked ? 'إزالة من المحفوظات' : 'حفظ في المفضلة'}
                      >
                        <Bookmark className={`w-3.5 h-3.5 ${bookmarked ? 'fill-current' : ''}`} />
                      </button>

                      {/* Share Card */}
                      <button
                        onClick={() =>
                          onOpenShare(currentSurahNumber, ayah.numberInSurah, ayah.textUthmani)
                        }
                        className="p-1.5 rounded-lg text-[#718096] hover:bg-[#EFE9DF] dark:hover:bg-[#28342D] transition"
                        title="مشاركة كبطاقة"
                      >
                        <Share2 className="w-3.5 h-3.5" />
                      </button>

                      {/* Copy */}
                      <button
                        onClick={() => handleCopy(ayah.numberInSurah, ayah.textUthmani)}
                        className="p-1.5 rounded-lg text-[#718096] hover:bg-[#EFE9DF] dark:hover:bg-[#28342D] transition"
                        title="نسخ الآية"
                      >
                        {copiedAyah === ayah.numberInSurah ? (
                          <Check className="w-3.5 h-3.5 text-emerald-600" />
                        ) : (
                          <Copy className="w-3.5 h-3.5" />
                        )}
                      </button>
                    </div>
                  </div>

                  {/* Ayah Arabic Script */}
                  <div
                    onClick={() => {
                      if (hifzMode !== 'visible') toggleReveal(ayah.numberInSurah);
                    }}
                    className={`py-4 cursor-pointer relative ${
                      hifzMode !== 'visible' ? 'hover:bg-amber-50/20 rounded-xl' : ''
                    }`}
                  >
                    <p
                      className={`font-quran leading-loose text-right text-[#1A202C] dark:text-[#F7FAFC] ${textBlurClass}`}
                      style={{ fontSize: `${fontSize}px` }}
                    >
                      {ayah.textUthmani}
                    </p>

                    {hifzMode !== 'visible' && !isRevealed && (
                      <div className="absolute inset-0 flex items-center justify-center">
                        <span className="text-xs font-semibold px-3 py-1 rounded-full bg-amber-100 text-amber-900 dark:bg-amber-900/60 dark:text-amber-200 shadow-sm border border-amber-300">
                          اضغط لإظهار الآية (وضع الحفظ)
                        </span>
                      </div>
                    )}
                  </div>

                  {/* English Translation */}
                  {showTranslation && ayah.translationEn && (
                    <div className="pt-2 border-t border-[#E8E2D7]/40 dark:border-[#27322B]/40" dir="ltr">
                      <p className="text-xs sm:text-sm text-[#4A5568] dark:text-[#94A3B8] leading-relaxed">
                        {ayah.translationEn}
                      </p>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        ) : (
          /* ========================================================== */
          /* CONTINUOUS MUSHAF PAGE FLOW                                */
          /* ========================================================== */
          <div className="p-6 sm:p-10 rounded-3xl bg-[#FAF7F2] dark:bg-[#1A221E] border border-[#E8E2D7] dark:border-[#27322B] shadow-sm space-y-6">
            <div className="text-justify leading-loose font-quran text-[#1A202C] dark:text-[#F7FAFC]" style={{ fontSize: `${fontSize}px` }}>
              {ayahs.map((ayah) => {
                const active = isAyahActive(ayah.numberInSurah);
                const bookmarked = isBookmarked(ayah.numberInSurah);

                return (
                  <span
                    key={ayah.numberInSurah}
                    className={`inline cursor-pointer px-1 py-0.5 rounded transition ${
                      active
                        ? 'bg-[#5D7263]/25 text-[#3B5249] dark:text-[#C5D8CA]'
                        : 'hover:bg-[#EFE9DF] dark:hover:bg-[#253028]'
                    }`}
                    onClick={() =>
                      onOpenTafseer(
                        currentSurahNumber,
                        ayah.numberInSurah,
                        ayah.textUthmani,
                        ayah.translationEn
                      )
                    }
                  >
                    {ayah.textUthmani}
                    <span
                      onClick={(e) => {
                        e.stopPropagation();
                        onPlayAyah(currentSurahNumber, ayah.numberInSurah);
                      }}
                      className={`inline-flex items-center justify-center w-7 h-7 mx-1.5 rounded-full text-xs font-bold font-sans align-middle cursor-pointer transition ${
                        active
                          ? 'bg-[#5D7263] text-white shadow'
                          : bookmarked
                          ? 'bg-amber-100 text-amber-800 dark:bg-amber-900/60 dark:text-amber-200'
                          : 'bg-[#5D7263]/15 text-[#3B5249] dark:text-[#A7BFAC] hover:bg-[#5D7263] hover:text-white'
                      }`}
                      title={`استماع للآية ${ayah.numberInSurah}`}
                    >
                      {ayah.numberInSurah}
                    </span>
                  </span>
                );
              })}
            </div>
          </div>
        )}

        {/* Bottom Surah Navigation */}
        <div className="mt-12 flex items-center justify-between pt-6 border-t border-[#E8E2D7] dark:border-[#242E28]">
          {currentSurahNumber > 1 ? (
            <button
              onClick={() => onSelectSurah(currentSurahNumber - 1)}
              className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#FAF7F2] dark:bg-[#1A221E] border border-[#E8E2D7] dark:border-[#2D3A32] text-xs font-bold text-[#3B5249] dark:text-[#A7BFAC] hover:bg-[#EFE9DF] transition"
            >
              <ChevronRight className="w-4 h-4" />
              <span>السورة السابقة: {SURAH_LIST[currentSurahNumber - 2].nameAr}</span>
            </button>
          ) : (
            <div />
          )}

          {currentSurahNumber < 114 && (
            <button
              onClick={() => onSelectSurah(currentSurahNumber + 1)}
              className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#FAF7F2] dark:bg-[#1A221E] border border-[#E8E2D7] dark:border-[#2D3A32] text-xs font-bold text-[#3B5249] dark:text-[#A7BFAC] hover:bg-[#EFE9DF] transition"
            >
              <span>السورة التالية: {SURAH_LIST[currentSurahNumber].nameAr}</span>
              <ChevronLeft className="w-4 h-4" />
            </button>
          )}
        </div>
      </main>
    </div>
  );
};
