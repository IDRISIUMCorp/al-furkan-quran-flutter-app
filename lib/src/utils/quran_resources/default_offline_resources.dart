import "dart:convert";

import "package:al_quran_v3/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_irab_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_tafsir_function.dart";
import "package:archive/archive.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

class DefaultOfflineResources {
  static const String _installFlagKey = "default_offline_resources_installed_v2";
  static const String _enforceFlagKey =
      "default_offline_resources_enforced_v2";

  static const String _saadiJsonGzAsset = "assets/wahy/saadi.json.gz";

  static final TafsirBookModel defaultTafsirSaadi = TafsirBookModel(
    language: "Arabic",
    name: "تفسير السعدي",
    totalAyahs: 6236,
    hasTafsir: 6236,
    score: 95,
    fullPath: "bundled/Arabic/Tafsir_Saadi.json",
  );

  static Future<void> ensureInstalled() async {
    if (!Hive.isBoxOpen("user")) {
      await Hive.openBox("user");
    }

    final userBox = Hive.box("user");

    final tafsirBoxName = QuranTafsirFunction.getTafsirBoxName(
      tafsirBook: defaultTafsirSaadi,
    );

    await _ensureBoxHasAyahDataOrReinstall(
      boxName: tafsirBoxName,
      reinstall: _installSaadiTafsir,
    );

    final bool alreadyEnforced =
        userBox.get(_enforceFlagKey, defaultValue: false) == true;
    if (!alreadyEnforced) {
      await userBox.put(_enforceFlagKey, true);
    }

    // Always ensure I'rab data is installed (idempotent - skips if already loaded)
    await _installIrabData();

    final bool alreadyInstalled =
        userBox.get(_installFlagKey, defaultValue: false) == true;
    if (alreadyInstalled) {
      // Do NOT force-enable Saadi every start.
      // Only auto-select if the user has no tafsir selected at all.
      final currentSelections = await QuranTafsirFunction.getTafsirSelections();
      if (currentSelections == null || currentSelections.isEmpty) {
        await QuranTafsirFunction.setTafsirSelection(defaultTafsirSaadi);
      }
      return;
    }

    await _installSaadiTafsir();

    // First install: make sure at least one tafsir is enabled (Saadi).
    final currentSelections = await QuranTafsirFunction.getTafsirSelections();
    if (currentSelections == null || currentSelections.isEmpty) {
      await QuranTafsirFunction.setTafsirSelection(defaultTafsirSaadi);
    }

    await userBox.put(_installFlagKey, true);
  }

  static Future<void> _ensureBoxHasAyahDataOrReinstall({
    required String boxName,
    required Future<void> Function() reinstall,
  }) async {
    bool exists = await Hive.boxExists(boxName);
    if (!exists) {
      await reinstall();
      return;
    }

    try {
      final box = await Hive.openLazyBox(boxName);
      final v = await box.get("1:1", defaultValue: null);
      if (v != null) return;
    } catch (_) {
      // Fallthrough to reinstall
    }

    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.lazyBox(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
    } catch (_) {}

    await reinstall();
  }

  static Future<void> _installSaadiTafsir() async {
    final boxName = QuranTafsirFunction.getTafsirBoxName(
      tafsirBook: defaultTafsirSaadi,
    );

    final LazyBox box = await Hive.openLazyBox(boxName);

    final ByteData bytes = await rootBundle.load(_saadiJsonGzAsset);
    final raw = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    final decoded = GZipDecoder().decodeBytes(raw);
    final jsonString = utf8.decode(decoded);
    final Map<dynamic, dynamic> data = await compute(_decodeJsonToMap, jsonString);

    for (final entry in data.entries) {
      await box.put(entry.key.toString(), entry.value);
    }

    await box.put("meta_data", defaultTafsirSaadi.toMap());

    await QuranTafsirFunction.setToListAlreadyDownloaded(
      tafsirBook: defaultTafsirSaadi,
    );

    await QuranTafsirFunction.setTafsirSelection(defaultTafsirSaadi);
  }

  static Map<dynamic, dynamic> _decodeJsonToMap(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map) return decoded;
    return {};
  }

  /// Install the bundled I'rab (grammatical analysis) database from the local JSON asset.
  static Future<void> _installIrabData() async {
    const irabBoxName = QuranIrabFunction.defaultBoxName;

    // Si already installed and has data, skip
    if (await Hive.boxExists(irabBoxName)) {
      LazyBox box;
      try {
        box = Hive.isBoxOpen(irabBoxName)
            ? Hive.lazyBox(irabBoxName)
            : await Hive.openLazyBox(irabBoxName);
        final v = await box.get("1:1", defaultValue: null);
        if (v != null) {
          // Data already loaded, just ensure selection
          await QuranIrabFunction.setDefaultSelected();
          return;
        }
      } catch (_) {
        // Fallthrough to reinstall
      }
    }

    // Load JSON from bundled asset
    try {
      final String jsonString = await rootBundle.loadString(
        "packages/alrab-al-quran-li-da-as.json",
      );
      final Map<dynamic, dynamic> data = await compute(_decodeJsonToMap, jsonString);

      // Delete old box if corrupt
      try {
        if (Hive.isBoxOpen(irabBoxName)) {
          await Hive.lazyBox(irabBoxName).close();
        }
        await Hive.deleteBoxFromDisk(irabBoxName);
      } catch (_) {}

      final LazyBox box = await Hive.openLazyBox(irabBoxName);

      for (final entry in data.entries) {
        await box.put(entry.key.toString(), entry.value);
      }

      await box.put("meta_data", QuranIrabFunction.defaultIrabMeta);

      // Set as default selection
      await QuranIrabFunction.setDefaultSelected();
    } catch (e) {
      debugPrint("[DefaultOfflineResources] Failed to install I'rab data: $e");
    }
  }
}
