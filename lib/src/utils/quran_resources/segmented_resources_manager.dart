import "dart:convert";

import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/api/apis_urls.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/utils/encode_decode.dart";
import "package:al_furkan/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:dio/dio.dart" as dio;
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

class SegmentedResourcesManager {
  static final String _selectedBox = "selected_segmented_recitation_box";
  static final String _allBoxKey = "segmented_recitation_boxes";
  static final String _metaKey = "meta_data";
  static Box? _segmentsBox;

  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen("user")) {
        await Hive.openBox("user").timeout(const Duration(seconds: 5));
      }
      final String? selectedBox = getSelectedDataBoxName();
      if (selectedBox != null) {
        debugPrint("📦 Opening segments box: $selectedBox");
        await changeSelectedBox(selectedBox).timeout(const Duration(seconds: 8));
        // Invalidate cache so lookups that previously failed can now succeed.
        invalidateCache();
        debugPrint("✅ Segments box opened successfully: $_segmentsBox");
      } else {
        debugPrint("⚠️ No selected segments box found in user preferences");
      }
    } catch (e) {
      debugPrint("❌ Error initializing SegmentedResourcesManager: $e");
      // If the box failed to open, ensure _segmentsBox stays null
      // so getAyahSegments() doesn't use a broken box.
      _segmentsBox = null;
    }
  }

  static Map segmentsCache = {};

  /// Clear the cache so future lookups retry from the box.
  static void invalidateCache() {
    segmentsCache.clear();
  }

  static int _boxNotOpenLogSuppression = 0;

  static List? getAyahSegments(String ayahKey) {
    if (_segmentsBox == null || _segmentsBox?.isOpen == false) {
      // Box not ready yet — do NOT cache -1, so we retry next time.
      // Throttle log to avoid spamming (only log once every 50 calls).
      _boxNotOpenLogSuppression++;
      if (_boxNotOpenLogSuppression == 1 || _boxNotOpenLogSuppression % 50 == 0) {
        debugPrint("⚠️ Segments box is not open for ayahKey: $ayahKey (call #$_boxNotOpenLogSuppression)");
      }
      return null;
    }
    _boxNotOpenLogSuppression = 0; // Reset when box is open

    final cached = segmentsCache[ayahKey];
    if (cached != null) {
      if (cached == -1) return null;
      // cached is a Map — extract segments from it.
      try {
        return List<List>.from(cached["segments"]);
      } catch (e) {
        debugPrint("❌ Error parsing cached segments for $ayahKey: $e");
        return null;
      }
    }

    // Read from box and cache the raw Map (not the parsed list).
    final Map? audioTimeStamp =
        _segmentsBox?.get(ayahKey, defaultValue: null);

    if (audioTimeStamp != null) {
      segmentsCache[ayahKey] = audioTimeStamp;
      try {
        final segments = List<List>.from(audioTimeStamp["segments"]);
        debugPrint("✅ Found ${segments.length} segments for $ayahKey");
        return segments;
      } catch (e) {
        debugPrint("❌ Error parsing segments for $ayahKey: $e");
        return null;
      }
    } else {
      // Only cache -1 when the box IS open and the key is genuinely missing.
      segmentsCache[ayahKey] = -1;
      debugPrint("⚠️ No segments found for $ayahKey");
      return null;
    }
  }

  static ReciterInfoModel? getOpenSegmentsReciter() {
    final String? metaData = _segmentsBox?.get(_metaKey, defaultValue: null);
    if (metaData == null) return null;
    return ReciterInfoModel.fromJson(_segmentsBox!.get(_metaKey));
  }

  static Future<void> closeAllBoxes() async {
    final List<String> boxesNames = getDownloadedBoxesNames();
    for (String boxName in boxesNames) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
    }
  }

  static String? getSelectedDataBoxName() {
    return Hive.box("user").get(_selectedBox, defaultValue: null);
  }

  static Future<void> saveSelectedBox(String boxName) async {
    await Hive.box("user").put(_selectedBox, boxName);
  }

  static List<String> getDownloadedBoxesNames() {
    return List<String>.from(
      Hive.box("user").get(_allBoxKey, defaultValue: []),
    );
  }

  static Future<void> changeSelectedBox(String toOpenBox) async {
    // close all opened boxes (with timeout safety)
    final List<String> boxesNames = getDownloadedBoxesNames();
    for (String boxName in boxesNames) {
      if (Hive.isBoxOpen(boxName)) {
        try {
          await Hive.box(boxName).close().timeout(const Duration(seconds: 3));
        } catch (e) {
          debugPrint("⚠️ Timeout/error closing box $boxName: $e");
        }
      }
    }
    // save selected box to user DB
    saveSelectedBox(toOpenBox);
    // open selected box (with timeout safety)
    try {
      _segmentsBox = await Hive.openBox(toOpenBox).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("❌ Failed to open segments box $toOpenBox: $e");
      _segmentsBox = null;
      rethrow;
    }
  }

  static Future<bool> downloadResources(
    BuildContext context,
    String url,
  ) async {
    if (await isAlreadyDownloaded(url)) {
      return true;
    } else {
      // ignore: use_build_context_synchronously
      final AppLocalizations appLocalizations = AppLocalizations.of(context);
      final fullUrl = ApisUrls.base + url;
      final response = await dio.Dio().get(fullUrl);
      final String boxName = praseStringToBoxName(fullUrl);
      if (response.statusCode == 200) {
        _segmentsBox = await Hive.openBox(boxName);
        // ignore: use_build_context_synchronously
        context.read<ResourcesProgressCubit>().updateProgress(
          null,
          appLocalizations.processingSegmentedQuranRecitation,
        );
        final Map segmentsInfo = await compute(
          (message) => jsonDecode(decodeBZip2String(message)),
          response.data,
        );

        for (final ayahKey in segmentsInfo.keys) {
          await _segmentsBox!.put(ayahKey, segmentsInfo[ayahKey]);
        }
        await _segmentsBox?.put(
          _metaKey,
          // ignore: use_build_context_synchronously
          context.read<SegmentedQuranReciterCubit>().state.toJson(),
        );
        await changeSelectedBox(praseStringToBoxName(url));
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<bool> isAlreadyDownloaded(String url) async {
    return await Hive.boxExists(praseStringToBoxName(url));
  }

  static String praseStringToBoxName(String url) {
    final Uri uri = Uri.parse(url);
    final String boxName = uri.pathSegments.last.replaceAll(
      RegExp(r"[^a-zA-Z0-9]"),
      "_",
    );
    return boxName.isNotEmpty
        ? boxName
        : "default_box_name"; // Fallback if parsing fails or result is empty
  }
}
