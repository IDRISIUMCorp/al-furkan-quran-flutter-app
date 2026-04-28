import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/azkar.dart';
import '../models/azkar_model.dart';

/// Azkar Local Data Source — JSON assets + Hive for progress tracking
class AzkarLocalDataSource {
  final Box _azkarBox;
  final SharedPreferences _prefs;

  /// Expose prefs for repository reset operations
  SharedPreferences get prefs => _prefs;

  AzkarLocalDataSource({
    required Box azkarBox,
    required SharedPreferences prefs,
  })  : _azkarBox = azkarBox,
        _prefs = prefs;

  static const String _keyCategories = 'azkar_categories_cache';
  static const String _keyAzkarPrefix = 'azkar_items_';
  static const String _keyProgressPrefix = 'azkar_progress_';
  static const String _keySelectedType = 'azkar_selected_type';

  /// Load azkar categories from bundled JSON assets
  Future<List<AzkarCategoryModel>> loadCategories() async {
    // Try cache first
    final cached = _azkarBox.get(_keyCategories) as String?;
    if (cached != null) {
      final list = jsonDecode(cached) as List<dynamic>;
      return list
          .map((e) => AzkarCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Load from assets
    final jsonStr = await rootBundle.loadString('assets/azkar/categories.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    final models = list
        .map((e) => AzkarCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache for offline use
    await _azkarBox.put(
      _keyCategories,
      jsonEncode(models.map((m) => m.toJson()).toList()),
    );

    return models;
  }

  /// Load azkar items for a specific category
  Future<List<AzkarItemModel>> loadAzkarByCategory(int categoryId) async {
    final cacheKey = '$_keyAzkarPrefix$categoryId';
    final cached = _azkarBox.get(cacheKey) as String?;
    if (cached != null) {
      final list = jsonDecode(cached) as List<dynamic>;
      return list
          .map((e) => AzkarItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Load from assets
    final jsonStr =
        await rootBundle.loadString('assets/azkar/category_$categoryId.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    final models = list
        .map((e) => AzkarItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache for offline use
    await _azkarBox.put(
      cacheKey,
      jsonEncode(models.map((m) => m.toJson()).toList()),
    );

    return models;
  }

  /// Get azkar progress (completed count) for a category
  int getAzkarProgress(int categoryId) {
    return _prefs.getInt('$_keyProgressPrefix$categoryId') ?? 0;
  }

  /// Save azkar progress for a category
  Future<void> saveAzkarProgress(int categoryId, int completedCount) async {
    await _prefs.setInt('$_keyProgressPrefix$categoryId', completedCount);
  }

  /// Get selected azkar type
  String getSelectedType() {
    return _prefs.getString(_keySelectedType) ?? AzkarType.morning.name;
  }

  /// Save selected azkar type
  Future<void> saveSelectedType(String type) async {
    await _prefs.setString(_keySelectedType, type);
  }
}
