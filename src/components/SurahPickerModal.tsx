import React, { useState } from 'react';
import { X, Search, BookOpen } from 'lucide-react';
import { SURAH_LIST } from '../data/surahList';
import { SurahMeta } from '../types/quran';

interface SurahPickerModalProps {
  currentSurahNumber: number;
  onSelectSurah: (num: number) => void;
  onClose: () => void;
}

export const SurahPickerModal: React.FC<SurahPickerModalProps> = ({
  currentSurahNumber,
  onSelectSurah,
  onClose,
}) => {
  const [search, setSearch] = useState<string>('');
  const [filterType, setFilterType] = useState<'all' | 'Meccan' | 'Medinan'>('all');

  const filteredSurahs = SURAH_LIST.filter((s) => {
    if (filterType !== 'all' && s.revelationType !== filterType) return false;
    if (!search.trim()) return true;
    const q = search.trim().toLowerCase();
    return (
      s.nameAr.includes(q) ||
      s.nameEn.toLowerCase().includes(q) ||
      s.nameTranslation.toLowerCase().includes(q) ||
      String(s.number) === q
    );
  });

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] w-full max-w-xl rounded-3xl border border-[#E8E2D7] dark:border-[#2D3A32] shadow-2xl flex flex-col max-h-[85vh] overflow-hidden">
        {/* Header */}
        <div className="p-5 border-b border-[#E8E2D7] dark:border-[#2D3A32] space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <BookOpen className="w-5 h-5 text-[#5D7263]" />
              <h3 className="font-bold text-base text-[#2D3748] dark:text-[#E2E8F0]">
                فهرس سور القرآن الكريم (114 سورة)
              </h3>
            </div>
            <button
              onClick={onClose}
              className="p-1.5 rounded-lg text-[#718096] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28]"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          {/* Search bar & filter pills */}
          <div className="flex flex-col sm:flex-row items-center gap-2">
            <div className="relative w-full">
              <Search className="w-4 h-4 absolute right-3 top-3 text-[#718096]" />
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="ابحث باسم السورة أو رقمها..."
                className="w-full pr-9 pl-3 py-2 rounded-xl bg-white dark:bg-[#222C26] border border-[#E0D7C9] dark:border-[#2D3931] text-xs font-semibold text-[#2D3748] dark:text-[#E2E8F0] focus:outline-none"
              />
            </div>

            <div className="flex items-center gap-1 shrink-0 w-full sm:w-auto">
              <button
                onClick={() => setFilterType('all')}
                className={`flex-1 sm:flex-none px-3 py-1.5 rounded-xl text-xs font-bold transition ${
                  filterType === 'all'
                    ? 'bg-[#5D7263] text-white shadow-sm'
                    : 'bg-[#EFE9DF] dark:bg-[#222C26] text-[#718096]'
                }`}
              >
                الكل
              </button>
              <button
                onClick={() => setFilterType('Meccan')}
                className={`flex-1 sm:flex-none px-3 py-1.5 rounded-xl text-xs font-bold transition ${
                  filterType === 'Meccan'
                    ? 'bg-[#5D7263] text-white shadow-sm'
                    : 'bg-[#EFE9DF] dark:bg-[#222C26] text-[#718096]'
                }`}
              >
                مكية
              </button>
              <button
                onClick={() => setFilterType('Medinan')}
                className={`flex-1 sm:flex-none px-3 py-1.5 rounded-xl text-xs font-bold transition ${
                  filterType === 'Medinan'
                    ? 'bg-[#5D7263] text-white shadow-sm'
                    : 'bg-[#EFE9DF] dark:bg-[#222C26] text-[#718096]'
                }`}
              >
                مدنية
              </button>
            </div>
          </div>
        </div>

        {/* Surahs Grid */}
        <div className="overflow-y-auto p-4 grid grid-cols-1 sm:grid-cols-2 gap-2 flex-1">
          {filteredSurahs.map((s) => {
            const isSelected = s.number === currentSurahNumber;
            return (
              <button
                key={s.number}
                onClick={() => {
                  onSelectSurah(s.number);
                  onClose();
                }}
                className={`p-3 rounded-2xl border text-right transition flex items-center justify-between gap-3 ${
                  isSelected
                    ? 'bg-[#5D7263]/15 dark:bg-[#5D7263]/25 border-[#5D7263] ring-1 ring-[#5D7263]'
                    : 'bg-white/80 dark:bg-[#202923] border-[#E8E2D7] dark:border-[#2A362F] hover:border-[#5D7263]'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-lg bg-[#5D7263]/10 text-[#5D7263] font-bold text-xs flex items-center justify-center font-mono">
                    {s.number}
                  </div>
                  <div>
                    <div className="font-bold text-sm text-[#2D3748] dark:text-[#E2E8F0]">
                      سورة {s.nameAr}
                    </div>
                    <div className="text-[11px] text-[#718096] dark:text-[#94A3B8]">
                      {s.nameEn} • {s.versesCount} آيات
                    </div>
                  </div>
                </div>

                <div className="text-left text-[11px] text-[#718096] dark:text-[#94A3B8]">
                  <div>جزء {s.juzStart}</div>
                  <div>صفحة {s.pageStart}</div>
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};
