/// Al-Furkan Plugin System — Interface-based extensibility
/// Allows dynamic registration of reciters, tafsirs, and translations
/// without compile-time dependencies on concrete implementations.

/// Base interface for all Al-Furkan plugins
abstract class AlFurkanPlugin {
  /// Unique identifier for this plugin
  String get id;

  /// Human-readable name
  String get name;

  /// Plugin version
  String get version;

  /// Plugin type category
  PluginType get type;

  /// Whether this plugin requires network access
  bool get requiresNetwork;

  /// Initialize the plugin (called on registration)
  Future<void> initialize();

  /// Dispose the plugin (called on unregistration)
  Future<void> dispose();
}

/// Plugin type categories
enum PluginType {
  reciter,
  tafsir,
  translation,
  audioSource,
  dataSource,
}

/// Plugin for adding new Quran reciters
abstract class ReciterPlugin implements AlFurkanPlugin {
  @override
  PluginType get type => PluginType.reciter;

  /// List of surahs available from this reciter
  List<int> get availableSurahs;

  /// Whether word-level segments are available
  bool get hasSegments;

  /// Get audio URL for a specific ayah
  String getAudioUrl(String ayahKey);

  /// Get segment timing data for a surah (for word-by-word sync)
  Future<Map<String, dynamic>?> getSegments(int surahNumber);
}

/// Plugin for adding new tafsir sources
abstract class TafsirPlugin implements AlFurkanPlugin {
  @override
  PluginType get type => PluginType.tafsir;

  /// Language code of this tafsir (e.g., 'ar', 'en')
  String get languageCode;

  /// Total number of surahs covered
  int get surahCount;

  /// Get tafsir text for a specific ayah
  Future<String?> getTafsirText(String ayahKey);

  /// Get all available ayah keys with tafsir
  Future<List<String>> getAvailableAyahKeys();
}

/// Plugin for adding new translation sources
abstract class TranslationPlugin implements AlFurkanPlugin {
  @override
  PluginType get type => PluginType.translation;

  /// ISO language code of this translation
  String get languageCode;

  /// Native language name (e.g., "العربية", "English")
  String get nativeLanguageName;

  /// Author name
  String get author;

  /// Get translation text for a specific ayah
  Future<String?> getTranslationText(String ayahKey);

  /// Get all available ayah keys with translation
  Future<List<String>> getAvailableAyahKeys();
}
