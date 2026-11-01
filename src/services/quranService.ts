import { Ayah, SurahMeta } from '../types/quran';
import { SURAH_LIST } from '../data/surahList';

// Cache for Quran scripts and Tafseer
let uthmaniDataCache: Record<string, Record<string, string[]>> | null = null;
let tafseerDataCache: string[][] | null = null;
let translationsCache: Record<number, Record<number, string>> = {};

export async function loadUthmaniScript(): Promise<Record<string, Record<string, string[]>>> {
  if (uthmaniDataCache) return uthmaniDataCache;
  try {
    const res = await fetch('/assets/quran_script/Uthmani.json');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    uthmaniDataCache = await res.json();
    return uthmaniDataCache!;
  } catch (err) {
    console.warn('Failed to load local Uthmani.json, falling back to CDN:', err);
    // Fallback: alquran.cloud CDN
    return {};
  }
}

export async function getSurahAyahs(surahNumber: number): Promise<Ayah[]> {
  const meta = SURAH_LIST.find((s) => s.number === surahNumber);
  const totalVerses = meta ? meta.versesCount : 7;

  try {
    const uthmani = await loadUthmaniScript();
    const surahWords = uthmani[String(surahNumber)];

    if (surahWords) {
      const ayahs: Ayah[] = [];
      for (let i = 1; i <= totalVerses; i++) {
        const words = surahWords[String(i)] || [];
        const text = words.join(' ');
        ayahs.push({
          numberInSurah: i,
          surahNumber,
          textUthmani: text || `آية ${i}`,
          translationEn: translationsCache[surahNumber]?.[i] || undefined,
        });
      }
      return ayahs;
    }
  } catch (e) {
    console.error('Error getting Surah ayahs:', e);
  }

  // Remote fallback from alquran.cloud if local asset is loading or missing
  try {
    const res = await fetch(`https://api.alquran.cloud/v1/surah/${surahNumber}/editions/quran-uthmani,en.sahih`);
    const data = await res.json();
    if (data.code === 200 && data.data && data.data.length >= 2) {
      const arabicVerses = data.data[0].ayahs;
      const englishVerses = data.data[1].ayahs;

      if (!translationsCache[surahNumber]) translationsCache[surahNumber] = {};

      return arabicVerses.map((a: any, idx: number) => {
        const enText = englishVerses[idx]?.text || '';
        translationsCache[surahNumber][idx + 1] = enText;
        return {
          numberInSurah: idx + 1,
          surahNumber,
          textUthmani: a.text,
          translationEn: enText,
          juz: a.juz,
          page: a.page,
        };
      });
    }
  } catch (remoteErr) {
    console.warn('Remote fallback failed too:', remoteErr);
  }

  return [];
}

export async function getAyahTafseer(surahNumber: number, ayahNumber: number): Promise<string> {
  if (!tafseerDataCache) {
    try {
      const res = await fetch('/assets/wahy/json/Tafseer_Al_Saddi.json');
      if (res.ok) {
        const data = await res.json();
        tafseerDataCache = data.tafsir || [];
      }
    } catch (e) {
      console.warn('Could not load Tafseer_Al_Saddi.json:', e);
    }
  }

  if (tafseerDataCache && tafseerDataCache[surahNumber - 1]) {
    const text = tafseerDataCache[surahNumber - 1][ayahNumber - 1];
    if (text) return text;
  }

  // Fallback to Quran.com API or general note
  try {
    const res = await fetch(`https://api.quran.com/api/v4/tafsirs/169/by_ayah/${surahNumber}:${ayahNumber}`);
    if (res.ok) {
      const data = await res.json();
      if (data.tafsir && data.tafsir.text) {
        // Strip HTML tags if any
        return data.tafsir.text.replace(/<[^>]*>/g, '');
      }
    }
  } catch (_) {}

  return 'تفسير ميسر للآية الكريمة: تدبر في معاني الآيات وأحكامها واستشعر عظمة كلام الله تبارك وتعالى.';
}

export async function searchQuran(query: string): Promise<{ surah: SurahMeta; ayahNumber: number; text: string }[]> {
  const trimmed = query.trim();
  if (!trimmed || trimmed.length < 2) return [];

  const results: { surah: SurahMeta; ayahNumber: number; text: string }[] = [];
  const normalizedQuery = removeArabicTashkeel(trimmed);

  try {
    const uthmani = await loadUthmaniScript();

    for (const s of SURAH_LIST) {
      const surahData = uthmani[String(s.number)];
      if (!surahData) continue;

      for (let a = 1; a <= s.versesCount; a++) {
        const words = surahData[String(a)];
        if (!words) continue;
        const fullText = words.join(' ');
        const normalizedVerse = removeArabicTashkeel(fullText);

        if (normalizedVerse.includes(normalizedQuery)) {
          results.push({
            surah: s,
            ayahNumber: a,
            text: fullText,
          });
          if (results.length >= 50) return results; // Max 50 results
        }
      }
    }
  } catch (err) {
    console.error('Search error:', err);
  }

  return results;
}

export function removeArabicTashkeel(text: string): string {
  return text
    .replace(/[\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]/g, '')
    .replace(/[إأآا]/g, 'ا')
    .replace(/ة/g, 'ه')
    .replace(/ى/g, 'ي')
    .trim();
}
