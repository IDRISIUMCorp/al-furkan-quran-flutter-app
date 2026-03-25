<div align="center">
  <img src="assets/img/Quran_Logo_v3.jpg" alt="Al-Furkan Quran App Logo" width="150" height="150" style="border-radius: 40px; box-shadow: 0px 10px 30px rgba(0,0,0,0.15);"/>

  # 📖 Al-Furkan Quran | الفُرقان - مصحف رقمي متكامل

  **A State-of-the-Art, Premium Digital Quran Experience crafted with Flutter.**

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Made by](https://img.shields.io/badge/Made%20by-IDRISIUM-black?logo=github)](https://github.com/IDRISIUM)

  *Crafted with precision by Idris Ghamid (إدريس غامد)*

  [Explore Features](#-features) • [Installation](#-installation) • [Screenshots](#-screenshots) • [Contact](#-contact)
</div>

---

## 🌟 About The App | عن التطبيق

**Al-Furkan** is an Apple-Design-inspired, highly polished, open-source Quran application prioritizing aesthetics, usability, and pure user experience. It avoids visual clutter and brings the modern *Glassmorphism* & *OLED Dark Mode* design directly to the reader's hands.

**الفُرقان** هو تطبيق مصحف رقمي مفتوح المصدر تم تصميمه بعناية فائقة ليعكس أحدث وأفخم معايير التصميم (Apple-Level Aesthetics). يجمع التطبيق بين نعومة الأداء والتجربة الروحانية العميقة، داعماً للوضع الداكن المخصص لشاشات OLED، والتجويد الملون، ومكتبة متكاملة من التفاسير.

---

## ✨ Features | المميزات الفاخرة

- 🎨 **Premium UI/UX:** Glassmorphism, blurred sheets, and seamless Flutter Animate transitions.
- 🌓 **OLED-Optimized Dark Mode:** Specifically designed "Night Blue" and "OLED Black" reading themes.
- 🕌 **Advanced Reading View:** Share Ayahs seamlessly as beautifully composed images. True dynamic coloring for Headers and Texts.
- 🎤 **+43 Global Reciters:** A comprehensive audio library featuring the world's renowned Quran reciters.
- 📚 **100% Complete Tafsirs:** Built-in Tafsir libraries including Al-Saddi, Al-Baghawi, Ibn Kathir, and more—optimized for zero-loading reading.
- 🕋 **Smart Qibla & Prayer Times:** AR-Ready visual compass and highly accurate global prayer timings.
- 📖 **Smart Khatma (الختمة الذكية):** A beautifully animated tracker to maintain your daily Quranic reading pacing.

---

## 🚀 Installation & Setup | التثبيت

To run this project locally, ensure you have the latest stable [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

```bash
# 1. Clone the repository
git clone https://github.com/IDRISIUMCorp/al-furkan-quran-flutter-app.git

# 2. Navigate into the directory
cd al-furkan-quran-flutter-app

# 3. Get dependencies
flutter pub get

# 4. Run the app
flutter run
```

---

## 📸 Core Modules Structure | هيكلة المشروع

The application dictates a highly decoupled, feature-first approach maintaining pristine `Clean Code` architecture:

```text
lib/
 ├── main.dart
 ├── l10n/                # Localization & Translation
 ├── src/
 │    ├── core/           # Utilities, Constants, Theming (AppColors)
 │    ├── screen/         # UI Feature Folders (mushaf, onboarding, qibla, etc.)
 │    │    └── mushaf/    # Refactored Core Reading Engine
 │    │         ├── mushaf_screen.dart                 # State Management
 │    │         ├── mushaf_share_extension.dart        # Image Generation Logic
 │    │         ├── mushaf_pronunciation_extension.dart# Word Audio Logic
 │    │         └── widgets/                           # Decoupled UI Components
 │    ├── theme/          # Centralized Bloc/Cubit implementations
 │    ├── widget/         # Highly Reusable Custom Glassmorphism Widgets
 └── packages/
      └── qcf_quran_with_update/  # The ultra-modified internal Core Engine Module
```

---

## 👨‍💻 Founder & Architect | المطور

**Idris Ghamid (إدريس غامد)**  
*Senior Principal Software Architect & Lead Developer @ IDRISIUM Corp*

<p align="center">
  <a href="https://github.com/IDRISIUM">
    <img src="https://img.shields.io/badge/GitHub-IDRISIUM-181717?logo=github&style=for-the-badge" height="35" />
  </a>
  <a href="https://www.instagram.com/idris.ghamid">
    <img src="https://img.shields.io/badge/Instagram-@idris.ghamid-E4405F?logo=instagram&style=for-the-badge" height="35" />
  </a>
  <a href="https://www.tiktok.com/@idris.ghamid">
    <img src="https://img.shields.io/badge/TikTok-@idris.ghamid-000000?logo=tiktok&style=for-the-badge" height="35" />
  </a>
  <a href="https://t.me/IDRV72">
    <img src="https://img.shields.io/badge/Telegram-@IDRV72-2CA5E0?logo=telegram&style=for-the-badge" height="35" />
  </a>
</p>

*For business queries or sponsorships, reach out via [idris.ghamid@gmail.com](mailto:idris.ghamid@gmail.com) • [IDRISIUM Web](http://idrisium.linkpc.net/)*

---

<div align="center">
  <p><i>"هذا العمل صدقة جارية خالصة لوجه الله تعالى. لا نبتغي منكم جزاءً ولا شكوراً"</i></p>
  <sub>Copyright © 2025-2026 IDRISIUM Corp. All Rights Reserved.</sub>
</div>