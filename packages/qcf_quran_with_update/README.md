# `qcf_quran_with_update`

An extensively modified and ultra-optimized Flutter package for rendering the Holy Quran with highest quality vector text (QCF) and complete page layouts.

**Proprietary fork heavily customized for the [Al-Furkan App](https://github.com/IDRISIUMCorp/al-furkan-quran-flutter-app).**

---

## 🚀 Recent Architecture Upgrades & Modifications
This internal module has been significantly expanded beyond its original state to fit the **IDRISIUM Corp** standard of "Apple-Level Aesthetics" and pixel-perfect rendering.

### 1. 🌓 Dynamic Dark Mode Deep-Integration (حساسية الوضع الداكن)
- Added explicit support for `Brightness.dark` context awareness across the core engine.
- **Smart Banners (بانرات ذكية متكيفة):** Refactored `HeaderWidget` to dynamically switch Surah Banners (e.g., loading `Darkmainframe.png` seamlessly) when the app is in Dark/OLED mode, providing a premium flush look.
- **Dynamic Text Colors (نصوص ذكية):** In-built smart inversion of `headerTextColor` to ensure maximum contrast and legibility regardless of OLED or Light scenarios.

### 2. 📸 High-Definition "Share As Image" Engine
- Completely overhauled how Ayahs are composed into images.
- Native injection of Dark Mode assets when exporting a Verse.
- Precision logic ensuring 100% accurate horizontal and vertical Center-Alignment for multi-line Ayahs under the Surah Banner.

### 3. ✨ Typography & Layout Enhancements
- Increased global font scaling limits to prevent Ayah tops from cropping at the top padding line.
- Removed hardcoded values and migrated towards centralized `QcfThemeData` instances for global styling cohesion.

### 4. 🧩 Clean Code Architecture
- Stripped unnecessary `const` rendering bugs regarding dynamic localized `TextSpan` builds.
- Refined component boundaries for injection into the highly customized `MushafScreen` inside the main application.

---

## 💻 Integration
This package should **not** be used independently outside of its designated parent directory due to tight coupling with `al-furkan-quran-flutter-app`'s core styling components. All assets are safely stored in `.assets/` and routed accordingly.

### 📜 Note
This module strictly follows the "No Placeholders" and standard coding practices defined by **Idris Ghamid**.