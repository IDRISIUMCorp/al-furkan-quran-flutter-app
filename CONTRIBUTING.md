# Contributing to Al-Furkan الفُرقان

First off, thank you for considering contributing to Al-Furkan! 🕌

This project is an **open-source Quran application** built as a _صدقة جارية_ (ongoing charity). Every contribution matters.

---

## Code of Conduct

This project follows the principle of **respect and sincerity**. We build for the Ummah. Disrespectful behavior, trolling, or unconstructive criticism will not be tolerated.

---

## How Can I Contribute?

### Bug Reports
- Open a [GitHub Issue](../../issues)
- Use the **Bug Report** template
- Include: device info, Flutter version, steps to reproduce, expected vs actual behavior

### Feature Requests
- Open a [GitHub Issue](../../issues)
- Use the **Feature Request** template
- Explain the use case and why it benefits Quran readers

### Pull Requests
1. **Fork** the repository
2. Create a **feature branch**: `git checkout -b feature/my-feature`
3. Make your changes with **clear commit messages**
4. Ensure `flutter analyze` passes with zero warnings
5. Add tests for new functionality
6. Submit a **Pull Request** with a clear description

---

## Development Setup

### Prerequisites
- Flutter SDK 3.10+ (Dart 3+)
- Android Studio / VS Code with Flutter extensions
- A physical device or emulator for testing

### Getting Started
```bash
# Clone the repo
git clone https://github.com/IDRISIUMCorp/al-furkan-quran-flutter-app.git
cd al-furkan-quran-flutter-app

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run the app
flutter run
```

### Firebase Setup (Optional — for admin features)
1. Create a Firebase project
2. Add your `google-services.json` to `android/app/`
3. Copy `.env.example` to `.env` and fill in your config
4. The app works **offline-first** without Firebase for core features

---

## Architecture

Al-Furkan follows **BLoC + Clean Architecture** with modular feature packages:

```
lib/
├── core/               # Theme, DI, storage, notifications, audio
├── features/           # Modular feature packages (Clean Architecture)
│   └── [feature]/
│       ├── data/       # Models, datasources, repository implementations
│       ├── domain/     # Entities (ZERO Flutter imports), repo interfaces, use cases
│       └── presentation/ # BLoC, screens, widgets
├── src/
│   ├── screen/         # Legacy UI screens (mushaf, settings, about)
│   ├── widget/         # Legacy reusable widgets
│   ├── core/           # Core services (audio, settings, storage, notifications)
│   ├── shared/         # Shared widgets (SkeletonLoading, ErrorState, Pressable, AppCard)
│   ├── theme/          # Theme system (AppColors, AppTextStyles, AppTheme, AppDecorations)
│   ├── constants/      # AppStrings, AppSizes, AppAssets, AppDurations
│   └── utils/          # Utilities and extensions
└── main.dart
```

### Feature Modules (Clean Architecture)
Each feature under `lib/src/features/` follows the same 3-layer pattern:

| Feature | BLoC | Screen(s) | DI File |
|---------|------|-----------|---------|
| Audio | `AudioBloc` | `AudioScreen` | `audio_injection.dart` |
| Tafsir | `TafsirBloc` | `TafsirScreen`, `TafsirDetailScreen` | `tafsir_injection.dart` |
| Azkar | `AzkarBloc` | `AzkarCategoriesScreen`, `AzkarItemsScreen` | `azkar_injection.dart` |
| Qibla | `QiblaBloc` | `QiblaScreen` | `qibla_injection.dart` |
| Hifz | `HifzBloc` | `HifzDashboardScreen` | `hifz_injection.dart` |
| Prayer | `PrayerBloc` | `PrayerTimesScreen` | `prayer_injection.dart` |

### Key Patterns
- **State Management**: `flutter_bloc` (Cubit + Bloc) — BLoC for event-heavy flows, Cubit for simple state
- **Dependency Injection**: `get_it` with `registerFactory` for BLoCs
- **Error Handling**: `Either<Failure, T>` from `dartz` — ZERO raw exceptions in domain/presentation
- **Theme Tokens**: All colors via `AppColors`, all spacing via `AppSizes`, all strings via `AppStrings`
- **Local Storage**: `hive_ce` + `shared_preferences`
- **Network**: `dio` via centralized `ApiClient` singleton

---

## Coding Standards

### Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` before every commit
- Maximum line length: **80 characters**
- Use single quotes for strings (except in generated code)

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `lowerCamelCase` (Dart convention)
- Private members: prefix with `_`

### Comments
- Use English for code comments
- Document public APIs with `///` doc comments
- Avoid commenting obvious code — write self-documenting code instead

### Theme Compliance (Non-Negotiable)
- **ZERO hardcoded colors** — always use `AppColors` tokens (e.g., `AppColors.lightBackground`, `AppColors.accentPrimary`)
- **ZERO hardcoded font sizes** — use `AppTextStyles` or `AppSizes` tokens
- **ZERO hardcoded strings** — use `AppStrings` or `AppLocalizations`
- **ZERO hardcoded spacing** — use `AppSizes` tokens (8dp grid system)
- **RTL support** — use `EdgeInsets.symmetric()` instead of `EdgeInsets.only(left:/right:)` for Arabic content
- **Dark/Light mode** — test every screen in both themes before submitting

### Commits
- Use [Conventional Commits](https://www.conventionalcommits.org/):
  - `feat: add bookmark sync feature`
  - `fix: resolve audio playback on background`
  - `refactor: extract mushaf page widget`
  - `docs: update README with new screenshots`
  - `test: add unit tests for settings repository`

---

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/src/core/settings/settings_repository_test.dart
```

### Testing Guidelines
- Write **unit tests** for repositories and use cases
- Write **widget tests** for complex UI components
- Write **integration tests** for critical user flows
- Aim for meaningful coverage, not 100% line coverage

---

## Release Process

1. Update `version` in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Run `flutter analyze` — must pass clean
4. Run `flutter test` — must pass
5. Build release artifacts
6. Tag the release: `git tag v1.x.x`

---

## Questions?

- Open a [GitHub Discussion](../../discussions)
- Contact the maintainer: [@IDRV72](https://t.me/IDRV72)

---

_JazakAllahu Khairan for contributing to this Sadaqah Jariyah project._ 🤲
