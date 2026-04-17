import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_furkan/src/screen/azkar/models/azkar_share_settings.dart';

/// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
/// AZKAR SHARE PREFERENCES - ╪¡┘ü╪╕ ┘ê╪¬╪¡┘à┘è┘ä ╪º┘ä╪Ñ╪╣╪»╪º╪»╪º╪¬
/// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
/// ╪º╪│╪¬╪«╪»╪º┘à SharedPreferences ┘ä╪¡┘ü╪╕ ╪¬┘ü╪╢┘è┘ä╪º╪¬ ╪º┘ä┘à╪│╪¬╪«╪»┘à
/// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

class AzkarSharePreferences {
  static const _keySettings = 'azkar_share_settings_v2';
  static const _keyFavoriteTheme = 'azkar_favorite_theme';
  static const _keyFavoriteTemplate = 'azkar_favorite_template';

  /// ╪¡┘ü╪╕ ╪º┘ä╪Ñ╪╣╪»╪º╪»╪º╪¬ ┘â╪º┘à┘ä╪⌐
  static Future<bool> saveSettings(AzkarShareSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySettings, settings.toJsonString());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ╪¬╪¡┘à┘è┘ä ╪º┘ä╪Ñ╪╣╪»╪º╪»╪º╪¬ ╪º┘ä┘à╪¡┘ü┘ê╪╕╪⌐
  static Future<AzkarShareSettings?> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keySettings);
      if (json == null) return null;
      return AzkarShareSettings.fromJsonString(json);
    } catch (e) {
      return null;
    }
  }

  /// ╪¡┘ü╪╕ ╪º┘ä╪½┘è┘à ╪º┘ä┘à┘ü╪╢┘ä ┘ü┘é╪╖
  static Future<bool> saveFavoriteTheme(String themeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFavoriteTheme, themeId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ╪¬╪¡┘à┘è┘ä ╪º┘ä╪½┘è┘à ╪º┘ä┘à┘ü╪╢┘ä
  static Future<String?> loadFavoriteTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyFavoriteTheme);
    } catch (e) {
      return null;
    }
  }

  /// ╪¡┘ü╪╕ ╪º┘ä┘é╪º┘ä╪¿ ╪º┘ä┘à┘ü╪╢┘ä
  static Future<bool> saveFavoriteTemplate(String templateType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFavoriteTemplate, templateType);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ╪¬╪¡┘à┘è┘ä ╪º┘ä┘é╪º┘ä╪¿ ╪º┘ä┘à┘ü╪╢┘ä
  static Future<String?> loadFavoriteTemplate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyFavoriteTemplate);
    } catch (e) {
      return null;
    }
  }

  /// ┘à╪│╪¡ ┘â┘ä ╪º┘ä╪Ñ╪╣╪»╪º╪»╪º╪¬
  static Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySettings);
      await prefs.remove(_keyFavoriteTheme);
      await prefs.remove(_keyFavoriteTemplate);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ╪º┘ä╪¬╪¡┘é┘é ┘à┘å ┘ê╪¼┘ê╪» ╪Ñ╪╣╪»╪º╪»╪º╪¬ ┘à╪¡┘ü┘ê╪╕╪⌐
  static Future<bool> hasSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_keySettings);
    } catch (e) {
      return false;
    }
  }
}
