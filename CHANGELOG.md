# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
