import "dart:convert";
import "dart:developer";

import "package:al_furkan/src/resources/quran_resources/models/mutashabihat_book_model.dart";
import "package:dio/dio.dart" as dio;
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

import "../../api/apis_urls.dart";
import "../../screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "../encode_decode.dart";
import "../basic_functions.dart";

class QuranMutashabihatFunction {
  static const String selectedMutashabihatListKey =
      "selected_mutashabihat_list";
  static const String downloadedMutashabihatBooksKey =
      "downloaded_mutashabihat_books";
  static const String downloadedMutashabihatOrderKey =
      "downloaded_mutashabihat_order";
  static const String downloadedMutashabihatSizeBytesKey =
      "downloaded_mutashabihat_size_bytes";
  static final Map<String, int?> _remoteSizeBytesCache = {};

  static List<String> getDownloadedMutashabihatOrderIds() {
    final userBox = Hive.box("user");
    final raw = userBox.get(downloadedMutashabihatOrderKey, defaultValue: []);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const <String>[];
  }

  static Future<void> setDownloadedMutashabihatOrderIds(
    List<String> ids,
  ) async {
    final userBox = Hive.box("user");
    final seen = <String>{};
    final deduped = <String>[];
    for (final id in ids) {
      if (seen.add(id)) deduped.add(id);
    }
    await userBox.put(downloadedMutashabihatOrderKey, deduped);
  }

  static int? getDownloadedMutashabihatSizeBytes(String id) {
    final userBox = Hive.box("user");
    final raw = userBox.get(downloadedMutashabihatSizeBytesKey);
    if (raw is Map) {
      final value = raw[id];
      return value is int ? value : int.tryParse(value?.toString() ?? "");
    }
    return null;
  }

  static Future<void> setDownloadedMutashabihatSizeBytes(
    String id,
    int bytes,
  ) async {
    final userBox = Hive.box("user");
    final raw = userBox.get(downloadedMutashabihatSizeBytesKey);
    final map = <String, dynamic>{};
    if (raw is Map) {
      map.addAll(raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    map[id] = bytes;
    await userBox.put(downloadedMutashabihatSizeBytesKey, map);
  }

  static String getMutashabihatBoxName({
    required MutashabihatBookModel mutashabihatBook,
  }) {
    String sanitizedBook = mutashabihatBook.fullPath
        .split("/")
        .last
        .replaceAll(RegExp(r"[^\w\.-]"), "_");
    return "mutashabihat_${mutashabihatBook.language}_$sanitizedBook";
  }

  static Future<bool> isAlreadyDownloaded(
    MutashabihatBookModel mutashabihatBook,
  ) async {
    final boxName = getMutashabihatBoxName(mutashabihatBook: mutashabihatBook);
    return await Hive.boxExists(boxName);
  }

  static Future<void> setToListAlreadyDownloaded({
    required MutashabihatBookModel mutashabihatBook,
  }) async {
    final userBox = Hive.box("user");
    List<MutashabihatBookModel> downloadedBooks =
        getDownloadedMutashabihatBooks();
    if (!downloadedBooks
        .any((book) => book.fullPath == mutashabihatBook.fullPath)) {
      downloadedBooks.add(mutashabihatBook);
      await userBox.put(
        downloadedMutashabihatBooksKey,
        downloadedBooks.map((e) => e.toMap()).toList(),
      );
    }
  }

  static List<MutashabihatBookModel> getDownloadedMutashabihatBooks() {
    final userBox = Hive.box("user");
    final raw = List<Map>.from(
      userBox.get(downloadedMutashabihatBooksKey, defaultValue: []),
    );
    return raw
        .map((e) =>
            MutashabihatBookModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> removeFromListAlreadyDownloaded(
    MutashabihatBookModel mutashabihatBook,
  ) async {
    final userBox = Hive.box("user");
    List<MutashabihatBookModel> downloadedBooks =
        getDownloadedMutashabihatBooks();
    bool changed = false;
    downloadedBooks.removeWhere((book) {
      if (mutashabihatBook.fullPath == book.fullPath) {
        changed = true;
        return true;
      }
      return false;
    });

    if (changed) {
      await userBox.put(
        downloadedMutashabihatBooksKey,
        downloadedBooks.map((e) => e.toMap()).toList(),
      );
    }

    final boxName =
        getMutashabihatBoxName(mutashabihatBook: mutashabihatBook);
    if (await Hive.boxExists(boxName)) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.lazyBox(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      log(
        "Deleted Mutashabihat box: $boxName",
        name: "removeFromListAlreadyDownloaded",
      );
    }
    await removeMutashabihatSelection(mutashabihatBook);
  }

  static Future<void> setMutashabihatSelection(
    MutashabihatBookModel mutashabihatBook,
  ) async {
    final userBox = Hive.box("user");
    List<MutashabihatBookModel> selectedList =
        (await getMutashabihatSelections()) ?? [];
    if (!selectedList.any((b) => b.fullPath == mutashabihatBook.fullPath)) {
      selectedList.add(mutashabihatBook);
      await userBox.put(
        selectedMutashabihatListKey,
        selectedList.map((e) => e.toMap()).toList(),
      );
    }
    await init();
  }

  static Future<void> removeMutashabihatSelection(
    MutashabihatBookModel mutashabihatBook,
  ) async {
    final userBox = Hive.box("user");
    List<MutashabihatBookModel> selectedList =
        (await getMutashabihatSelections()) ?? [];
    selectedList.removeWhere(
      (element) => element.fullPath == mutashabihatBook.fullPath,
    );
    await userBox.put(
      selectedMutashabihatListKey,
      selectedList.map((e) => e.toMap()).toList(),
    );
    await init();
  }

  static Future<void> replaceMutashabihatSelections(
    List<MutashabihatBookModel> books,
  ) async {
    final userBox = Hive.box("user");
    final seen = <String>{};
    final deduped = <MutashabihatBookModel>[];
    for (final b in books) {
      if (seen.add(b.fullPath)) deduped.add(b);
    }
    await userBox.put(
      selectedMutashabihatListKey,
      deduped.map((e) => e.toMap()).toList(),
    );
    await init();
  }

  static Future<List<MutashabihatBookModel>?> getMutashabihatSelections() async {
    final userBox = Hive.box("user");
    List? booksList = userBox.get(selectedMutashabihatListKey);
    return booksList
        ?.map((e) =>
            MutashabihatBookModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<int?> getRemoteBookSizeBytes(
    MutashabihatBookModel book,
  ) async {
    if (_remoteSizeBytesCache.containsKey(book.fullPath)) {
      return _remoteSizeBytesCache[book.fullPath];
    }
    try {
      final response = await dio.Dio().head<dynamic>(
        ApisUrls.base + book.fullPath,
      );
      final raw = response.headers.value("content-length");
      final bytes = raw == null ? null : int.tryParse(raw);
      _remoteSizeBytesCache[book.fullPath] = bytes;
      return bytes;
    } catch (_) {
      _remoteSizeBytesCache[book.fullPath] = null;
      return null;
    }
  }

  static Future<void> init() async {
    if (!Hive.isBoxOpen("user")) {
      await Hive.openBox("user");
    }

    List<MutashabihatBookModel>? booksListToOpen =
        await getMutashabihatSelections();
    booksListToOpen ??= [];

    for (MutashabihatBookModel bookModel in booksListToOpen) {
      final boxName = getMutashabihatBoxName(mutashabihatBook: bookModel);
      if (!Hive.isBoxOpen(boxName)) {
        try {
          await Hive.openLazyBox(boxName);
        } catch (_) {
          // Box doesn't exist yet - will be downloaded later
        }
      }
    }
  }

  static Future<bool> downloadResources({
    required BuildContext context,
    required MutashabihatBookModel mutashabihatBook,
    bool isSetupProcess = false,
  }) async {
    final cubit = context.read<ResourcesProgressCubit>();

    if (await isAlreadyDownloaded(mutashabihatBook)) {
      log(
        "Mutashabihat '${mutashabihatBook.fullPath}' is already downloaded.",
        name: "downloadResources",
      );
      if (isSetupProcess) {
        await setMutashabihatSelection(mutashabihatBook);
      }
      await init();
      return true;
    }

    cubit.onProcess();
    cubit.updateProgress(
      0.0,
      "Downloading: ${mutashabihatBook.name}",
      activeResourceId: mutashabihatBook.fullPath,
    );

    final boxName =
        getMutashabihatBoxName(mutashabihatBook: mutashabihatBook);

    log(
      "Starting download for Mutashabihat Box: $boxName",
      name: "downloadResources",
    );

    LazyBox mutashabihatBox;
    try {
      mutashabihatBox = await Hive.openLazyBox(boxName);
    } catch (e) {
      log(
        "Error opening LazyBox '$boxName': $e. Trying to delete and reopen.",
        name: "downloadResources",
      );
      try {
        await Hive.deleteBoxFromDisk(boxName);
        mutashabihatBox = await Hive.openLazyBox(boxName);
      } catch (e2) {
        log(
          "Failed to open LazyBox '$boxName' even after delete: $e2",
          name: "downloadResources",
        );
        cubit.failure(
          "Error preparing Mutashabihat storage",
          activeResourceId: mutashabihatBook.fullPath,
        );
        return false;
      }
    }

    int? reportedTotalBytes;
    try {
      String base = ApisUrls.base;
      cubit.updateProgress(
        0.0,
        "Downloading: ${mutashabihatBook.name}",
        activeResourceId: mutashabihatBook.fullPath,
      );
      dio.Response response = await dio.Dio().get(
        base + mutashabihatBook.fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            reportedTotalBytes = total;
            double progress = received / total;
            cubit.updateProgress(
              progress * 0.5,
              "Downloading: ${mutashabihatBook.name}",
              transferredBytes: received,
              totalBytes: total,
              activeResourceId: mutashabihatBook.fullPath,
            );
          }
        },
      );

      // Detect HTML responses — the backend sometimes returns an HTML page
      // instead of actual data for resources that aren't hosted yet.
      String? responseData = response.data as String?;
      final bool isHtml = responseData != null &&
          (responseData.trimLeft().startsWith('<') ||
           response.headers.value('content-type')?.contains('text/html') == true);

      Map data;
      if (isHtml && ApisUrls.fallbackMutashabihat.isNotEmpty) {
        // Primary server returned HTML — try fallback CDN (plain JSON, not BZip2)
        log(
          "Primary server returned HTML for Mutashabihat. Trying fallback CDN.",
          name: "downloadResources",
        );
        cubit.updateProgress(
          0.1,
          "Downloading (fallback): ${mutashabihatBook.name}",
          activeResourceId: mutashabihatBook.fullPath,
        );
        final fallbackResponse = await dio.Dio().get(
          ApisUrls.fallbackMutashabihat,
        );
        final fallbackData = fallbackResponse.data as String;
        // Fallback is plain JSON — parse directly, no BZip2 decompression.
        final parsed = await compute(
          (message) => jsonDecode(message) as Map,
          fallbackData,
        );
        // Transform Waqar144 format: { "1:1": [{src, muts, ctx}], ... }
        // into our expected format keyed by ayah key.
        data = parsed;
        reportedTotalBytes = fallbackData.length;
      } else {
        cubit.updateProgress(
          0.5,
          "Processing: ${mutashabihatBook.name}",
          activeResourceId: mutashabihatBook.fullPath,
        );
        data = await compute(
          (message) => jsonDecode(decodeBZip2String(message as String)),
          response.data,
        );
      }

      cubit.updateProgress(
        0.75,
        "Processing Mutashabihat",
        activeResourceId: mutashabihatBook.fullPath,
      );

      await mutashabihatBox.putAll(data.cast<String, dynamic>());
      await mutashabihatBox.put("meta_data", mutashabihatBook.toMap());

      await setToListAlreadyDownloaded(mutashabihatBook: mutashabihatBook);
      if (reportedTotalBytes != null && reportedTotalBytes! > 0) {
        await setDownloadedMutashabihatSizeBytes(
          mutashabihatBook.fullPath,
          reportedTotalBytes!,
        );
      }
      if (isSetupProcess) {
        await setMutashabihatSelection(mutashabihatBook);
      }

      log(
        "Mutashabihat '${mutashabihatBook.fullPath}' downloaded and processed successfully.",
        name: "downloadResources",
      );
      await init();
      cubit.updateProgress(
        1.0,
        "Downloaded: ${mutashabihatBook.name}",
        transferredBytes: 1,
        totalBytes: 1,
        activeResourceId: mutashabihatBook.fullPath,
      );
      await Future<void>.delayed(const Duration(milliseconds: 220));
      cubit.success(activeResourceId: mutashabihatBook.fullPath);
      return true;
    } catch (e, s) {
      log(
        "Error downloading or processing Mutashabihat '${mutashabihatBook.name}': $e\n$s",
        name: "downloadResources",
      );
      cubit.failure(
        "Error downloading Mutashabihat",
        activeResourceId: mutashabihatBook.fullPath,
      );
      if (mutashabihatBox.isOpen) {
        await mutashabihatBox.close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      return false;
    }
  }

  /// Get mutashabihat data for a specific ayah
  static Future<List<Map<String, dynamic>>?> getMutashabihatForAyah(
    MutashabihatBookModel book,
    String ayahKey,
  ) async {
    final boxName = getMutashabihatBoxName(mutashabihatBook: book);
    LazyBox? box;
    if (!Hive.isBoxOpen(boxName)) {
      box = await Hive.openLazyBox(boxName);
    } else {
      box = Hive.lazyBox(boxName);
    }

    // 1) Try string ayahKey (e.g. "2:3") — original BZip2 format
    final data = await box.get(ayahKey, defaultValue: null);
    if (data != null) {
      if (data is List) {
        return data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      if (data is Map) {
        return [Map<String, dynamic>.from(data)];
      }
      if (data is String && data.trim().isNotEmpty) {
        return [{"t": data.trim(), "src": ayahKey}];
      }
    }

    // 2) Fallback CDN (Waqar144) stores data per-surah with int keys (1,2,3…114)
    //    Format: List of {src: {ayah: ABSOLUTE_NUM}, muts: [{ayah: ABSOLUTE_NUM}, …], ctx?: int}
    //    where ABSOLUTE_NUM is the ayah number from the beginning of the Quran
    final parts = ayahKey.split(":");
    if (parts.length != 2) return null;
    final surahNum = int.tryParse(parts.first);
    if (surahNum == null) return null;

    final surahData = await box.get(surahNum, defaultValue: null);
    if (surahData is! List) return null;

    // Convert requested ayahKey to absolute number for comparison
    final absoluteAyahNum = convertKeyToAyahNumber(ayahKey);
    if (absoluteAyahNum == null) return null;

    final matches = <Map<String, dynamic>>[];
    for (final entry in surahData) {
      if (entry is! Map) continue;
      final src = entry['src'];
      if (src is! Map) continue;
      // src.ayah can be a single int or a List of ints (multi-ayah match)
      final srcAyah = src['ayah'];
      final bool isMatch;
      if (srcAyah is List) {
        isMatch = srcAyah.contains(absoluteAyahNum);
      } else if (srcAyah is int) {
        isMatch = srcAyah == absoluteAyahNum;
      } else {
        isMatch = false;
      }
      if (isMatch) {
        // Convert absolute ayah numbers to surah:verse keys for display
        final convertedEntry = Map<String, dynamic>.from(entry);
        // Convert src.ayah
        if (srcAyah is int) {
          final key = convertAyahNumberToKey(srcAyah);
          convertedEntry['src'] = {"ayah_key": key ?? ayahKey, "absolute": srcAyah};
        } else if (srcAyah is List) {
          convertedEntry['src'] = {
            "ayah_keys": srcAyah.map((a) => convertAyahNumberToKey(a) ?? "?").toList(),
            "absolute": srcAyah,
          };
        }
        // Convert muts ayah numbers
        final muts = entry['muts'];
        if (muts is List) {
          convertedEntry['muts'] = muts.map((m) {
            if (m is Map && m['ayah'] is int) {
              final key = convertAyahNumberToKey(m['ayah']);
              return {"ayah_key": key ?? "?", "absolute": m['ayah']};
            }
            return m;
          }).toList();
        }
        matches.add(convertedEntry);
      }
    }
    if (matches.isEmpty) return null;
    return matches;
  }

  /// Get similar ayahs data for a specific ayah (from similar_ayah books)
  static Future<List<Map<String, dynamic>>?> getSimilarAyahsForAyah(
    MutashabihatBookModel book,
    String ayahKey,
  ) async {
    final boxName = getMutashabihatBoxName(mutashabihatBook: book);
    if (!await Hive.boxExists(boxName)) return null;
    LazyBox? box;
    if (!Hive.isBoxOpen(boxName)) {
      box = await Hive.openLazyBox(boxName);
    } else {
      box = Hive.lazyBox(boxName);
    }

    // 1) Try string ayahKey
    final data = await box.get(ayahKey, defaultValue: null);
    if (data != null) {
      if (data is List) {
        return data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      if (data is Map) {
        return [Map<String, dynamic>.from(data)];
      }
      if (data is String && data.trim().isNotEmpty) {
        return [{"t": data.trim(), "src": ayahKey}];
      }
    }

    // 2) Fallback: Waqar144 surah-keyed with int keys + absolute ayah numbers
    final parts = ayahKey.split(":");
    if (parts.length != 2) return null;
    final surahNum = int.tryParse(parts.first);
    if (surahNum == null) return null;

    final surahData = await box.get(surahNum, defaultValue: null);
    if (surahData is! List) return null;

    final absoluteAyahNum = convertKeyToAyahNumber(ayahKey);
    if (absoluteAyahNum == null) return null;

    final matches = <Map<String, dynamic>>[];
    for (final entry in surahData) {
      if (entry is! Map) continue;
      final src = entry['src'];
      if (src is! Map) continue;
      final srcAyah = src['ayah'];
      final bool isMatch;
      if (srcAyah is List) {
        isMatch = srcAyah.contains(absoluteAyahNum);
      } else if (srcAyah is int) {
        isMatch = srcAyah == absoluteAyahNum;
      } else {
        isMatch = false;
      }
      if (isMatch) {
        final convertedEntry = Map<String, dynamic>.from(entry);
        if (srcAyah is int) {
          final key = convertAyahNumberToKey(srcAyah);
          convertedEntry['src'] = {"ayah_key": key ?? ayahKey, "absolute": srcAyah};
        } else if (srcAyah is List) {
          convertedEntry['src'] = {
            "ayah_keys": srcAyah.map((a) => convertAyahNumberToKey(a) ?? "?").toList(),
            "absolute": srcAyah,
          };
        }
        final muts = entry['muts'];
        if (muts is List) {
          convertedEntry['muts'] = muts.map((m) {
            if (m is Map && m['ayah'] is int) {
              final key = convertAyahNumberToKey(m['ayah']);
              return {"ayah_key": key ?? "?", "absolute": m['ayah']};
            }
            return m;
          }).toList();
        }
        matches.add(convertedEntry);
      }
    }
    if (matches.isEmpty) return null;
    return matches;
  }

  static Future<void> close() async {
    List<MutashabihatBookModel> selectedBooks =
        getDownloadedMutashabihatBooks();
    selectedBooks.addAll(await getMutashabihatSelections() ?? []);
    for (MutashabihatBookModel bookModel in selectedBooks) {
      String boxName = getMutashabihatBoxName(mutashabihatBook: bookModel);
      if (Hive.isBoxOpen(boxName)) {
        await Hive.lazyBox(boxName).close();
      }
    }
  }
}
