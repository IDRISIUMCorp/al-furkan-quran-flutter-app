import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/core/storage/app_boxes.dart";
import "dart:convert";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Custom Playlist — قوائم التشغيل المخصصة
// ═══════════════════════════════════════════════════════════════════

class CustomPlaylist {
  final String id;
  final String name;
  final List<int> surahNumbers;
  final ReciterInfoModel reciter;
  final DateTime createdAt;

  const CustomPlaylist({
    required this.id,
    required this.name,
    required this.surahNumbers,
    required this.reciter,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "surahNumbers": surahNumbers,
        "reciter": reciter.toJson(),
        "createdAt": createdAt.toIso8601String(),
      };

  factory CustomPlaylist.fromJson(Map<String, dynamic> json) => CustomPlaylist(
        id: json["id"] as String,
        name: json["name"] as String,
        surahNumbers: List<int>.from(json["surahNumbers"] as List),
        reciter: ReciterInfoModel.fromJson(json["reciter"] as String),
        createdAt: DateTime.parse(json["createdAt"] as String),
      );
}

class CustomPlaylistState {
  final List<CustomPlaylist> playlists;

  const CustomPlaylistState({this.playlists = const []});

  CustomPlaylistState copyWith({List<CustomPlaylist>? playlists}) =>
      CustomPlaylistState(playlists: playlists ?? this.playlists);
}

class CustomPlaylistCubit extends Cubit<CustomPlaylistState> {
  CustomPlaylistCubit() : super(const CustomPlaylistState()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final box = Hive.box(AppBoxes.readingStats);
    final raw = box.get("custom_playlists", defaultValue: "[]") as String;
    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    final playlists = jsonList
        .map((e) => CustomPlaylist.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    emit(CustomPlaylistState(playlists: playlists));
  }

  void _saveToStorage() {
    final box = Hive.box(AppBoxes.readingStats);
    final raw = jsonEncode(state.playlists.map((p) => p.toJson()).toList());
    box.put("custom_playlists", raw);
  }

  /// Create a new playlist
  void createPlaylist({
    required String name,
    required List<int> surahNumbers,
    required ReciterInfoModel reciter,
  }) {
    final playlist = CustomPlaylist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      surahNumbers: surahNumbers,
      reciter: reciter,
      createdAt: DateTime.now(),
    );
    final newList = List<CustomPlaylist>.from(state.playlists)..add(playlist);
    emit(state.copyWith(playlists: newList));
    _saveToStorage();
  }

  /// Delete a playlist by ID
  void deletePlaylist(String id) {
    final newList = state.playlists.where((p) => p.id != id).toList();
    emit(state.copyWith(playlists: newList));
    _saveToStorage();
  }

  /// Rename a playlist
  void renamePlaylist(String id, String newName) {
    final newList = state.playlists.map((p) {
      if (p.id == id) {
        return CustomPlaylist(
          id: p.id,
          name: newName,
          surahNumbers: p.surahNumbers,
          reciter: p.reciter,
          createdAt: p.createdAt,
        );
      }
      return p;
    }).toList();
    emit(state.copyWith(playlists: newList));
    _saveToStorage();
  }

  /// Add a surah to a playlist
  void addSurahToPlaylist(String id, int surahNumber) {
    final newList = state.playlists.map((p) {
      if (p.id == id && !p.surahNumbers.contains(surahNumber)) {
        return CustomPlaylist(
          id: p.id,
          name: p.name,
          surahNumbers: [...p.surahNumbers, surahNumber],
          reciter: p.reciter,
          createdAt: p.createdAt,
        );
      }
      return p;
    }).toList();
    emit(state.copyWith(playlists: newList));
    _saveToStorage();
  }

  /// Remove a surah from a playlist
  void removeSurahFromPlaylist(String id, int surahNumber) {
    final newList = state.playlists.map((p) {
      if (p.id == id) {
        return CustomPlaylist(
          id: p.id,
          name: p.name,
          surahNumbers: p.surahNumbers.where((s) => s != surahNumber).toList(),
          reciter: p.reciter,
          createdAt: p.createdAt,
        );
      }
      return p;
    }).toList();
    emit(state.copyWith(playlists: newList));
    _saveToStorage();
  }
}
