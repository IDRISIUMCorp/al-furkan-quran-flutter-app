import "package:al_furkan/src/platform_services.dart" as platform_services;

class ApisUrls {
  static String baseRender = "https://quran-backend-7hyd.onrender.com/";
  static String baseVercel = "https://quran-backend-delta.vercel.app/";
  static String basePrayerTime = "https://api.aladhan.com/v1/";

  /// Deterministic server selection — try Vercel first (more reliable),
  /// then Render as fallback. Random selection caused intermittent failures.
  static String get base {
    if (platform_services.getPlatform() ==
            platform_services.PlatformOwn.isWasm ||
        platform_services.getPlatform() ==
            platform_services.PlatformOwn.isWeb) {
      return baseVercel;
    }
    return baseVercel;
  }

  /// Fallback CDN URLs for resources not available on the primary backend.
  /// These are served from GitHub raw content (plain JSON, not BZip2).
  static const String cdnGitHub =
      "https://raw.githubusercontent.com/";

  /// Mutashabihat fallback (Waqar144/Quran_Mutashabihat_Data)
  static const String fallbackMutashabihat =
      "${cdnGitHub}Waqar144/Quran_Mutashabihat_Data/master/mutashabiha_data.json";

  /// Transliteration fallback (risan/quran-json)
  static const String fallbackTransliteration =
      "${cdnGitHub}risan/quran-json/main/dist/quran_transliteration.json";
}
