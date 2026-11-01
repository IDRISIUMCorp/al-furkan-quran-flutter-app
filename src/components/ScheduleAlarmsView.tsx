import React, { useState, useEffect } from 'react';
import {
  BellRing,
  Clock,
  Sparkles,
  MapPin,
  CheckCircle,
  AlertTriangle,
  Play,
  Volume2,
} from 'lucide-react';
import { PrayerAlarmItem } from '../types/hifz';
import {
  computeTunisiaPrayerTimes,
  formatPrayerTime,
  INITIAL_PRAYER_ALARMS,
} from '../services/alarmService';
import { EscalatingAlarmModal } from './EscalatingAlarmModal';

interface ScheduleAlarmsViewProps {
  onStartHifzForAlarm?: (targetDescription: string) => void;
}

export const ScheduleAlarmsView: React.FC<ScheduleAlarmsViewProps> = ({
  onStartHifzForAlarm,
}) => {
  const [alarms, setAlarms] = useState<PrayerAlarmItem[]>(() => {
    const saved = localStorage.getItem('zen_hifz_alarms');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (_) {}
    }
    return INITIAL_PRAYER_ALARMS;
  });

  const [simulatingAlarm, setSimulatingAlarm] = useState<PrayerAlarmItem | null>(null);

  // Recalculate daily prayer times based on Tunisia 18°
  useEffect(() => {
    const times = computeTunisiaPrayerTimes();
    setAlarms((prev) =>
      prev.map((item) => {
        let t = item.time;
        if (item.id === 'fajr') t = formatPrayerTime(times.fajr);
        if (item.id === 'dhuhr') t = formatPrayerTime(times.dhuhr);
        if (item.id === 'asr') t = formatPrayerTime(times.asr);
        if (item.id === 'maghrib') t = formatPrayerTime(times.maghrib);
        if (item.id === 'isha') t = formatPrayerTime(times.isha);
        return { ...item, time: t };
      })
    );
  }, []);

  const handleToggleAlarm = (id: string) => {
    setAlarms((prev) => {
      const updated = prev.map((a) =>
        a.id === id ? { ...a, isAlarmEnabled: !a.isAlarmEnabled } : a
      );
      localStorage.setItem('zen_hifz_alarms', JSON.stringify(updated));
      return updated;
    });
  };

  const handleTriggerTestAlarm = (item: PrayerAlarmItem) => {
    setSimulatingAlarm(item);
  };

  const handleDismissViaHifz = () => {
    if (simulatingAlarm && onStartHifzForAlarm) {
      onStartHifzForAlarm(simulatingAlarm.targetVersesDescription);
    }
    setSimulatingAlarm(null);
  };

  return (
    <div
      dir="rtl"
      className="max-w-2xl mx-auto px-4 py-6 space-y-6 text-[#1E201D] dark:text-[#E6D5B8]"
    >
      {/* Header Banner */}
      <div className="text-center space-y-1">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#4A6B5D]/10 dark:bg-[#7FA695]/15 text-[#4A6B5D] dark:text-[#7FA695] text-xs font-bold mb-1">
          <MapPin className="w-3.5 h-3.5" />
          <span>توقيت تونس (زاوية الفجر 18° • زاوية العشاء 18°)</span>
        </div>
        <h1 className="text-xl font-bold font-cairo">جدول الصلوات والمنبهات الصارمة</h1>
        <p className="text-xs text-[#7F8E87] dark:text-[#8D9F96]">
          4 مراحل متصاعدة لكل صلاة (معرفات 101 إلى 104) بفارق 5 دقائق ولا يتوقف إلا بإنجاز الحفظ
        </p>
      </div>

      {/* 5-Prayer Timeline Cards */}
      <div className="space-y-3">
        {alarms.map((item) => (
          <div
            key={item.id}
            className={`p-4 sm:p-5 rounded-2xl border transition-all duration-200 flex flex-col sm:flex-row sm:items-center justify-between gap-4 ${
              item.isAlarmEnabled
                ? 'bg-[#FBF8F3] dark:bg-[#151C18] border-[#4A6B5D]/40 dark:border-[#7FA695]/40 shadow-xs'
                : 'bg-[#F2ECE1]/50 dark:bg-[#131715]/50 border-[#E2D9CC] dark:border-[#202924] opacity-80'
            }`}
          >
            {/* Left: Prayer Name & Time */}
            <div className="flex items-center gap-4">
              <div
                className={`w-12 h-12 rounded-2xl flex items-center justify-center font-bold text-sm ${
                  item.isAlarmEnabled
                    ? 'bg-[#4A6B5D] text-white shadow-xs'
                    : 'bg-[#E2D9CC] dark:bg-[#202924] text-[#7B8B83]'
                }`}
              >
                {item.prayerNameAr}
              </div>

              <div>
                <div className="flex items-center gap-2">
                  <span className="text-lg font-bold font-mono tracking-tight">
                    {item.time}
                  </span>
                  <span className="text-xs text-[#7E8E86] dark:text-[#8D9F96] font-medium">
                    {item.prayerNameEn}
                  </span>
                </div>
                <p className="text-xs font-medium text-[#4A6B5D] dark:text-[#7FA695] flex items-center gap-1 mt-0.5">
                  <Sparkles className="w-3 h-3" />
                  <span>{item.targetVersesDescription}</span>
                </p>
              </div>
            </div>

            {/* Right: Toggle & Test Buttons */}
            <div className="flex items-center justify-between sm:justify-end gap-3 pt-2 sm:pt-0 border-t sm:border-t-0 border-[#E8E2D7] dark:border-[#222E27]">
              {item.isAlarmEnabled && (
                <button
                  type="button"
                  onClick={() => handleTriggerTestAlarm(item)}
                  className="px-2.5 py-1.5 rounded-xl bg-[#E8E1D5] dark:bg-[#202A25] hover:bg-[#DDD2C4] dark:hover:bg-[#2A3730] text-[11px] font-bold text-[#4A6B5D] dark:text-[#7FA695] transition-colors flex items-center gap-1"
                >
                  <Volume2 className="w-3.5 h-3.5" />
                  <span>تجربة الرنين</span>
                </button>
              )}

              {/* Alarm Switch */}
              <button
                type="button"
                onClick={() => handleToggleAlarm(item.id)}
                className={`relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-hidden ${
                  item.isAlarmEnabled ? 'bg-[#4A6B5D]' : 'bg-[#D2C8BA] dark:bg-[#2E3B34]'
                }`}
              >
                <span
                  className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow-sm ring-0 transition duration-200 ease-in-out ${
                    item.isAlarmEnabled ? '-translate-x-5' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Strict Escalation Explanation Card */}
      <div className="p-4 rounded-2xl bg-[#F2ECE1]/60 dark:bg-[#1A221E]/60 border border-[#E2D9CC] dark:border-[#25322B] space-y-2 text-xs text-[#62716A] dark:text-[#90A49A]">
        <div className="flex items-center gap-1.5 font-bold text-[#1E201D] dark:text-[#E6D5B8]">
          <AlertTriangle className="w-4 h-4 text-amber-600 dark:text-amber-400" />
          <span>نظام الإنذار الإجباري للحفظ (Escalating Protocol)</span>
        </div>
        <p>
          عند حلول وقت الصلاة، يبدأ التنبيه بالمعرف (101)، ثم بعد 5 دقائق يتصاعد إلى (102)، ثم (103)، ثم الإنذار الأقصى (104). صُمم التطبيق ليربط استيقاظك بالآيات القرآنية مباشرة لمنع النوم والتكاسل.
        </p>
      </div>

      {/* Escalating Alarm Simulation Modal */}
      <EscalatingAlarmModal
        alarm={simulatingAlarm}
        isOpen={Boolean(simulatingAlarm)}
        onDismissViaHifz={handleDismissViaHifz}
        onSnooze5Min={() => setSimulatingAlarm(null)}
      />
    </div>
  );
};
