// معلومات تفصيلية عن موارد القرآن (التفاسير والترجمات)
// تحتوي على المؤلف، المصدر، الوصف لكل مورد

class ResourceMetadata {
  final String author;
  final String source;
  final String description;

  const ResourceMetadata({
    required this.author,
    required this.source,
    required this.description,
  });
}

/// معلومات التفاسير العربية
final Map<String, ResourceMetadata> tafsirMetadata = {
  // التفاسير العربية
  "تفسير السعدي": ResourceMetadata(
    author: "عبد الرحمن بن ناصر السعدي (المتوفى 1376هـ)",
    source: "تيسير الكريم الرحمن في تفسير كلام المنان",
    description: "تفسير مختصر وواضح يجمع بين السهولة والعمق",
  ),
  "التفسير الميسر": ResourceMetadata(
    author: "مجمع الملك فهد لطباعة المصحف الشريف",
    source: "المدينة المنورة، المملكة العربية السعودية",
    description: "تفسير مبسط وسهل الفهم صادر عن مجمع الملك فهد",
  ),
  "تفسير ابن كثير": ResourceMetadata(
    author: "إسماعيل بن عمر بن كثير (المتوفى 774هـ)",
    source: "تفسير القرآن العظيم",
    description: "من أشهر التفاسير بالمأثور، يعتمد على الأحاديث والآثار",
  ),
  "تفسير الطبري": ResourceMetadata(
    author: "محمد بن جرير الطبري (المتوفى 310هـ)",
    source: "جامع البيان في تأويل القرآن",
    description: "أول تفسير شامل للقرآن، يجمع أقوال السلف",
  ),
  "تفسير القرطبي": ResourceMetadata(
    author: "محمد بن أحمد القرطبي (المتوفى 671هـ)",
    source: "الجامع لأحكام القرآن",
    description: "تفسير يركز على الأحكام الفقهية المستنبطة من الآيات",
  ),
  "تفسير البغوي": ResourceMetadata(
    author: "الحسين بن مسعود البغوي (المتوفى 516هـ)",
    source: "معالم التنزيل في تفسير القرآن",
    description: "تفسير معتدل يجمع بين التفسير بالمأثور والرأي",
  ),
  "التفسير الوسيط": ResourceMetadata(
    author: "مجموعة من العلماء",
    source: "مجمع البحوث الإسلامية بالأزهر",
    description: "تفسير معاصر يجمع بين الأصالة والمعاصرة",
  ),
  "المختصر في تفسير القرآن الكريم": ResourceMetadata(
    author: "مركز تفسير للدراسات القرآنية",
    source: "الرياض، المملكة العربية السعودية",
    description: "تفسير مختصر معاصر يجمع أقوال المفسرين",
  ),
  "السراج في بيان غريب القرآن": ResourceMetadata(
    author: "محمد بن عبد العزيز الخضيري",
    source: "دار ابن الجوزي",
    description: "تفسير يركز على شرح الكلمات الغريبة في القرآن",
  ),
  "تفسير تنوير المقباس": ResourceMetadata(
    author: "عبد الله بن عباس (منسوب إليه)",
    source: "تنوير المقباس من تفسير ابن عباس",
    description: "تفسير مختصر منسوب لابن عباس رضي الله عنهما",
  ),

  // التفاسير الإنجليزية
  "Tafsir Ibn Kathir (Abridged)": ResourceMetadata(
    author: "Ismail ibn Kathir (d. 774 AH)",
    source: "Tafsir al-Quran al-Azim (Abridged)",
    description: "Renowned classical tafsir focusing on Quranic verses and hadith",
  ),
  "Tazkirul Quran (Maulana Wahiduddin Khan)": ResourceMetadata(
    author: "Maulana Wahiduddin Khan",
    source: "Goodword Books",
    description: "Contemporary tafsir emphasizing spiritual and practical guidance",
  ),
  "Maarif-ul-Quran": ResourceMetadata(
    author: "Mufti Muhammad Shafi (d. 1976)",
    source: "Maariful Quran",
    description: "Comprehensive tafsir covering jurisprudence and spiritual insights",
  ),
  "Al-Mukhtasar": ResourceMetadata(
    author: "Tafsir Center for Quranic Studies",
    source: "Riyadh, Saudi Arabia",
    description: "Concise modern tafsir summarizing classical interpretations",
  ),

  // التفاسير الأردية
  "فی ظلال القرآن": ResourceMetadata(
    author: "سید قطب شہید (متوفی 1966ء)",
    source: "فی ظلال القرآن",
    description: "تفسیر عصری جو قرآن کی روحانی اور عملی تعلیمات پر زور دیتی ہے",
  ),
  "تفسیر بیان القرآن": ResourceMetadata(
    author: "اشرف علی تھانوی (متوفی 1943ء)",
    source: "بیان القرآن",
    description: "سادہ اور آسان اردو تفسیر",
  ),
  "تفسیر السعدی - اردو": ResourceMetadata(
    author: "عبد الرحمن بن ناصر السعدی (متوفی 1376ھ)",
    source: "تیسیر الکریم الرحمن - اردو ترجمہ",
    description: "تفسیر سعدی کا اردو ترجمہ",
  ),
  "تذکیر القرآن (مولانا وحید الدین خان)": ResourceMetadata(
    author: "مولانا وحید الدین خان",
    source: "گڈورڈ بکس",
    description: "عصری تفسیر جو روحانی اور عملی رہنمائی پر زور دیتی ہے",
  ),

  // التفاسير الفارسية
  "المختصر فی تفسیر قرآن کریم": ResourceMetadata(
    author: "مرکز تفسیر برای مطالعات قرآنی",
    source: "ریاض، عربستان سعودی",
    description: "تفسیر مختصر معاصر که تفاسیر کلاسیک را خلاصه می‌کند",
  ),

  // التفاسير البنغالية
  "তাফসীর ফাতহুল মাজীদ": ResourceMetadata(
    author: "আব্দুল্লাহ আল মাহমুদ",
    source: "ফাতহুল মাজীদ",
    description: "বাংলা ভাষায় সহজ ও বিস্তারিত তাফসীর",
  ),
  "তাফসীর ইবনে কাসীর": ResourceMetadata(
    author: "ইসমাঈল ইবনে কাসীর (মৃত্যু ৭৭৪ হিজরী)",
    source: "তাফসীরুল কুরআনিল আযীম - বাংলা অনুবাদ",
    description: "বিখ্যাত ক্লাসিক্যাল তাফসীরের বাংলা অনুবাদ",
  ),
  "তাফসীর আবু বকর যাকারিয়া": ResourceMetadata(
    author: "আবু বকর মুহাম্মাদ যাকারিয়া",
    source: "তাফসীর আবু বকর যাকারিয়া",
    description: "সহজ বাংলায় কুরআনের ব্যাখ্যা",
  ),
  "কুরআনের সংক্ষিপ্ত ব্যাখ্যা": ResourceMetadata(
    author: "তাফসীর কেন্দ্র",
    source: "রিয়াদ, সৌদি আরব",
    description: "সংক্ষিপ্ত আধুনিক তাফসীর",
  ),
  "তাফসীর আহসানুল বায়ান": ResourceMetadata(
    author: "সালাহউদ্দীন ইউসুফ",
    source: "আহসানুল বায়ান",
    description: "সহজ ও প্রাঞ্জল বাংলা তাফসীর",
  ),

  // التفاسير الروسية
  "Тафсир Ас-Саади": ResourceMetadata(
    author: "Абдуррахман ибн Насир ас-Саади (ум. 1376 г.х.)",
    source: "Тайсир аль-Карим ар-Рахман - русский перевод",
    description: "Краткий и ясный тафсир на русском языке",
  ),
  "Тафсир Аль-Мухтасар": ResourceMetadata(
    author: "Центр тафсира",
    source: "Эр-Рияд, Саудовская Аравия",
    description: "Краткий современный тафсир",
  ),
  "Тафсир Ибн Касира": ResourceMetadata(
    author: "Исмаил ибн Касир (ум. 774 г.х.)",
    source: "Тафсир аль-Куран аль-Азым - русский перевод",
    description: "Известный классический тафсир на русском",
  ),

  // التفاسير التركية
  "Muhtasar Kur'an-ı Kerim Tefsiri": ResourceMetadata(
    author: "Tefsir Merkezi",
    source: "Riyad, Suudi Arabistan",
    description: "Kısa ve öz modern tefsir",
  ),

  // التفاسير الإندونيسية
  "Tafsir Al-Mukhtasar": ResourceMetadata(
    author: "Pusat Tafsir untuk Studi Al-Quran",
    source: "Riyadh, Arab Saudi",
    description: "Tafsir ringkas modern yang merangkum tafsir klasik",
  ),

  // التفاسير الأخرى
  "Skraćeno tumačenje Kur'ana": ResourceMetadata(
    author: "Centar za tefsir",
    source: "Rijad, Saudijska Arabija",
    description: "Kratko savremeno tumačenje Kur'ana",
  ),
  "Explicación Abreviada del Corán": ResourceMetadata(
    author: "Centro de Tafsir",
    source: "Riad, Arabia Saudita",
    description: "Explicación concisa y moderna del Corán",
  ),
  "Al-Mukhtasar nell'interpretazione del Nobile Corano": ResourceMetadata(
    author: "Centro di Tafsir",
    source: "Riyadh, Arabia Saudita",
    description: "Interpretazione concisa e moderna del Corano",
  ),
  "古兰经简明注解": ResourceMetadata(
    author: "古兰经研究中心",
    source: "利雅得，沙特阿拉伯",
    description: "简明现代古兰经注释",
  ),
  "تەفسیری کوردی ڕێبەر": ResourceMetadata(
    author: "ناوەندی تەفسیر",
    source: "ڕیاز، عەرەبستانی سەعوودی",
    description: "تەفسیری کورت و مۆدێرن",
  ),
  "ഖുർആനിന്റെ സംക്ഷിപ്ത വിശദീകരണം": ResourceMetadata(
    author: "തഫ്സീർ കേന്ദ്രം",
    source: "റിയാദ്, സൗദി അറേബ്യ",
    description: "സംക്ഷിപ്തവും ആധുനികവുമായ തഫ്സീർ",
  ),
  "Explication Abrégée du Coran": ResourceMetadata(
    author: "Centre de Tafsir",
    source: "Riyad, Arabie Saoudite",
    description: "Explication concise et moderne du Coran",
  ),
  "অসমীয়া কোৰআনৰ সংক্ষিপ্ত ব্যাখ্যা": ResourceMetadata(
    author: "তাফছীৰ কেন্দ্ৰ",
    source: "ৰিয়াদ, চৌদি আৰব",
    description: "সংক্ষিপ্ত আধুনিক তাফছীৰ",
  ),
  "簡約クルアーン解説": ResourceMetadata(
    author: "タフスィールセンター",
    source: "リヤド、サウジアラビア",
    description: "簡潔で現代的なクルアーン解説",
  ),
  "Al-Mukhtasar sa Pagpapaliwanag ng Banal na Quran": ResourceMetadata(
    author: "Tafsir Center",
    source: "Riyadh, Saudi Arabia",
    description: "Maikling modernong paliwanag ng Quran",
  ),
  "Tafsir Al-Mukhtasar (Vietnamese)": ResourceMetadata(
    author: "Pusat Tafsir",
    source: "Riyadh, Arab Saudi",
    description: "Tafsir ringkas moden",
  ),
  "Tefsiri i Sadit": ResourceMetadata(
    author: "Abdurrahman ibn Nasir as-Saadi (v. 1376 h.)",
    source: "Tejsir el-Kerim er-Rahman - përkthim shqip",
    description: "Tefsir i shkurtër dhe i qartë",
  ),
  "ការពន្យល់ដោយសង្ខេបនៃគម្ពីរកូរ៉ាន": ResourceMetadata(
    author: "មជ្ឈមណ្ឌលតាហ្វសៀរ",
    source: "រីយ៉ាដ ប្រទេសអារ៉ាប៊ីសាអូឌីត",
    description: "ការពន្យល់សង្ខេបនិងទំនើប",
  ),
};

/// معلومات الترجمات
final Map<String, ResourceMetadata> translationMetadata = {
  // الترجمات العربية (للمقارنة)
  "المصحف المفسر": ResourceMetadata(
    author: "مجموعة من العلماء",
    source: "مجمع الملك فهد",
    description: "ترجمة تفسيرية للمعاني",
  ),

  // الترجمات الإنجليزية
  "Sahih International": ResourceMetadata(
    author: "Saheeh International",
    source: "Abul-Qasim Publishing House",
    description: "Clear and accurate modern English translation",
  ),
  "Dr. Mustafa Khattab": ResourceMetadata(
    author: "Dr. Mustafa Khattab",
    source: "The Clear Quran",
    description: "Contemporary English translation with clarity",
  ),
  "Pickthall": ResourceMetadata(
    author: "Mohammed Marmaduke Pickthall (d. 1936)",
    source: "The Meaning of the Glorious Quran",
    description: "Classic English translation by British Muslim scholar",
  ),
  "Yusuf Ali": ResourceMetadata(
    author: "Abdullah Yusuf Ali (d. 1953)",
    source: "The Holy Quran: Text, Translation and Commentary",
    description: "Well-known English translation with extensive notes",
  ),

  // الترجمات الأردية
  "احمد رضا خان": ResourceMetadata(
    author: "احمد رضا خان بریلوی (متوفی 1921ء)",
    source: "کنز الایمان",
    description: "مشہور اردو ترجمہ",
  ),
  "فتح محمد جالندھری": ResourceMetadata(
    author: "فتح محمد جالندھری (متوفی 1988ء)",
    source: "ترجمہ جالندھری",
    description: "سادہ اور آسان اردو ترجمہ",
  ),
  "محمد جوناگڑھی": ResourceMetadata(
    author: "محمد جوناگڑھی",
    source: "ترجمہ جوناگڑھی",
    description: "واضح اردو ترجمہ",
  ),

  // الترجمات الفارسية
  "حسین انصاریان": ResourceMetadata(
    author: "حسین انصاریان",
    source: "ترجمه انصاریان",
    description: "ترجمه فارسی معاصر",
  ),
  "مهدی الهی قمشه‌ای": ResourceMetadata(
    author: "مهدی الهی قمشه‌ای",
    source: "ترجمه الهی قمشه‌ای",
    description: "ترجمه فارسی روان",
  ),

  // الترجمات البنغالية
  "মুহিউদ্দীন খান": ResourceMetadata(
    author: "মুহিউদ্দীন খান",
    source: "তাফহীমুল কুরআন বাংলা",
    description: "জনপ্রিয় বাংলা অনুবাদ",
  ),
  "তাফসীরুল কুরআন": ResourceMetadata(
    author: "আবু বকর যাকারিয়া",
    source: "তাফসীরুল কুরআন",
    description: "সহজ বাংলা অনুবাদ",
  ),

  // الترجمات الإندونيسية
  "Kementerian Agama": ResourceMetadata(
    author: "Kementerian Agama Republik Indonesia",
    source: "Al-Quran dan Terjemahnya",
    description: "Terjemahan resmi pemerintah Indonesia",
  ),

  // الترجمات التركية
  "Diyanet İşleri": ResourceMetadata(
    author: "Diyanet İşleri Başkanlığı",
    source: "Kur'an-ı Kerim Meali",
    description: "Resmi Türkçe meal",
  ),
  "Süleyman Ateş": ResourceMetadata(
    author: "Süleyman Ateş",
    source: "Kur'an-ı Kerim ve Yüce Meali",
    description: "Modern Türkçe meal",
  ),

  // الترجمات الماليزية
  "Abdullah Muhammad Basmeih": ResourceMetadata(
    author: "Abdullah Muhammad Basmeih",
    source: "Tafsir Pimpinan Ar-Rahman",
    description: "Terjemahan Melayu yang popular",
  ),

  // الترجمات الفرنسية
  "Muhammad Hamidullah": ResourceMetadata(
    author: "Muhammad Hamidullah (d. 2002)",
    source: "Le Saint Coran",
    description: "Traduction française de référence",
  ),

  // الترجمات الروسية
  "Эльмир Кулиев": ResourceMetadata(
    author: "Эльмир Кулиев",
    source: "Смысловой перевод Корана",
    description: "Современный русский перевод",
  ),
  "Иман Валерия Порохова": ResourceMetadata(
    author: "Иман Валерия Порохова",
    source: "Коран: перевод смыслов",
    description: "Литературный русский перевод",
  ),

  // الترجمات الإسبانية
  "Abdel Ghani Navio": ResourceMetadata(
    author: "Abdel Ghani Navio",
    source: "El Corán",
    description: "Traducción española clara",
  ),

  // الترجمات الألمانية
  "Frank Bubenheim": ResourceMetadata(
    author: "Frank Bubenheim & Nadeem Elyas",
    source: "Der edle Quran",
    description: "Deutsche Übersetzung",
  ),

  // الترجمات الصينية
  "马坚": ResourceMetadata(
    author: "马坚 (1906-1978)",
    source: "古兰经中文译解",
    description: "著名中文翻译",
  ),

  // الترجمات اليابانية
  "日本ムスリム協会": ResourceMetadata(
    author: "日本ムスリム協会",
    source: "聖クルアーン",
    description: "日本語翻訳",
  ),

  // الترجمات الكورية
  "최영길": ResourceMetadata(
    author: "최영길",
    source: "성 꾸란 의미의 한국어 번역",
    description: "한국어 번역",
  ),

  // الترجمات الفيتنامية
  "Hasan Basri": ResourceMetadata(
    author: "Hasan Basri",
    source: "Kinh Qur'an",
    description: "Bản dịch tiếng Việt",
  ),

  // الترجمات التاميلية
  "ஜான் டிரஸ்ட்": ResourceMetadata(
    author: "ஜான் டிரஸ்ட்",
    source: "திருக்குர்ஆன்",
    description: "தமிழ் மொழிபெயர்ப்பு",
  ),

  // الترجمات السواحيلية
  "Ali Muhsin Al-Barwani": ResourceMetadata(
    author: "Ali Muhsin Al-Barwani",
    source: "Qurani Tukufu",
    description: "Tafsiri ya Kiswahili",
  ),

  // الترجمات الأذرية
  "Vasim Məmmədəliyev": ResourceMetadata(
    author: "Vasim Məmmədəliyev və Ziya Bünyadov",
    source: "Qurani-Kərim",
    description: "Azərbaycan dilində tərcümə",
  ),

  // الترجمات الكازاخية
  "Халифа Алтай": ResourceMetadata(
    author: "Халифа Алтай",
    source: "Құран Кәрім",
    description: "Қазақ тіліндегі аударма",
  ),

  // الترجمات البنجابية
  "ਮੁਹੰਮਦ ਜੁਨਾਗੜੀ": ResourceMetadata(
    author: "ਮੁਹੰਮਦ ਜੁਨਾਗੜੀ",
    source: "ਪਵਿੱਤਰ ਕੁਰਾਨ",
    description: "ਪੰਜਾਬੀ ਅਨੁਵਾਦ",
  ),

  // الترجمات البشتوية
  "عبدالولي": ResourceMetadata(
    author: "عبدالولي",
    source: "قرآن کریم",
    description: "د پښتو ژباړه",
  ),
};

/// الحصول على معلومات المورد
ResourceMetadata? getResourceMetadata(String resourceName, {bool isTranslation = false}) {
  final metadata = isTranslation ? translationMetadata : tafsirMetadata;
  return metadata[resourceName];
}
