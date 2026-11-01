import { PrayerAlarmItem } from '../types/hifz';

// Tunisia calculation convention: Fajr 18.0°, Isha 18.0°
export interface TunisiaPrayerCalculation {
  fajr: Date;
  sunrise: Date;
  dhuhr: Date;
  asr: Date;
  maghrib: Date;
  isha: Date;
}

export function computeTunisiaPrayerTimes(
  date: Date = new Date(),
  lat: number = 36.8065,
  lng: number = 10.1815
): TunisiaPrayerCalculation {
  // Astronomical Julian Date calculation
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();

  const a = Math.floor((14 - month) / 12);
  const y = year + 4800 - a;
  const m = month + 12 * a - 3;
  const jd =
    day +
    Math.floor((153 * m + 2) / 5) +
    365 * y +
    Math.floor(y / 4) -
    Math.floor(y / 100) +
    Math.floor(y / 400) -
    32045;

  const d = jd - 2451545.0;

  // Mean solar anomaly and ecliptic longitude
  const g = (357.529 + 0.98560028 * d) % 360;
  const q = (280.459 + 0.98564736 * d) % 360;
  const L =
    (q +
      1.915 * Math.sin((g * Math.PI) / 180) +
      0.02 * Math.sin((2 * g * Math.PI) / 180)) %
    360;

  // Obliquity of ecliptic
  const e = 23.439 - 0.00000036 * d;

  // Sun right ascension and declination
  const RA =
    (Math.atan2(
      Math.cos((e * Math.PI) / 180) * Math.sin((L * Math.PI) / 180),
      Math.cos((L * Math.PI) / 180)
    ) *
      180) /
    Math.PI;
  const dec =
    (Math.asin(
      Math.sin((e * Math.PI) / 180) * Math.sin((L * Math.PI) / 180)
    ) *
      180) /
    Math.PI;

  // Equation of time & solar noon
  const eqt = (q / 15 - (RA < 0 ? RA + 360 : RA) / 15) * 60; // in minutes
  const timezoneOffsetHours = -date.getTimezoneOffset() / 60;
  const noonHours = 12 + timezoneOffsetHours - lng / 15 - eqt / 60;

  // Sun hour angle helper
  const hourAngle = (angle: number): number => {
    const latRad = (lat * Math.PI) / 180;
    const decRad = (dec * Math.PI) / 180;
    const angRad = (angle * Math.PI) / 180;

    const cosH =
      (-Math.sin(angRad) - Math.sin(latRad) * Math.sin(decRad)) /
      (Math.cos(latRad) * Math.cos(decRad));

    if (cosH > 1) return 0; // Sun never rises
    if (cosH < -1) return 12; // Sun never sets
    return (Math.acos(cosH) * 180) / Math.PI / 15;
  };

  // Asr shadow angle (Shafi'i / standard: shadow = 1 + noon shadow)
  const asrAngle = (): number => {
    const latRad = (lat * Math.PI) / 180;
    const decRad = (dec * Math.PI) / 180;
    const noonAlt = 90 - Math.abs(lat - dec);
    const noonAltRad = (noonAlt * Math.PI) / 180;
    const cotAlt = 1 + 1 / Math.tan(noonAltRad);
    const targetAlt = (Math.atan(1 / cotAlt) * 180) / Math.PI;
    const cosH =
      (Math.sin((targetAlt * Math.PI) / 180) -
        Math.sin(latRad) * Math.sin(decRad)) /
      (Math.cos(latRad) * Math.cos(decRad));
    if (cosH > 1) return 0;
    if (cosH < -1) return 12;
    return (Math.acos(cosH) * 180) / Math.PI / 15;
  };

  // Tunisia convention: Fajr 18°, Isha 18°
  const fajrH = hourAngle(18);
  const sunriseH = hourAngle(0.833);
  const asrH = asrAngle();
  const maghribH = hourAngle(0.833);
  const ishaH = hourAngle(18);

  const makeDate = (hoursFraction: number): Date => {
    const result = new Date(date);
    const totalMinutes = Math.round(hoursFraction * 60);
    const h = Math.floor(totalMinutes / 60) % 24;
    const m = totalMinutes % 60;
    result.setHours(h, m, 0, 0);
    return result;
  };

  return {
    fajr: makeDate(noonHours - fajrH),
    sunrise: makeDate(noonHours - sunriseH),
    dhuhr: makeDate(noonHours),
    asr: makeDate(noonHours + asrH),
    maghrib: makeDate(noonHours + maghribH),
    isha: makeDate(noonHours + ishaH),
  };
}

export function formatPrayerTime(d: Date): string {
  return d.toLocaleTimeString('ar-TN', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false,
  });
}

export interface EscalatingAlarmSchedule {
  prayerId: string;
  prayerNameAr: string;
  baseTime: Date;
  alarms: {
    id: number;
    delayMinutes: number;
    triggerTime: Date;
    stage: number;
    label: string;
  }[];
}

export function createEscalatingAlarmSchedule(
  prayerId: string,
  prayerNameAr: string,
  baseTime: Date
): EscalatingAlarmSchedule {
  return {
    prayerId,
    prayerNameAr,
    baseTime,
    alarms: [
      {
        id: 101,
        delayMinutes: 0,
        triggerTime: new Date(baseTime.getTime() + 0 * 60000),
        stage: 1,
        label: 'الرنين الأول: تنبيه وقت الصلاة والحفظ',
      },
      {
        id: 102,
        delayMinutes: 5,
        triggerTime: new Date(baseTime.getTime() + 5 * 60000),
        stage: 2,
        label: 'الرنين الثاني: تذكير متصاعد (+5 دقائق)',
      },
      {
        id: 103,
        delayMinutes: 10,
        triggerTime: new Date(baseTime.getTime() + 10 * 60000),
        stage: 3,
        label: 'الرنين الثالث: نداء ملح للقيام (+10 دقائق)',
      },
      {
        id: 104,
        delayMinutes: 15,
        triggerTime: new Date(baseTime.getTime() + 15 * 60000),
        stage: 4,
        label: 'الإنذار الأخير الأقصى: إيقاف عبر إنجاز الحفظ فقط',
      },
    ],
  };
}

export const INITIAL_PRAYER_ALARMS: PrayerAlarmItem[] = [
  {
    id: 'fajr',
    prayerNameAr: 'الفجر',
    prayerNameEn: 'Fajr',
    time: '05:12',
    timestamp: new Date(),
    isAlarmEnabled: true,
    targetVersesDescription: 'سورة البقرة • الآيات (1 - 5) [حفظ جديد]',
    escalationIds: [101, 102, 103, 104],
  },
  {
    id: 'dhuhr',
    prayerNameAr: 'الظهر',
    prayerNameEn: 'Dhuhr',
    time: '12:28',
    timestamp: new Date(),
    isAlarmEnabled: false,
    targetVersesDescription: 'سورة البقرة • مراجعة ورد الصباح',
    escalationIds: [101, 102, 103, 104],
  },
  {
    id: 'asr',
    prayerNameAr: 'العصر',
    prayerNameEn: 'Asr',
    time: '15:35',
    timestamp: new Date(),
    isAlarmEnabled: true,
    targetVersesDescription: 'سورة البقرة • الآيات (6 - 10) [ربط وتثبيت]',
    escalationIds: [101, 102, 103, 104],
  },
  {
    id: 'maghrib',
    prayerNameAr: 'المغرب',
    prayerNameEn: 'Maghrib',
    time: '18:15',
    timestamp: new Date(),
    isAlarmEnabled: false,
    targetVersesDescription: 'أذكار المساء وسماع تلاوة قالون',
    escalationIds: [101, 102, 103, 104],
  },
  {
    id: 'isha',
    prayerNameAr: 'العشاء',
    prayerNameEn: 'Isha',
    time: '19:42',
    timestamp: new Date(),
    isAlarmEnabled: true,
    targetVersesDescription: 'مراجعة الثمن الكامل قبل النوم',
    escalationIds: [101, 102, 103, 104],
  },
];
