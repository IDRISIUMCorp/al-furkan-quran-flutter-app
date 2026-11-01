import React, { useState, useEffect } from 'react';
import { BellRing, ShieldAlert, Sparkles, Volume2, CheckCircle2 } from 'lucide-react';
import { PrayerAlarmItem } from '../types/hifz';

interface EscalatingAlarmModalProps {
  alarm: PrayerAlarmItem | null;
  onDismissViaHifz: () => void;
  onSnooze5Min: () => void;
  isOpen: boolean;
}

export const EscalatingAlarmModal: React.FC<EscalatingAlarmModalProps> = ({
  alarm,
  onDismissViaHifz,
  onSnooze5Min,
  isOpen,
}) => {
  const [currentStage, setCurrentStage] = useState<number>(1);
  const [stageSecondsLeft, setStageSecondsLeft] = useState<number>(300); // 5 min per stage

  useEffect(() => {
    if (!isOpen) return;
    setCurrentStage(1);
    setStageSecondsLeft(300);

    // Audio chime loop simulation
    const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
    let isCancelled = false;

    const playBeep = () => {
      if (isCancelled) return;
      try {
        const osc = audioContext.createOscillator();
        const gain = audioContext.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(587.33, audioContext.currentTime); // D5 note
        gain.gain.setValueAtTime(0.15, audioContext.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, audioContext.currentTime + 0.6);
        osc.connect(gain);
        gain.connect(audioContext.destination);
        osc.start();
        osc.stop(audioContext.currentTime + 0.6);
      } catch (_) {}
    };

    const interval = setInterval(playBeep, 2500);
    playBeep();

    const timer = setInterval(() => {
      setStageSecondsLeft((s) => {
        if (s <= 1) {
          setCurrentStage((st) => Math.min(4, st + 1));
          return 300;
        }
        return s - 1;
      });
    }, 1000);

    return () => {
      isCancelled = true;
      clearInterval(interval);
      clearInterval(timer);
      audioContext.close().catch(() => {});
    };
  }, [isOpen]);

  if (!isOpen || !alarm) return null;

  const stageLabels: Record<number, { title: string; subtitle: string }> = {
    1: {
      title: 'المرحلة 1: تنبيه أولي بدخول وقت الصلاة والورد',
      subtitle: 'حان وقت الحفظ المبارك والوقوف بين يدي الله',
    },
    2: {
      title: 'المرحلة 2: تصعيد التنبيه (+5 دقائق)',
      subtitle: 'تذكير ثانٍ لتجنب الغفلة والتأخير',
    },
    3: {
      title: 'المرحلة 3: رنين حازم (+10 دقائق)',
      subtitle: 'أقبل على كتاب الله وصلاتك ولا تسوف',
    },
    4: {
      title: 'المرحلة 4: الإنذار الأقصى الصارم (+15 دقيقة)',
      subtitle: 'المنبه لا يتوقف إلا عند بدء ورد الحفظ الفعلي!',
    },
  };

  const minutes = Math.floor(stageSecondsLeft / 60);
  const seconds = stageSecondsLeft % 60;
  const timerStr = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

  return (
    <div
      dir="rtl"
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-md p-4 animate-in fade-in duration-200"
    >
      <div className="w-full max-w-md rounded-3xl bg-[#FBF8F3] dark:bg-[#151C18] text-[#1E201D] dark:text-[#E6D5B8] border-2 border-rose-500 shadow-2xl p-6 text-center space-y-6">
        {/* Pulsing Alarm Icon */}
        <div className="relative inline-flex mx-auto">
          <div className="w-20 h-20 rounded-full bg-rose-500/15 dark:bg-rose-500/25 flex items-center justify-center animate-pulse">
            <BellRing className="w-10 h-10 text-rose-500 animate-bounce" />
          </div>
          <span className="absolute -top-1 -right-1 px-2.5 py-0.5 rounded-full bg-rose-500 text-white font-mono text-xs font-bold">
            مرحلة {currentStage}/4
          </span>
        </div>

        {/* Alarm Info */}
        <div className="space-y-1">
          <p className="text-xs font-bold text-rose-500 uppercase tracking-widest">
            منبه صلاة {alarm.prayerNameAr} المتصاعد (طريقة تونس 18°)
          </p>
          <h2 className="text-2xl font-bold font-cairo">
            {stageLabels[currentStage]?.title}
          </h2>
          <p className="text-xs text-[#708077] dark:text-[#90A49B]">
            {stageLabels[currentStage]?.subtitle}
          </p>
        </div>

        {/* Hifz Requirement Target */}
        <div className="p-4 rounded-2xl bg-[#F2ECE1] dark:bg-[#1C2520] border border-[#E2D9CC] dark:border-[#28362E] text-right space-y-2">
          <div className="flex items-center gap-1.5 text-xs font-bold text-[#4A6B5D] dark:text-[#7FA695]">
            <Sparkles className="w-4 h-4" />
            <span>شرط إيقاف المنبه: إنجاز ورد الحفظ</span>
          </div>
          <p className="text-sm font-bold text-[#1E201D] dark:text-[#E6D5B8]">
            {alarm.targetVersesDescription}
          </p>
          <p className="text-[11px] text-[#788880] dark:text-[#8D9F96]">
            التصعيد القادم للمرحلة التالية خلال: <span className="font-mono font-bold text-rose-600">{timerStr}</span>
          </p>
        </div>

        {/* Action Buttons */}
        <div className="space-y-2.5">
          <button
            onClick={onDismissViaHifz}
            className="w-full py-3.5 rounded-2xl bg-[#4A6B5D] hover:bg-[#3D5B4F] text-white font-bold text-sm shadow-lg flex items-center justify-center gap-2 transition-transform active:scale-98"
          >
            <CheckCircle2 className="w-5 h-5" />
            <span>بدء جلسة الحفظ المباركة لإلغاء المنبه</span>
          </button>

          {currentStage < 4 && (
            <button
              onClick={onSnooze5Min}
              className="w-full py-2.5 rounded-xl bg-[#F2ECE1] dark:bg-[#1C2520] hover:bg-[#E4DACB] dark:hover:bg-[#25322B] text-xs font-semibold text-[#66756E] dark:text-[#A7BAAE] transition-colors"
            >
              غفوة مؤقتة (5 دقائق إلى المرحلة {currentStage + 1})
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
