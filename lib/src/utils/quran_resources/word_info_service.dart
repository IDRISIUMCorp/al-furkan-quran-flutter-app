import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Enum for different word info types
enum WordInfoKind {
  irab,
  qiraat,
  sarf,
}

/// Service for downloading and managing word info resources
class WordInfoService {
  static final WordInfoService instance = WordInfoService._();
  WordInfoService._();

  static const String _baseUrl = 'https://api.idrisium.linkpc.net/quran';

  /// Get label for each kind
  String labelFor(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.irab:
        return 'الإعراب';
      case WordInfoKind.qiraat:
        return 'القراءات';
      case WordInfoKind.sarf:
        return 'الصرف';
    }
  }

  /// Get size string for each kind
  String sizeFor(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.irab:
        return '~45 MB';
      case WordInfoKind.qiraat:
        return '~120 MB';
      case WordInfoKind.sarf:
        return '~30 MB';
    }
  }

  /// Get download URL for each kind
  String _getUrlFor(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.irab:
        return '$_baseUrl/irab_data.zip';
      case WordInfoKind.qiraat:
        return '$_baseUrl/qiraat_data.zip';
      case WordInfoKind.sarf:
        return '$_baseUrl/sarf_data.zip';
    }
  }

  /// Get local path for each kind
  Future<String> _getLocalPath(WordInfoKind kind) async {
    final appDir = await getApplicationDocumentsDirectory();
    final folderName = kind.name;
    return '${appDir.path}/$folderName';
  }

  /// Check if data is downloaded
  Future<bool> isDownloaded(WordInfoKind kind) async {
    final path = await _getLocalPath(kind);
    final dir = Directory(path);
    if (!await dir.exists()) return false;
    
    // Check for marker file
    final markerFile = File('$path/.downloaded');
    return await markerFile.exists();
  }

  /// Download data for a specific kind
  Future<void> download({
    required WordInfoKind kind,
    required void Function(double progress) onProgress,
  }) async {
    final url = _getUrlFor(kind);
    final localPath = await _getLocalPath(kind);
    
    // Create directory
    final dir = Directory(localPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Download zip file
    final zipPath = '$localPath/temp.zip';
    final dio = Dio();
    
    await dio.download(
      url,
      zipPath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    // Extract zip (simplified - in real app use archive package)
    // For now, just mark as downloaded
    final markerFile = File('$localPath/.downloaded');
    await markerFile.writeAsString(DateTime.now().toIso8601String());

    // Cleanup
    final zipFile = File(zipPath);
    if (await zipFile.exists()) {
      await zipFile.delete();
    }

    // Save to Hive
    final box = Hive.box('user');
    await box.put('${kind.name}_downloaded', true);
  }

  /// Delete downloaded data
  Future<void> delete(WordInfoKind kind) async {
    final path = await _getLocalPath(kind);
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }

    // Remove from Hive
    final box = Hive.box('user');
    await box.delete('${kind.name}_downloaded');
  }

  /// Get download progress from Hive
  double getProgress(WordInfoKind kind) {
    final box = Hive.box('user');
    return box.get('${kind.name}_progress', defaultValue: 0.0) as double;
  }

  /// Save download progress to Hive
  Future<void> saveProgress(WordInfoKind kind, double progress) async {
    final box = Hive.box('user');
    await box.put('${kind.name}_progress', progress);
  }
}
