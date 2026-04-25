import "dart:convert";
import "dart:developer";

import "package:al_furkan/src/resources/quran_resources/models/transliteration_book_model.dart";
import "package:dio/dio.dart" as dio;
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

import "../../api/apis_urls.dart";
import "../../screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "../encode_decode.dart";

class QuranTransliterationFunction {
  static const String selectedTransliterationListKey =
      "selected_transliteration_list";
  static const String downloadedTransliterationBooksKey =
      "downloaded_transliteration_books";
  static const String downloadedTransliterationOrderKey =
      "downloaded_transliteration_order";
  static const String downloadedTransliterationSizeBytesKey =
      "downloaded_transliteration_size_bytes";
  static final Map<String, int?> _remoteSizeBytesCache = {};

  static List<String> getDownloadedTransliterationOrderIds() {
    final userBox = Hive.box("user");
    final raw =
        userBox.get(downloadedTransliterationOrderKey, defaultValue: []);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const <String>[];
  }

  static Future<void> setDownloadedTransliterationOrderIds(
    List<String> ids,
  ) async {
    final userBox = Hive.box("user");
    final seen = <String>{};
    final deduped = <String>[];
    for (final id in ids) {
      if (seen.add(id)) deduped.add(id);
    }
    await userBox.put(downloadedTransliterationOrderKey, deduped);
  }

  static int? getDownloadedTransliterationSizeBytes(String id) {
    final userBox = Hive.box("user");
    final raw = userBox.get(downloadedTransliterationSizeBytesKey);
    if (raw is Map) {
      final value = raw[id];
      return value is int ? value : int.tryParse(value?.toString() ?? "");
    }
    return null;
  }

  static Future<void> setDownloadedTransliterationSizeBytes(
    String id,
    int bytes,
  ) async {
    final userBox = Hive.box("user");
    final raw = userBox.get(downloadedTransliterationSizeBytesKey);
    final map = <String, dynamic>{};
    if (raw is Map) {
      map.addAll(raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    map[id] = bytes;
    await userBox.put(downloadedTransliterationSizeBytesKey, map);
  }

  static String getTransliterationBoxName({
    required TransliterationBookModel transliterationBook,
  }) {
    String sanitizedBook = transliterationBook.fullPath
        .split("/")
        .last
        .replaceAll(RegExp(r"[^\w\.-]"), "_");
    return "transliteration_${transliterationBook.language}_$sanitizedBook";
  }

  static Future<bool> isAlreadyDownloaded(
    TransliterationBookModel transliterationBook,
  ) async {
    final boxName =
        getTransliterationBoxName(transliterationBook: transliterationBook);
    return await Hive.boxExists(boxName);
  }

  static Future<void> setToListAlreadyDownloaded({
    required TransliterationBookModel transliterationBook,
  }) async {
    final userBox = Hive.box("user");
    List<TransliterationBookModel> downloadedBooks =
        getDownloadedTransliterationBooks();
    if (!downloadedBooks
        .any((book) => book.fullPath == transliterationBook.fullPath)) {
      downloadedBooks.add(transliterationBook);
      await userBox.put(
        downloadedTransliterationBooksKey,
        downloadedBooks.map((e) => e.toMap()).toList(),
      );
    }
  }

  static List<TransliterationBookModel>
      getDownloadedTransliterationBooks() {
    final userBox = Hive.box("user");
    final raw = List<Map>.from(
      userBox.get(downloadedTransliterationBooksKey, defaultValue: []),
    );
    return raw
        .map((e) =>
            TransliterationBookModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> removeFromListAlreadyDownloaded(
    TransliterationBookModel transliterationBook,
  ) async {
    final userBox = Hive.box("user");
    List<TransliterationBookModel> downloadedBooks =
        getDownloadedTransliterationBooks();
    bool changed = false;
    downloadedBooks.removeWhere((book) {
      if (transliterationBook.fullPath == book.fullPath) {
        changed = true;
        return true;
      }
      return false;
    });

    if (changed) {
      await userBox.put(
        downloadedTransliterationBooksKey,
        downloadedBooks.map((e) => e.toMap()).toList(),
      );
    }

    final boxName =
        getTransliterationBoxName(transliterationBook: transliterationBook);
    if (await Hive.boxExists(boxName)) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.lazyBox(boxName).close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      log(
        "Deleted Transliteration box: $boxName",
        name: "removeFromListAlreadyDownloaded",
      );
    }
    await removeTransliterationSelection(transliterationBook);
  }

  static Future<void> setTransliterationSelection(
    TransliterationBookModel transliterationBook,
  ) async {
    final userBox = Hive.box("user");
    List<TransliterationBookModel> selectedList =
        (await getTransliterationSelections()) ?? [];
    if (!selectedList
        .any((b) => b.fullPath == transliterationBook.fullPath)) {
      selectedList.add(transliterationBook);
      await userBox.put(
        selectedTransliterationListKey,
        selectedList.map((e) => e.toMap()).toList(),
      );
    }
    await init();
  }

  static Future<void> removeTransliterationSelection(
    TransliterationBookModel transliterationBook,
  ) async {
    final userBox = Hive.box("user");
    List<TransliterationBookModel> selectedList =
        (await getTransliterationSelections()) ?? [];
    selectedList.removeWhere(
      (element) => element.fullPath == transliterationBook.fullPath,
    );
    await userBox.put(
      selectedTransliterationListKey,
      selectedList.map((e) => e.toMap()).toList(),
    );
    await init();
  }

  static Future<void> replaceTransliterationSelections(
    List<TransliterationBookModel> books,
  ) async {
    final userBox = Hive.box("user");
    final seen = <String>{};
    final deduped = <TransliterationBookModel>[];
    for (final b in books) {
      if (seen.add(b.fullPath)) deduped.add(b);
    }
    await userBox.put(
      selectedTransliterationListKey,
      deduped.map((e) => e.toMap()).toList(),
    );
    await init();
  }

  static Future<List<TransliterationBookModel>?>
      getTransliterationSelections() async {
    final userBox = Hive.box("user");
    List? booksList = userBox.get(selectedTransliterationListKey);
    return booksList
        ?.map((e) =>
            TransliterationBookModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<int?> getRemoteBookSizeBytes(
    TransliterationBookModel book,
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

    List<TransliterationBookModel>? booksListToOpen =
        await getTransliterationSelections();
    booksListToOpen ??= [];

    for (TransliterationBookModel bookModel in booksListToOpen) {
      final boxName =
          getTransliterationBoxName(transliterationBook: bookModel);
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
    required TransliterationBookModel transliterationBook,
    bool isSetupProcess = false,
  }) async {
    final cubit = context.read<ResourcesProgressCubit>();

    if (await isAlreadyDownloaded(transliterationBook)) {
      log(
        "Transliteration '${transliterationBook.fullPath}' is already downloaded.",
        name: "downloadResources",
      );
      if (isSetupProcess) {
        await setTransliterationSelection(transliterationBook);
      }
      await init();
      return true;
    }

    cubit.onProcess();
    cubit.updateProgress(
      0.0,
      "Downloading: ${transliterationBook.name}",
      activeResourceId: transliterationBook.fullPath,
    );

    final boxName =
        getTransliterationBoxName(transliterationBook: transliterationBook);

    log(
      "Starting download for Transliteration Box: $boxName",
      name: "downloadResources",
    );

    LazyBox transliterationBox;
    try {
      transliterationBox = await Hive.openLazyBox(boxName);
    } catch (e) {
      log(
        "Error opening LazyBox '$boxName': $e. Trying to delete and reopen.",
        name: "downloadResources",
      );
      try {
        await Hive.deleteBoxFromDisk(boxName);
        transliterationBox = await Hive.openLazyBox(boxName);
      } catch (e2) {
        log(
          "Failed to open LazyBox '$boxName' even after delete: $e2",
          name: "downloadResources",
        );
        cubit.failure(
          "Error preparing Transliteration storage",
          activeResourceId: transliterationBook.fullPath,
        );
        return false;
      }
    }

    int? reportedTotalBytes;
    try {
      String base = ApisUrls.base;
      cubit.updateProgress(
        0.0,
        "Downloading: ${transliterationBook.name}",
        activeResourceId: transliterationBook.fullPath,
      );
      dio.Response response = await dio.Dio().get(
        base + transliterationBook.fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            reportedTotalBytes = total;
            double progress = received / total;
            cubit.updateProgress(
              progress * 0.5,
              "Downloading: ${transliterationBook.name}",
              transferredBytes: received,
              totalBytes: total,
              activeResourceId: transliterationBook.fullPath,
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
      if (isHtml && ApisUrls.fallbackTransliteration.isNotEmpty) {
        // Primary server returned HTML — try fallback CDN (plain JSON, not BZip2)
        log(
          "Primary server returned HTML for Transliteration. Trying fallback CDN.",
          name: "downloadResources",
        );
        cubit.updateProgress(
          0.1,
          "Downloading (fallback): ${transliterationBook.name}",
          activeResourceId: transliterationBook.fullPath,
        );
        final fallbackResponse = await dio.Dio().get(
          ApisUrls.fallbackTransliteration,
        );
        final fallbackData = fallbackResponse.data as String;
        // Fallback is plain JSON — parse directly, no BZip2 decompression.
        // risan/quran-json format: { "1": { "1": "bismi...", "2": "..." }, ... }
        final parsed = await compute(
          (message) => jsonDecode(message) as Map,
          fallbackData,
        );
        // Convert surah-keyed format to ayah-keyed format
        final ayahKeyed = <String, dynamic>{};
        for (final surahEntry in parsed.entries) {
          final surahNum = surahEntry.key;
          final verses = surahEntry.value;
          if (verses is Map) {
            for (final verseEntry in verses.entries) {
              final ayahKey = "$surahNum:${verseEntry.key}";
              ayahKeyed[ayahKey] = verseEntry.value;
            }
          }
        }
        data = ayahKeyed;
        reportedTotalBytes = fallbackData.length;
      } else {
        cubit.updateProgress(
          0.5,
          "Processing: ${transliterationBook.name}",
          activeResourceId: transliterationBook.fullPath,
        );
        data = await compute(
          (message) => jsonDecode(decodeBZip2String(message as String)),
          response.data,
        );
      }

      cubit.updateProgress(
        0.75,
        "Processing Transliteration",
        activeResourceId: transliterationBook.fullPath,
      );

      await transliterationBox.putAll(data.cast<String, dynamic>());
      await transliterationBox.put("meta_data", transliterationBook.toMap());

      await setToListAlreadyDownloaded(
        transliterationBook: transliterationBook,
      );
      if (reportedTotalBytes != null && reportedTotalBytes! > 0) {
        await setDownloadedTransliterationSizeBytes(
          transliterationBook.fullPath,
          reportedTotalBytes!,
        );
      }
      if (isSetupProcess) {
        await setTransliterationSelection(transliterationBook);
      }

      log(
        "Transliteration '${transliterationBook.fullPath}' downloaded and processed successfully.",
        name: "downloadResources",
      );
      await init();
      cubit.updateProgress(
        1.0,
        "Downloaded: ${transliterationBook.name}",
        transferredBytes: 1,
        totalBytes: 1,
        activeResourceId: transliterationBook.fullPath,
      );
      await Future<void>.delayed(const Duration(milliseconds: 220));
      cubit.success(activeResourceId: transliterationBook.fullPath);
      return true;
    } catch (e, s) {
      log(
        "Error downloading or processing Transliteration '${transliterationBook.name}': $e\n$s",
        name: "downloadResources",
      );
      cubit.failure(
        "Error downloading Transliteration",
        activeResourceId: transliterationBook.fullPath,
      );
      if (transliterationBox.isOpen) {
        await transliterationBox.close();
      }
      await Hive.deleteBoxFromDisk(boxName);
      return false;
    }
  }

  /// Get transliteration for a specific ayah
  static Future<String?> getTransliterationForAyah(
    TransliterationBookModel book,
    String ayahKey,
  ) async {
    final boxName =
        getTransliterationBoxName(transliterationBook: book);
    LazyBox? box;
    if (!Hive.isBoxOpen(boxName)) {
      box = await Hive.openLazyBox(boxName);
    } else {
      box = Hive.lazyBox(boxName);
    }
    final data = await box.get(ayahKey, defaultValue: null);
    if (data is String) return data;
    if (data is Map) return data['text']?.toString();
    return null;
  }

  static Future<void> close() async {
    List<TransliterationBookModel> selectedBooks =
        getDownloadedTransliterationBooks();
    selectedBooks.addAll(await getTransliterationSelections() ?? []);
    for (TransliterationBookModel bookModel in selectedBooks) {
      String boxName =
          getTransliterationBoxName(transliterationBook: bookModel);
      if (Hive.isBoxOpen(boxName)) {
        await Hive.lazyBox(boxName).close();
      }
    }
  }
}
