import React, { useEffect, useState } from 'react';
import { Compass, MapPin, Navigation, Info, RotateCw } from 'lucide-react';
import { POPULAR_CITIES, CityLocation, calculateQibla } from '../services/prayerService';

export const QiblaCompassView: React.FC = () => {
  const [selectedCity, setSelectedCity] = useState<CityLocation>(POPULAR_CITIES[3]); // Cairo default
  const [deviceHeading, setDeviceHeading] = useState<number>(0);
  const [hasCompassSupport, setHasCompassSupport] = useState<boolean>(false);

  const { bearing: qiblaBearing, distanceKm } = calculateQibla(selectedCity.lat, selectedCity.lng);

  // Device orientation event listener
  useEffect(() => {
    const handleOrientation = (e: DeviceOrientationEvent) => {
      if (e.alpha !== null) {
        setHasCompassSupport(true);
        // iOS provides webkitCompassHeading, standard is 360 - alpha
        const heading = (e as any).webkitCompassHeading !== undefined
          ? (e as any).webkitCompassHeading
          : (360 - (e.alpha || 0)) % 360;
        setDeviceHeading(Math.round(heading));
      }
    };

    if (window.DeviceOrientationEvent) {
      window.addEventListener('deviceorientation', handleOrientation, true);
    }

    return () => {
      window.removeEventListener('deviceorientation', handleOrientation);
    };
  }, []);

  const relativeQiblaAngle = (qiblaBearing - deviceHeading + 360) % 360;
  const isAligned = Math.abs(relativeQiblaAngle) < 5 || Math.abs(relativeQiblaAngle - 360) < 5;

  return (
    <div className="max-w-xl mx-auto px-4 sm:px-6 py-6 space-y-6 pb-28 text-center">
      {/* City & Distance Card */}
      <div className="bg-[#FAF7F2] dark:bg-[#1A221E] p-5 rounded-3xl border border-[#E8E2D7] dark:border-[#27322B] shadow-sm space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Compass className="w-5 h-5 text-[#5D7263]" />
            <h2 className="font-bold text-base text-[#2D3748] dark:text-[#E2E8F0]">
              بوصلة القبلة المشرفة
            </h2>
          </div>

          <select
            value={selectedCity.nameEn}
            onChange={(e) => {
              const c = POPULAR_CITIES.find((city) => city.nameEn === e.target.value);
              if (c) setSelectedCity(c);
            }}
            className="bg-[#EFE9DF] dark:bg-[#222C26] border border-[#E0D7C9] dark:border-[#2D3931] text-xs font-semibold rounded-xl px-2.5 py-1.5 focus:outline-none"
          >
            {POPULAR_CITIES.map((c) => (
              <option key={c.nameEn} value={c.nameEn}>
                {c.nameAr}
              </option>
            ))}
          </select>
        </div>

        <div className="flex items-center justify-around pt-2 border-t border-[#E8E2D7]/60 dark:border-[#27322B]/60 text-xs">
          <div>
            <span className="text-[#718096] dark:text-[#94A3B8] block">زاوية القبلة:</span>
            <span className="text-base font-black text-[#3B5249] dark:text-[#A7BFAC] font-mono">
              {qiblaBearing}° من الشمال
            </span>
          </div>
          <div className="w-px h-8 bg-[#E8E2D7] dark:bg-[#27322B]" />
          <div>
            <span className="text-[#718096] dark:text-[#94A3B8] block">المسافة إلى مكة:</span>
            <span className="text-base font-black text-[#3B5249] dark:text-[#A7BFAC] font-mono">
              {distanceKm.toLocaleString('ar-SA')} كم
            </span>
          </div>
        </div>
      </div>

      {/* Alignment Status */}
      <div>
        {isAligned ? (
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 font-bold text-xs border border-emerald-300 animate-pulse">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-500" />
            <span>أنت متجه مباشرة نحو الكعبة المشرفة!</span>
          </div>
        ) : (
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-[#EFE9DF] dark:bg-[#222C26] text-[#718096] dark:text-[#94A3B8] text-xs font-semibold">
            <span>قم بتدوير الجهاز حتى تتطابق الإبرة مع علامة الكعبة</span>
          </div>
        )}
      </div>

      {/* The Visual Compass Dial */}
      <div className="relative w-72 h-72 mx-auto my-6 flex items-center justify-center">
        {/* Outer Ring */}
        <div
          className="absolute inset-0 rounded-full border-4 border-[#5D7263]/30 dark:border-[#5D7263]/40 bg-gradient-to-b from-[#FAF7F2] to-[#ECE5D8] dark:from-[#1A221E] dark:to-[#121614] shadow-2xl flex items-center justify-center transition-transform duration-300 ease-out"
          style={{ transform: `rotate(${-deviceHeading}deg)` }}
        >
          {/* Compass cardinal directions */}
          <span className="absolute top-3 font-bold text-sm text-rose-600">شمال (N)</span>
          <span className="absolute bottom-3 font-bold text-xs text-[#718096]">جنوب (S)</span>
          <span className="absolute right-3 font-bold text-xs text-[#718096]">شرق (E)</span>
          <span className="absolute left-3 font-bold text-xs text-[#718096]">غرب (W)</span>

          {/* Dial tick marks */}
          <div className="absolute inset-5 rounded-full border border-dashed border-[#5D7263]/25" />

          {/* Qibla Direction Kaaba Indicator Marker */}
          <div
            className="absolute inset-0 flex flex-col items-center justify-start pt-1.5 pointer-events-none"
            style={{ transform: `rotate(${qiblaBearing}deg)` }}
          >
            <div className="flex flex-col items-center">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-amber-400 to-amber-600 text-black flex items-center justify-center shadow-lg border-2 border-white dark:border-black font-bold text-[10px]">
                🕋
              </div>
              <div className="w-0.5 h-16 bg-gradient-to-b from-amber-500 to-transparent" />
            </div>
          </div>
        </div>

        {/* Center Needle & Hub */}
        <div className="relative z-10 w-16 h-16 rounded-full bg-[#FAF7F2] dark:bg-[#1A221E] border-2 border-[#5D7263] shadow-lg flex flex-col items-center justify-center">
          <Navigation className="w-6 h-6 text-[#5D7263] transform rotate-45" />
          <span className="text-[10px] font-mono font-bold text-[#3B5249] dark:text-[#A7BFAC]">
            {qiblaBearing}°
          </span>
        </div>
      </div>

      {/* Manual Heading Slider (for desktop or when device gyroscope is disabled) */}
      {!hasCompassSupport && (
        <div className="bg-[#FAF7F2] dark:bg-[#1A221E] p-4 rounded-2xl border border-[#E8E2D7] dark:border-[#27322B] space-y-2">
          <div className="flex items-center justify-between text-xs text-[#718096]">
            <span>محاكاة اتجاه الهاتف: {deviceHeading}°</span>
            <button
              onClick={() => setDeviceHeading(qiblaBearing)}
              className="text-[#5D7263] font-bold hover:underline"
            >
              محاذاة مع القبلة
            </button>
          </div>
          <input
            type="range"
            min="0"
            max="360"
            value={deviceHeading}
            onChange={(e) => setDeviceHeading(Number(e.target.value))}
            className="w-full h-1.5 bg-[#E0D7C9] dark:bg-[#2D3931] accent-[#5D7263] rounded-lg cursor-pointer"
          />
        </div>
      )}

      {/* Guidance Note */}
      <div className="flex items-start gap-2.5 p-4 rounded-2xl bg-[#EFE9DF]/60 dark:bg-[#202923] text-right text-xs text-[#718096] dark:text-[#94A3B8]">
        <Info className="w-4 h-4 text-[#5D7263] shrink-0 mt-0.5" />
        <p className="leading-relaxed">
          للحصول على أدق نتيجة، ضع الهاتف على سطح مستوٍ ومستقيم بعيداً عن الأجهزة الإلكترونية والمعادن المغناطيسية، وقم بتحريك الجهاز على شكل الرقم 8 لمعايرة البوصلة.
        </p>
      </div>
    </div>
  );
};
