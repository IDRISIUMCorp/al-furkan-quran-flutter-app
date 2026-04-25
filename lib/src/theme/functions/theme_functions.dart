import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:shared_preferences/shared_preferences.dart";

class ThemeFunctions {
  static SharedPreferences? preferences;

  static Future<void> initThemeFunction() async {
    preferences = await SharedPreferences.getInstance();
  }

  static Future<void> setThemeMode(ThemeMode themeMode) async {
    systemChromeSetting(themeMode);
    await preferences!.setString("app_theme_mode", themeMode.toString());
  }

  static ThemeMode loadThemeMode() {
    assert(preferences != null, "Theme Function need to be init first");
    final String? savedThemeName = preferences!.getString("app_theme_mode");
    ThemeMode themeMode =
        savedThemeName == null
            ? ThemeMode.system
            : ThemeMode.values.firstWhere(
              (e) => e.toString() == savedThemeName,
            );
    systemChromeSetting(themeMode);
    return themeMode;
  }

  static void systemChromeSetting(ThemeMode themeMode) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
}
