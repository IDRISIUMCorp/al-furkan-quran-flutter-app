import React, { useState, useEffect } from 'react';
import { Flame, CheckCircle2, RotateCcw, Target, Calendar, Trophy } from 'lucide-react';
import confetti from 'canvas-confetti';

interface KhatmaData {
  targetDays: number;
  startDate: string;
  completedJuz: number[];
  streakDays: number;
}

export const KhatmaTrackerView: React.FC = () => {
  const [khatma, setKhatma] = useState<KhatmaData>(() => {
    const saved = localStorage.getItem('alfurkan_khatma_plan');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (_) {}
    }
    return {
      targetDays: 30,
      startDate: new Date().toISOString().split('T')[0],
      completedJuz: [],
      streakDays: 3,
    };
  });

  useEffect(() => {
    localStorage.setItem('alfurkan_khatma_plan', JSON.stringify(khatma));
  }, [khatma]);

  const toggleJuz = (juzNum: number) => {
    setKhatma((prev) => {
      const exists = prev.completedJuz.includes(juzNum);
      const updated = exists
        ? prev.completedJuz.filter((j) => j !== juzNum)
        : [...prev.completedJuz, juzNum];

      if (!exists && updated.length === 30) {
        // Completed entire Quran!
        try {
          confetti({
            particleCount: 100,
            spread: 90,
            origin: { y: 0.6 },
          });
        } catch (_) {}
      }

      return {
        ...prev,
        completedJuz: updated,
      };
    });
  };

  const handleReset = () => {
    if (window.confirm('هل تريد بالتأكيد بدء ختمة جديدة وتصفير تقدم الأجزاء؟')) {
      setKhatma((prev) => ({
        ...prev,
        completedJuz: [],
        startDate: new Date().toISOString().split('T')[0],
      }));
    }
  };

  const completedCount = khatma.completedJuz.length;
  const progressPercent = Math.round((completedCount / 30) * 100);
  const remainingJuz = 30 - completedCount;
  const dailyTargetPages = Math.ceil(604 / khatma.targetDays);

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-6 space-y-6 pb-28">
      {/* Top Banner */}
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] p-6 rounded-3xl border border-[#E8E2D7] dark:border-[#27322B] shadow-sm space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-amber-500/15 text-amber-600 dark:text-amber-400 flex items-center justify-center">
              <Trophy className="w-6 h-6" />
            </div>
            <div>
              <h2 className="font-bold text-lg text-[#2D3748] dark:text-[#E2E8F0]">
                مساحة الختمة الذكية
              </h2>
              <p className="text-xs text-[#718096] dark:text-[#94A3B8]">
                خطط لختم القرآن الكريم وتتبع تقدمك جزءاً بجزء
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleReset}
              className="flex items-center gap-1.5 px-3 py-2 rounded-xl bg-[#EFE9DF] dark:bg-[#242E28] text-xs font-semibold text-[#718096] hover:text-[#2D3748] transition"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>بدء ختمة جديدة</span>
            </button>
          </div>
        </div>

        {/* Progress Card */}
        <div className="p-6 rounded-2xl bg-gradient-to-br from-[#3B5249] to-[#25362F] text-white shadow-md space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <span className="text-xs font-medium text-emerald-200">نسبة الإنجاز</span>
              <div className="text-4xl font-extrabold font-mono mt-0.5">{progressPercent}%</div>
            </div>
            <div className="text-left">
              <span className="text-xs font-medium text-emerald-200">الأجزاء المنجزة</span>
              <div className="text-2xl font-bold font-mono mt-0.5">
                {completedCount} / 30
              </div>
            </div>
          </div>

          {/* Progress Bar */}
          <div className="w-full h-3 bg-white/20 rounded-full overflow-hidden p-0.5">
            <div
              className="h-full bg-gradient-to-r from-emerald-400 to-amber-300 rounded-full transition-all duration-500"
              style={{ width: `${progressPercent}%` }}
            />
          </div>

          <div className="flex items-center justify-between text-xs text-emerald-100/90 pt-1">
            <span>متبقي: {remainingJuz} جزء</span>
            <span>الهدف اليومي: {dailyTargetPages} صفحة ({Math.ceil(30 / khatma.targetDays * 10) / 10} جزء)</span>
          </div>
        </div>

        {/* Plan Settings */}
        <div className="flex flex-wrap items-center justify-between gap-3 pt-2 text-xs">
          <div className="flex items-center gap-2">
            <Target className="w-4 h-4 text-[#5D7263]" />
            <span className="font-semibold text-[#4A5568] dark:text-[#CBD5E1]">مدة خطة الختمة:</span>
            <div className="flex items-center gap-1">
              {[15, 30, 60].map((days) => (
                <button
                  key={days}
                  onClick={() => setKhatma((prev) => ({ ...prev, targetDays: days }))}
                  className={`px-3 py-1 rounded-lg font-bold transition ${
                    khatma.targetDays === days
                      ? 'bg-[#5D7263] text-white shadow-sm'
                      : 'bg-[#EFE9DF] dark:bg-[#242E28] text-[#718096]'
                  }`}
                >
                  {days} يوماً
                </button>
              ))}
            </div>
          </div>

          <div className="flex items-center gap-1.5 text-amber-600 dark:text-amber-400 font-bold">
            <Flame className="w-4 h-4 fill-current" />
            <span>حماسة القراءة: ٣ أيام متتالية 🔥</span>
          </div>
        </div>
      </div>

      {/* 30-Juz Interactive Grid */}
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] p-6 rounded-3xl border border-[#E8E2D7] dark:border-[#27322B] shadow-sm space-y-4">
        <h3 className="font-bold text-sm text-[#2D3748] dark:text-[#E2E8F0]">
          أجزاء القرآن الكريم الثلاثون (اضغط لتحديد القراءة):
        </h3>

        <div className="grid grid-cols-3 sm:grid-cols-5 md:grid-cols-6 gap-3">
          {Array.from({ length: 30 }, (_, i) => i + 1).map((juzNum) => {
            const isDone = khatma.completedJuz.includes(juzNum);
            return (
              <button
                key={juzNum}
                onClick={() => toggleJuz(juzNum)}
                className={`p-3.5 rounded-2xl border text-center transition-all transform active:scale-95 flex flex-col items-center justify-center gap-1.5 ${
                  isDone
                    ? 'bg-emerald-600 text-white border-emerald-700 shadow-sm'
                    : 'bg-[#EFE9DF]/50 dark:bg-[#202923] border-[#E0D7C9] dark:border-[#2D3931] hover:border-[#5D7263] text-[#4A5568] dark:text-[#CBD5E1]'
                }`}
              >
                <span className="text-xs font-semibold opacity-80">الجزء</span>
                <span className="text-xl font-bold font-mono">{juzNum}</span>
                {isDone ? (
                  <CheckCircle2 className="w-4 h-4 text-emerald-200" />
                ) : (
                  <span className="w-4 h-4 rounded-full border border-current opacity-30" />
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};
