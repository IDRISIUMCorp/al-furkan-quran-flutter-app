import '../plugins/plugin_interface.dart';
import '../plugins/plugin_registry.dart';

/// Al-Furkan Module Registrar — Registers all modules and plugins with DI
/// Called during app bootstrap. Each module registers its own services.
class ModuleRegistrar {
  ModuleRegistrar._();

  /// Register all core modules and their plugins
  static Future<void> registerAll() async {
    // Plugin registration happens after module initialization
    // Modules are registered via GetIt in service_locator.dart
    // This method handles plugin-specific registration
    await _registerPlugins();
  }

  /// Register built-in plugins
  static Future<void> _registerPlugins() async {
    // Built-in reciter, tafsir, and translation plugins
    // are registered by their respective modules during init.
    // Third-party plugins can be registered here or via
    // PluginRegistry.register() from external code.
  }

  /// Register a single external plugin
  static Future<void> registerPlugin(AlFurkanPlugin plugin) async {
    await PluginRegistry.register(plugin);
  }

  /// Unregister a plugin by ID
  static Future<void> unregisterPlugin(String pluginId) async {
    await PluginRegistry.unregister(pluginId);
  }

  /// Dispose all modules and plugins (for testing or app shutdown)
  static Future<void> disposeAll() async {
    await PluginRegistry.clearAll();
  }
}
