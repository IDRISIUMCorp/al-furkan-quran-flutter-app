/// Word Info Repository for downloading and loading Qiraat, Tasreef, Eerab data
/// Extracted and adapted from quran_library package
library;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import 'word_info_models.dart';

/// Callback for download progress
typedef DownloadProgressCallback = void Function(double progress);

/// Configuration for each WordInfo kind
class _WordInfoKindConfig {
  final String zipName;
  final String dirName;
  final List<String> zipUrls;
  final String webBaseUrl;

  const _WordInfoKindConfig({
    required this.zipName,
    required this.dirName,
    required this.zipUrls,
    required this.webBaseUrl,
  });
}

/// Repository for managing WordInfo data (Qiraat, Tasreef, Eerab)
class WordInfoRepository {
  WordInfoRepository();

  static const _downloadedKindsKey = 'word_info_downloaded_kinds';
  static const _downloadedKindsOrderKey = 'word_info_downloaded_kinds_order';

  /// Download URLs and configs for each kind
  static const Map<WordInfoKind, _WordInfoKindConfig> _configs = {
    WordInfoKind.recitations: _WordInfoKindConfig(
      zipName: 'word_qeraat.zip',
      dirName: 'word_qeraat',
      zipUrls: [
        'https://github.com/alheekmahlib/Islamic_database/releases/download/word_qeraat/word_qeraat.zip',
      ],
      webBaseUrl:
          'https://raw.githubusercontent.com/alheekmahlib/Islamic_database/main/quran_database/Quran%20Font/word_qeraat',
    ),
    WordInfoKind.tasreef: _WordInfoKindConfig(
      zipName: 'word_tasreef.zip',
      dirName: 'word_tasreef',
      zipUrls: [
        'https://github.com/alheekmahlib/Islamic_database/releases/download/word_tasreef/word_tasreef.zip',
      ],
      webBaseUrl:
          'https://raw.githubusercontent.com/alheekmahlib/Islamic_database/main/quran_database/quran_data/word_tasreef',
    ),
    WordInfoKind.eerab: _WordInfoKindConfig(
      zipName: 'word_eerab.zip',
      dirName: 'word_eerab',
      zipUrls: [
        'https://github.com/alheekmahlib/Islamic_database/releases/download/word_eerab/word_eerab.zip',
      ],
      webBaseUrl:
          'https://raw.githubusercontent.com/alheekmahlib/Islamic_database/main/quran_database/quran_data/word_eerab',
    ),
  };

  /// Cache for loaded surahs by kind
  final Map<WordInfoKind, Map<int, QiraatSurahWords>> _cacheByKind = {
    for (final k in WordInfoKind.values) k: <int, QiraatSurahWords>{},
  };

  final Map<WordInfoKind, int?> _remoteZipSizeBytesCache = {
    for (final k in WordInfoKind.values) k: null,
  };

  /// Currently loading surahs
  final Map<WordInfoKind, Set<int>> _loadingSurahsByKind = {
    for (final k in WordInfoKind.values) k: <int>{},
  };

  /// File paths by surah for each kind
  final Map<WordInfoKind, Map<int, String>> _filePathBySurahByKind = {
    for (final k in WordInfoKind.values) k: <int, String>{},
  };

  /// Whether index has been built for each kind
  final Map<WordInfoKind, bool> _indexReadyByKind = {
    for (final k in WordInfoKind.values) k: false,
  };

  /// Check if a kind is downloaded
  bool isKindDownloaded(WordInfoKind kind) {
    return _downloadedKinds().contains(kind.name);
  }

  List<String> getDownloadedOrderIds() {
    if (!Hive.isBoxOpen('user')) return const <String>[];
    final box = Hive.box('user');
    final raw = box.get(_downloadedKindsOrderKey, defaultValue: []);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const <String>[];
  }

  Future<void> setDownloadedOrderIds(List<String> ids) async {
    if (!Hive.isBoxOpen('user')) await Hive.openBox('user');
    final box = Hive.box('user');
    final seen = <String>{};
    final deduped = <String>[];
    for (final id in ids) {
      if (seen.add(id)) deduped.add(id);
    }
    await box.put(_downloadedKindsOrderKey, deduped);
  }

  Future<int?> getLocalKindSizeBytes(WordInfoKind kind) async {
    try {
      final dir = await _getKindDir(kind);
      if (!await dir.exists()) return null;
      int total = 0;
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final stat = await entity.stat();
          total += stat.size;
        }
      }
      return total;
    } catch (_) {
      return null;
    }
  }

  /// Download a specific kind
  Future<void> downloadKind({
    required WordInfoKind kind,
    required DownloadProgressCallback onProgress,
  }) async {
    if (isKindDownloaded(kind)) return;

    final config = _configs[kind]!;

    final baseDir = await getApplicationDocumentsDirectory();
    final destDir = Directory('${baseDir.path}/${config.dirName}');
    final zipFile = File('${baseDir.path}/${config.zipName}');

    // Reset index/cache
    _indexReadyByKind[kind] = false;
    _filePathBySurahByKind[kind]?.clear();
    _cacheByKind[kind]?.clear();

    try {
      // Download zip
      final dio = Dio();
      final response = await dio.get<List<int>>(
        config.zipUrls.first,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress((received / total) * 100);
          }
        },
      );

      // Save zip file
      await zipFile.writeAsBytes(response.data!, flush: true);

      // Extract zip
      await _extractZip(zipFile.path, destDir.path);

      // Build index
      await _ensureIndex(kind);

      // Mark as downloaded
      _markKindDownloaded(kind);

      // Cleanup zip
      if (await zipFile.exists()) {
        await zipFile.delete();
      }

      onProgress(100.0);
    } catch (e) {
      log('Error downloading ${kind.name}: $e', name: 'WordInfoRepository');
      rethrow;
    }
  }

  Future<int?> getRemoteZipSizeBytes(WordInfoKind kind) async {
    final cached = _remoteZipSizeBytesCache[kind];
    if (cached != null) return cached;

    final config = _configs[kind]!;
    final url = config.zipUrls.first;
    try {
      final dio = Dio();
      final response = await dio.head<dynamic>(url);
      final raw = response.headers.value('content-length');
      final bytes = raw == null ? null : int.tryParse(raw);
      _remoteZipSizeBytesCache[kind] = bytes;
      return bytes;
    } catch (_) {
      _remoteZipSizeBytesCache[kind] = null;
      return null;
    }
  }

  /// Get word info for a specific word
  Future<QiraatWordInfo?> getWordInfo({
    required WordInfoKind kind,
    required WordRef ref,
  }) async {
    if (!isKindDownloaded(kind)) return null;
    final surah = await _ensureSurahLoaded(kind: kind, surahNumber: ref.surahNumber);
    return surah?.lookup(ref);
  }

  /// Get word info synchronously (from cache only)
  QiraatWordInfo? getWordInfoSync({
    required WordInfoKind kind,
    required WordRef ref,
  }) {
    final surah = _cacheByKind[kind]?[ref.surahNumber];
    return surah?.lookup(ref);
  }

  /// Get all word info for an ayah
  Future<QiraatAyahWords?> getAyahWords({
    required WordInfoKind kind,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (!isKindDownloaded(kind)) return null;
    final surah = await _ensureSurahLoaded(kind: kind, surahNumber: surahNumber);
    return surah?.ayahsByNumber[ayahNumber];
  }

  /// Preload a surah into cache
  Future<bool> prewarmSurah(WordInfoKind kind, int surahNumber) async {
    if (!isKindDownloaded(kind)) return false;
    final cache = _cacheByKind[kind]!;
    final loading = _loadingSurahsByKind[kind]!;

    if (cache.containsKey(surahNumber)) return false;
    if (loading.contains(surahNumber)) return false;

    loading.add(surahNumber);
    try {
      await _ensureSurahLoaded(kind: kind, surahNumber: surahNumber);
      return cache.containsKey(surahNumber);
    } finally {
      loading.remove(surahNumber);
    }
  }

  /// Ensure a surah is loaded into cache
  Future<QiraatSurahWords?> _ensureSurahLoaded({
    required WordInfoKind kind,
    required int surahNumber,
  }) async {
    final cache = _cacheByKind[kind]!;
    final cached = cache[surahNumber];
    if (cached != null) return cached;

    await _ensureIndex(kind);
    final path = _filePathBySurahByKind[kind]?[surahNumber];
    if (path == null) return null;

    final file = File(path);
    if (!await file.exists()) return null;

    final text = await file.readAsString();
    final decoded = jsonDecode(text);
    if (decoded is! List) return null;

    final model = QiraatSurahWords.fromJson(
      surahNumber: surahNumber,
      jsonList: decoded,
    );
    cache[surahNumber] = model;
    return model;
  }

  /// Build index of surah files for a kind
  Future<void> _ensureIndex(WordInfoKind kind) async {
    if (_indexReadyByKind[kind] == true) return;
    _indexReadyByKind[kind] = true;

    final dir = await _getKindDir(kind);
    if (!await dir.exists()) return;

    final regex = RegExp(r'^sura_(\d{3})\.json$');
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final name = entity.path.split(Platform.pathSeparator).last;
      final match = regex.firstMatch(name);
      if (match == null) continue;
      final surahNumber = int.tryParse(match.group(1) ?? '');
      if (surahNumber == null) continue;
      _filePathBySurahByKind[kind]?[surahNumber] = entity.path;
    }
  }

  /// Get directory for a kind
  Future<Directory> _getKindDir(WordInfoKind kind) async {
    final config = _configs[kind]!;
    final baseDir = await getApplicationDocumentsDirectory();
    return Directory('${baseDir.path}/${config.dirName}');
  }

  /// Extract zip file using archive package
  Future<void> _extractZip(String zipPath, String destPath) async {
    final destDir = Directory(destPath);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    // Read zip file
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract all files
    for (final file in archive) {
      final outputPath = '$destPath/${file.name}';
      if (file.isFile) {
        final outputFile = File(outputPath);
        await outputFile.parent.create(recursive: true);
        await outputFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(outputPath).create(recursive: true);
      }
    }
    log('Extracted ${archive.length} files to $destPath', name: 'WordInfoRepository');
  }

  /// Get downloaded kinds from Hive storage
  Set<String> _downloadedKinds() {
    if (!Hive.isBoxOpen('user')) return <String>{};
    final box = Hive.box('user');
    final raw = box.get(_downloadedKindsKey);
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  /// Mark a kind as downloaded in Hive
  void _markKindDownloaded(WordInfoKind kind) {
    if (!Hive.isBoxOpen('user')) return;
    final box = Hive.box('user');
    final set = _downloadedKinds();
    set.add(kind.name);
    box.put(_downloadedKindsKey, set.toList());

    final orderRaw = box.get(_downloadedKindsOrderKey, defaultValue: []);
    final order = <String>[];
    if (orderRaw is List) {
      order.addAll(orderRaw.map((e) => e.toString()));
    }
    if (!order.contains(kind.name)) {
      order.add(kind.name);
      box.put(_downloadedKindsOrderKey, order);
    }
  }

  /// Clear cache for a kind
  void clearCache(WordInfoKind kind) {
    _cacheByKind[kind]?.clear();
  }

  /// Delete a downloaded kind
  Future<void> deleteKind(WordInfoKind kind) async {
    try {
      final dir = await _getKindDir(kind);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      
      if (!Hive.isBoxOpen('user')) await Hive.openBox('user');
      final box = Hive.box('user');
      final set = _downloadedKinds();
      set.remove(kind.name);
      await box.put(_downloadedKindsKey, set.toList());

      final orderRaw = box.get(_downloadedKindsOrderKey, defaultValue: []);
      if (orderRaw is List) {
        final order = orderRaw.map((e) => e.toString()).toList();
        order.remove(kind.name);
        await box.put(_downloadedKindsOrderKey, order);
      }
      
      clearCache(kind);
      _filePathBySurahByKind[kind]?.clear();
      _indexReadyByKind[kind] = false;
      
      log("Deleted WordInfo kind: ${kind.name}");
    } catch (e) {
      log("Error deleting WordInfo kind ${kind.name}: $e");
    }
  }

  /// Clear all caches
  void clearAllCaches() {
    for (final k in WordInfoKind.values) {
      _cacheByKind[k]?.clear();
    }
  }
}
