import { Ayah, SurahMeta } from '../types/quran';
import { Riwayah } from '../types/hifz';
import { SURAH_LIST } from '../data/surahList';

// Cache for Quran scripts and Tafseer
const scriptCaches: Record<Riwayah, Record<string, Record<string, string[]>> | null> = {
  hafs: null,
  warsh: null,
  qalun: null,
};
let tafseerDataCache: string[][] | null = null;
let translationsCache: Record<number, Record<number, string>> = {};

export async function loadRiwayahScript(riwayah: Riwayah = 'hafs'): Promise<Record<string, Record<string, string[]>>> {
  if (scriptCaches[riwayah]) return scriptCaches[riwayah]!;

  const fileMap: Record<Riwayah, string> = {
    hafs: '/assets/quran_script/Uthmani.json',
    warsh: '/assets/quran_script/Warsh.json',
    qalun: '/assets/quran_script/Qalun.json',
  };

  const filePath = fileMap[riwayah] || fileMap.hafs;

  try {
    const res = await fetch(filePath);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();
    scriptCaches[riwayah] = data;
    return data;
  } catch (err) {
    console.warn(`Failed to load ${filePath}, attempting fallback:`, err);
    // If Warsh/Qalun fail, fallback to Hafs if available
    if (riwayah !== 'hafs' && scriptCaches.hafs) {
      return scriptCaches.hafs!;
    }
    return {};
  }
}

// Backward-compatible export
export async function loadUthmaniScript(): Promise<Record<string, Record<string, string[]>>> {
  return loadRiwayahScript('hafs');
}

export async function getSurahAyahs(surahNumber: number, riwayah: Riwayah = 'hafs'): Promise<Ayah[]> {
  const meta = SURAH_LIST.find((s) => s.number === surahNumber);
  const defaultTotalVerses = meta ? meta.versesCount : 7;

  try {
    const script = await loadRiwayahScript(riwayah);
    const surahWords = script[String(surahNumber)];

    if (surahWords) {
      const keys = Object.keys(surahWords).map(Number).filter((n) => !isNaN(n));
      const totalVerses = keys.length > 0 ? Math.max(...keys) : defaultTotalVerses;

      const ayahs: Ayah[] = [];
      for (let i = 1; i <= totalVerses; i++) {
        const words = surahWords[String(i)] || [];
        const text = words.join(' ');
        if (text || i <= defaultTotalVerses) {
          ayahs.push({
            numberInSurah: i,
            surahNumber,
            textUthmani: text || `آية ${i}`,
            translationEn: translationsCache[surahNumber]?.[i] || undefined,
          });
        }
      }
      if (ayahs.length > 0) return ayahs;
    }
  } catch (e) {
    console.error(`Error getting Surah ${surahNumber} ayahs for riwayah ${riwayah}:`, e);
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
