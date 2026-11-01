export interface CityLocation {
  nameAr: string;
  nameEn: string;
  countryAr: string;
  lat: number;
  lng: number;
  timezoneOffset: number; // in hours
}

export const POPULAR_CITIES: CityLocation[] = [
  { nameAr: 'مكة المكرمة', nameEn: 'Makkah', countryAr: 'السعودية', lat: 21.4225, lng: 39.8262, timezoneOffset: 3 },
  { nameAr: 'المدينة المنورة', nameEn: 'Madinah', countryAr: 'السعودية', lat: 24.5247, lng: 39.5692, timezoneOffset: 3 },
  { nameAr: 'القدس الشريف', nameEn: 'Jerusalem', countryAr: 'فلسطين', lat: 31.7683, lng: 35.2137, timezoneOffset: 2 },
  { nameAr: 'القاهرة', nameEn: 'Cairo', countryAr: 'مصر', lat: 30.0444, lng: 31.2357, timezoneOffset: 2 },
  { nameAr: 'الرياض', nameEn: 'Riyadh', countryAr: 'السعودية', lat: 24.7136, lng: 46.6753, timezoneOffset: 3 },
  { nameAr: 'دبي', nameEn: 'Dubai', countryAr: 'الإمارات', lat: 25.2048, lng: 55.2708, timezoneOffset: 4 },
  { nameAr: 'إسطنبول', nameEn: 'Istanbul', countryAr: 'تركيا', lat: 41.0082, lng: 28.9784, timezoneOffset: 3 },
  { nameAr: 'لندن', nameEn: 'London', countryAr: 'المملكة المتحدة', lat: 51.5074, lng: -0.1278, timezoneOffset: 0 },
  { nameAr: 'باريس', nameEn: 'Paris', countryAr: 'فرنسا', lat: 48.8566, lng: 2.3522, timezoneOffset: 1 },
  { nameAr: 'نيويورك', nameEn: 'New York', countryAr: 'الولايات المتحدة', lat: 40.7128, lng: -74.006, timezoneOffset: -5 },
  { nameAr: 'جاكرتا', nameEn: 'Jakarta', countryAr: 'إندونيسيا', lat: -6.2088, lng: 106.8456, timezoneOffset: 7 },
  { nameAr: 'الرباط', nameEn: 'Rabat', countryAr: 'المغرب', lat: 34.0209, lng: -6.8416, timezoneOffset: 1 },
  { nameAr: 'تونس', nameEn: 'Tunis', countryAr: 'تونس', lat: 36.8065, lng: 10.1815, timezoneOffset: 1 },
  { nameAr: 'الجزائر', nameEn: 'Algiers', countryAr: 'الجزائر', lat: 36.7538, lng: 3.0588, timezoneOffset: 1 },
];

export interface PrayerTimesResult {
  fajr: string;
  sunrise: string;
  dhuhr: string;
  asr: string;
  maghrib: string;
  isha: string;
  fajrDate: Date;
  sunriseDate: Date;
  dhuhrDate: Date;
  asrDate: Date;
  maghribDate: Date;
  ishaDate: Date;
  nextPrayer: {
    id: string;
    nameAr: string;
    time: string;
    remainingMinutes: number;
    formattedCountdown: string;
  };
  forbiddenTimes: {
    nameAr: string;
    range: string;
    activeNow: boolean;
  }[];
}

// Astronomical calculation helpers
const KAABA_LAT = 21.4225;
const KAABA_LNG = 39.8262;

export function calculateQibla(userLat: number, userLng: number): { bearing: number; distanceKm: number } {
  const phiK = (KAABA_LAT * Math.PI) / 180;
  const lambdaK = (KAABA_LNG * Math.PI) / 180;
  const phi = (userLat * Math.PI) / 180;
  const lambda = (userLng * Math.PI) / 180;

  const y = Math.sin(lambdaK - lambda);
  const x = Math.cos(phi) * Math.tan(phiK) - Math.sin(phi) * Math.cos(lambdaK - lambda);
  let qibla = (Math.atan2(y, x) * 180) / Math.PI;
  qibla = (qibla + 360) % 360;

  // Haversine distance
  const R = 6371; // Earth radius in km
  const dLat = phiK - phi;
  const dLng = lambdaK - lambda;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(phi) * Math.cos(phiK) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distanceKm = Math.round(R * c);

  return { bearing: Math.round(qibla), distanceKm };
}

export function calculatePrayerTimes(lat: number, lng: number, date: Date = new Date()): PrayerTimesResult {
  // Day of year
  const start = new Date(date.getFullYear(), 0, 0);
  const diff = date.getTime() - start.getTime() + (start.getTimezoneOffset() - date.getTimezoneOffset()) * 60 * 1000;
  const dayOfYear = Math.floor(diff / (1000 * 60 * 60 * 24));

  // Sun declination & Equation of Time
  const B = (2 * Math.PI * (dayOfYear - 81)) / 365;
  const EoT = 9.87 * Math.sin(2 * B) - 7.53 * Math.cos(B) - 1.5 * Math.sin(B); // in minutes
  const declination = 23.45 * Math.sin(B); // in degrees
  const decRad = (declination * Math.PI) / 180;
  const latRad = (lat * Math.PI) / 180;

  // Solar Noon (in local hours)
  const localTimezoneOffset = -date.getTimezoneOffset() / 60;
  const solarNoonMinutes = 720 - 4 * lng - EoT + localTimezoneOffset * 60;
  const noonHour = solarNoonMinutes / 60;

  // Hour angle for angles
  const getHourAngle = (angle: number) => {
    const angleRad = (angle * Math.PI) / 180;
    const cosHA = (Math.sin(angleRad) - Math.sin(latRad) * Math.sin(decRad)) / (Math.cos(latRad) * Math.cos(decRad));
    if (cosHA > 1) return 0;
    if (cosHA < -1) return Math.PI;
    return Math.acos(cosHA);
  };

  // Sunrise / Sunset: angle = -0.833°
  const haSunrise = getHourAngle(-0.833);
  const sunriseHours = haSunrise * (180 / Math.PI) * 4 / 60;

  // Fajr: angle = -18.0° (Muslim World League / Umm al-Qura standard)
  const haFajr = getHourAngle(-18.0);
  const fajrHours = haFajr * (180 / Math.PI) * 4 / 60;

  // Isha: angle = -17.5°
  const haIsha = getHourAngle(-17.5);
  const ishaHours = haIsha * (180 / Math.PI) * 4 / 60;

  // Asr: Shafi'i shadow factor = 1
  const asrAlt = (Math.atan(1 / (1 + Math.tan(Math.abs(latRad - decRad)))) * 180) / Math.PI;
  const haAsr = getHourAngle(asrAlt);
  const asrHours = haAsr * (180 / Math.PI) * 4 / 60;

  // Times in decimal hours
  const tFajr = noonHour - fajrHours;
  const tSunrise = noonHour - sunriseHours;
  const tDhuhr = noonHour;
  const tAsr = noonHour + asrHours;
  const tMaghrib = noonHour + sunriseHours;
  const tIsha = noonHour + ishaHours;

  const toDate = (decHours: number): Date => {
    const d = new Date(date);
    const hrs = Math.floor(decHours);
    const mins = Math.floor((decHours - hrs) * 60);
    d.setHours(hrs, mins, 0, 0);
    return d;
  };

  const formatTime = (d: Date): string => {
    return d.toLocaleTimeString('ar-SA', { hour: '2-digit', minute: '2-digit', hour12: true });
  };

  const fajrDate = toDate(tFajr);
  const sunriseDate = toDate(tSunrise);
  const dhuhrDate = toDate(tDhuhr);
  const asrDate = toDate(tAsr);
  const maghribDate = toDate(tMaghrib);
  const ishaDate = toDate(tIsha);

  const now = new Date();

  // Determine next prayer
  const prayers = [
    { id: 'fajr', nameAr: 'الفجر', date: fajrDate },
    { id: 'sunrise', nameAr: 'الشروق', date: sunriseDate },
    { id: 'dhuhr', nameAr: 'الظهر', date: dhuhrDate },
    { id: 'asr', nameAr: 'العصر', date: asrDate },
    { id: 'maghrib', nameAr: 'المغرب', date: maghribDate },
    { id: 'isha', nameAr: 'العشاء', date: ishaDate },
  ];

  let nextP = prayers.find((p) => p.date.getTime() > now.getTime());
  if (!nextP) {
    // Tomorrow's Fajr
    const tomorrowFajr = new Date(fajrDate);
    tomorrowFajr.setDate(tomorrowFajr.getDate() + 1);
    nextP = { id: 'fajr', nameAr: 'الفجر', date: tomorrowFajr };
  }

  const diffMs = nextP.date.getTime() - now.getTime();
  const diffMins = Math.max(0, Math.floor(diffMs / 60000));
  const hrsRemain = Math.floor(diffMins / 60);
  const minsRemain = diffMins % 60;
  const formattedCountdown = `${hrsRemain} س ${minsRemain} د`;

  // Forbidden prayer times
  // 1. Sunrise forbidden time: from sunrise until 15 mins after
  // 2. Solar noon forbidden time: 10 mins before Dhuhr
  // 3. Sunset forbidden time: 15 mins before Maghrib until Maghrib
  const forbiddenTimes = [
    {
      nameAr: 'بعد الشروق (حتى ترتفع الشمس قيد رمح)',
      range: `${formatTime(sunriseDate)} - ${formatTime(new Date(sunriseDate.getTime() + 15 * 60000))}`,
      activeNow: now >= sunriseDate && now <= new Date(sunriseDate.getTime() + 15 * 60000),
    },
    {
      nameAr: 'عند استواء الشمس في كبد السماء',
      range: `${formatTime(new Date(dhuhrDate.getTime() - 10 * 60000))} - ${formatTime(dhuhrDate)}`,
      activeNow: now >= new Date(dhuhrDate.getTime() - 10 * 60000) && now <= dhuhrDate,
    },
    {
      nameAr: 'عند اصفرار الشمس وقبل الغروب',
      range: `${formatTime(new Date(maghribDate.getTime() - 15 * 60000))} - ${formatTime(maghribDate)}`,
      activeNow: now >= new Date(maghribDate.getTime() - 15 * 60000) && now <= maghribDate,
    },
  ];

  return {
    fajr: formatTime(fajrDate),
    sunrise: formatTime(sunriseDate),
    dhuhr: formatTime(dhuhrDate),
    asr: formatTime(asrDate),
    maghrib: formatTime(maghribDate),
    isha: formatTime(ishaDate),
    fajrDate,
    sunriseDate,
    dhuhrDate,
    asrDate,
    maghribDate,
    ishaDate,
    nextPrayer: {
      id: nextP.id,
      nameAr: nextP.nameAr,
      time: formatTime(nextP.date),
      remainingMinutes: diffMins,
      formattedCountdown,
    },
    forbiddenTimes,
  };
}

export function getHijriDate(): string {
  try {
    const formatter = new Intl.DateTimeFormat('ar-SA-u-ca-islamic-umalqura', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
    return formatter.format(new Date());
  } catch (_) {
    return '١٤٤٧ هـ';
  }
}
