import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

class AyahKeyCubit extends Cubit<AyahKeyManagement> {
  AyahKeyCubit()
    : super(
        _loadInitialState(),
      );

  static AyahKeyManagement _loadInitialState() {
    try {
      final box = Hive.isBoxOpen("user") ? Hive.box("user") : null;
      return AyahKeyManagement(
        start: box?.get("last_ayah_start", defaultValue: "1:1") ?? "1:1",
        end: box?.get("last_ayah_end", defaultValue: "1:7") ?? "1:7",
        ayahList: List<String>.from(
          box?.get(
            "last_ayah_ayah_list",
            defaultValue: ["1:1", "1:2", "1:3", "1:4", "1:5", "1:6", "1:7"],
          ) ??
              ["1:1", "1:2", "1:3", "1:4", "1:5", "1:6", "1:7"],
        ),
        current: box?.get("last_ayah_current", defaultValue: "1:1") ?? "1:1",
        lastScrolledPageNumber: box?.get("last_scrolled_page", defaultValue: null),
      );
    } catch (_) {
      return AyahKeyManagement(
        start: "1:1",
        end: "1:7",
        ayahList: ["1:1", "1:2", "1:3", "1:4", "1:5", "1:6", "1:7"],
        current: "1:1",
        lastScrolledPageNumber: null,
      );
    }
  }

  void changeCurrentAyahKey(String ayahKey) {
    emit(state.copyWith(current: ayahKey));
    Hive.box("user").put("last_ayah_current", ayahKey);
  }

  void changeData(AyahKeyManagement ayahData) {
    emit(ayahData);
    saveAyahKeyChanges(ayahData);
  }

  void saveAyahKeyChanges(AyahKeyManagement ayahData) {
    Hive.box("user").put("last_ayah_start", ayahData.start);
    Hive.box("user").put("last_ayah_end", ayahData.end);
    Hive.box("user").put("last_ayah_ayah_list", ayahData.ayahList);
    Hive.box("user").put("last_ayah_current", ayahData.current);
  }

  void changeLastScrolledPage(int page) {
    emit(state.copyWith(lastScrolledPageNumber: page));
    Hive.box("user").put("last_scrolled_page", page);
  }
}
