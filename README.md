<div align="center">

# 📖 Al-Furkan — الفُرقان

Al-Furkan is an open source Quran mobile app built with Flutter. It supports: – Quran reading
– Recitation audio
– Prayer times
– Bookmarks
– Dark/light theme

Al-Furkan is a modern, open-source Quran application built using Flutter and BLoC architecture.

<p align="center">
  <img src="assets/img/Quran_Logo_v3.png" width="120" style="border-radius: 24px; box-shadow: 0 8px 32px rgba(0,0,0,0.1); margin-bottom: 20px;" /><br>
  <b>تطبيق قرآني متكامل صُمم بأحدث التقنيات مع واجهة استخدام حديثة</b>
</p>

[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white&style=for-the-badge)](https://developer.android.com)
[![Built with Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-Waqf_(Charity)-red?style=for-the-badge)](LICENSE)
[![Developer](https://img.shields.io/badge/Developed_By-IDRISIUM_Corp-8B5CF6?style=for-the-badge)](https://github.com/IDRISIUM)

---

### 📸 نظرة على واجهة المستخدم (The Interface)

<p align="center">
  <img src="assets/img/ScreenSH (1).png" width="22%" style="border-radius: 12px; margin: 4px;" />
  <img src="assets/img/ScreenSH (2).png" width="22%" style="border-radius: 12px; margin: 4px;" />
  <img src="assets/img/ScreenSH (3).png" width="22%" style="border-radius: 12px; margin: 4px;" />
  <img src="assets/img/ScreenSH (4).png" width="22%" style="border-radius: 12px; margin: 4px;" />
</p>
<p align="center">
  <img src="assets/img/ScreenSH (5).png" width="22%" style="border-radius: 12px; margin: 4px;" />
  <img src="assets/img/ScreenSH (6).png" width="22%" style="border-radius: 12px; margin: 4px;" />
  <img src="assets/img/ScreenSH (7).png" width="22%" style="border-radius: 12px; margin: 4px;" />
  <img src="assets/img/ScreenSH (8).png" width="22%" style="border-radius: 12px; margin: 4px;" />
</p>

</div>

---

## ✨ التجربة القرآنية الخالصة

لقد قمنا بتطوير "الفُرقان" ليكون الرفيق الرقمي الأمثل لكل مسلم، مع التركيز التام على تجربة المستخدم، الأداء الخالي من التقطيع، والتصميم العصري الحديث.

### 📕 تجربة القراءة والتلاوة
*   **المصحف التفاعلي**: عرض صفحات بصرية تتطابق مع المصحف الورقي بدقة خطوط عثمانية متناهية.
*   **وضع التلاوة (آية بآية)**: تجربة قراءة ليلية מريحة (Dark Mode) مع خيارات تفاعل ذكية لكل آية.
*   **البنية التحتية للصوتيات**: مشغل صوتي متطور مدمج مستوحى من كبرى تطبيقات الصوتيات العالمية، يحتوي على +43 قارئ مشهور مع تتبع الآيات المسموعة كلمة بكلمة.
*   **محرك البحث السريع**: محرك داخلي يوفر لك قدرة على البحث في كامل النص القرآني في أجزاء من الثانية.

### 🧠 التفسير، الترجمة والإعراب
*   يحتوي على أشهر وأوثق التفاسير (كالميسر وابن كثير) مدمجة في شاشة عرض الآيات.
*   إمكانية استعراض الإعراب التفصيلي لكل كلمة.
*   دعم الترجمات لعدة لغات عالمية لخدمة غير الناطقين بالعربية. "قريبًا في تحديثات قادمه باذن الله"

### 🕌 أركان المسلم الأساسية
*   **مواقيت الصلاة الذكية**: خوارزميات حساب دقيقة لمقدار وموعد كل صلاة أينما كنت.
*   **البوصلة والقبلة**: بوصلة دقيقة الاستجابة مع واجهة رسومية تفاعلية.
*   **نظام الختمة**: مخططات الختمة (7، 15، 30 يوم) لمساعدتك على إتمام خطتك القرآنية.

---

## 🏗️ الأركان الهندسية والتقنية (Architecture)

تم بناء التطبيق باستخدام أحدث التقنيات ولغات البرمجة المتاحة في السوق (2025/2026 Standards):

| التقنية (Technology) | الوظيفة (Role) |
|----------------------|----------------|
| **Flutter 3.x** | إطار العمل الرئيسي والتطوير متعدد المنصات (Cross-Platform). |
| **Dart** | لغة البرمجة التي تدير واجهة المستخدم ونواقل البيانات. |
| **flutter_bloc / Cubit** | هندسة معمارية صارمة لإدارة الحالة (State Management). |
| **just_audio** | نواة تشغيل وبث الصوتيات وتتبع التلاوات. |
| **hive_ce** | قواعد البيانات المحلية فائقة السرعة بدون انقطاع للإنترنت (NoSQL). |
| **flutter_animate** | المحرك المسؤول عن حيوية الحركة وانتقالات الواجهة السلسة. |

---
## 🚀 التثبيت وطريقة التشغيل (Installation & Setup)

لتشغيل تطبيق "الفُرقان" على جهازك أو المساهمة في تطويره، يرجى اتباع الخطوات التالية:

### المتطلبات الأساسية (Prerequisites)
* بيئة عمل [Flutter](https://docs.flutter.dev/get-started/install) (الإصدار 3.x أو أحدث).
* محرر أكواد مثل VS Code أو Android Studio.

### الخطوات (Steps)

1. **استنساخ المشروع (Clone the repository):**
```bash
git clone https://github.com/IDRISIUMCorp/al-furkan-quran-flutter-app.git
```

 * الدخول لمجلد المشروع (Navigate to the project directory):
```bash
cd al-furkan-quran-flutter-app
```

 * تحميل المكاتب والاعتماديات (Install dependencies):
```bash
flutter pub get
```

 * تشغيل التطبيق (Run the app):
   قم بتوصيل هاتفك أو تشغيل المحاكي (Emulator)، ثم نفذ الأمر التالي:
```bash
flutter run
```
> ملاحظة للمطورين: التطبيق يعتمد على قواعد بيانات محلية (hive_ce) ولا يتطلب أي إعدادات معقدة للخوادم أو مفاتيح API خارجية للعمل المبدئي. كل شيء جاهز للعمل بمجرد التشغيل!
---

## 🤝 شكر وتقدير (Acknowledgments)

إن هذا الإنجاز التقني لم يكن ليخرج بهذا الكمال لولا فضل الله، ثم البناء على أعمال إخوة ومطورين كرام:

1. **العرض العثماني للقرآن (QCF Quran)**:
   تم الاستعانة بالمكتبة البرمجية الأساسية [qcf_quran](https://github.com/m4hmoud-atef/qcf_quran) للمطور **محمود عاطف** (جزاه الله خيراً كبيراً).
   *   **إعادة الهندسة والتطوير**: لقد قام **المهندس إدريس غامد** بإجراء عملية [إعادة بناء وتخصيص عميقة للمكتبة](https://github.com/idris-ghamid/qcf_quran_with_update) لتتوافق مع المعايير التصميمية لتطبيق الفُرقان، حيث شملت التعديلات:
       *   بناء وتكامل نظام **`QcfThemeData`** ليتمكن المصحف من تعديل ألوانه ديناميكياً والتفاعل مع نظام (Dark/Light Mode) الخاص بالتطبيق باحترافية.
       *   تطوير نظام **Responsive Typography** يوازن حجم الخطوط القرآنية آلياً ليتناسب بشكل لا تشوبه شائبة مع جميع أحجام وزوايا مئات الشاشات العاملة بنظام تشغيل أندرويد.
       *   الإصلاح الجذري لمشاكل القص البصري للتشكيل (Font Clipping) لتظهر الآيات بمنتهى الصفاء والوضوح.

2. **العمود الفقري وقاعدة البيانات**:
   اعتمدنا في القواعد الأساسية للمشروع (مثل قاعدة بيانات القراء، تفريعات التفاسير، الترجمات، ومحرك العمليات الرياضية لحساب مواقيت الصلاة) على مشروع [al_quran_v3](https://github.com/IsmailHosenIsmailJames/al_quran_v3) المفتوح المصدر للمطور **Ismail Hosen** (بارك الله في جهده). 
   لقد تطابقت رؤيتنا على هذا الأساس ليتم بناء وتطوير هوية بصرية بالكامل (UI/UX) تتبع أحدث منهجيات التصميم (Apple-Style Interface)، إضافة إلى استحداث ميزات تفاعلية متطورة لم تكن موجودة.

---

## 👨‍💻 مخرج المشروع والمطور الرئيسي

<div align="center">

تبني وتصميم واجهة المستخدم، وتطوير سائر تقنيات التطبيق، والخروج بنسخة المشروع النهائية بواسطة:  
**IDRISIUM Corp | المهندس إدريس غامد**

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/IDRISIUM)
[![Instagram](https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://instagram.com/idris.ghamid)
[![TikTok](https://img.shields.io/badge/TikTok-000000?style=for-the-badge&logo=tiktok&logoColor=white)](https://tiktok.com/@idris.ghamid)
[![Telegram](https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/IDRV72)
[![Portfolio](https://img.shields.io/badge/Website-00B2FF?style=for-the-badge&logo=react&logoColor=white)](http://idrisium.linkpc.net/)

</div>

---

## ⚖️ الترخيص الوقفي (Charity & License)

هذا المشروع يخضع لترخيص **Apache License 2.0** مقترناً بـ **شرط وقفي قطعي الدلالة**:

التطبيق وكامل المصدر البرمجي (Source Code) الخاص به متاحان كـ **"صدقة جارية"** لوجه الله تعالى عن المطور الرئيسي **إدريس غامد** وشركة **IDRISIUM Corp**.

<div align="center">
  <b style="color: red;">يُمنع منعاً باتاً وتاماً وتحت طائلة أي ظرف من الظروف بيع هذا الكود، أو طرح أي تطبيق مبني عليه بهدف التربح أو الاستخدام التجاري المغلق أو إضافة مساحات إعلانية ربحية. يجب أن تظل كافة النسخ المستنسخة منه مجانية للمسلمين 100% مع وجوب الالتزام بذكر المصدر والمطور الأصلي.</b>
</div>

لمزيد من التفاصيل المعقمة وشروط الاستخدام، يرجى مراجعة ملف حقوق الملكية والترخيص المرفق [LICENSE](LICENSE).

---
<div align="center">

يقول عز وجل

"إِنَّا نَحْنُ نَزَّلْنَا الذِّكْرَ وَإِنَّا لَهُ لَحَافِظُونَ"

</div>
