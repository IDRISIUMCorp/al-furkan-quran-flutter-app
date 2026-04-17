# مهام إزالة ميزة تخصيص التطبيق

## المهام الرئيسية

- [x] 1. حذف الملفات الأساسية للميزة
  - [x] 1.1 حذف ملف `app_customization_settings.dart`
  - [x] 1.2 حذف ملف `app_customization_repository.dart`
  - [x] 1.3 حذف ملف `app_customization_settings_page.dart`

- [x] 2. تنظيف ملف `settings_page.dart`
  - [x] 2.1 إزالة استيراد `AppCustomizationSettingsPage`
  - [x] 2.2 حذف اختصار "تخصيص التطبيق" من قسم الاختصارات السريعة
  - [x] 2.3 حذف `Gap(10.h)` التالي للاختصار المحذوف

- [x] 3. تنظيف ملف `wahy_side_drawer.dart`
  - [x] 3.1 إزالة استيرادات `AppCustomizationSettings` و `AppCustomizationRepository`
  - [x] 3.2 حذف متغير `_menuVisibility`
  - [x] 3.3 حذف دالة `_loadMenuVisibility()`
  - [x] 3.4 حذف getter `_hasAnyIslamicService`
  - [x] 3.5 إزالة استدعاء `_loadMenuVisibility()` من `initState`
  - [x] 3.6 حذف دالة `didChangeDependencies` إذا كانت تحتوي فقط على `_loadMenuVisibility`
  - [x] 3.7 إزالة جميع الشروط `if (_menuVisibility.show...)` من عناصر القائمة
  - [x] 3.8 حذف عنصر القائمة الذي يفتح `AppCustomizationSettingsPage`

- [x] 4. تنظيف ملف `main.dart`
  - [x] 4.1 إزالة استيرادات `AppCustomizationSettings` و `AppCustomizationRepository`
  - [x] 4.2 حذف متغير `_defaultScreen`
  - [x] 4.3 حذف متغير `_isLoading`
  - [x] 4.4 حذف دالة `_loadDefaultScreen()`
  - [x] 4.5 إزالة استدعاء `_loadDefaultScreen()` من `initState`
  - [x] 4.6 تبسيط دالة `build` لإرجاع `MushafScreen` مباشرة

- [x] 5. اختبار التطبيق
  - [x] 5.1 تشغيل `flutter clean`
  - [x] 5.2 تشغيل `flutter pub get`
  - [x] 5.3 التأكد من عدم وجود أخطاء في الكومبايل
  - [x] 5.4 اختبار فتح التطبيق (يجب أن يفتح على المصحف)
  - [x] 5.5 اختبار القائمة الجانبية (جميع العناصر ظاهرة)
  - [x] 5.6 اختبار صفحة الإعدادات (لا يوجد اختصار تخصيص التطبيق)
