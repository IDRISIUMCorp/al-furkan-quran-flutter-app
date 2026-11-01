import React from 'react';
import { BookOpen, Clock, Compass, Sparkles, Bookmark, Moon, Sun, Search, Eye, Flame } from 'lucide-react';

export type ActiveTab = 'mushaf' | 'prayer' | 'qibla' | 'azkar' | 'khatma' | 'bookmarks';

interface NavbarProps {
  activeTab: ActiveTab;
  setActiveTab: (tab: ActiveTab) => void;
  isDarkMode: boolean;
  setIsDarkMode: (val: boolean | ((prev: boolean) => boolean)) => void;
  nightModeAmber: boolean;
  setNightModeAmber: (val: boolean | ((prev: boolean) => boolean)) => void;
  onOpenSearch: () => void;
  onOpenSurahPicker: () => void;
  currentSurahName: string;
}

export const Navbar: React.FC<NavbarProps> = ({
  activeTab,
  setActiveTab,
  isDarkMode,
  setIsDarkMode,
  nightModeAmber,
  setNightModeAmber,
  onOpenSearch,
  onOpenSurahPicker,
  currentSurahName,
}) => {
  return (
    <header className="sticky top-0 z-40 bg-[#FAF7F2]/95 dark:bg-[#151B17]/95 backdrop-blur-md border-b border-[#E8E2D7] dark:border-[#242E28] transition-colors">
      <div className="max-w-7xl mx-auto px-4 sm:px-6">
        <div className="flex items-center justify-between h-16 gap-2">
          {/* Brand Logo & Title */}
          <div className="flex items-center gap-3 cursor-pointer" onClick={() => setActiveTab('mushaf')}>
            <img
              src="/assets/img/Quran_Logo_v3.png"
              alt="Al-Furkan Logo"
              className="w-10 h-10 rounded-xl shadow-sm object-cover border border-[#5D7263]/20"
              onError={(e) => {
                // Fallback if image fails
                (e.target as HTMLElement).style.display = 'none';
              }}
            />
            <div>
              <div className="flex items-center gap-2">
                <span className="font-bold text-lg text-[#3B5249] dark:text-[#A7BFAC] tracking-tight">
                  الفُرقان
                </span>
                <span className="text-xs px-2 py-0.5 rounded-full bg-[#5D7263]/10 text-[#5D7263] dark:text-[#A7BFAC] font-medium hidden sm:inline-block">
                  Al-Furkan
                </span>
              </div>
              <p className="text-[11px] text-[#718096] dark:text-[#94A3B8] hidden md:block">
                تطبيق قرآني متكامل ومواقيت الصلاة والأذكار
              </p>
            </div>
          </div>

          {/* Quick Surah jump button if in mushaf mode */}
          {activeTab === 'mushaf' && (
            <button
              onClick={onOpenSurahPicker}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-[#5D7263]/10 hover:bg-[#5D7263]/20 text-[#3B5249] dark:text-[#C5D8CA] text-xs font-semibold transition"
              title="اختر سورة"
            >
              <BookOpen className="w-3.5 h-3.5 text-[#5D7263]" />
              <span>{currentSurahName}</span>
              <span className="text-[10px] text-[#718096]">▼</span>
            </button>
          )}

          {/* Navigation Items (Desktop & Tablet) */}
          <nav className="hidden lg:flex items-center gap-1 bg-[#EFE9DF]/60 dark:bg-[#1D2520] p-1 rounded-xl">
            <button
              onClick={() => setActiveTab('mushaf')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                activeTab === 'mushaf'
                  ? 'bg-[#5D7263] text-white shadow-sm'
                  : 'text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#E5DFD4] dark:hover:bg-[#28342D]'
              }`}
            >
              <BookOpen className="w-4 h-4" />
              <span>المصحف</span>
            </button>
            <button
              onClick={() => setActiveTab('prayer')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                activeTab === 'prayer'
                  ? 'bg-[#5D7263] text-white shadow-sm'
                  : 'text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#E5DFD4] dark:hover:bg-[#28342D]'
              }`}
            >
              <Clock className="w-4 h-4" />
              <span>المواقيت</span>
            </button>
            <button
              onClick={() => setActiveTab('qibla')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                activeTab === 'qibla'
                  ? 'bg-[#5D7263] text-white shadow-sm'
                  : 'text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#E5DFD4] dark:hover:bg-[#28342D]'
              }`}
            >
              <Compass className="w-4 h-4" />
              <span>القبلة</span>
            </button>
            <button
              onClick={() => setActiveTab('azkar')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                activeTab === 'azkar'
                  ? 'bg-[#5D7263] text-white shadow-sm'
                  : 'text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#E5DFD4] dark:hover:bg-[#28342D]'
              }`}
            >
              <Sparkles className="w-4 h-4" />
              <span>الأذكار</span>
            </button>
            <button
              onClick={() => setActiveTab('khatma')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                activeTab === 'khatma'
                  ? 'bg-[#5D7263] text-white shadow-sm'
                  : 'text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#E5DFD4] dark:hover:bg-[#28342D]'
              }`}
            >
              <Flame className="w-4 h-4" />
              <span>الختمة</span>
            </button>
            <button
              onClick={() => setActiveTab('bookmarks')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                activeTab === 'bookmarks'
                  ? 'bg-[#5D7263] text-white shadow-sm'
                  : 'text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#E5DFD4] dark:hover:bg-[#28342D]'
              }`}
            >
              <Bookmark className="w-4 h-4" />
              <span>المحفوظات</span>
            </button>
          </nav>

          {/* Action Icons */}
          <div className="flex items-center gap-1.5">
            {/* Search Button */}
            <button
              onClick={onOpenSearch}
              className="p-2 rounded-lg text-[#5D7263] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28] transition"
              title="بحث في القرآن الكريم"
            >
              <Search className="w-4 h-4" />
            </button>

            {/* Amber Night Warmth Mode Button */}
            <button
              onClick={() => setNightModeAmber((prev) => !prev)}
              className={`p-2 rounded-lg transition ${
                nightModeAmber
                  ? 'bg-amber-100 text-amber-800 dark:bg-amber-950/60 dark:text-amber-300 ring-1 ring-amber-400'
                  : 'text-[#718096] dark:text-[#A0AEC0] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28]'
              }`}
              title={nightModeAmber ? 'إيقاف وضع القراءة الكهرماني' : 'تفعيل وضع القراءة الليلي الكهرماني'}
            >
              <Eye className="w-4 h-4" />
            </button>

            {/* Dark Mode Toggle */}
            <button
              onClick={() => setIsDarkMode((prev) => !prev)}
              className="p-2 rounded-lg text-[#718096] dark:text-[#A0AEC0] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28] transition"
              title={isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي'}
            >
              {isDarkMode ? <Sun className="w-4 h-4 text-amber-400" /> : <Moon className="w-4 h-4 text-slate-700" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation Bar */}
        <div className="lg:hidden flex items-center justify-around py-2 border-t border-[#E8E2D7]/60 dark:border-[#242E28]/60 overflow-x-auto gap-1">
          <button
            onClick={() => setActiveTab('mushaf')}
            className={`flex flex-col items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-medium transition ${
              activeTab === 'mushaf'
                ? 'text-[#3B5249] dark:text-[#A7BFAC] font-bold'
                : 'text-[#718096] dark:text-[#94A3B8]'
            }`}
          >
            <BookOpen className="w-4 h-4" />
            <span>المصحف</span>
          </button>
          <button
            onClick={() => setActiveTab('prayer')}
            className={`flex flex-col items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-medium transition ${
              activeTab === 'prayer'
                ? 'text-[#3B5249] dark:text-[#A7BFAC] font-bold'
                : 'text-[#718096] dark:text-[#94A3B8]'
            }`}
          >
            <Clock className="w-4 h-4" />
            <span>المواقيت</span>
          </button>
          <button
            onClick={() => setActiveTab('qibla')}
            className={`flex flex-col items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-medium transition ${
              activeTab === 'qibla'
                ? 'text-[#3B5249] dark:text-[#A7BFAC] font-bold'
                : 'text-[#718096] dark:text-[#94A3B8]'
            }`}
          >
            <Compass className="w-4 h-4" />
            <span>القبلة</span>
          </button>
          <button
            onClick={() => setActiveTab('azkar')}
            className={`flex flex-col items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-medium transition ${
              activeTab === 'azkar'
                ? 'text-[#3B5249] dark:text-[#A7BFAC] font-bold'
                : 'text-[#718096] dark:text-[#94A3B8]'
            }`}
          >
            <Sparkles className="w-4 h-4" />
            <span>الأذكار</span>
          </button>
          <button
            onClick={() => setActiveTab('khatma')}
            className={`flex flex-col items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-medium transition ${
              activeTab === 'khatma'
                ? 'text-[#3B5249] dark:text-[#A7BFAC] font-bold'
                : 'text-[#718096] dark:text-[#94A3B8]'
            }`}
          >
            <Flame className="w-4 h-4" />
            <span>الختمة</span>
          </button>
          <button
            onClick={() => setActiveTab('bookmarks')}
            className={`flex flex-col items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-medium transition ${
              activeTab === 'bookmarks'
                ? 'text-[#3B5249] dark:text-[#A7BFAC] font-bold'
                : 'text-[#718096] dark:text-[#94A3B8]'
            }`}
          >
            <Bookmark className="w-4 h-4" />
            <span>محفوظات</span>
          </button>
        </div>
      </div>
    </header>
  );
};
