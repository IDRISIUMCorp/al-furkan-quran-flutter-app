/// Al-Furkan User-Facing String Constants — Single Source of Truth
/// ZERO hardcoded user-facing strings outside this file and l10n ARB files.
/// For localized strings, use AppLocalizations (generated from ARB).
/// This file holds non-localized technical strings only.
class AppStrings {
  AppStrings._();

  // ── App Identity ──
  static const String appName = 'Al-Furkan';
  static const String appNameAr = 'الفُرقان';
  static const String publisher = 'IDRISIUM Corp';
  static const String founderName = 'Idris Ghamid';
  static const String founderNameAr = 'إدريس غامد';
  static const String founderTitle = 'Founder & Software Architect';
  static const String tagline = 'Engineered with precision by IDRISIUM Corp';

  // ── URLs ──
  static const String website = 'http://idrisium.linkpc.net/';
  static const String githubIdrisium = 'https://github.com/IDRISIUMCorp';
  static const String githubFounder = 'https://github.com/idris-ghamid';
  static const String telegram = 'https://t.me/IDRV72';
  static const String email = 'idris.ghamid@gmail.com';

  // ── Data Source Attribution ──
  static const String quranDataSource = 'Tanzil.net';
  static const String quranDataVersion = 'v1.1 (Uthmanic)';
  static const String prayerTimeApi = 'Aladhan.com';

  // ── Error Messages (fallback — prefer l10n for user-facing) ──
  static const String errorNetwork = 'No internet connection';
  static const String errorTimeout = 'Request timed out';
  static const String errorServer = 'Server error occurred';
  static const String errorUnknown = 'An unexpected error occurred';
  static const String errorDataIntegrity =
      'Data integrity check failed — resource may be corrupted';

  // ── Notification Channel ──
  static const String notificationChannelId = 'al_furkan_notifications';
  static const String notificationChannelName = 'Al-Furkan Notifications';

  // ── Hive Box Names ──
  static const String hiveBoxUser = 'user';
  static const String hiveBoxPinned = 'pinned';
  static const String hiveBoxNotes = 'notes';

  // ── Hive Data Keys ──
  static const String hiveKeySurahs = 'surahs_data';
  static const String hiveKeyBookmarks = 'bookmarks_data';
  static const String hiveKeyNotes = 'notes_data';

  // ── Shared Preferences Keys ──
  static const String prefFirstRun = 'idrisium_first_run_defaults_applied';
  static const String prefLanguageCode = 'selectedLanguageCode';
  static const String prefThemeMode = 'app_theme_mode';
  static const String prefsKeyLastPage = 'last_page';
  static const String prefsKeyLastAyahKey = 'last_ayah_key';

  // ── Route Names ──
  static const String routeHome = '/';
  static const String routeScript = '/script';
  static const String routeSearch = '/search';
  static const String routePrayer = '/prayer';
  static const String routeQibla = '/qibla';
  static const String routeAzkar = '/azkar';
  static const String routeSunnah = '/sunnah';
  static const String routeWudu = '/wudu';
  static const String routeSettings = '/settings';
  static const String routeSettingsTheme = '/settings/theme';
  static const String routeSettingsNotifications = '/settings/notifications';
  static const String routeSettingsLanguage = '/settings/language';
  static const String routeAbout = '/about';
  static const String routeBookmarks = '/bookmarks';
  static const String routeHifz = '/hifz';
  static const String routeStats = '/stats';
  static const String routeResources = '/resources';
  static const String routeOffline = '/offline';
  static const String routeKhatma = '/khatma';
  static const String routeOnboarding = '/onboarding';
}
