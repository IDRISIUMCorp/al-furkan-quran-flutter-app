import "dart:io";
import "dart:async";

import "package:al_furkan/main.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/core/audio/player/audio_player_manager.dart";
import "package:al_furkan/src/core/audio/resources/recitations.dart";
import "package:al_furkan/src/resources/quran_resources/meta/meta_data_surah.dart";

import "package:al_furkan/src/resources/quran_resources/quran_ayah_count.dart";
import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:path/path.dart" as p;

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Offline Audio Service — Download Manager & Storage
// ═══════════════════════════════════════════════════════════════════

/// Tracks download progress for a single surah.
class SurahDownloadProgress {
  final int surahNumber;
  final int totalAyahs;
  final int downloadedAyahs;
  final bool isDownloading;
  final String? error;

  const SurahDownloadProgress({
    required this.surahNumber,
    required this.totalAyahs,
    this.downloadedAyahs = 0,
    this.isDownloading = false,
    this.error,
  });

  double get progress => totalAyahs > 0 ? downloadedAyahs / totalAyahs : 0.0;

  SurahDownloadProgress copyWith({
    int? surahNumber,
    int? totalAyahs,
    int? downloadedAyahs,
    bool? isDownloading,
    String? error,
  }) =>
      SurahDownloadProgress(
        surahNumber: surahNumber ?? this.surahNumber,
        totalAyahs: totalAyahs ?? this.totalAyahs,
        downloadedAyahs: downloadedAyahs ?? this.downloadedAyahs,
        isDownloading: isDownloading ?? this.isDownloading,
        error: error,
      );
}

/// Info about a downloaded reciter's surah.
class DownloadedSurahInfo {
  final ReciterInfoModel reciter;
  final int surahNumber;
  final int ayahCount;
  final int sizeBytes;

  const DownloadedSurahInfo({
    required this.reciter,
    required this.surahNumber,
    required this.ayahCount,
    required this.sizeBytes,
  });

  String get surahName {
    try {
      return metaDataSurah[surahNumber.toString()]?["name"] ?? "سورة $surahNumber";
    } catch (_) {
      return "سورة $surahNumber";
    }
  }

  String get reciterLabel => "${reciter.name} (${reciter.style ?? ''})";
}

class OfflineAudioService {
  OfflineAudioService._();

  static final _dio = Dio();
  static final Map<String, CancelToken> _cancelTokens = {};

  /// Stream controllers for download progress per surah.
  static final Map<String, StreamController<SurahDownloadProgress>>
      _progressControllers = {};

  /// Get progress stream for a specific surah download.
  static Stream<SurahDownloadProgress> progressStream(
    ReciterInfoModel reciter,
    int surahNumber,
  ) {
    final key = _downloadKey(reciter, surahNumber);
    _progressControllers.putIfAbsent(
      key,
      () => StreamController<SurahDownloadProgress>.broadcast(),
    );
    return _progressControllers[key]!.stream;
  }

  // ─── Download ──────────────────────────────────────────────

  /// Download all ayahs of a surah for a specific reciter.
  static Future<bool> downloadSurah({
    required ReciterInfoModel reciter,
    required int surahNumber,
  }) async {
    if (applicationDataPath == null) return false;

    final key = _downloadKey(reciter, surahNumber);
    final cancelToken = CancelToken();
    _cancelTokens[key] = cancelToken;

    final surahDir = _surahDir(reciter, surahNumber);
    final totalAyahs = quranAyahCount[surahNumber - 1];

    // Ensure directory exists
    await Directory(surahDir).create(recursive: true);

    final controller = _getProgressController(key);
    controller.add(SurahDownloadProgress(
      surahNumber: surahNumber,
      totalAyahs: totalAyahs,
      isDownloading: true,
    ));

    int downloaded = 0;

    try {
      int skipped404 = 0;
      for (int ayah = 1; ayah <= totalAyahs; ayah++) {
        if (cancelToken.isCancelled) break;

        final ayahKey = "$surahNumber:$ayah";
        final targetFile = p.join(surahDir, "${ayah.toString().padLeft(3, '0')}.mp3");

        // Skip if already downloaded
        if (await File(targetFile).exists()) {
          downloaded++;
          controller.add(SurahDownloadProgress(
            surahNumber: surahNumber,
            totalAyahs: totalAyahs,
            downloadedAyahs: downloaded,
            isDownloading: true,
          ));
          continue;
        }

        final url = AudioPlayerManager.getUrlOfAudioFromAyahKey(ayahKey, reciter);

        try {
          await _dio.download(
            url,
            targetFile,
            cancelToken: cancelToken,
            options: Options(
              responseType: ResponseType.bytes,
              receiveTimeout: const Duration(seconds: 30),
            ),
          );
          downloaded++;
        } on DioException catch (dioErr) {
          // 404 = ayah not available for this reciter — skip gracefully
          if (dioErr.response?.statusCode == 404) {
            skipped404++;
            debugPrint("⚠️ Ayah $ayahKey not available (404) for ${reciter.name} — skipping");
            // Clean up any partial file
            final f = File(targetFile);
            if (await f.exists()) await f.delete();
          } else {
            rethrow;
          }
        }

        controller.add(SurahDownloadProgress(
          surahNumber: surahNumber,
          totalAyahs: totalAyahs,
          downloadedAyahs: downloaded,
          isDownloading: true,
        ));
      }

      final errorMsg = skipped404 > 0 ? "تخطي $skipped404 آية غير متاحة" : null;
      controller.add(SurahDownloadProgress(
        surahNumber: surahNumber,
        totalAyahs: totalAyahs,
        downloadedAyahs: downloaded,
        isDownloading: false,
        error: errorMsg,
      ));

      return downloaded > 0;
    } catch (e) {
      if (cancelToken.isCancelled) {
        debugPrint("⏹ Download cancelled for surah $surahNumber");
      } else {
        debugPrint("❌ Download error for surah $surahNumber: $e");
      }
      controller.add(SurahDownloadProgress(
        surahNumber: surahNumber,
        totalAyahs: totalAyahs,
        downloadedAyahs: downloaded,
        isDownloading: false,
        error: e.toString(),
      ));
      return false;
    } finally {
      _cancelTokens.remove(key);
    }
  }

  /// Download multiple surahs sequentially.
  static Future<int> downloadSurahs({
    required ReciterInfoModel reciter,
    required List<int> surahNumbers,
  }) async {
    int successCount = 0;
    for (final sn in surahNumbers) {
      final ok = await downloadSurah(reciter: reciter, surahNumber: sn);
      if (ok) successCount++;
    }
    return successCount;
  }

  /// Cancel an ongoing download.
  static void cancelDownload(ReciterInfoModel reciter, int surahNumber) {
    final key = _downloadKey(reciter, surahNumber);
    _cancelTokens[key]?.cancel();
    _cancelTokens.remove(key);
  }

  // ─── Delete ─────────────────────────────────────────────────

  /// Delete a downloaded surah directory.
  static Future<bool> deleteSurah({
    required ReciterInfoModel reciter,
    required int surahNumber,
  }) async {
    final dir = _surahDir(reciter, surahNumber);
    final d = Directory(dir);
    if (await d.exists()) {
      await d.delete(recursive: true);
      debugPrint("🗑️ Deleted surah $surahNumber for ${reciter.name}");
      return true;
    }
    return false;
  }

  /// Delete all downloaded data for a reciter.
  static Future<bool> deleteReciter(ReciterInfoModel reciter) async {
    final dir = _reciterDir(reciter);
    final d = Directory(dir);
    if (await d.exists()) {
      await d.delete(recursive: true);
      debugPrint("🗑️ Deleted all data for ${reciter.name}");
      return true;
    }
    return false;
  }

  /// Delete all downloaded recitations.
  static Future<void> deleteAll() async {
    if (applicationDataPath == null) return;
    final dir = Directory(p.join(applicationDataPath!, "recitations"));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      debugPrint("🗑️ Deleted all offline recitations");
    }
  }

  // ─── Query ──────────────────────────────────────────────────

  /// Check if a specific surah is fully downloaded for a reciter.
  static Future<bool> isSurahDownloaded({
    required ReciterInfoModel reciter,
    required int surahNumber,
  }) async {
    final dir = _surahDir(reciter, surahNumber);
    final d = Directory(dir);
    if (!await d.exists()) return false;

    final totalAyahs = quranAyahCount[surahNumber - 1];
    int count = 0;
    await for (final entity in d.list()) {
      if (entity is File && entity.path.endsWith('.mp3')) count++;
    }
    return count >= totalAyahs;
  }

  /// Get list of downloaded surah numbers for a reciter.
  static Future<List<int>> getDownloadedSurahs(ReciterInfoModel reciter) async {
    final dir = _reciterDir(reciter);
    final d = Directory(dir);
    if (!await d.exists()) return [];

    final List<int> surahs = [];
    await for (final entity in d.list()) {
      if (entity is Directory) {
        final name = p.basename(entity.path);
        final num = int.tryParse(name);
        if (num != null && num >= 1 && num <= 114) {
          // Verify at least some ayahs exist
          int mp3Count = 0;
          await for (final f in entity.list()) {
            if (f is File && f.path.endsWith('.mp3')) mp3Count++;
          }
          if (mp3Count > 0) surahs.add(num);
        }
      }
    }
    surahs.sort();
    return surahs;
  }

  /// Get list of reciters that have at least one downloaded surah.
  static Future<List<ReciterInfoModel>> getDownloadedReciters() async {
    if (applicationDataPath == null) return [];

    final baseDir = Directory(p.join(applicationDataPath!, "recitations"));
    if (!await baseDir.exists()) return [];

    final allReciters = recitationsInfoList
        .map((e) => ReciterInfoModel.fromMap(e))
        .toList();

    final List<ReciterInfoModel> result = [];
    await for (final entity in baseDir.list()) {
      if (entity is Directory) {
        final reciterName = p.basename(entity.path);
        // Match by name
        for (final r in allReciters) {
          if (r.name == reciterName) {
            // Check if any style subfolder has content
            await for (final styleDir in entity.list()) {
              if (styleDir is Directory) {
                int mp3Count = 0;
                await for (final f in styleDir.list()) {
                  if (f is Directory) {
                    await for (final ff in f.list()) {
                      if (ff is File && ff.path.endsWith('.mp3')) mp3Count++;
                    }
                  }
                }
                if (mp3Count > 0) {
                  result.add(r);
                  break;
                }
              }
            }
            break;
          }
        }
      }
    }
    return result;
  }

  /// Get total size of downloaded audio in bytes.
  static Future<int> getTotalDownloadedSize() async {
    if (applicationDataPath == null) return 0;
    return _dirSize(Directory(p.join(applicationDataPath!, "recitations")));
  }

  /// Get size of downloaded audio for a specific reciter.
  static Future<int> getReciterDownloadedSize(ReciterInfoModel reciter) async {
    return _dirSize(Directory(_reciterDir(reciter)));
  }

  /// Get size of a specific surah download.
  static Future<int> getSurahDownloadedSize({
    required ReciterInfoModel reciter,
    required int surahNumber,
  }) async {
    return _dirSize(Directory(_surahDir(reciter, surahNumber)));
  }

  /// Get detailed info about all downloaded surahs.
  static Future<List<DownloadedSurahInfo>> getAllDownloadedInfo() async {
    if (applicationDataPath == null) return [];

    final baseDir = Directory(p.join(applicationDataPath!, "recitations"));
    if (!await baseDir.exists()) return [];

    final allReciters = recitationsInfoList
        .map((e) => ReciterInfoModel.fromMap(e))
        .toList();

    final List<DownloadedSurahInfo> result = [];

    await for (final reciterDir in baseDir.list()) {
      if (reciterDir is! Directory) continue;
      final reciterName = p.basename(reciterDir.path);

      for (final r in allReciters) {
        if (r.name != reciterName) continue;

        await for (final styleDir in reciterDir.list()) {
          if (styleDir is! Directory) continue;
          // styleDir could be the style folder (e.g. "Murattal")
          // Inside it are surah folders (001, 002, ...)
          await for (final surahDir in styleDir.list()) {
            if (surahDir is! Directory) continue;
            final surahNum = int.tryParse(p.basename(surahDir.path));
            if (surahNum == null || surahNum < 1 || surahNum > 114) continue;

            int mp3Count = 0;
            int size = 0;
            await for (final f in surahDir.list()) {
              if (f is File && f.path.endsWith('.mp3')) {
                mp3Count++;
                size += await f.length();
              }
            }
            if (mp3Count > 0) {
              result.add(DownloadedSurahInfo(
                reciter: r,
                surahNumber: surahNum,
                ayahCount: mp3Count,
                sizeBytes: size,
              ));
            }
          }
        }
      }
    }

    return result;
  }

  /// Format bytes to human-readable string.
  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}";
  }

  // ─── Helpers ────────────────────────────────────────────────

  static String _downloadKey(ReciterInfoModel r, int surahNumber) =>
      "${r.name}_${r.style}_$surahNumber";

  static String _reciterDir(ReciterInfoModel r) => p.join(
        applicationDataPath!,
        "recitations",
        r.name,
        r.style ?? "default",
      );

  static String _surahDir(ReciterInfoModel r, int surahNumber) => p.join(
        _reciterDir(r),
        surahNumber.toString().padLeft(3, '0'),
      );

  static StreamController<SurahDownloadProgress> _getProgressController(
    String key,
  ) {
    _progressControllers.putIfAbsent(
      key,
      () => StreamController<SurahDownloadProgress>.broadcast(),
    );
    return _progressControllers[key]!;
  }

  static Future<int> _dirSize(Directory dir) async {
    if (!await dir.exists()) return 0;
    int size = 0;
    try {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (_) {}
    return size;
  }
}
