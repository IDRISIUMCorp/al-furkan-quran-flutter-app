import React, { useEffect, useState } from 'react';
import { Sparkles, RotateCcw, CheckCircle2, Bookmark, Share2, Info, Search } from 'lucide-react';
import confetti from 'canvas-confetti';
import { DhikrItem } from '../types/quran';
import { loadAzkar, getCategories } from '../services/azkarService';

export const AzkarView: React.FC = () => {
  const [allAzkar, setAllAzkar] = useState<DhikrItem[]>([]);
  const [categories, setCategories] = useState<string[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('أذكار الصباح');
  const [counters, setCounters] = useState<Record<number, number>>({});
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    loadAzkar().then((items) => {
      setAllAzkar(items);
      const cats = getCategories(items);
      setCategories(cats);
      if (cats.length > 0 && !cats.includes(selectedCategory)) {
        setSelectedCategory(cats[0]);
      }
      setIsLoading(false);
    });
  }, []);

  const handleIncrement = (item: DhikrItem) => {
    const current = counters[item.id] || 0;
    if (current >= item.count) return;

    const next = current + 1;
    setCounters((prev) => ({
      ...prev,
      [item.id]: next,
    }));

    // Trigger celebration when target completed
    if (next === item.count) {
      try {
        confetti({
          particleCount: 50,
          spread: 60,
          origin: { y: 0.8 },
          colors: ['#5D7263', '#A7BFAC', '#E2C37A'],
        });
      } catch (_) {}
    }
  };

  const handleResetItem = (id: number) => {
    setCounters((prev) => ({
      ...prev,
      [id]: 0,
    }));
  };

  const handleResetCategory = () => {
    setCounters((prev) => {
      const copy = { ...prev };
      filteredItems.forEach((item) => {
        copy[item.id] = 0;
      });
      return copy;
    });
  };

  const filteredItems = allAzkar.filter((item) => {
    const matchesCat = item.category === selectedCategory;
    if (!matchesCat) return false;
    if (!searchQuery.trim()) return true;
    return (
      item.zekr.includes(searchQuery.trim()) ||
      item.description.includes(searchQuery.trim()) ||
      item.reference.includes(searchQuery.trim())
    );
  });

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-6 space-y-6 pb-28">
      {/* Header & Category Filter Bar */}
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] p-4 sm:p-5 rounded-3xl border border-[#E8E2D7] dark:border-[#27322B] shadow-sm space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div className="flex items-center gap-2.5">
            <div className="w-10 h-10 rounded-xl bg-[#5D7263]/15 text-[#5D7263] flex items-center justify-center">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <h2 className="font-bold text-base text-[#2D3748] dark:text-[#E2E8F0]">
                أذكار وأدعية المسلم
              </h2>
              <p className="text-xs text-[#718096] dark:text-[#94A3B8]">
                مستندة إلى الأحاديث الصحيحة مع عداد تسبيح تفاعلي
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleResetCategory}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-[#EFE9DF] dark:bg-[#242E28] text-xs font-semibold text-[#718096] hover:text-[#2D3748] dark:hover:text-[#E2E8F0] transition"
              title="تصفير عدادات القسم الحالي"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>تصفير العدادات</span>
            </button>
          </div>
        </div>

        {/* Categories Tabs Scrollable */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1 text-xs font-bold scrollbar-none">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3.5 py-2 rounded-xl whitespace-nowrap transition ${
                selectedCategory === cat
                  ? 'bg-[#5D7263] text-white shadow-sm'
                  : 'bg-[#EFE9DF]/80 dark:bg-[#222C26] text-[#4A5568] dark:text-[#CBD5E1] hover:bg-[#E5DFD4]'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Loading */}
      {isLoading ? (
        <div className="py-20 flex flex-col items-center justify-center gap-3">
          <div className="w-8 h-8 border-3 border-[#5D7263] border-t-transparent rounded-full animate-spin" />
          <span className="text-xs text-[#718096]">جاري تحميل الأذكار...</span>
        </div>
      ) : filteredItems.length === 0 ? (
        <div className="py-16 text-center text-sm text-[#718096] dark:text-[#94A3B8]">
          لا توجد أذكار في هذا القسم حالياً.
        </div>
      ) : (
        /* Azkar Cards List */
        <div className="space-y-4">
          {filteredItems.map((item) => {
            const count = counters[item.id] || 0;
            const isCompleted = count >= item.count;
            const remaining = Math.max(0, item.count - count);
            const progressPercent = Math.min(100, Math.round((count / item.count) * 100));

            return (
              <div
                key={item.id}
                className={`p-6 rounded-3xl border transition-all duration-200 relative overflow-hidden ${
                  isCompleted
                    ? 'bg-emerald-50/50 dark:bg-emerald-950/20 border-emerald-300 dark:border-emerald-800/50'
                    : 'bg-[#FAF7F2] dark:bg-[#1A221E] border-[#E8E2D7] dark:border-[#27322B] shadow-sm'
                }`}
              >
                {/* Progress bar background on top border */}
                <div
                  className="absolute top-0 right-0 h-1 bg-[#5D7263] transition-all duration-300"
                  style={{ width: `${progressPercent}%` }}
                />

                <div className="space-y-4 text-right">
                  {/* Dhikr Arabic Text */}
                  <p className="font-quran text-2xl sm:text-3xl leading-loose text-[#1A202C] dark:text-[#F7FAFC]">
                    {item.zekr}
                  </p>

                  {/* Virtue / Reference Note */}
                  {(item.description || item.reference) && (
                    <div className="p-3.5 rounded-2xl bg-[#EFE9DF]/50 dark:bg-[#202923] text-xs space-y-1 text-[#718096] dark:text-[#94A3B8]">
                      {item.description && <p className="leading-relaxed">{item.description}</p>}
                      {item.reference && (
                        <p className="text-[11px] font-semibold text-[#5D7263] dark:text-[#A7BFAC]">
                          مصدر الذكر: {item.reference}
                        </p>
                      )}
                    </div>
                  )}

                  {/* Counter Interaction Button */}
                  <div className="flex items-center justify-between pt-2">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => handleResetItem(item.id)}
                        className="p-2 rounded-xl text-[#718096] hover:bg-[#EFE9DF] dark:hover:bg-[#242E28] transition text-xs"
                        title="إعادة تعيين العداد"
                      >
                        <RotateCcw className="w-4 h-4" />
                      </button>
                    </div>

                    <button
                      onClick={() => handleIncrement(item)}
                      disabled={isCompleted}
                      className={`flex items-center gap-3 px-6 py-3 rounded-2xl font-bold text-sm transition-all transform active:scale-95 ${
                        isCompleted
                          ? 'bg-emerald-600 text-white cursor-default shadow-sm'
                          : 'bg-[#5D7263] hover:bg-[#4E6153] text-white shadow-md'
                      }`}
                    >
                      {isCompleted ? (
                        <>
                          <CheckCircle2 className="w-5 h-5 text-white" />
                          <span>اكتمل التكرار ({item.count})</span>
                        </>
                      ) : (
                        <>
                          <span>اضغط للتسبيح</span>
                          <span className="w-6 h-6 rounded-full bg-white/25 flex items-center justify-center font-mono text-xs">
                            {remaining}
                          </span>
                        </>
                      )}
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};
