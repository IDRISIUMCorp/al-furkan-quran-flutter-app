# Al-Furkan — Architecture Plan v1.0
> Transforming Al-Furkan into a World-Class Open Source Quran Platform & Developer Framework

**Date:** April 2026  
**Author:** IDRISIUM Corp — Idris Ghamid  
**Status:** 🔒 BLUEPRINT LOCKED  

---

## 1. Project Vision

**Current State:** A feature-rich Flutter Quran app with BLoC state management, GetIt DI, Hive local storage, JustAudio playback, and QCF Uthmanic script rendering. 61 tafsirs, 209+ translations, 56 reciters, prayer times, azkar, qibla — but architecturally monolithic with a restrictive license.

**Target State:** A production-grade, globally trusted, modular, open-source Quran **platform** and **developer framework** that:
- Is easy to fork, extend, and embed
- Is trusted for Quranic accuracy with verified data sources
- Serves as a base for production apps
- Attracts contributors and scales into a community-driven platform
- Ships with a plugin system for reciters, tafsirs, and translations

**License Change:** `صدقة جارية` (no commercial use) → **MIT OR Apache-2.0** (dual-license for maximum adoption)

**Publisher:** IDRISIUM Corp | المهندس إدريس غامد

---

## 2. Tech Stack

| Concern | Current | Target | Version | Why |
|---------|---------|--------|---------|-----|
| Language | Dart 3 | Dart 3+ | 3.x | Records, Patterns, Sealed Classes |
| State | BLoC/Cubit | BLoC/Cubit (kept) | flutter_bloc ^8.x | Already deeply integrated; event-heavy flows |
| Navigation | Manual | GoRouter | ^14.x | Deep linking, type-safe, declarative |
| DI | GetIt | GetIt + Injectable | ^7.x / ^2.x | Auto-registration, testable |
| Network | http/dio | Dio + Retrofit | ^5.x / ^4.x | Type-safe API calls, interceptors |
| Local DB | Hive_ce | Hive_ce (kept) + drift (relational) | ^2.x / ^2.x | KV stays Hive; structured data → drift |
| Serialization | Manual | freezed + json_serializable | ^2.x / ^6.x | Immutable models, no boilerplate |
| Audio | just_audio | just_audio (kept) | ^0.9.x | Best Quran audio support |
| Responsiveness | flutter_screenutil | flutter_screenutil (kept) | ^5.x | Pixel-perfect across sizes |
| Animation | Manual | flutter_animate | ^4.x | Composable, performant |
| Logging | print/dart:log | talker_flutter | ^4.x | Production-grade logging |
| Connectivity | — | connectivity_plus | ^6.x | Offline state handling |
| Caching | — | flutter_cache_manager | ^3.x | Offline-first resource caching |
| Quran Script | qcf_quran_with_update | qcf_quran_with_update (kept, refactored) | local pkg | Uthmanic QCF rendering |
| Compass | flutter_compass_v2_patch | flutter_compass_v2_patch (kept) | local pkg | Qibla direction |
| Testing | Minimal | flutter_test + mockito + bloc_test | — | Comprehensive coverage |
| CI | GitHub Actions | GitHub Actions (enhanced) | — | Analyze + test + coverage |

---

## 3. Complete Folder Structure

```
al-furkan-quran-flutter-app/
├── .github/
│   ├── workflows/
│   │   ├── flutter_ci.yml              ← Enhanced: analyze + test + coverage
│   │   └── sync-to-gitlab.yml
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── data_accuracy_report.md     ← NEW: Quran data accuracy reports
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── labels.json                     ← good-first-issue, help-wanted, etc.
├── android/
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
├── assets/
│   ├── adhan/
│   ├── fonts/
│   └── img/
├── packages/                            ← INDEPENDENT MODULES
│   ├── core_quran_engine/              ← Quran text, pages, surah metadata
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── data/
│   │   │   │   │   ├── models/          ← @freezed Quran models
│   │   │   │   │   ├── datasources/
│   │   │   │   │   │   ├── local/       ← Hive/drift Quran data
│   │   │   │   │   │   └── remote/      ← Backend API
│   │   │   │   │   └── repositories/   ← Concrete impls
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/        ← Pure Dart (Ayah, Surah, Page, Juz)
│   │   │   │   │   ├── repositories/    ← Abstract interfaces
│   │   │   │   │   └── usecases/        ← GetSurah, GetPage, SearchAyah...
│   │   │   │   └── presentation/       ← (none — pure engine)
│   │   │   └── core_quran_engine.dart
│   │   ├── test/
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   ├── quran_data_provider/            ← Verified data source management
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── data/
│   │   │   │   │   ├── models/          ← ResourceMetadata, DataSourceInfo
│   │   │   │   │   ├── datasources/
│   │   │   │   │   │   ├── tanzil/      ← Verified Tanzil dataset
│   │   │   │   │   │   ├── local/       ← Bundled resources
│   │   │   │   │   │   └── remote/      ← CDN/GitHub fallbacks
│   │   │   │   │   └── repositories/
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/
│   │   │   │   │   ├── repositories/
│   │   │   │   │   └── usecases/        ← LoadTranslation, LoadTafsir, VerifyHash
│   │   │   │   └── integrity/          ← Hash/checksum validation
│   │   │   └── quran_data_provider.dart
│   │   ├── test/
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   ├── audio_player_module/            ← Audio playback + sync
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── data/
│   │   │   │   │   ├── models/          ← ReciterInfo, AudioSource, Segment
│   │   │   │   │   ├── datasources/
│   │   │   │   │   │   ├── local/       ← Offline audio cache
│   │   │   │   │   │   └── remote/      ← Streaming URLs
│   │   │   │   │   └── repositories/
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/
│   │   │   │   │   ├── repositories/
│   │   │   │   │   └── usecases/        ← PlayAyah, PlayRange, SyncAudio
│   │   │   │   └── presentation/
│   │   │   │       ├── cubits/          ← AudioUiCubit, PlayerStateCubit, etc.
│   │   │   │       └── widgets/         ← AudioControllerUI, PlayerBar
│   │   │   └── audio_player_module.dart
│   │   ├── test/
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   ├── tafsir_module/                  ← Tafsir display + management
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── data/
│   │   │   │   │   ├── models/
│   │   │   │   │   ├── datasources/
│   │   │   │   │   └── repositories/
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/
│   │   │   │   │   ├── repositories/
│   │   │   │   │   └── usecases/        ← GetTafsir, ListTafsirs, SwitchTafsir
│   │   │   │   └── presentation/
│   │   │   │       ├── cubits/
│   │   │   │       └── widgets/         ← TafsirView, TafsirSelector
│   │   │   └── tafsir_module.dart
│   │   ├── test/
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   ├── prayer_times_module/            ← Prayer times + qibla + reminders
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── data/
│   │   │   │   │   ├── models/
│   │   │   │   │   ├── datasources/     ← Aladhan API + local calc
│   │   │   │   │   └── repositories/
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/
│   │   │   │   │   ├── repositories/
│   │   │   │   │   └── usecases/        ← GetPrayerTimes, GetQibla, SetReminder
│   │   │   │   └── presentation/
│   │   │   │       ├── cubits/
│   │   │   │       └── widgets/
│   │   │   └── prayer_times_module.dart
│   │   ├── test/
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   ├── search_module/                  ← Quran search engine
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── data/
│   │   │   │   │   ├── models/
│   │   │   │   │   ├── datasources/     ← Local index + remote search
│   │   │   │   │   └── repositories/
│   │   │   │   ├── domain/
│   │   │   │   │   ├── entities/
│   │   │   │   │   ├── repositories/
│   │   │   │   │   └── usecases/        ← SearchQuran, SearchTranslation, SearchTafsir
│   │   │   │   └── presentation/
│   │   │   │       ├── cubits/
│   │   │   │       └── widgets/
│   │   │   └── search_module.dart
│   │   ├── test/
│   │   ├── pubspec.yaml
│   │   └── README.md
│   │
│   ├── qcf_quran_with_update/          ← KEPT: Uthmanic QCF rendering
│   └── flutter_compass_v2_patch/       ← KEPT: Qibla compass
│
├── lib/                                 ← MAIN APP (thin orchestration layer)
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart         ← SINGLE SOURCE OF TRUTH for colors
│   │   │   ├── app_text_styles.dart    ← All TextStyle definitions
│   │   │   ├── app_theme.dart          ← ThemeData (light + dark)
│   │   │   └── app_decorations.dart    ← BoxDecoration, InputDecoration presets
│   │   ├── constants/
│   │   │   ├── app_strings.dart        ← All user-facing strings
│   │   │   ├── app_assets.dart         ← All asset paths
│   │   │   ├── app_sizes.dart          ← Spacing, radius, icon sizes
│   │   │   └── app_durations.dart      ← Animation timing constants
│   │   ├── router/
│   │   │   ├── app_router.dart         ← GoRouter configuration
│   │   │   └── app_routes.dart         ← Route name constants
│   │   ├── di/
│   │   │   ├── service_locator.dart    ← GetIt + Injectable config
│   │   │   └── module_registrar.dart   ← Plugin/module registration
│   │   ├── network/
│   │   │   ├── api_client.dart         ← Dio instance + interceptors
│   │   │   └── error_handler.dart      ← Centralized error parsing
│   │   ├── error/
│   │   │   ├── failures.dart           ← Sealed class failures
│   │   │   ├── exceptions.dart         ← Custom exceptions
│   │   │   └── release_error_handler.dart
│   │   ├── storage/
│   │   │   ├── app_boxes.dart
│   │   │   └── app_storage.dart
│   │   ├── bootstrap/
│   │   │   └── app_bootstrap_coordinator.dart
│   │   ├── notifications/
│   │   │   └── notification_scheduler.dart
│   │   ├── plugins/                    ← NEW: Plugin system
│   │   │   ├── plugin_registry.dart    ← Register/discover plugins
│   │   │   ├── plugin_interface.dart   ← Base plugin interface
│   │   │   ├── reciter_plugin.dart     ← Reciter plugin interface
│   │   │   ├── tafsir_plugin.dart      ← Tafsir plugin interface
│   │   │   └── translation_plugin.dart ← Translation plugin interface
│   │   └── utils/
│   │       ├── extensions/
│   │       ├── helpers/
│   │       └── validators/
│   │
│   ├── features/                        ← APP-LEVEL FEATURES (UI orchestration)
│   │   ├── mushaf/                      ← Main Quran reading experience
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── mushaf_screen.dart
│   │   │   │   │   └── quran_script_view.dart
│   │   │   │   ├── cubits/
│   │   │   │   │   ├── quran_script_view_cubit.dart
│   │   │   │   │   ├── quran_settings_cubit.dart
│   │   │   │   │   └── night_reading_cubit.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── mushaf_layout_widgets.dart
│   │   │   │       ├── wahy_mushaf_top_header.dart
│   │   │   │       ├── listen_range_sheet.dart
│   │   │   │       ├── khatma_sheet.dart
│   │   │   │       └── library_sheet.dart
│   │   │   └── mushaf_feature.dart     ← Feature barrel export
│   │   │
│   │   ├── quran_reader/               ← Ayah-by-ayah reading
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   ├── cubits/
│   │   │   │   └── widgets/
│   │   │   └── quran_reader_feature.dart
│   │   │
│   │   ├── search/                     ← Search feature (uses search_module)
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   ├── cubits/
│   │   │   │   └── widgets/
│   │   │   └── search_feature.dart
│   │   │
│   │   ├── prayer_times/               ← Prayer feature (uses prayer_times_module)
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   ├── cubits/
│   │   │   │   └── widgets/
│   │   │   └── prayer_times_feature.dart
│   │   │
│   │   ├── azkar/                      ← Azkar & adhkar
│   │   │   ├── presentation/
│   │   │   └── azkar_feature.dart
│   │   │
│   │   ├── settings/                   ← App settings
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── settings_page.dart
│   │   │   │   │   ├── theme_settings_enhanced.dart
│   │   │   │   │   ├── notification_settings_page_enhanced.dart
│   │   │   │   │   └── app_language_settings.dart
│   │   │   │   ├── cubits/
│   │   │   │   │   ├── theme_cubit.dart
│   │   │   │   │   └── language_cubit.dart
│   │   │   │   └── widgets/
│   │   │   └── settings_feature.dart
│   │   │
│   │   ├── about/                      ← IDRISIUM Signature
│   │   │   ├── presentation/
│   │   │   │   └── screens/
│   │   │   │       └── about_the_app.dart
│   │   │   └── about_feature.dart
│   │   │
│   │   ├── bookmarks/                  ← Bookmarks + pinned + notes
│   │   │   ├── presentation/
│   │   │   └── bookmarks_feature.dart
│   │   │
│   │   ├── hifz/                       ← Memorization tracking
│   │   │   ├── presentation/
│   │   │   │   ├── cubits/
│   │   │   │   └── widgets/
│   │   │   └── hifz_feature.dart
│   │   │
│   │   ├── reading_stats/              ← Reading statistics
│   │   │   ├── presentation/
│   │   │   │   └── cubits/
│   │   │   └── reading_stats_feature.dart
│   │   │
│   │   ├── quran_resources/            ← Resource management (downloads)
│   │   │   ├── presentation/
│   │   │   └── quran_resources_feature.dart
│   │   │
│   │   ├── qibla/                      ← Qibla direction
│   │   │   ├── presentation/
│   │   │   └── qibla_feature.dart
│   │   │
│   │   ├── sunnah/                     ← Sunnah prayers + wudu guide
│   │   │   ├── presentation/
│   │   │   └── sunnah_feature.dart
│   │   │
│   │   └── offline_player/             ← Offline audio management
│   │       ├── presentation/
│   │       └── offline_player_feature.dart
│   │
│   ├── shared/                          ← Cross-feature shared
│   │   ├── widgets/                     ← Reusable UI components
│   │   │   ├── quran_script/           ← Script rendering widgets
│   │   │   ├── audio/                  ← Audio UI widgets
│   │   │   ├── share/                  ← Share functionality
│   │   │   └── components/             ← Generic components
│   │   └── models/                      ← Shared models
│   │
│   ├── l10n/                            ← Localization (50+ languages)
│   └── main.dart                        ← Entry point
│
├── test/
│   ├── unit/                            ← Unit tests per module
│   ├── widget/                          ← Widget tests per feature
│   ├── integration/                     ← Integration tests
│   ├── golden/                          ← Golden tests (Mushaf rendering)
│   └── fixtures/                        ← Test data fixtures
│
├── LICENSE                              ← MIT OR Apache-2.0
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── README.md                            ← Developer-first documentation
├── ARCHITECTURE_PLAN.md                 ← THIS FILE
├── CHANGELOG.md
├── pubspec.yaml
├── analysis_options.yaml
└── .env.example
```

---

## 4. Feature Manifest (50+ Features)

### 🔵 CORE (Must Ship)

| # | Feature | Description |
|---|---------|-------------|
| 1 | **Uthmanic QCF Mushaf Rendering** | Pixel-perfect Quran page rendering with QCF v1/v2 fonts, word-level positioning |
| 2 | **Ayah-by-Ayah Reading Mode** | Vertical scrolling with per-ayah display, translation, and tafsir |
| 3 | **209+ Translations** | Multi-language Quran translations with offline-first loading and lazy download |
| 4 | **61 Tafsirs** | Arabic and translated tafsir with inline display and selector |
| 5 | **56 Reciters** | Audio playback with reciter selection, segmented (word-by-word) support for 10+ reciters |
| 6 | **Prayer Times** | Aladhan API + local calculation, 12+ calculation methods, location-based |
| 7 | **Qibla Direction** | Compass-based qibla with device orientation |
| 8 | **Full-Text Search** | Search across Quran text, translations, and tafsir with instant results |
| 9 | **Bookmarks & Pins** | Pin ayahs, surahs, pages; organize into collections |
| 10 | **Reading Position Memory** | Auto-save last read page/ayah, restore on app open |
| 11 | **50+ Language Localization** | ARB-based l10n with RTL support for Arabic, Urdu, Farsi, etc. |
| 12 | **Offline-First Architecture** | Core features work without internet; resources cached locally |
| 13 | **Dark/Light Theme** | Warm beige (light) + deep slate (dark) with Material 3 |
| 14 | **Mushaf Page Navigation** | Page-based navigation with jump-to-page, surah, juz, hizb |
| 15 | **Word-by-Word Highlight** | Synchronized word highlighting during audio playback |
| 16 | **MIT/Apache-2.0 License** | Dual-license for maximum open-source adoption |
| 17 | **Data Integrity Verification** | SHA-256 checksums for Quran text, translations, tafsir data |
| 18 | **Plugin System** | Interface-based plugin registry for reciters, tafsirs, translations |

### 🟡 ADVANCED (Should Ship)

| # | Feature | Description |
|---|---------|-------------|
| 19 | **Khatma Tracking** | Create reading khatma with progress tracking and notifications |
| 20 | **Hifz Memorization** | Track memorized ayahs with revision scheduling |
| 21 | **Reading Statistics** | Daily/weekly/monthly reading stats with streak tracking |
| 22 | **Ayah Share** | Share ayah as image or text with custom styling |
| 23 | **Notes & Annotations** | Add personal notes to any ayah with rich text |
| 24 | **Audio Playlist Range** | Play from ayah X to ayah Y with auto-advance |
| 25 | **Playback Speed Control** | 0.5x to 2.0x speed with smooth transition |
| 26 | **Audio Stream/Download Toggle** | Stream or download audio per reciter preference |
| 27 | **Night Reading Mode** | Extra-dim mode for late-night reading with amber tint |
| 28 | **Font Size Control** | Granular font size for Quran text, translation, tafsir |
| 29 | **Mutashabihat Display** | Show similar ayahs (mutashabihat) with cross-references |
| 30 | **Tajweed Rules Overlay** | Color-coded tajweed markers on Quran text |
| 31 | **Irab (Grammar) Display** | Arabic grammatical analysis per ayah |
| 32 | **Transliteration** | Romanized Quran text for non-Arabic readers |
| 33 | **Azkar & Adhkar** | Morning/evening azkar with counter and categories |
| 34 | **Sunnah Prayer Guide** | Detailed sunnah prayer descriptions with illustrations |
| 35 | **Wudu Guide** | Step-by-step wudu instructions with illustrations |
| 36 | **Prayer Reminders** | Per-prayer notification with custom sound and timing |
| 37 | **Prayer Time Adjustment** | Manual +minute adjustment per prayer |
| 38 | **Adhan Audio** | Custom adhan audio playback at prayer time |
| 39 | **Offline Audio Player** | Download and manage reciter audio for offline use |
| 40 | **Resource Manager** | Download/delete translations, tafsirs, reciters from UI |
| 41 | **Ayah of the Day** | Daily ayah notification with random selection |
| 42 | **GoRouter Navigation** | Type-safe routing with deep link support |
| 43 | **Error Recovery** | Graceful error handling with user-facing messages and retry |

### 🟢 PREMIUM (If Time Allows)

| # | Feature | Description |
|---|---------|-------------|
| 44 | **Golden Tests** | Mushaf rendering golden tests for pixel-perfect regression detection |
| 45 | **Isolate-based Parsing** | Heavy JSON/parsing in isolates to prevent UI jank |
| 46 | **Smart Caching** | LRU cache for Quran resources with size limits and eviction |
| 47 | **Audio Preloading** | Preload next ayah audio during playback for gapless experience |
| 48 | **Accessibility (Semantics)** | Screen reader support, semantic labels, high-contrast mode |
| 49 | **Responsive Tablet Layout** | Two-pane layout on tablets (list + detail side-by-side) |
| 50 | **CI Coverage Reports** | Automated test coverage in CI with minimum threshold |
| 51 | **Performance Benchmarks** | Page render time, audio latency, search speed benchmarks |
| 52 | **Developer CLI Tool** | `dart run al_furkan:check-data` for data integrity verification |
| 53 | **Web Support** | Full web deployment with WASM-compatible code paths |

### ⚪ FUTURE (Documented Roadmap)

| # | Feature | Description |
|---|---------|-------------|
| 54 | **AI-Powered Tafsir Search** | Semantic search across tafsir content |
| 55 | **Community Translations** | User-submitted translation corrections with review workflow |
| 56 | **Cross-Device Sync** | Firebase-based reading position and bookmark sync |
| 57 | **Print-Ready Mushaf Export** | PDF export of selected pages with custom styling |
| 58 | **Braille Quran Support** | Accessibility for visually impaired users |
| 59 | **Desktop-optimized Layout** | Native Windows/macOS/Linux window management |
| 60 | **Plugin Marketplace** | Community-contributed plugins with rating system |

---

## 5. Screen Map

| Screen | Route | Contains |
|--------|-------|----------|
| **Mushaf (Main)** | `/` | PageView of 604 pages, top header, audio bar, bottom nav |
| **Quran Script View** | `/script` | Ayah-by-ayah vertical reading with translation/tafsir |
| **Search** | `/search` | Search bar, results list (quran/translation/tafsir tabs) |
| **Prayer Times** | `/prayer` | Prayer time cards, next prayer countdown, location |
| **Qibla** | `/qibla` | Compass with qibla direction indicator |
| **Azkar** | `/azkar` | Azkar categories → azkar list with counter |
| **Sunnah Prayers** | `/sunnah` | Sunnah prayer descriptions with illustrations |
| **Wudu Guide** | `/wudu` | Step-by-step wudu instructions |
| **Settings** | `/settings` | Theme, language, notifications, Quran display, audio |
| **Theme Settings** | `/settings/theme` | Light/dark toggle, accent color, font size |
| **Notification Settings** | `/settings/notifications` | Per-prayer toggles, quiet hours, sound selection |
| **Language Settings** | `/settings/language` | App language selector with 50+ options |
| **About** | `/about` | IDRISIUM Signature — logo, founder, social links |
| **Bookmarks** | `/bookmarks` | Pinned ayahs/collections list |
| **Hifz** | `/hifz` | Memorization progress dashboard |
| **Reading Stats** | `/stats` | Daily/weekly charts, streak, total reading time |
| **Resource Manager** | `/resources` | Download/delete translations, tafsirs, reciters |
| **Offline Player** | `/offline` | Downloaded audio management per reciter |
| **Khatma** | `/khatma` | Khatma creation, progress, completion |
| **Tafsir View** | (bottom sheet) | Inline tafsir display for selected ayah |
| **Translation View** | (bottom sheet) | Translation selector + display |
| **Listen Range** | (bottom sheet) | Set ayah range for audio playback |
| **Ayah Options** | (bottom sheet) | Share, bookmark, note, copy, tafsir for single ayah |
| **Quick Jump** | (dialog) | Jump to page/surah/ayah/juz/hizb |
| **Onboarding** | `/onboarding` | First-run setup wizard |

---

## 6. Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        PRESENTATION                         │
│  Screens ← Cubits/BLoC ← Widgets ← Shared Widgets          │
└──────────┬──────────────────────────────┬──────────────────┘
           │                              │
     State changes                  User actions
           │                              │
           ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         DOMAIN                              │
│  Use Cases ← Repository Interfaces ← Entities               │
│  (Pure Dart — ZERO Flutter imports)                         │
└──────────┬──────────────────────────────┬──────────────────┘
           │                              │
     Depends on                    Depends on
           │                              │
           ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                          DATA                               │
│  Repository Impls ← DataSources (Remote + Local) ← Models   │
│  Returns Either<Failure, T>                                 │
└──────────┬──────────────────────────────┬──────────────────┘
           │                              │
     Network calls                  Local storage
           │                              │
           ▼                              ▼
┌──────────────────┐          ┌──────────────────────────────┐
│   REMOTE API     │          │       LOCAL STORAGE          │
│  Vercel/Render   │          │  Hive (KV) + drift (SQL)    │
│  Aladhan API     │          │  SharedPreferences          │
│  CDN Fallbacks   │          │  File System (audio cache)  │
└──────────────────┘          └──────────────────────────────┘

MODULE DEPENDENCY GRAPH:
═════════════════════════
                    ┌──────────────┐
                    │  Main App    │
                    └──────┬───────┘
           ┌──────────────┼──────────────┐
           ▼              ▼              ▼
    ┌─────────────┐ ┌───────────┐ ┌───────────┐
    │ core_quran  │ │  audio    │ │  tafsir    │
    │  _engine    │ │  _player  │ │  _module   │
    └──────┬──────┘ └─────┬─────┘ └─────┬─────┘
           │              │              │
           ▼              ▼              ▼
    ┌─────────────────────────────────────────┐
    │        quran_data_provider              │
    │  (Verified datasets + integrity checks) │
    └─────────────────────────────────────────┘
           │              │
           ▼              ▼
    ┌─────────────┐ ┌───────────┐
    │   search    │ │  prayer   │
    │  _module    │ │  _times   │
    └─────────────┘ └───────────┘

PLUGIN SYSTEM FLOW:
═══════════════════
  PluginRegistry.register(ReciterPlugin)
  PluginRegistry.register(TafsirPlugin)
  PluginRegistry.register(TranslationPlugin)
         │
         ▼
  Module consumes plugin via interface
  (No compile-time dependency on concrete impl)
```

---

## 7. State Management Architecture

**Primary: BLoC/Cubit** (kept — already deeply integrated)

| Module | Cubit/BLoC | Responsibility |
|--------|-----------|----------------|
| Audio | `AudioUiCubit` | Audio bar visibility, expanded state |
| Audio | `PlayerStateCubit` | Playing/paused/stopped, loop mode |
| Audio | `AyahKeyCubit` | Current ayah key tracking |
| Audio | `PlayerPositionCubit` | Playback position, duration |
| Audio | `SegmentedQuranReciterCubit` | Segmented reciter selection |
| Audio | `WordPlayingStateCubit` | Word-by-word highlight state |
| Theme | `ThemeCubit` | Light/dark/night mode |
| Language | `LanguageCubit` | App locale |
| Settings | `QuranScriptViewCubit` | Quran view preferences |
| Settings | `QuranSettingsCubit` | Unified Quran display settings |
| Prayer | `PrayerTimeCubit` | Prayer times + reminders |
| Hifz | `HifzCubit` | Memorization tracking |
| Stats | `ReadingStatsCubit` | Reading statistics |
| Night | `NightReadingCubit` | Night reading mode |

**Pattern:**
- Cubit for simple state (settings, preferences)
- BLoC for event-heavy flows (audio playback pipeline)
- Every Cubit/BLoC depends on Domain use cases, never on Data layer directly
- State classes are immutable (freezed where applicable)

---

## 8. Navigation Map

```
GoRouter Configuration:
═══════════════════════

/ (MushafScreen)                    ← Root: Quran page view
├── /script (QuranScriptView)       ← Ayah-by-ayah reading
├── /search (SearchScreen)          ← Full-text search
├── /prayer (PrayerTimePage)        ← Prayer times
├── /qibla (QiblaDirection)        ← Qibla compass
├── /azkar (AzkarCategoriesScreen)  ← Azkar & adhkar
├── /sunnah (SunnahPrayerPage)      ← Sunnah guide
├── /wudu (SunnahWuduPage)         ← Wudu guide
├── /settings (SettingsPage)       ← App settings
│   ├── /settings/theme            ← Theme configuration
│   ├── /settings/notifications    ← Notification settings
│   └── /settings/language         ← Language selection
├── /about (AboutTheApp)           ← IDRISIUM Signature
├── /bookmarks                     ← Bookmarks & pins
├── /hifz                          ← Memorization
├── /stats                         ← Reading statistics
├── /resources (QuranResourcesView) ← Resource manager
├── /offline (OfflinePlayerScreen)  ← Offline audio
├── /khatma                        ← Khatma tracking
└── /onboarding                    ← First-run setup (guard: !isOnboarded)

Guards:
- /onboarding: redirect to / if isOnboardingV2Done
- /: redirect to /onboarding if !isOnboardingV2Done

Bottom Sheets (not routes):
- Tafsir bottom sheet
- Translation selector
- Listen range selector
- Ayah options sheet
- Quick jump dialog
- Quran settings bottom sheet
```

---

## 9. API Contract

### Primary Backend (Vercel — quran-backend-delta.vercel.app)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/quran/text/{surah}` | GET | Surah text with ayah keys |
| `/api/v1/quran/page/{number}` | GET | Page data (ayahs, surah headers) |
| `/api/v1/translations` | GET | Available translations list |
| `/api/v1/translations/{id}/ayahs` | GET | Translation text per ayah |
| `/api/v1/tafsir` | GET | Available tafsirs list |
| `/api/v1/tafsir/{id}/ayahs` | GET | Tafsir text per ayah |
| `/api/v1/reciters` | GET | Available reciters list |
| `/api/v1/reciters/{id}/audio/{ayah_key}` | GET | Audio URL for ayah |
| `/api/v1/reciters/{id}/segments/{surah}` | GET | Timing segments for sync |
| `/api/v1/search` | GET | Full-text search across Quran |
| `/api/v1/mutashabihat` | GET | Similar ayahs data |
| `/api/v1/transliteration` | GET | Transliteration data |
| `/api/v1/irab/{ayah_key}` | GET | Grammatical analysis |

### Prayer Times API (Aladhan)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/timings/{timestamp}` | GET | Prayer times by coordinates |
| `/timingsByCity/{timestamp}` | GET | Prayer times by city |

### CDN Fallbacks (GitHub Raw)

| URL | Purpose |
|-----|---------|
| `Waqar144/Quran_Mutashabihat_Data/master/mutashabiha_data.json` | Mutashabihat fallback |
| `risan/quran-json/main/dist/quran_transliteration.json` | Transliteration fallback |

---

## 10. Local Data Schema

### Hive Boxes

| Box Name | Keys | Purpose |
|----------|------|---------|
| `user` | `wahy_last_page`, `wahy_last_ayah_key`, `selected_quran_script_type`, `isAyahByAyah`, `isAyahByAyahHorizontal`, `onboarding_v2_done`, `quick_setup_done`, `is_setup_complete`, `view_*` (12+ keys) | User preferences & view state |
| `pinned` | Ayah keys as keys | Bookmarked/pinned ayahs |
| `notes` | Ayah keys as keys | User notes per ayah |

### SharedPreferences

| Key | Type | Purpose |
|-----|------|---------|
| `selectedLanguageCode` | String | App language |
| `app_theme_mode` | String | Theme mode |
| `idrisium_first_run_defaults_applied` | Bool | First-run flag |
| `prayer_reminder_items_v1` | String (JSON) | Prayer reminders |
| `prayer_previous_modes_v1` | String (JSON) | Reminder modes |
| `prayer_time_adjustments_v1` | String (JSON) | Time adjustments |
| `prayer_enforce_alarm_sound_v1` | Bool | Alarm sound |
| `prayer_sound_volume_v1` | Double | Sound volume |

### File System Cache

| Path | Purpose |
|------|---------|
| `Application Documents/audio/` | Downloaded reciter audio files |
| `Application Documents/quran_resources/` | Cached translations, tafsirs |
| `Application Documents/qcf_fonts/` | QCF font files |

### drift Database (NEW — for structured queries)

| Table | Columns | Purpose |
|-------|---------|---------|
| `ayahs` | id, surah, ayah_number, page, juz, hizb, text_uthmani, text_imlaei | Quran text index |
| `surahs` | id, name_ar, name_en, revelation_type, ayah_count | Surah metadata |
| `bookmarks` | id, ayah_key, created_at, collection_id | Structured bookmarks |
| `reading_sessions` | id, date, pages_read, duration_seconds | Reading statistics |

---

## 11. Risk Register + Mitigations

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| 1 | **Quran text accuracy** — Any corruption in Quran text is unacceptable | 🔴 Critical | Use verified Tanzil dataset; SHA-256 checksums on all data files; data integrity tests in CI; `DataAccuracyReport` issue template |
| 2 | **Breaking existing functionality** — Refactoring could break core features | 🔴 Critical | Incremental migration (one module at a time); comprehensive test suite before each move; feature flags for new architecture |
| 3 | **Module dependency cycles** — Circular deps between packages | 🟡 High | Strict dependency graph (see Section 6); `dependency_validator` in CI; `core_quran_engine` has ZERO deps on other modules |
| 4 | **Audio sync accuracy** — Word-by-word highlight must match audio | 🟡 High | Integration tests for audio+ayah sync; fallback to ayah-level highlight if segments unavailable |
| 5 | **Performance regression** — Modularization could add overhead | 🟡 High | Benchmark tests for page render time; isolate-based parsing; lazy module loading |
| 6 | **License incompatibility** — Some deps may conflict with MIT/Apache | 🟠 Medium | Audit all dependency licenses before switch; document any constraints |
| 7 | **Migration complexity** — Moving code to packages is error-prone | 🟠 Medium | One module per PR; keep old code working until new module is verified; gradual cutover |
| 8 | **Cross-platform breakage** — Changes may break web/desktop | 🟠 Medium | CI matrix for all platforms; platform-specific code paths preserved |

---

## 12. Build Phases Timeline

### Phase 0: IGNITION ✅ COMPLETE
- Analyzed current codebase structure
- Identified architectural patterns (BLoC, GetIt, Hive)
- Found critical license conflict
- Mapped all features and dependencies

### Phase 1: BLUEPRINT ✅ COMPLETE
- This document (`ARCHITECTURE_PLAN.md`)
- 12 sections defined and locked
- Feature manifest: 60 features (18 core, 25 advanced, 10 premium, 7 future)

### Phase 2: FOUNDATION ✅ COMPLETE
- [x] Replace LICENSE with MIT OR Apache-2.0
- [x] Update `pubspec.yaml` with new deps (GoRouter, freezed, injectable, talker, etc.)
- [x] Create `core/theme/app_text_styles.dart`
- [x] Create `core/theme/app_decorations.dart`
- [x] Create `core/constants/app_strings.dart`
- [x] Create `core/constants/app_sizes.dart`
- [x] Create `core/constants/app_assets.dart`
- [x] Create `core/constants/app_durations.dart`
- [x] Create `core/router/app_routes.dart` + `app_router.dart`
- [x] Create `core/di/module_registrar.dart`
- [x] Create `core/network/api_client.dart` + `error_handler.dart`
- [x] Create `core/error/failures.dart` + `exceptions.dart`
- [x] Create `core/plugins/plugin_registry.dart` + interfaces
- [x] Update `analysis_options.yaml` with strict rules
- [x] Update `main.dart` for new architecture

### Phase 3: ENGINE ✅ COMPLETE
- [x] Feature modules with Clean Architecture: data → domain → presentation
- [x] `features/audio/` — BLoC, entities, repository interface, DI
- [x] `features/tafsir/` — BLoC, entities, repository interface, DI
- [x] `features/azkar/` — BLoC, entities, repository interface, DI
- [x] `features/qibla/` — BLoC, entities, repository interface, DI
- [x] `features/hifz/` — BLoC, entities, repository interface, DI
- [x] `features/prayer/` — BLoC, entities, repository interface, DI
- [x] BLoC DI registrations via GetIt `registerFactory`
- [ ] Extract to independent packages (deferred to post-ship)

### Phase 4: THE UI ✅ COMPLETE
- [x] Presentation BLoCs for Audio, Tafsir, Azkar, Qibla, Hifz, Prayer
- [x] BLoC DI registrations in all feature injection files
- [x] Shared UI widgets: SkeletonLoading, ErrorStateWidget, EmptyStateWidget
- [x] Shared UI widgets: Pressable, PressableOpacity, AppCard, SectionHeader, AppChip
- [x] Feature screens: Azkar (categories + items), Qibla (compass), Hifz (dashboard)
- [x] Feature screens: Tafsir (list + detail), Audio (reciters), Prayer Times (schedule)
- [x] RTL support across all new screens
- [x] Theme compliance — migrated all deprecated `ayaX` aliases to `lightX` tokens
- [x] Removed all deprecated legacy aliases from AppColors
- [x] Fixed `app_decorations.dart` import path
- [x] Fixed `api_client.dart` DioException constructor (`originalError` → `error`)

### Phase 5: IDRISIUM SIGNATURE ✅ COMPLETE
- [x] Existing About screen (`about_the_app.dart`) already has premium design
- [x] Animated logo reveal, founder photo with glow, glassmorphism cards
- [x] Social links grid (GitHub, TikTok, Instagram, Telegram, Email, Website)
- [x] Feature categories grid, mission statement card, version info

### Phase 6: QUALITY GATE ✅ COMPLETE
- [x] Theme compliance: ZERO hardcoded colors in new modules (all use AppColors tokens)
- [x] Deprecated aliases removed — all consumers migrated
- [x] Dart analyze: ZERO errors/warnings in new modules
- [x] Architecture integrity: Domain entities have ZERO Flutter imports
- [x] Unit tests: AzkarBloc (7 cases), HifzBloc (5 cases) with manual mock repos
- [ ] Widget tests: UI consistency per feature (deferred to post-ship)
- [ ] Integration tests: Audio + ayah sync, prayer times (deferred to post-ship)
- [ ] Performance: Isolate parsing, smart caching, lazy loading (deferred to post-ship)
- [ ] Cross-platform: Android, iOS, Web verification (deferred to post-ship)

### Phase 7: SHIP ✅ COMPLETE
- [x] Update `README.md` — added PHASE 4–5 feature descriptions
- [x] Update `CONTRIBUTING.md` — modular architecture docs, feature table, theme compliance rules
- [x] Create `CODE_OF_CONDUCT.md` (Contributor Covenant v2.1)
- [x] Create `.github/ISSUE_TEMPLATE/` (bug_report, feature_request)
- [x] Create `.github/PULL_REQUEST_TEMPLATE.md` with theme compliance checklist
- [x] Update `CHANGELOG.md` with v1.2.0 entries
- [x] Create `.github/labels.json` (20 labels: bug, enhancement, feature-specific, architecture, theme, i18n, performance, data-accuracy)
- [x] Delivery Report (بالمصري) — `DELIVERY_REPORT.md`

---

**🔒 BLUEPRINT LOCKED — No changes without documented justification.**

*IDRISIUM Corp — Engineering Excellence, Not Just Code.*  
*Founded by Idris Ghamid | إدريس غامد*
