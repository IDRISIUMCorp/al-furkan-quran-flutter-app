import { Reciter } from '../types/quran';

export const RECITERS: Reciter[] = [
  {
    id: 'alafasy',
    nameAr: 'مشاري راشد العفاسي',
    nameEn: 'Mishary Rashid Alafasy',
    style: 'مرتل',
    subfolder: 'Alafasy_128kbps',
    format: 'mp3',
    bitrate: '128kbps',
  },
  {
    id: 'abdul_basit',
    nameAr: 'عبد الباسط عبد الصمد',
    nameEn: 'Abdul Basit Abdus Samad',
    style: 'مرتل',
    subfolder: 'Abdul_Basit_Murattal_192kbps',
    format: 'mp3',
    bitrate: '192kbps',
  },
  {
    id: 'husary',
    nameAr: 'محمود خليل الحصري',
    nameEn: 'Mahmoud Khalil Al-Husary',
    style: 'مرتل',
    subfolder: 'Husary_128kbps',
    format: 'mp3',
    bitrate: '128kbps',
  },
  {
    id: 'minshawy',
    nameAr: 'محمد صديق المنشاوي',
    nameEn: 'Mohamed Siddiq Al-Minshawi',
    style: 'مرتل',
    subfolder: 'Minshawy_Murattal_128kbps',
    format: 'mp3',
    bitrate: '128kbps',
  },
  {
    id: 'muaiqly',
    nameAr: 'ماهر المعيقلي',
    nameEn: 'Maher Al-Muaiqly',
    style: 'مرتل',
    subfolder: 'MaherAlMuaiqly128kbps',
    format: 'mp3',
    bitrate: '128kbps',
  },
  {
    id: 'ghamadi',
    nameAr: 'سعد الغامدي',
    nameEn: 'Saad Al-Ghamdi',
    style: 'مرتل',
    subfolder: 'Ghamadi_40kbps',
    format: 'mp3',
    bitrate: '40kbps',
  },
  {
    id: 'sudais',
    nameAr: 'عبد الرحمن السديس',
    nameEn: 'Abdur-Rahman As-Sudais',
    style: 'مرتل',
    subfolder: 'Abdurrahmaan_As-Sudais_192kbps',
    format: 'mp3',
    bitrate: '192kbps',
  },
  {
    id: 'shatri',
    nameAr: 'أبو بكر الشاطري',
    nameEn: 'Abu Bakr Al-Shatri',
    style: 'مرتل',
    subfolder: 'Abu_Bakr_Ash-Shaatree_128kbps',
    format: 'mp3',
    bitrate: '128kbps',
  },
];

export function getAyahAudioUrl(reciterSubfolder: string, surah: number, ayah: number): string {
  const surahPadded = String(surah).padStart(3, '0');
  const ayahPadded = String(ayah).padStart(3, '0');
  return `https://everyayah.com/data/${reciterSubfolder}/${surahPadded}${ayahPadded}.mp3`;
}
