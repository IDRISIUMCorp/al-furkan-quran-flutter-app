# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-04-28

### Added — PHASE 6: QUALITY GATE
- Unit tests for `AzkarBloc` (7 test cases: initial state, load categories, error handling, load by type, decrement count, zero-count guard, reset daily counts)
- Unit tests for `HifzBloc` (5 test cases: initial state, load all progress, error handling, load stats, load due for review, load progress for surah)
- Unit tests for `AudioBloc` (8 test cases: initial state, load reciters, error, select reciter, play, pause, resume, stop, update position)
- Unit tests for `QiblaBloc` (5 test cases: initial state, load qibla info, error, update location, compass availability)
- Unit tests for `TafsirBloc` (5 test cases: initial state, load all tafsirs, error, select tafsir, load for ayah, load for surah)
- Unit tests for `PrayerBloc` (3 test cases: initial state, load today, error, refresh)
- Manual mock repositories for all 6 features (no code-gen dependency)
- Theme compliance verified: ZERO hardcoded colors in new modules
- Architecture integrity verified: Domain entities have ZERO Flutter imports
- Dart analyze: ZERO errors/warnings across entire codebase

### Added — PHASE 7: SHIP
- Updated `README.md` with PHASE 4–5 feature descriptions
- Updated `CONTRIBUTING.md` with modular architecture docs, feature module table, and theme compliance rules
- Created `CODE_OF_CONDUCT.md` (Contributor Covenant v2.1)
- Created GitHub issue templates: Bug Report, Feature Request
- Created GitHub Pull Request template with theme compliance checklist
- Created `.github/labels.json` with 20 categorized labels
- Created `DELIVERY_REPORT.md` — comprehensive project delivery report

### Fixed
- `api_client.dart`: Fixed `DioException` constructor parameter (`originalError` → `error`) for Dio 5.x compatibility
- Removed `bloc_test` dependency (network issue) — tests written with `flutter_test` only

## [1.1.0] - 2025-04-28

### Added — PHASE 4: THE UI
- Presentation BLoCs for Audio, Tafsir, Azkar, Qibla, Hifz modules
- BLoC DI registrations in all feature injection files
- Shared UI widgets: SkeletonLoading, ErrorStateWidget, EmptyStateWidget
- Shared UI widgets: Pressable (scale feedback), PressableOpacity, AppCard, SectionHeader, AppChip
- Feature screens: AzkarCategoriesScreen, AzkarItemsScreen with type filter chips
- Feature screens: QiblaScreen with custom compass painter
- Feature screens: HifzDashboardScreen with stats grid and progress cards
- Feature screens: TafsirScreen, TafsirDetailScreen
- Feature screens: AudioScreen with reciter list
- Feature screens: PrayerTimesScreen with next prayer highlight
- IDRISIUM Signature About screen with glassmorphism and animations

### Changed
- Migrated all deprecated `ayaX` color aliases to new `lightX` token names
- Removed all deprecated legacy aliases from AppColors
- Fixed `app_decorations.dart` import path for AppSizes
- Updated test file to remove legacy alias test

## [1.0.0] - 2025-01-01

### Added
- Advanced Uthmanic (QCF) Quran rendering engine with 6 fonts
- 3 mushaf layout modes: single page, double page, continuous scroll
- Word-level Ayah analysis library (translation, grammar, morphology, qira'at, mutashabihat, topics, transliteration)
- 61 tafsirs across 25 languages
- 209+ translations across 50+ languages
- 56 reciters with multiple riwayat (Hafs, Warsh, Qalun, etc.)
- Advanced audio player with repeat, speed control, sleep timer, background playback
- Offline audio download and management system
- Prayer times with multiple calculation methods
- Qibla compass with AR view
- Comprehensive Azkar (morning, evening, prayer, sleep, etc.)
- Sunnah guide with daily practices
- Smart Khatma tracking with multiple plans
- Advanced notification system (khatma, azkar, ayah of the day, prayer times)
- Customizable home widget (Ayah of the Day)
- Hifz/Memorization mode with 3 concealment levels
- Night reading mode with automatic sunset activation
- Collections and bookmarks system
- Ayah sharing as text or customizable image
- BLoC + Clean Architecture
- Dependency injection with GetIt
- Offline-first with Hive CE
- Multi-language support (Arabic, English, Urdu, Turkish, Indonesian, Malay, French, and more)
- Light/Dark theme with Ayah-inspired color palette
- Firebase integration (Auth, Firestore, FCM)
- Admin system with analytics dashboard
- MSIX packaging for Windows Store
- Custom QCF Quran package with auto-update
- Patched flutter_compass_v2 for improved accuracy

### Changed
- Refactored mushaf_screen.dart (7600+ lines) into modular components
- Migrated to Hive CE for improved performance
- Upgraded to Flutter 3.10+ / Dart 3+

### Removed
- Unused dependencies: connectivity_plus, fl_chart, firebase_analytics, firebase_remote_config, firebase_storage, permission_handler, web, meta, bloc, path
- Duplicate flutter_launcher_icons (consolidated to icons_launcher)
