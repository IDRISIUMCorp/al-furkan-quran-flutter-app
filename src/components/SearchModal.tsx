import React, { useState, useEffect } from 'react';
import { Search, X, BookOpen, ArrowLeft } from 'lucide-react';
import { SurahMeta } from '../types/quran';
import { searchQuran } from '../services/quranService';

interface SearchModalProps {
  onClose: () => void;
  onSelectResult: (surahNumber: number, ayahNumber: number) => void;
}

export const SearchModal: React.FC<SearchModalProps> = ({ onClose, onSelectResult }) => {
  const [query, setQuery] = useState<string>('');
  const [results, setResults] = useState<{ surah: SurahMeta; ayahNumber: number; text: string }[]>([]);
  const [isSearching, setIsSearching] = useState<boolean>(false);

  useEffect(() => {
    const trimmed = query.trim();
    if (trimmed.length < 2) {
      setResults([]);
      return;
    }

    const timer = setTimeout(() => {
      setIsSearching(true);
      searchQuran(trimmed).then((res) => {
        setResults(res);
        setIsSearching(false);
      });
    }, 250);

    return () => clearTimeout(timer);
  }, [query]);

  return (
    <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-sm flex items-start justify-center p-4 pt-16">
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] w-full max-w-2xl rounded-3xl border border-[#E8E2D7] dark:border-[#2D3A32] shadow-2xl overflow-hidden flex flex-col max-h-[80vh] animate-in fade-in zoom-in-95 duration-150">
        {/* Search Input Bar */}
        <div className="p-4 border-b border-[#E8E2D7] dark:border-[#2D3A32] flex items-center gap-3 bg-white/50 dark:bg-[#151B17]/50">
          <Search className="w-5 h-5 text-[#5D7263] shrink-0" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="ابحث في آيات القرآن الكريم (مثال: الصلاة، الرحمة، الجنة)..."
            autoFocus
            className="w-full bg-transparent text-sm sm:text-base font-semibold text-[#2D3748] dark:text-[#E2E8F0] placeholder-[#A0AEC0] focus:outline-none"
          />
          {query && (
            <button onClick={() => setQuery('')} className="p-1 text-[#718096] hover:text-[#2D3748]">
              <X className="w-4 h-4" />
            </button>
          )}
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-xs font-bold bg-[#EFE9DF] dark:bg-[#242E28] text-[#718096] hover:text-[#2D3748]"
          >
            إغلاق
          </button>
        </div>

        {/* Results list */}
        <div className="overflow-y-auto p-4 space-y-2.5 flex-1">
          {isSearching ? (
            <div className="py-12 flex flex-col items-center justify-center gap-2">
              <div className="w-6 h-6 border-2 border-[#5D7263] border-t-transparent rounded-full animate-spin" />
              <span className="text-xs text-[#718096]">جاري البحث في المصحف الشريف...</span>
            </div>
          ) : query.trim().length >= 2 && results.length === 0 ? (
            <div className="py-12 text-center text-sm text-[#718096] dark:text-[#94A3B8]">
              لم يتم العثور على نتائج تطابق &quot;{query}&quot;
            </div>
          ) : query.trim().length < 2 ? (
            <div className="py-10 text-center text-xs text-[#718096] dark:text-[#94A3B8]">
              اكتب كلمتين أو حرفين على الأقل لبدء البحث الدقيق
            </div>
          ) : (
            results.map((r, idx) => (
              <button
                key={idx}
                onClick={() => {
                  onSelectResult(r.surah.number, r.ayahNumber);
                  onClose();
                }}
                className="w-full p-4 rounded-2xl bg-white/70 dark:bg-[#222C26] border border-[#E8E2D7] dark:border-[#2D3931] hover:border-[#5D7263] text-right space-y-2 transition-all transform hover:-translate-y-0.5 shadow-xs"
              >
                <div className="flex items-center justify-between text-xs text-[#5D7263] dark:text-[#A7BFAC] font-bold">
                  <span>سورة {r.surah.nameAr}</span>
                  <span className="font-mono text-[#718096]">الآية {r.ayahNumber}</span>
                </div>
                <p className="font-quran text-lg leading-loose text-[#2D3748] dark:text-[#F7FAFC]">
                  {r.text}
                </p>
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  );
};
