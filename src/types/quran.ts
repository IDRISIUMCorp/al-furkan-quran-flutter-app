export interface SurahMeta {
  number: number;
  nameAr: string;
  nameEn: string;
  nameTranslation: string;
  versesCount: number;
  revelationType: 'Meccan' | 'Medinan';
  revelationOrder: number;
  juzStart: number;
  pageStart: number;
}

export interface Ayah {
  numberInSurah: number;
  surahNumber: number;
  textUthmani: string;
  textIndoPak?: string;
  translationEn?: string;
  juz?: number;
  page?: number;
  sajda?: boolean;
}

export interface Reciter {
  id: string;
  nameAr: string;
  nameEn: string;
  style: string;
  subfolder: string;
  format: 'mp3';
  bitrate: string;
}

export interface PrayerTimeItem {
  id: string;
  nameAr: string;
  nameEn: string;
  time: string;
  timestamp: Date;
  isNext: boolean;
  iconName: string;
}

export interface DhikrItem {
  id: number;
  category: string;
  count: number;
  currentCount?: number;
  description: string;
  reference: string;
  zekr: string;
  completed?: boolean;
}

export interface Bookmark {
  id: string;
  surahNumber: number;
  surahNameAr: string;
  ayahNumber: number;
  textSnippet: string;
  createdAt: number;
  note?: string;
}

export interface KhatmaPlan {
  targetDays: number;
  startDate: string;
  completedPages: number[];
  completedJuz: number[];
  lastReadSurah: number;
  lastReadAyah: number;
}
