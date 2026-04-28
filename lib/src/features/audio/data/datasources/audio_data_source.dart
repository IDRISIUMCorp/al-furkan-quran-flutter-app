import 'dart:convert';
import 'dart:io';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reciter_model.dart';

/// Audio Remote Data Source — Quran audio CDN (everyayah.com / alquran.cloud)
class AudioRemoteDataSource {
  AudioRemoteDataSource();

  static const String _baseUrl = 'https://cdn.islamic.network/quran/audio-surah';

  /// Get list of available reciters from local config (no remote API for this)
  /// Reciter list is bundled with the app as a static JSON asset
  Future<List<ReciterModel>> getReciters() async {
    // Reciters are loaded from bundled asset — no network call needed
    // This will be replaced with asset loading in the repository
    return [];
  }

  /// Get audio URL for a specific surah by reciter
  String getSurahAudioUrl({required int reciterId, required int surahId}) {
    final surahPadded = surahId.toString().padLeft(3, '0');
    return '$_baseUrl/$reciterId/$surahPadded.mp3';
  }

  /// Get audio URL for a specific ayah by reciter (ayah-by-ayah mode)
  String getAyahAudioUrl({required int reciterId, required String ayahKey}) {
    return 'https://cdn.islamic.network/quran/audio/128/$reciterId/$ayahKey.mp3';
  }
}

/// Audio Local Data Source — Hive + SharedPreferences for offline audio management
class AudioLocalDataSource {
  final Box _cacheBox;
  final SharedPreferences _prefs;

  AudioLocalDataSource({required Box cacheBox, required SharedPreferences prefs})
      : _cacheBox = cacheBox,
        _prefs = prefs;

  static const String _keyReciters = 'reciters_data';
  static const String _keySelectedReciter = 'selected_reciter_id';
  static const String _audioDirName = 'al_furkan_audio';

  /// Get cached reciters list
  List<ReciterModel> getCachedReciters() {
    final raw = _cacheBox.get(_keyReciters) as String?;
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ReciterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cache reciters list
  Future<void> cacheReciters(List<ReciterModel> reciters) async {
    await _cacheBox.put(
      _keyReciters,
      jsonEncode(reciters.map((r) => r.toJson()).toList()),
    );
  }

  /// Get selected reciter ID
  int getSelectedReciterId() {
    return _prefs.getInt(_keySelectedReciter) ?? 7; // Default: Mishary Rashid Alafasy
  }

  /// Save selected reciter ID
  Future<void> saveSelectedReciterId(int id) async {
    await _prefs.setInt(_keySelectedReciter, id);
  }

  /// Get local directory for audio files
  Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/$_audioDirName');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// Check if a surah audio file exists locally
  Future<bool> isSurahDownloaded({required int reciterId, required int surahId}) async {
    final dir = await getAudioDirectory();
    final file = File('${dir.path}/${reciterId}_${surahId.toString().padLeft(3, '0')}.mp3');
    return file.exists();
  }

  /// Delete a downloaded surah audio file
  Future<void> deleteSurahAudio({required int reciterId, required int surahId}) async {
    final dir = await getAudioDirectory();
    final file = File('${dir.path}/${reciterId}_${surahId.toString().padLeft(3, '0')}.mp3');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
