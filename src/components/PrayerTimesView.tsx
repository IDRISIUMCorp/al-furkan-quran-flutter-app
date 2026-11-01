import React, { useEffect, useState, useRef } from 'react';
import {
  Clock,
  MapPin,
  Volume2,
  VolumeX,
  AlertTriangle,
  Sun,
  Sunset,
  Moon,
  CloudSun,
  Sparkles,
} from 'lucide-react';
import {
  POPULAR_CITIES,
  CityLocation,
  calculatePrayerTimes,
  PrayerTimesResult,
  getHijriDate,
} from '../services/prayerService';

export const PrayerTimesView: React.FC = () => {
  const [selectedCity, setSelectedCity] = useState<CityLocation>(POPULAR_CITIES[0]); // Makkah default
  const [prayerData, setPrayerData] = useState<PrayerTimesResult>(() =>
    calculatePrayerTimes(POPULAR_CITIES[0].lat, POPULAR_CITIES[0].lng)
  );
  const [currentTime, setCurrentTime] = useState<Date>(new Date());
  const [isPlayingAdhan, setIsPlayingAdhan] = useState<boolean>(false);
  const adhanAudioRef = useRef<HTMLAudioElement | null>(null);

  // Update clock every minute
  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      setCurrentTime(now);
      setPrayerData(calculatePrayerTimes(selectedCity.lat, selectedCity.lng, now));
    }, 1000 * 30);
    return () => clearInterval(timer);
  }, [selectedCity]);

  const handleCityChange = (cityNameEn: string) => {
    const city = POPULAR_CITIES.find((c) => c.nameEn === cityNameEn) || POPULAR_CITIES[0];
    setSelectedCity(city);
    setPrayerData(calculatePrayerTimes(city.lat, city.lng));
  };

  const handleUseMyLocation = () => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          const customCity: CityLocation = {
            nameAr: 'موقعي الحالي',
            nameEn: 'My Location',
            countryAr: '',
            lat: pos.coords.latitude,
            lng: pos.coords.longitude,
            timezoneOffset: -new Date().getTimezoneOffset() / 60,
          };
          setSelectedCity(customCity);
          setPrayerData(calculatePrayerTimes(pos.coords.latitude, pos.coords.longitude));
        },
        (err) => {
          console.warn('Geolocation denied or unavailable:', err);
        }
      );
    }
  };

  const toggleAdhan = () => {
    if (!adhanAudioRef.current) return;
    if (isPlayingAdhan) {
      adhanAudioRef.current.pause();
      adhanAudioRef.current.currentTime = 0;
      setIsPlayingAdhan(false);
    } else {
      adhanAudioRef.current.play().then(() => setIsPlayingAdhan(true)).catch((e) => {
        console.warn('Audio play error:', e);
      });
    }
  };

  const prayerCards = [
    {
      id: 'fajr',
      nameAr: 'الفجر',
      nameEn: 'Fajr',
      time: prayerData.fajr,
      icon: <Sun className="w-5 h-5 text-amber-500" />,
      isNext: prayerData.nextPrayer.id === 'fajr',
    },
    {
      id: 'sunrise',
      nameAr: 'الشروق',
      nameEn: 'Sunrise',
      time: prayerData.sunrise,
      icon: <CloudSun className="w-5 h-5 text-amber-600" />,
      isNext: prayerData.nextPrayer.id === 'sunrise',
    },
    {
      id: 'dhuhr',
      nameAr: 'الظهر',
      nameEn: 'Dhuhr',
      time: prayerData.dhuhr,
      icon: <Sun className="w-5 h-5 text-amber-400" />,
      isNext: prayerData.nextPrayer.id === 'dhuhr',
    },
    {
      id: 'asr',
      nameAr: 'العصر',
      nameEn: 'Asr',
      time: prayerData.asr,
      icon: <CloudSun className="w-5 h-5 text-orange-400" />,
      isNext: prayerData.nextPrayer.id === 'asr',
    },
    {
      id: 'maghrib',
      nameAr: 'المغرب',
      nameEn: 'Maghrib',
      time: prayerData.maghrib,
      icon: <Sunset className="w-5 h-5 text-rose-400" />,
      isNext: prayerData.nextPrayer.id === 'maghrib',
    },
    {
      id: 'isha',
      nameAr: 'العشاء',
      nameEn: 'Isha',
      time: prayerData.isha,
      icon: <Moon className="w-5 h-5 text-indigo-400" />,
      isNext: prayerData.nextPrayer.id === 'isha',
    },
  ];

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 py-6 space-y-6 pb-28">
      {/* Hidden Adhan audio */}
      <audio
        ref={adhanAudioRef}
        src="/assets/adhan/adhan_by_Ahamed_al_Nafees.mp3"
        onEnded={() => setIsPlayingAdhan(false)}
      />

      {/* Top Location & Date Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-[#FAF7F2] dark:bg-[#1A221E] p-4 rounded-2xl border border-[#E8E2D7] dark:border-[#27322B] shadow-sm">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-[#5D7263]/15 text-[#5D7263] flex items-center justify-center">
            <MapPin className="w-5 h-5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-bold text-sm text-[#2D3748] dark:text-[#E2E8F0]">
                {selectedCity.nameAr}
              </span>
              {selectedCity.countryAr && (
                <span className="text-xs text-[#718096] dark:text-[#94A3B8]">
                  • {selectedCity.countryAr}
                </span>
              )}
            </div>
            <div className="text-xs text-[#718096] dark:text-[#94A3B8]">
              {getHijriDate()}
            </div>
          </div>
        </div>

        {/* City selector & geolocation */}
        <div className="flex items-center gap-2">
          <select
            value={selectedCity.nameEn}
            onChange={(e) => handleCityChange(e.target.value)}
            className="bg-[#EFE9DF] dark:bg-[#222C26] border border-[#E0D7C9] dark:border-[#2D3931] text-xs font-semibold rounded-xl px-3 py-2 text-[#2D3748] dark:text-[#E2E8F0] focus:outline-none"
          >
            {POPULAR_CITIES.map((c) => (
              <option key={c.nameEn} value={c.nameEn}>
                {c.nameAr} ({c.nameEn})
              </option>
            ))}
          </select>

          <button
            onClick={handleUseMyLocation}
            className="px-3 py-2 rounded-xl bg-[#5D7263]/10 hover:bg-[#5D7263]/20 text-[#3B5249] dark:text-[#A7BFAC] text-xs font-bold transition"
            title="تحديد الموقع عبر GPS"
          >
            موقعي
          </button>
        </div>
      </div>

      {/* Hero Next Prayer Card */}
      <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-[#3B5249] via-[#2F423B] to-[#1E2B26] text-white p-7 shadow-lg space-y-4">
        {/* Subtle decorative Kaaba icon */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
            <span className="text-xs font-medium text-emerald-200 uppercase tracking-wider">
              الصلاة القادمة
            </span>
          </div>

          <button
            onClick={toggleAdhan}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-bold transition ${
              isPlayingAdhan
                ? 'bg-rose-500 text-white animate-pulse'
                : 'bg-white/15 hover:bg-white/25 text-white'
            }`}
          >
            {isPlayingAdhan ? <VolumeX className="w-3.5 h-3.5" /> : <Volume2 className="w-3.5 h-3.5" />}
            <span>{isPlayingAdhan ? 'إيقاف الأذان' : 'سماع الأذان (بصوت أحمد النفيس)'}</span>
          </button>
        </div>

        <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
          <div>
            <h2 className="text-4xl sm:text-5xl font-extrabold text-white">
              صلاة {prayerData.nextPrayer.nameAr}
            </h2>
            <p className="text-emerald-100/90 text-sm mt-1">
              في تمام الساعة {prayerData.nextPrayer.time}
            </p>
          </div>

          <div className="bg-white/10 backdrop-blur-md rounded-2xl px-5 py-3 border border-white/15 text-center sm:text-right">
            <span className="text-[11px] text-emerald-200 block">المتبقي على الأذان:</span>
            <span className="text-2xl font-black text-white font-mono">
              {prayerData.nextPrayer.formattedCountdown}
            </span>
          </div>
        </div>
      </div>

      {/* Grid of All 5 Prayers + Sunrise */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        {prayerCards.map((p) => {
          return (
            <div
              key={p.id}
              className={`p-4 rounded-2xl border text-center transition space-y-2 ${
                p.isNext
                  ? 'bg-[#5D7263]/15 dark:bg-[#5D7263]/25 border-[#5D7263] ring-1 ring-[#5D7263]'
                  : 'bg-[#FAF7F2] dark:bg-[#1A221E] border-[#E8E2D7] dark:border-[#27322B]'
              }`}
            >
              <div className="flex items-center justify-center">{p.icon}</div>
              <div>
                <span className="font-bold text-sm text-[#2D3748] dark:text-[#E2E8F0] block">
                  {p.nameAr}
                </span>
                <span className="text-[10px] text-[#718096] dark:text-[#94A3B8] block">
                  {p.nameEn}
                </span>
              </div>
              <div className="font-mono font-bold text-sm text-[#3B5249] dark:text-[#A7BFAC] pt-1 border-t border-[#E8E2D7]/60 dark:border-[#27322B]/60">
                {p.time}
              </div>
            </div>
          );
        })}
      </div>

      {/* Forbidden Times for Prayer (أوقات النهي) */}
      <div className="p-5 rounded-2xl bg-[#FAF7F2] dark:bg-[#1A221E] border border-[#E8E2D7] dark:border-[#27322B] shadow-sm space-y-3">
        <div className="flex items-center gap-2 text-amber-700 dark:text-amber-400 font-bold text-sm">
          <AlertTriangle className="w-4 h-4" />
          <span>أوقات النهي عن الصلاة (النوافل غير ذات السبب)</span>
        </div>
        <p className="text-xs text-[#718096] dark:text-[#94A3B8] leading-relaxed">
          نهى النبي ﷺ عن الصلاة في ثلاثة أوقات: حين تطلع الشمس بازغة حتى ترتفع، وحين يقوم قائم الظهيرة حتى تميل الشمس، وحين تضيف الشمس للغروب حتى تغرب.
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5 pt-1">
          {prayerData.forbiddenTimes.map((f, idx) => (
            <div
              key={idx}
              className={`p-3 rounded-xl border text-xs space-y-1 ${
                f.activeNow
                  ? 'bg-amber-100/80 border-amber-400 text-amber-900 dark:bg-amber-950/40 dark:border-amber-700 dark:text-amber-200'
                  : 'bg-[#EFE9DF]/50 dark:bg-[#202923] border-[#E0D7C9] dark:border-[#2D3931] text-[#4A5568] dark:text-[#CBD5E1]'
              }`}
            >
              <div className="font-bold flex items-center justify-between">
                <span>{f.nameAr}</span>
                {f.activeNow && (
                  <span className="text-[10px] bg-amber-500 text-white px-1.5 py-0.5 rounded">
                    الآن
                  </span>
                )}
              </div>
              <div className="font-mono text-xs opacity-80">{f.range}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
