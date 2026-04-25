import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/core/audio/services/offline_audio_service.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Offline Download Cubit — State Management
// ═══════════════════════════════════════════════════════════════════

class OfflineDownloadState {
  final List<DownloadedSurahInfo> downloadedSurahs;
  final int totalSizeBytes;
  final bool isLoading;
  final Map<String, SurahDownloadProgress> activeDownloads;
  final String? error;

  const OfflineDownloadState({
    this.downloadedSurahs = const [],
    this.totalSizeBytes = 0,
    this.isLoading = false,
    this.activeDownloads = const {},
    this.error,
  });

  /// Group downloaded surahs by reciter.
  Map<String, List<DownloadedSurahInfo>> get byReciter {
    final Map<String, List<DownloadedSurahInfo>> map = {};
    for (final info in downloadedSurahs) {
      final key = info.reciterLabel;
      map.putIfAbsent(key, () => []).add(info);
    }
    return map;
  }

  /// Get total size formatted.
  String get totalSizeFormatted => OfflineAudioService.formatBytes(totalSizeBytes);

  /// Check if a surah is currently being downloaded.
  bool isDownloading(ReciterInfoModel reciter, int surahNumber) {
    final key = "${reciter.name}_${reciter.style}_$surahNumber";
    return activeDownloads[key]?.isDownloading ?? false;
  }

  /// Get download progress for a surah.
  SurahDownloadProgress? getProgress(ReciterInfoModel reciter, int surahNumber) {
    final key = "${reciter.name}_${reciter.style}_$surahNumber";
    return activeDownloads[key];
  }

  /// Check if a surah is fully downloaded.
  bool isSurahDownloaded(ReciterInfoModel reciter, int surahNumber) {
    return downloadedSurahs.any(
      (info) =>
          info.reciter.name == reciter.name &&
          info.reciter.style == reciter.style &&
          info.surahNumber == surahNumber,
    );
  }

  OfflineDownloadState copyWith({
    List<DownloadedSurahInfo>? downloadedSurahs,
    int? totalSizeBytes,
    bool? isLoading,
    Map<String, SurahDownloadProgress>? activeDownloads,
    String? error,
  }) =>
      OfflineDownloadState(
        downloadedSurahs: downloadedSurahs ?? this.downloadedSurahs,
        totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
        isLoading: isLoading ?? this.isLoading,
        activeDownloads: activeDownloads ?? this.activeDownloads,
        error: error,
      );
}

class OfflineDownloadCubit extends Cubit<OfflineDownloadState> {
  OfflineDownloadCubit() : super(const OfflineDownloadState());

  /// Refresh the list of downloaded content.
  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final surahs = await OfflineAudioService.getAllDownloadedInfo();
      final totalSize = await OfflineAudioService.getTotalDownloadedSize();
      emit(state.copyWith(
        downloadedSurahs: surahs,
        totalSizeBytes: totalSize,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint("❌ Error refreshing offline downloads: $e");
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Download a surah for a reciter.
  Future<void> downloadSurah({
    required ReciterInfoModel reciter,
    required int surahNumber,
  }) async {
    final key = "${reciter.name}_${reciter.style}_$surahNumber";

    // Listen to progress
    OfflineAudioService.progressStream(reciter, surahNumber).listen((progress) {
      final updated = Map<String, SurahDownloadProgress>.from(state.activeDownloads);
      updated[key] = progress;
      emit(state.copyWith(activeDownloads: updated));
    });

    final success = await OfflineAudioService.downloadSurah(
      reciter: reciter,
      surahNumber: surahNumber,
    );

    // Remove from active downloads
    final updated = Map<String, SurahDownloadProgress>.from(state.activeDownloads);
    updated.remove(key);
    emit(state.copyWith(activeDownloads: updated));

    if (success) {
      await refresh();
    }
  }

  /// Download multiple surahs.
  Future<void> downloadSurahs({
    required ReciterInfoModel reciter,
    required List<int> surahNumbers,
  }) async {
    for (final sn in surahNumbers) {
      await downloadSurah(reciter: reciter, surahNumber: sn);
    }
  }

  /// Cancel a download.
  void cancelDownload(ReciterInfoModel reciter, int surahNumber) {
    OfflineAudioService.cancelDownload(reciter, surahNumber);
  }

  /// Delete a downloaded surah.
  Future<void> deleteSurah({
    required ReciterInfoModel reciter,
    required int surahNumber,
  }) async {
    await OfflineAudioService.deleteSurah(
      reciter: reciter,
      surahNumber: surahNumber,
    );
    await refresh();
  }

  /// Delete all data for a reciter.
  Future<void> deleteReciter(ReciterInfoModel reciter) async {
    await OfflineAudioService.deleteReciter(reciter);
    await refresh();
  }

  /// Delete all downloaded content.
  Future<void> deleteAll() async {
    await OfflineAudioService.deleteAll();
    await refresh();
  }
}
