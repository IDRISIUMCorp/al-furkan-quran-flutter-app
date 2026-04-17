# تصميم الحل: إزالة ميزة تخصيص التطبيق

## 🎯 نظرة عامة

سيتم إزالة ميزة تخصيص التطبيق بالكامل من الكود، مع الحفاظ على استقرار التطبيق وعمله بشكل طبيعي.

## 🏗️ البنية المعمارية

### الملفات المراد حذفها:

```
lib/src/core/settings/
├── app_customization_settings.dart      ❌ حذف
└── app_customization_repository.dart    ❌ حذف

lib/src/screen/settings/
└── app_customization_settings_page.dart ❌ حذف
```

### الملفات المراد تعديلها:

```
lib/src/screen/settings/
└── settings_page.dart                   ✏️ تعديل (إزالة الاختصار)

lib/src/screen/mushaf/widgets/
└── wahy_side_drawer.dart                ✏️ تعديل (إزالة المنطق الشرطي)

lib/
└── main.dart                            ✏️ تعديل (إزالة منطق الشاشة الافتراضية)
```

## 🔧 التغييرات التفصيلية

### 1. حذف الملفات الثلاثة

**الملفات:**
- `lib/src/core/settings/app_customization_settings.dart`
- `lib/src/core/settings/app_customization_repository.dart`
- `lib/src/screen/settings/app_customization_settings_page.dart`

**الإجراء:** حذف كامل للملفات

---

### 2. تعديل `settings_page.dart`

**الموقع:** `lib/src/screen/settings/settings_page.dart`

**التغييرات:**

#### إزالة الاستيراد:
```dart
// حذف هذا السطر
import "package:al_quran_v3/src/screen/settings/app_customization_settings_page.dart";
```

#### إزالة الاختصار من قسم "اختصارات سريعة":
```dart
// حذف هذا الكود بالكامل (من السطر ~160 إلى ~172)
_SettingsShortcutTile(
  icon: Icons.tune_rounded,
  title: "تخصيص التطبيق",
  subtitle: "التحكم في القائمة الرئيسية واختيار الشاشة الافتراضية.",
  themeState: themeState,
  isDark: isDark,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AppCustomizationSettingsPage(),
    ),
  ),
),
Gap(10.h),  // حذف هذا أيضاً
```

---

### 3. تعديل `wahy_side_drawer.dart`

**الموقع:** `lib/src/screen/mushaf/widgets/wahy_side_drawer.dart`

**التغييرات:**

#### إزالة الاستيرادات:
```dart
// حذف هذه السطور
import 'package:al_quran_v3/src/core/settings/app_customization_settings.dart';
import 'package:al_quran_v3/src/core/settings/app_customization_repository.dart';
```

#### إزالة المتغير والدوال المتعلقة:
```dart
// حذف هذا المتغير (السطر ~42)
MenuItemsVisibility _menuVisibility = const MenuItemsVisibility();

// حذف هذه الدالة بالكامل (السطر ~62-69)
Future<void> _loadMenuVisibility() async {
  final prefs = await SharedPreferences.getInstance();
  final repository = AppCustomizationRepository(prefs);
  final settings = repository.getSettings();
  setState(() {
    _menuVisibility = settings.menuVisibility;
  });
}

// حذف هذه الدالة (السطر ~71-76)
bool get _hasAnyIslamicService =>
    _menuVisibility.showPrayerTimes ||
    _menuVisibility.showQibla ||
    _menuVisibility.showAzkar ||
    _menuVisibility.showAyahWidget ||
    _menuVisibility.showSunnah;
```

#### إزالة استدعاء الدالة من initState:
```dart
// في initState، حذف هذا السطر
_loadMenuVisibility();
```

#### إزالة استدعاء الدالة من didChangeDependencies:
```dart
// حذف هذه الدالة بالكامل إذا كانت تحتوي فقط على _loadMenuVisibility
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _loadMenuVisibility();
}
```

#### إزالة الشروط من عناصر القائمة:
البحث عن جميع الشروط مثل:
```dart
if (_menuVisibility.showMushaf) ...
if (_menuVisibility.showPrayerTimes) ...
if (_menuVisibility.showQibla) ...
if (_menuVisibility.showAzkar) ...
if (_menuVisibility.showAyahWidget) ...
if (_menuVisibility.showSunnah) ...
if (_menuVisibility.showIndex) ...
if (_menuVisibility.showKhatma) ...
```

**استبدالها بـ:** عرض العناصر مباشرة بدون شروط

#### إزالة اختصار "تخصيص التطبيق" من القائمة:
البحث عن:
```dart
onTap: () => _closeThenPush(
  context,
  const AppCustomizationSettingsPage(),
),
```
وحذف العنصر بالكامل.

---

### 4. تعديل `main.dart`

**الموقع:** `lib/main.dart`

**التغييرات:**

#### إزالة الاستيرادات:
```dart
// حذف هذه السطور
import 'package:al_quran_v3/src/core/settings/app_customization_settings.dart';
import 'package:al_quran_v3/src/core/settings/app_customization_repository.dart';
```

#### إزالة المتغيرات:
```dart
// حذف هذه المتغيرات من State
DefaultScreen? _defaultScreen;
bool _isLoading = true;
```

#### إزالة دالة تحميل الشاشة الافتراضية:
```dart
// حذف هذه الدالة بالكامل (السطر ~477-493)
Future<void> _loadDefaultScreen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final repository = AppCustomizationRepository(prefs);
    final settings = repository.getSettings();
    setState(() {
      _defaultScreen = settings.defaultScreen;
      _isLoading = false;
    });
  } catch (e) {
    log("Failed to load default screen: $e", name: "DefaultScreen");
    setState(() {
      _defaultScreen = DefaultScreen.mushaf;
      _isLoading = false;
    });
  }
}
```

#### إزالة استدعاء الدالة من initState:
```dart
// حذف هذا السطر من initState
_loadDefaultScreen();
```

#### تبسيط دالة build:
```dart
// استبدال منطق switch بـ:
@override
Widget build(BuildContext context) {
  return const MushafScreen();  // دائماً المصحف
}
```

---

## ✅ معايير النجاح

1. **حذف الملفات:**
   - تم حذف 3 ملفات بالكامل
   - لا توجد أي مراجع لهذه الملفات في الكود

2. **تعديل الملفات:**
   - تم إزالة جميع الاستيرادات المتعلقة
   - تم إزالة جميع المتغيرات المتعلقة
   - تم إزالة جميع الدوال المتعلقة
   - تم إزالة جميع الشروط المتعلقة

3. **الاستقرار:**
   - التطبيق يعمل بدون أخطاء
   - جميع عناصر القائمة ظاهرة
   - الشاشة الافتراضية دائماً المصحف

## 🧪 خطة الاختبار

1. **اختبار الكومبايل:**
   - تشغيل `flutter clean`
   - تشغيل `flutter pub get`
   - تشغيل `flutter build apk --debug`
   - التأكد من عدم وجود أخطاء

2. **اختبار وظيفي:**
   - فتح التطبيق والتأكد من فتح شاشة المصحف
   - فتح القائمة الجانبية والتأكد من ظهور جميع العناصر
   - فتح صفحة الإعدادات والتأكد من عدم وجود اختصار "تخصيص التطبيق"
   - التنقل بين الشاشات المختلفة

3. **اختبار الأداء:**
   - التأكد من عدم وجود تأخير في فتح التطبيق
   - التأكد من عدم وجود تأخير في فتح القائمة الجانبية
