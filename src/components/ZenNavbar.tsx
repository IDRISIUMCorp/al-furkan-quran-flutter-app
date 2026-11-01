import React from 'react';
import { Moon, Sun, Settings2, Sparkles, BookOpen } from 'lucide-react';
import { Riwayah } from '../types/hifz';

interface ZenNavbarProps {
  surahNameAr: string;
  startAyah: number;
  endAyah: number;
  riwayah: Riwayah;
  isDarkMode: boolean;
  onToggleTheme: () => void;
  onOpenSetup: () => void;
  onOpenSurahPicker: () => void;
}

export const ZenNavbar: React.FC<ZenNavbarProps> = ({
  surahNameAr,
  startAyah,
  endAyah,
  riwayah,
  isDarkMode,
  onToggleTheme,
  onOpenSetup,
  onOpenSurahPicker,
}) => {
  const riwayahLabels: Record<Riwayah, string> = {
    hafs: 'رواية حفص',
    qalun: 'رواية قالون',
    warsh: 'رواية ورش',
  };

  return (
    <header className="sticky top-0 z-30 transition-colors duration-200 backdrop-blur-md bg-[#FBF8F3]/90 dark:bg-[#121615]/90 border-b border-[#E8E2D7] dark:border-[#222B27]">
      <div className="max-w-4xl mx-auto px-4 h-16 flex items-center justify-between">
        {/* Left / Surah Selector Pill */}
        <div className="flex items-center gap-3">
          <button
            onClick={onOpenSurahPicker}
            className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-[#F2ECE1] dark:bg-[#1A221E] hover:bg-[#EAE2D4] dark:hover:bg-[#232F2A] text-[#1E201D] dark:text-[#E6D5B8] transition-all border border-[#E2D9CC] dark:border-[#2C3B34] text-sm font-semibold shadow-xs"
            title="اختيار سورة"
          >
            <BookOpen className="w-4 h-4 text-[#4A6B5D] dark:text-[#7FA695]" />
            <span>{surahNameAr}</span>
            <span className="text-xs px-1.5 py-0.5 rounded-md bg-[#4A6B5D]/10 dark:bg-[#7FA695]/15 text-[#4A6B5D] dark:text-[#7FA695] font-mono">
              {startAyah}-{endAyah}
            </span>
          </button>

          <span className="hidden sm:inline-flex items-center gap-1 text-xs text-[#6F7B75] dark:text-[#8D9F96] font-medium">
            <Sparkles className="w-3.5 h-3.5 text-[#4A6B5D] dark:text-[#7FA695]" />
            {riwayahLabels[riwayah]}
          </span>
        </div>

        {/* Right / Actions */}
        <div className="flex items-center gap-2">
          {/* Setup Session Button */}
          <button
            onClick={onOpenSetup}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-[#4A6B5D] hover:bg-[#3D5B4F] text-white text-xs font-semibold shadow-sm transition-transform active:scale-95"
          >
            <Settings2 className="w-3.5 h-3.5" />
            <span>إعداد التكرار</span>
          </button>

          {/* Theme Toggle */}
          <button
            onClick={onToggleTheme}
            className="p-2 rounded-xl text-[#6F7B75] dark:text-[#8D9F96] hover:bg-[#F2ECE1] dark:hover:bg-[#1A221E] transition-colors"
            title={isDarkMode ? 'الوضع النهاري (ورق دافئ)' : 'وضع الحفظ الليلي (داكن هادئ)'}
          >
            {isDarkMode ? (
              <Sun className="w-4 h-4 text-[#E6D5B8]" />
            ) : (
              <Moon className="w-4 h-4 text-[#4A6B5D]" />
            )}
          </button>
        </div>
      </div>
    </header>
  );
};
