import { DhikrItem } from '../types/quran';

let azkarCache: DhikrItem[] | null = null;

const DEFAULT_AZKAR: DhikrItem[] = [
  {
    id: 1,
    category: 'أذكار الصباح',
    count: 1,
    description: 'من قالها حين يصبح أجير من الجن حتى يمسي ومن قالها حين يمسي أجير من الجن حتى يصبح',
    reference: 'آية الكرسي - البقرة 255',
    zekr: 'اللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
  },
  {
    id: 2,
    category: 'أذكار الصباح',
    count: 3,
    description: 'من قالها حين يصبح وحين يمسي كفته من كل شيء',
    reference: 'سورة الإخلاص والمعوذتين',
    zekr: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
  },
  {
    id: 3,
    category: 'أذكار الصباح',
    count: 1,
    description: 'سيد الاستغفار',
    reference: 'صحيح البخاري',
    zekr: 'اللَّهُمَّ أَنْتَ رَبِّي لا إِلَهَ إِلا أَنْتَ ، خَلَقْتَنِي وَأَنَا عَبْدُكَ ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي ، فَإِنَّهُ لا يَغْفِرُ الذُّنُوبَ إِلا أَنْتَ',
  },
  {
    id: 4,
    category: 'أذكار الصباح',
    count: 3,
    description: 'لم يضره شيء في ذلك اليوم',
    reference: 'سنن أبي داود والترمذي',
    zekr: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
  },
  {
    id: 5,
    category: 'أذكار المساء',
    count: 1,
    description: 'حفظه الله من كل سوء',
    reference: 'صحيح مسلم',
    zekr: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
  },
  {
    id: 6,
    category: 'أذكار بعد الصلاة',
    count: 33,
    description: 'تسبیح بعد الصلاة المكتوبة',
    reference: 'صحيح مسلم',
    zekr: 'سُبْحَانَ اللَّهِ',
  },
  {
    id: 7,
    category: 'أذكار بعد الصلاة',
    count: 33,
    description: 'تحميد بعد الصلاة المكتوبة',
    reference: 'صحيح مسلم',
    zekr: 'الْحَمْدُ لِلَّهِ',
  },
  {
    id: 8,
    category: 'أذكار بعد الصلاة',
    count: 33,
    description: 'تكبير بعد الصلاة المكتوبة',
    reference: 'صحيح مسلم',
    zekr: 'اللَّهُ أَكْبَرُ',
  },
  {
    id: 9,
    category: 'أذكار النوم',
    count: 1,
    description: 'آية الكرسي قبل النوم',
    reference: 'صحيح البخاري',
    zekr: 'اللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ',
  },
  {
    id: 10,
    category: 'أذكار النوم',
    count: 1,
    description: 'دعاء النوم',
    reference: 'صحيح البخاري',
    zekr: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
  },
  {
    id: 11,
    category: 'أدعية نبوية',
    count: 100,
    description: 'حطت خطاياه وإن كانت مثل زبد البحر',
    reference: 'صحيح البخاري',
    zekr: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
  },
  {
    id: 12,
    category: 'أدعية نبوية',
    count: 10,
    description: 'الصلاة على النبي ﷺ ترفع الدرجات وتكفر السيئات',
    reference: 'الترمذي',
    zekr: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
  },
];

export async function loadAzkar(): Promise<DhikrItem[]> {
  if (azkarCache) return azkarCache;
  try {
    const res = await fetch('/assets/wahy/json/azkar.json');
    if (!res.ok) throw new Error('Failed to fetch azkar.json');
    const json = await res.json();
    if (json.data && Array.isArray(json.data)) {
      azkarCache = json.data.map((item: any) => ({
        id: item.id,
        category: item.category || 'أذكار عامة',
        count: parseInt(item.count, 10) || 1,
        description: item.description || '',
        reference: item.reference || '',
        zekr: item.zekr || '',
      }));
      return azkarCache!;
    }
  } catch (e) {
    console.warn('Using default azkar list:', e);
  }

  azkarCache = DEFAULT_AZKAR;
  return azkarCache;
}

export function getCategories(items: DhikrItem[]): string[] {
  const set = new Set<string>();
  items.forEach((i) => set.add(i.category));
  return Array.from(set);
}
