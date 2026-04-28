import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../constants/app_strings.dart';
import '../models/bookmark_model.dart';
import '../models/surah_model.dart';

/// Quran Local Data Source — Hive-based persistence for Quran data
class QuranLocalDataSource {
  final Box _userBox;
  final Box _pinnedBox;

  QuranLocalDataSource({
    required Box userBox,
    required Box pinnedBox,
  })  : _userBox = userBox,
        _pinnedBox = pinnedBox;

  // ── Surahs ──

  Future<List<SurahModel>> getAllSurahs() async {
    final data = _userBox.get(AppStrings.hiveKeySurahs);
    if (data == null) throw CacheException(message: 'Surahs data not found');
    final List<dynamic> jsonList = jsonDecode(data as String);
    return jsonList.map((e) => SurahModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveSurahs(List<SurahModel> surahs) async {
    final jsonList = surahs.map((e) => e.toJson()).toList();
    await _userBox.put(AppStrings.hiveKeySurahs, jsonEncode(jsonList));
  }

  // ── Bookmarks ──

  Future<List<BookmarkModel>> getBookmarks() async {
    final data = _userBox.get(AppStrings.hiveKeyBookmarks);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data as String);
    return jsonList.map((e) => BookmarkModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveBookmarks(List<BookmarkModel> bookmarks) async {
    final jsonList = bookmarks.map((e) => e.toJson()).toList();
    await _userBox.put(AppStrings.hiveKeyBookmarks, jsonEncode(jsonList));
  }

  // ── Last Read Position ──

  Future<({int page, String ayahKey})> getLastReadPosition() async {
    final page = _userBox.get(AppStrings.prefsKeyLastPage) as int? ?? 1;
    final ayahKey = _userBox.get(AppStrings.prefsKeyLastAyahKey) as String? ?? '1:1';
    return (page: page, ayahKey: ayahKey);
  }

  Future<void> saveLastReadPosition({
    required int page,
    required String ayahKey,
  }) async {
    await _userBox.put(AppStrings.prefsKeyLastPage, page);
    await _userBox.put(AppStrings.prefsKeyLastAyahKey, ayahKey);
  }

  // ── Pinned Surahs ──

  Future<List<int>> getPinnedSurahs() async {
    final data = _pinnedBox.get('pinned_surahs');
    if (data == null) return [];
    return (data as List).cast<int>();
  }

  Future<void> savePinnedSurahs(List<int> surahIds) async {
    await _pinnedBox.put('pinned_surahs', surahIds);
  }
}
