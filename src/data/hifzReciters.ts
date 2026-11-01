import { HifzReciter, Riwayah } from '../types/hifz';

export const HIFZ_RECITERS: HifzReciter[] = [
  // --- HAFS ---
  {
    id: 'husary_muallim',
    nameAr: 'محمود خليل الحصري (المعلم)',
    nameEn: 'Al-Husary (Muallim)',
    riwayah: 'hafs',
    style: 'معلم مع الوقف',
    cdnPattern: 'https://everyayah.com/data/Husary_Muallim_128kbps/{surah:03d}{ayah:03d}.mp3',
  },
  {
    id: 'husary_murattal',
    nameAr: 'محمود خليل الحصري (مرتل)',
    nameEn: 'Al-Husary (Murattal)',
    riwayah: 'hafs',
    style: 'مرتل متمكن',
    cdnPattern: 'https://everyayah.com/data/Husary_128kbps/{surah:03d}{ayah:03d}.mp3',
  },
  {
    id: 'alafasy',
    nameAr: 'مشاري راشد العفاسي',
    nameEn: 'Mishary Rashid Alafasy',
    riwayah: 'hafs',
    style: 'مرتل واضح',
    cdnPattern: 'https://everyayah.com/data/Alafasy_128kbps/{surah:03d}{ayah:03d}.mp3',
  },
  {
    id: 'minshawy',
    nameAr: 'محمد صديق المنشاوي (مرتل)',
    nameEn: 'Al-Minshawy (Murattal)',
    riwayah: 'hafs',
    style: 'مرتل خاشع',
    cdnPattern: 'https://everyayah.com/data/Minshawy_Murattal_128kbps/{surah:03d}{ayah:03d}.mp3',
  },
  {
    id: 'ayman_sowaid',
    nameAr: 'أيمن سويد (تجويد تعليمي)',
    nameEn: 'Ayman Sowaid',
    riwayah: 'hafs',
    style: 'تجويد تعليمي دقيق',
    cdnPattern: 'https://everyayah.com/data/Ayman_Sowaid_64kbps/{surah:03d}{ayah:03d}.mp3',
  },

  // --- WARSH ---
  {
    id: 'warsh_ibrahim_aldosary',
    nameAr: 'إبراهيم الدوسري (ورش)',
    nameEn: 'Ibrahim Al-Dosary (Warsh)',
    riwayah: 'warsh',
    style: 'رواية ورش عن نافع',
    cdnPattern: 'https://everyayah.com/data/warsh/warsh_ibrahim_aldosary_128kbps/{surah:03d}{ayah:03d}.mp3',
  },
  {
    id: 'warsh_yassin_al_jazaery',
    nameAr: 'ياسين الجزائري (ورش)',
    nameEn: 'Yassin Al-Jazaery (Warsh)',
    riwayah: 'warsh',
    style: 'رواية ورش عن نافع',
    cdnPattern: 'https://everyayah.com/data/warsh/warsh_yassin_al_jazaery_64kbps/{surah:03d}{ayah:03d}.mp3',
  },
  {
    id: 'warsh_abdul_basit',
    nameAr: 'عبد الباسط عبد الصمد (ورش)',
    nameEn: 'Abdul Basit (Warsh)',
    riwayah: 'warsh',
    style: 'رواية ورش عن نافع',
    cdnPattern: 'https://everyayah.com/data/warsh/warsh_Abdul_Basit_128kbps/{surah:03d}{ayah:03d}.mp3',
  },

  // --- QALUN ---
  {
    id: 'qalun_ali_hudhaifi',
    nameAr: 'علي الحذيفي (قالون)',
    nameEn: 'Ali Al-Hudhaify (Qalun)',
    riwayah: 'qalun',
    style: 'رواية قالون عن نافع',
    cdnPattern: 'https://everyayah.com/data/Hudhaify_128kbps/{surah:03d}{ayah:03d}.mp3',
  },
  {
    id: 'qalun_husary',
    nameAr: 'محمود خليل الحصري (قالون)',
    nameEn: 'Al-Husary (Qalun)',
    riwayah: 'qalun',
    style: 'رواية قالون عن نافع',
    cdnPattern: 'https://everyayah.com/data/Husary_128kbps/{surah:03d}{ayah:03d}.mp3',
  },
  {
    id: 'qalun_dokali',
    nameAr: 'محمد العالم الدوكالي (قالون)',
    nameEn: 'Muhammad Al-Dokali (Qalun)',
    riwayah: 'qalun',
    style: 'رواية قالون عن نافع',
    cdnPattern: 'https://everyayah.com/data/Hudhaify_128kbps/{surah:03d}{ayah:03d}.mp3',
  },
];

export function getRecitersByRiwayah(riwayah: Riwayah): HifzReciter[] {
  return HIFZ_RECITERS.filter((r) => r.riwayah === riwayah);
}

export function buildAudioUrl(reciter: HifzReciter, surah: number, ayah: number): string {
  const surahPadded = String(surah).padStart(3, '0');
  const ayahPadded = String(ayah).padStart(3, '0');
  return reciter.cdnPattern
    .replace('{surah:03d}', surahPadded)
    .replace('{ayah:03d}', ayahPadded);
}

export function getFallbackAudioUrl(surah: number, ayah: number): string {
  const surahPadded = String(surah).padStart(3, '0');
  const ayahPadded = String(ayah).padStart(3, '0');
  // High-reliability EveryAyah fallback
  return `https://everyayah.com/data/Husary_Muallim_128kbps/${surahPadded}${ayahPadded}.mp3`;
}
