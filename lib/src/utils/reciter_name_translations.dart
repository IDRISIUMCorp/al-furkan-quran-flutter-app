/// ترجمة أسماء القراء للعربية
/// Reciter name translations to Arabic
class ReciterNameTranslations {
  static const Map<String, String> _arabicNames = {
    // قراء مشهورون
    'Abdul Basit Abdus Samad': 'عبد الباسط عبد الصمد',
    'Mahmoud Khalil Al-Husary': 'محمود خليل الحصري',
    'Mahmoud Khalil Al-Husary (Teacher)': 'محمود خليل الحصري (معلم)',
    'Mishari Rashid Alafasy': 'مشاري راشد العفاسي',
    'Saad Al-Ghamdi': 'سعد الغامدي',
    'Maher Al Muaiqly': 'ماهر المعيقلي',
    'Mohamed Siddiq al-Minshawi': 'محمد صديق المنشاوي',
    'Mohamed Siddiq al-Minshawi (Teacher)': 'محمد صديق المنشاوي (معلم)',
    'Yasser Ad-Dussary': 'ياسر الدوسري',
    'Abdur-Rahman as-Sudais': 'عبد الرحمن السديس',
    'Abu Bakr al-Shatri': 'أبو بكر الشاطري',
    "Sa'ud ash-Shuraym": 'سعود الشريم',
    'Nasser Al Qatami': 'ناصر القطامي',
    'Ahmed ibn Ali al-Ajamy': 'أحمد بن علي العجمي',
    'Muhammad Ayyoub': 'محمد أيوب',
    'Muhammad Jibreel': 'محمد جبريل',
    'Mustafa Ismail': 'مصطفى إسماعيل',
    'Khalifa Al-Tunaiji': 'خليفة الطنيجي',
    'Fares Abbad': 'فارس عباد',
    'Salah Al Budair': 'صلاح البدير',
    'Abdullah Matroud': 'عبد الله مطرود',
    'Muhsin Al Qasim': 'محسن القاسم',
    'Ali Jaber': 'علي جابر',
    'Hani ar-Rifai': 'هاني الرفاعي',
    'Mohamed al-Tablawi': 'محمد الطبلاوي',
    'Mahmoud Ali Al-Banna': 'محمود علي البنا',
    'Ayman Sowaid': 'أيمن سويد',
    'Akram Al Alaqimy': 'أكرم العلاقمي',
    'Yaser Salamah': 'ياسر سلامة',
    'Sahl Yassin': 'سهل ياسين',
    'Aziz Alili': 'عزيز عليلي',
    'Abdullah Awad Al-Juhani': 'عبد الله عواد الجهني',
    'Khalid Abdullah al-Qahtani': 'خالد عبد الله القحطاني',
    'Ahmed Nuaina': 'أحمد نعينع',
    'Abdullah Basfar': 'عبد الله بصفر',
    'Salah Bukhatir': 'صلاح بوخاطر',
    'Ibrahim Akhdar': 'إبراهيم الأخضر',
    'Ali Al-Hudhaify': 'علي الحذيفي',
    'Muhammad AbdulKareem': 'محمد عبد الكريم',
    'Abdulrahman Al-Ossi': 'عبد الرحمن العوسي',
    'Ali Hajjaj Al-Suesy': 'علي حجاج السيسي',

    // قراء جدد
    'Karim Mansoori': 'كريم منصوري',
    "Nabil Rifa'i": 'نبيل رفاعي',
    'Shahriar Parhizgar': 'شهريار پرهيزگار',

    // قراء رواية ورش
    'Ibrahim Al-Dosary': 'إبراهيم الدوسري',
    'Yassin Al-Jazaery': 'ياسين الجزائري',
    'Qari Yacoub': 'قاري يعقوب',

    // قراء جدد — من QuranicAudio و EveryAyah
    'Abdul Bari Al-Thubaity': 'عبد الباري الثبيتي',
    'Bandar Baleela': 'بندر بليلة',
    'Khalid Al-Jalil': 'خالد الجليل',
    'Mohammad Ismaeel Al-Muqaddim': 'محمد إسماعيل المقدم',
    'Abdul Kareem Al-Hazmi': 'عبد الكريم الحازمي',
    'Wadee Hammadi Al-Yamani': 'وديع حمادي اليماني',
    "Abdul-Mun'im Abdul-Mubdi": "عبد المنعم عبد المبدئ",
    'Al-Hussayni Al-Azazy': 'الحسيني العزازي',
  };

  /// الحصول على الاسم العربي للقارئ
  /// Get Arabic name for reciter
  static String getArabicName(String englishName, String locale) {
    // إذا كانت اللغة عربية، نرجع الاسم العربي
    if (locale.startsWith('ar')) {
      return _arabicNames[englishName] ?? englishName;
    }
    // وإلا نرجع الاسم الإنجليزي
    return englishName;
  }

  /// ترجمة نوع القراءة
  /// Translate recitation style
  static String getArabicStyle(String style, String locale) {
    if (!locale.startsWith('ar')) {
      return style;
    }

    const Map<String, String> styleTranslations = {
      'Murattal': 'مرتل',
      'Mujawwad': 'مجود',
      'Warsh': 'رواية ورش',
      'Muallim': 'معلم',
      'Teacher': 'معلم',
    };

    return styleTranslations[style] ?? style;
  }
}
