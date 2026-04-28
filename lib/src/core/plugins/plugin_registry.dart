import 'package:flutter/foundation.dart';

import 'plugin_interface.dart';

/// Al-Furkan Plugin Registry — Central registration point for all plugins
/// Modules consume plugins via this registry, never instantiate directly.
class PluginRegistry {
  PluginRegistry._();

  static final Map<String, AlFurkanPlugin> _plugins = {};
  static final Map<PluginType, List<AlFurkanPlugin>> _pluginsByType = {
    for (final type in PluginType.values) type: [],
  };

  /// Register a plugin
  static Future<void> register(AlFurkanPlugin plugin) async {
    if (_plugins.containsKey(plugin.id)) {
      if (kDebugMode) {
        debugPrint('PluginRegistry: Re-registering plugin ${plugin.id}');
      }
      await unregister(plugin.id);
    }

    await plugin.initialize();
    _plugins[plugin.id] = plugin;
    _pluginsByType[plugin.type]!.add(plugin);
  }

  /// Unregister a plugin by ID
  static Future<void> unregister(String pluginId) async {
    final plugin = _plugins.remove(pluginId);
    if (plugin != null) {
      _pluginsByType[plugin.type]!.remove(plugin);
      await plugin.dispose();
    }
  }

  /// Get a plugin by ID
  static T? get<T extends AlFurkanPlugin>(String pluginId) {
    final plugin = _plugins[pluginId];
    if (plugin is T) return plugin;
    return null;
  }

  /// Get all plugins of a specific type
  static List<T> getByType<T extends AlFurkanPlugin>(PluginType type) {
    return _pluginsByType[type]!
        .whereType<T>()
        .toList(growable: false);
  }

  /// Get all registered reciters
  static List<ReciterPlugin> get reciters =>
      getByType<ReciterPlugin>(PluginType.reciter);

  /// Get all registered tafsirs
  static List<TafsirPlugin> get tafsirs =>
      getByType<TafsirPlugin>(PluginType.tafsir);

  /// Get all registered translations
  static List<TranslationPlugin> get translations =>
      getByType<TranslationPlugin>(PluginType.translation);

  /// Get count of registered plugins
  static int get count => _plugins.length;

  /// Check if a plugin is registered
  static bool isRegistered(String pluginId) => _plugins.containsKey(pluginId);

  /// Clear all plugins (for testing)
  static Future<void> clearAll() async {
    for (final plugin in _plugins.values.toList()) {
      await plugin.dispose();
    }
    _plugins.clear();
    for (final type in PluginType.values) {
      _pluginsByType[type]!.clear();
    }
  }
}
