import "dart:convert";
import "dart:developer";

import "package:al_furkan/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:dio/dio.dart" as dio;
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

import "package:al_furkan/src/utils/quran_resources/default_offline_resources.dart";

import "../../api/apis_urls.dart";
import "../../screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "../encode_decode.dart";
import "../get_tafsir_from_db.dart";

class QuranTafsirFunction {
  static const String selectedTafsirListKey = "selected_tafsir_list";
  static const String downloadedTafsirBooksKey = "downloaded_tafsir_books";
  static const String downloadedTafsirOrderKey = "downloaded_tafsir_order";
  static const String downloadedTafsirSizeBytesKey =
      "downloaded_tafsir_size_bytes";
  static final Map<String, int?> _remoteSizeBytesCache = {};

  static List<String> getDownloadedTafsirOrderIds() {
    final userBox = Hive.box("user");
    final raw = userBox.get(downloadedTafsirOrderKey, defaultValue: []);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const <String>[];
  }

  static Future<void> setDownloadedTafsirOrderIds(List<String> ids) async {
    final userBox = Hive.box("user");
    final seen = <String>{};
    final deduped = <String>[];
    for (final id in ids) {
      if (seen.add(id)) deduped.add(id);
    }
    await userBox.put(downloadedTafsirOrderKey, deduped);
  }

  static int? getDownloadedTafsirSizeBytes(String id) {
    final userBox = Hive.box("user");
    final raw = userBox.get(downloadedTafsirSizeBytesKey);
    if (raw is Map) {
      final value = raw[id];
      return value is int ? value : int.tryParse(value?.toString() ?? "");
    }
    return null;
  }

  static Future<void> setDownloadedTafsirSizeBytes(String id, int bytes) async {
    final userBox = Hive.box("user");
    final raw = userBox.get(downloadedTafsirSizeBytesKey);
    final map = <String, dynamic>{};
    if (raw is Map) {
      map.addAll(raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    map[id] = bytes;
    await userBox.put(downloadedTafsirSizeBytesKey, map);
  }

  static bool _isBundled(TafsirBookModel book) {
    return book.fullPath.startsWith("bundled/");
  }

  static List<TafsirBookModel> _dedupeBooks(Iterable<TafsirBookModel> books) {
    final seen = <String>{};
    final deduped = <TafsirBookModel>[];
    for (final book in books) {
      final key = "${book.language}::${book.fullPath}";
      if (seen.add(key)) {
        deduped.add(book);
      }
    }
    return deduped;
  }

  static final TafsirBookModel _defaultSaadiTafsir =
      DefaultOfflineResources.defaultTafsirSaadi;

  static Future<void> init() async {
    if (!Hive.isBoxOpen("user")) {
      await Hive.openBox("user");
    }

    // Ensure bundled offline resources (including Saadi) are installed and
    // present in Hive before we open selections.
    await DefaultOfflineResources.ensureInstalled();

    List<TafsirBookModel>? booksListToOpen = await getTafsirSelections();

    // Only auto-select Saadi if the key doesn't exist at all (first run).
    final userBox = Hive.box("user");
    if (!userBox.containsKey(selectedTafsirListKey)) {
      booksListToOpen = [_defaultSaadiTafsir];
      await userBox.put(
        selectedTafsirListKey,
        _dedupeBooks(booksListToOpen).map((e) => e.toMap()).toList(),
      );
    } else {
      booksListToOpen ??= [];
    }

    log(
      booksListToOpen.map((e) => e.toMap()).toString(),
      name: "QuranTafsirFunction.init",
    );

    for (TafsirBookModel bookModel in booksListToOpen) {
      final boxName = getTafsirBoxName(tafsirBook: bookModel);
      if (!Hive.isBoxOpen(boxName)) {
        try {
          await Hive.openLazyBox(boxName);
        } catch (_) {
          // Box doesn't exist yet - will be downloaded later
        }
      }
    }

    // Saadi is bundled; no network download should be triggered here.
  }

  /// Downloads a tafsir book silently in the background without UI feedback.
  static Future<void> _downloadSilently(TafsirBookModel book) async {
    try {
      log(
        "Silent download starting for '${book.name}'",
        name: "QuranTafsirFunction",
      );

      final tafsirBoxName = getTafsirBoxName(tafsirBook: book);
      LazyBox tafsirBox;
      try {
        tafsirBox = Hive.isBoxOpen(tafsirBoxName)
            ? Hive.lazyBox(tafsirBoxName)
            : await Hive.openLazyBox(tafsirBoxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(tafsirBoxName);
        tafsirBox = await Hive.openLazyBox(tafsirBoxName);
      }

      Map data;
      if (book.name == _defaultSaadiTafsir.name) {
        // Load natively built-in offline Tafsir directly from assets
        final assetString = await rootBundle.loadString(
          "assets/wahy/json/Tafseer_Al_Saddi.json",
        );
        data = await compute((message) {
          final rawJson = jsonDecode(message);
          if (rawJson is Map && rawJson.containsKey("tafsir")) {
            // Uncompress array of arrays into "surah:verse" -> {"text": ...}
            final List tafsirList = rawJson["tafsir"];
            Map<String, dynamic> converted = {};
            for (int s = 0; s < tafsirList.length; s++) {
               final verses = tafsirList[s] as List;
               for (int v = 0; v < verses.length; v++) {
                 converted["${s+1}:${v+1}"] = {"text": verses[v]};
               }
            }
            return converted;
          }
          return rawJson as Map; // Assume it's already key-value mapped
        }, assetString);
      } else {
        // Fallback for downloading other optional Tafsirs
        final response = await dio.Dio().get(ApisUrls.base + book.fullPath);
        data = await compute(
          (message) => jsonDecode(decodeBZip2String(message as String)),
          response.data,
        );
      }

      await tafsirBox.putAll(data.cast<String, dynamic>());

      await tafsirBox.put("meta_data", book.toMap());
      await setToListAlreadyDownloaded(tafsirBook: book);

      log(
        "Silent download completed for '${book.name}'",
        name: "QuranTafsirFunction",
      );
    } catch (e, s) {
      log(
        "Silent download failed for '${book.name}': $e\n$s",
        name: "QuranTafsirFunction",
      );
      // Fail silently - user can manually download later
    }
  }

  static String getTafsirBoxName({required TafsirBookModel tafsirBook}) {
    String sanitizedBook = tafsirBook.fullPath
        .split("/")
        .last
        .replaceAll(RegExp(r"[^\w\.-]"), "_");

    return "tafsir_${tafsirBook.language}_$sanitizedBook";
  }

  static Future<List<String>?> getSelectedTafsirBoxName() async {
    List<TafsirBookModel>? tafsirSelectionList = await getTafsirSelections();
    if (tafsirSelectionList != null) {
      return tafsirSelectionList
          .map((e) => getTafsirBoxName(tafsirBook: e))
          .toList();
    }
    return null;
  }

  static Future<String?> getResolvedTafsirTextForBook(
    TafsirBookModel tafsirBook,
    String ayahKey, {
    int maxDepth = 3,
  }) async {
    String currentKey = ayahKey;
    for (int depth = 0; depth <= maxDepth; depth++) {
      final TafsirOfAyah? tafsir = await getTafsirForBook(
        tafsirBook,
        currentKey,
      );
      final Map? map = tafsir?.tafsir;
      final String? text = getStringFromTafsirFromDb(
        map,
        returnAyahKeyIfLinked: true,
      );

      if (text == null || text.trim().isEmpty) {
        return null;
      }

      final parts = text.split(":");
      final bool isLinked =
          parts.length == 2 &&
          int.tryParse(parts.first) != null &&
          int.tryParse(parts.last) != null;

      if (!isLinked) {
        return text;
      }

      currentKey = text;
    }

    return null;
  }

  static Future<bool> isAlreadyDownloaded(TafsirBookModel tafsirBook) async {
    if (_isBundled(tafsirBook)) {
      return true;
    }
    final boxName = getTafsirBoxName(tafsirBook: tafsirBook);
    return await Hive.boxExists(boxName);
  }

  static Future<void> setToListAlreadyDownloaded({
    required TafsirBookModel tafsirBook,
  }) async {
    final userBox = Hive.box("user");
    List<TafsirBookModel> downloadedBooks = getDownloadedTafsirBooks();
    if (!downloadedBooks.any((book) => book.fullPath == tafsirBook.fullPath)) {
      downloadedBooks.add(tafsirBook);
      await userBox.put(
        downloadedTafsirBooksKey,
        downloadedBooks.map((e) => e.toMap()).toList(),
      );
    }
  }

  static List<TafsirBookModel> getDownloadedTafsirBooks() {
    final userBox = Hive.box("user");
    final raw = List<Map>.from(
      userBox.get(downloadedTafsirBooksKey, defaultValue: []),
    );

    final books = raw
        .map((e) => TafsirBookModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    // Bundled tafsirs should always be treated as downloaded.
    // This ensures 'تفسير السعدي' never appears as a downloadable resource.
    books.add(DefaultOfflineResources.defaultTafsirSaadi);

    // De-duplicate by fullPath after normalization.
    final seen = <String>{};
    final deduped = <TafsirBookModel>[];
    for (final b in books) {
      if (seen.add(b.fullPath)) {
        deduped.add(b);
      }
    }
    return deduped;
  }

  static Future<void> removeFromListAlreadyDownloaded(
    TafsirBookModel tafsirBook,
  ) async {
    final userBox = Hive.box("user");
    List<TafsirBookModel> downloadedBooks = getDownloadedTafsirBooks();
    bool changed = false;
    downloadedBooks.removeWhere((book) {
      if (tafsirBook.fullPath == book.fullPath) {
        changed = true;
        return true;
      }
      return false;
    });

    if (changed) {
      // Filter out bundled tafsir before saving to DB
      final toSave = downloadedBooks.where((b) => !_isBundled(b)).toList();
      await userBox.put(
        downloadedTafsirBooksKey,
        toSave.map((e) => e.toMap()).toList(),
      );
    }

    final tafsirBoxName = getTafsirBoxName(tafsirBook: tafsirBook);
    if (await Hive.boxExists(tafsirBoxName)) {
      if (Hive.isBoxOpen(tafsirBoxName)) {
        await Hive.lazyBox(tafsirBoxName).close();
      }
      await Hive.deleteBoxFromDisk(tafsirBoxName);
      log(
        "Deleted Tafsir box: $tafsirBoxName",
        name: "removeFromListAlreadyDownloaded",
      );
    }
    await removeTafsirSelection(tafsirBook);
  }

  static Future<void> setTafsirSelection(TafsirBookModel tafsirBook) async {
    final userBox = Hive.box("user");
    List<TafsirBookModel> selectedTafsirList =
        (await getTafsirSelections()) ?? [];
    if (!selectedTafsirList.any((b) => b.fullPath == tafsirBook.fullPath)) {
      selectedTafsirList.add(tafsirBook);
      await userBox.put(
        selectedTafsirListKey,
        _dedupeBooks(selectedTafsirList).map((e) => e.toMap()).toList(),
      );
    }
    await init();
  }

  static Future<void> removeTafsirSelection(TafsirBookModel tafsirBook) async {
    final userBox = Hive.box("user");
    List<TafsirBookModel> selectedTafsirList =
        (await getTafsirSelections()) ?? [];
    selectedTafsirList.removeWhere(
      (element) => element.fullPath == tafsirBook.fullPath,
    );
    await userBox.put(
      selectedTafsirListKey,
      selectedTafsirList.map((e) => e.toMap()).toList(),
    );
    await init();
  }

  static Future<void> replaceTafsirSelections(
    List<TafsirBookModel> books,
  ) async {
    final userBox = Hive.box("user");
    final deduped = _dedupeBooks(books);
    await userBox.put(
      selectedTafsirListKey,
      deduped.map((e) => e.toMap()).toList(),
    );
    await init();
  }

  static Future<List<TafsirBookModel>?> getTafsirSelections() async {
    final userBox = Hive.box("user");
    final Map<String, dynamic>? previousBookMap = userBox
        .get("selected_tafsir")
        ?.cast<String, dynamic>();

    if (previousBookMap != null) {
      await userBox.put(selectedTafsirListKey, [previousBookMap]);
      await userBox.delete("selected_tafsir");
    }

    List? booksList = userBox.get(selectedTafsirListKey);
    final parsed = booksList
        ?.map((e) => TafsirBookModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final hasLegacySaadi = (parsed ?? const <TafsirBookModel>[]).any(
      (b) =>
          b.name.trim() == DefaultOfflineResources.defaultTafsirSaadi.name &&
          b.fullPath != DefaultOfflineResources.defaultTafsirSaadi.fullPath,
    );

    final normalized = parsed
        ?.map((b) {
          if (b.name.trim() == DefaultOfflineResources.defaultTafsirSaadi.name) {
            return DefaultOfflineResources.defaultTafsirSaadi;
          }
          return b;
        })
        .toList();

    final result = normalized == null ? null : _dedupeBooks(normalized);
    if (result != null && hasLegacySaadi) {
      await userBox.put(
        selectedTafsirListKey,
        result.map((e) => e.toMap()).toList(),
      );
    }
    return result;
  }

  static Future<int?> getRemoteBookSizeBytes(TafsirBookModel book) async {
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

  static Future<bool> downloadResources({
    required BuildContext context,
    required TafsirBookModel tafsirBook,
    bool isSetupProcess = false,
  }) async {
    if (_isBundled(tafsirBook)) {
      // Bundled resources are already available locally.
      if (isSetupProcess) {
        await setTafsirSelection(tafsirBook);
      }
      await init();
      return true;
    }

    final cubit = context.read<ResourcesProgressCubit>();

    if (await isAlreadyDownloaded(tafsirBook)) {
      log(
        "Tafsir '${tafsirBook.fullPath}' is already downloaded.",
        name: "downloadResources",
      );
      if (isSetupProcess) {
        await setTafsirSelection(tafsirBook);
      }
      await init();
      return true;
    }

    cubit.onProcess();
    cubit.changeTafsirBook(tafsirBook);
    cubit.updateProgress(
      0.0,
      "Downloading Tafsir: ${tafsirBook.name}",
      activeResourceId: tafsirBook.fullPath,
    );

    final tafsirBoxName = getTafsirBoxName(tafsirBook: tafsirBook);

    log(
      "Starting download for Tafsir Box: $tafsirBoxName",
      name: "downloadResources",
    );

    LazyBox tafsirBox;
    try {
      tafsirBox = await Hive.openLazyBox(tafsirBoxName);
    } catch (e) {
      log(
        "Error opening LazyBox '$tafsirBoxName': $e. Trying to delete and reopen.",
        name: "downloadResources",
      );
      try {
        await Hive.deleteBoxFromDisk(tafsirBoxName);
        tafsirBox = await Hive.openLazyBox(tafsirBoxName);
      } catch (e2) {
        log(
          "Failed to open LazyBox '$tafsirBoxName' even after delete: $e2",
          name: "downloadResources",
        );
        cubit.failure("Error preparing Tafsir storage", activeResourceId: tafsirBook.fullPath);
        return false;
      }
    }

    int? reportedTotalBytes;
    try {
      String base = ApisUrls.base;
      cubit.updateProgress(
        0.0,
        "Downloading: ${tafsirBook.name}",
        activeResourceId: tafsirBook.fullPath,
      );
      dio.Response response = await dio.Dio().get(
        base + tafsirBook.fullPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            reportedTotalBytes = total;
            double progress = received / total;
            cubit.updateProgress(
              progress * 0.5,
              "Downloading: ${tafsirBook.name}",
              transferredBytes: received,
              totalBytes: total,
              activeResourceId: tafsirBook.fullPath,
            );
          }
        },
      );

      // Detect HTML responses — safety net in case the server returns
      // an HTML page instead of actual BZip2-compressed data.
      String? responseData = response.data as String?;
      final bool isHtml = responseData != null &&
          (responseData.trimLeft().startsWith('<') ||
           response.headers.value('content-type')?.contains('text/html') == true);

      if (isHtml) {
        log(
          "Server returned HTML instead of Tafsir data for '${tafsirBook.fullPath}'",
          name: "downloadResources",
        );
        cubit.failure(
          "المورد غير متاح حالياً على السيرفر — جرب لاحقاً",
          activeResourceId: tafsirBook.fullPath,
        );
        if (tafsirBox.isOpen) await tafsirBox.close();
        await Hive.deleteBoxFromDisk(tafsirBoxName);
        return false;
      }

      cubit.updateProgress(
        0.5,
        "Processing: ${tafsirBook.name}",
        activeResourceId: tafsirBook.fullPath,
      );
      Map data = await compute(
        (message) => jsonDecode(decodeBZip2String(message)),
        response.data,
      );

      cubit.updateProgress(
        0.75,
        "Processing Tafsir",
        activeResourceId: tafsirBook.fullPath,
      );
      
      await tafsirBox.putAll(data.cast<String, dynamic>());

      await tafsirBox.put("meta_data", tafsirBook.toMap());

      await setToListAlreadyDownloaded(tafsirBook: tafsirBook);
      if (reportedTotalBytes != null && reportedTotalBytes! > 0) {
        await setDownloadedTafsirSizeBytes(tafsirBook.fullPath, reportedTotalBytes!);
      }
      if (isSetupProcess) {
        await setTafsirSelection(tafsirBook);
      }

      log(
        "Tafsir '${tafsirBook.fullPath}' downloaded and processed successfully.",
        name: "downloadResources",
      );
      await init();
      cubit.updateProgress(
        1.0,
        "Downloaded: ${tafsirBook.name}",
        transferredBytes: 1,
        totalBytes: 1,
        activeResourceId: tafsirBook.fullPath,
      );
      await Future<void>.delayed(const Duration(milliseconds: 220));
      cubit.success(activeResourceId: tafsirBook.fullPath);
      return true;
    } catch (e, s) {
      log(
        "Error downloading or processing Tafsir '${tafsirBook.name}': $e\n$s",
        name: "downloadResources",
      );
      cubit.failure("Error downloading Tafsir", activeResourceId: tafsirBook.fullPath);
      if (tafsirBox.isOpen) {
        await tafsirBox.close();
      }
      await Hive.deleteBoxFromDisk(tafsirBoxName);
      return false;
    }
  }

  static Future<List<TafsirOfAyah>> getTafsir(String ayahKey) async {
    final List<TafsirOfAyah> toReturn = [];
    List<TafsirBookModel>? selectedBooks = await getTafsirSelections() ?? [];

    final orderIds = getDownloadedTafsirOrderIds();
    if (orderIds.isNotEmpty) {
      selectedBooks.sort((a, b) {
        final indexA = orderIds.indexOf(a.fullPath);
        final indexB = orderIds.indexOf(b.fullPath);
        if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
        if (indexA != -1) return -1;
        if (indexB != -1) return 1;
        return 0;
      });
    }

    for (TafsirBookModel bookModel in selectedBooks) {
      String boxName = getTafsirBoxName(tafsirBook: bookModel);
      LazyBox? tafsirBox;
      if (!Hive.isBoxOpen(boxName)) {
        tafsirBox = await Hive.openLazyBox(boxName);
      } else {
        tafsirBox = Hive.lazyBox(boxName);
      }
      final tafsirData = await tafsirBox.get(ayahKey, defaultValue: null);
      if (tafsirData != null) {
        toReturn.add(
          TafsirOfAyah(
            tafsir: Map<String, dynamic>.from(tafsirData),
            bookInfo: bookModel,
          ),
        );
      }
    }
    return toReturn;
  }

  static Future<List<TafsirOfAyah>> getDownloadedTafsirs(String ayahKey) async {
    final List<TafsirOfAyah> toReturn = [];

    List<TafsirBookModel> targetBooks = await getTafsirSelections() ?? [];

    // Sort targetBooks according to downloadedTafsirOrderKey
    final orderIds = getDownloadedTafsirOrderIds();
    if (orderIds.isNotEmpty) {
      targetBooks.sort((a, b) {
        final indexA = orderIds.indexOf(a.fullPath);
        final indexB = orderIds.indexOf(b.fullPath);
        if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
        if (indexA != -1) return -1;
        if (indexB != -1) return 1;
        return 0;
      });
    }

    for (TafsirBookModel bookModel in targetBooks) {
      final result = await getTafsirForBook(bookModel, ayahKey);
      if (result != null) {
        toReturn.add(result);
      }
    }

    return toReturn;
  }

  static Future<TafsirOfAyah?> getTafsirForBook(
    TafsirBookModel tafsirBook,
    String ayahKey,
  ) async {
    String boxName = getTafsirBoxName(tafsirBook: tafsirBook);
    LazyBox? tafsirBox;
    if (!Hive.isBoxOpen(boxName)) {
      tafsirBox = await Hive.openLazyBox(boxName);
    } else {
      tafsirBox = Hive.lazyBox(boxName);
    }
    final tafsirData = await tafsirBox.get(ayahKey, defaultValue: null);
    if (tafsirData != null) {
      return TafsirOfAyah(
        tafsir: Map<String, dynamic>.from(tafsirData),
        bookInfo: tafsirBook,
      );
    }
    return null;
  }

  static Future<Map?> getMetaInfoAsync(TafsirBookModel tafsirBook) async {
    final boxName = getTafsirBoxName(tafsirBook: tafsirBook);
    if (await Hive.boxExists(boxName)) {
      final box = await Hive.openLazyBox(boxName);
      try {
        final data = await box.get("meta_data");
        await box.close();
        return data as Map?;
      } catch (e) {
        log("Error fetching meta_data: $e", name: "getMetaInfoAsync");
        await box.close();
        return null;
      }
    }
    log(
      "Tafsir box is not open. Cannot get meta info.",
      name: "getMetaInfoAsync",
    );
    return null;
  }

  static Future<void> close() async {
    List<TafsirBookModel> selectedBooks = getDownloadedTafsirBooks();
    selectedBooks.addAll(await getTafsirSelections() ?? []);
    for (TafsirBookModel bookModel in selectedBooks) {
      String boxName = getTafsirBoxName(tafsirBook: bookModel);
      if (Hive.isBoxOpen(boxName)) {
        await Hive.lazyBox(boxName).close();
      }
    }
  }
}

class TafsirOfAyah {
  final Map<String, dynamic> tafsir;
  final TafsirBookModel bookInfo;

  TafsirOfAyah({required this.tafsir, required this.bookInfo});
}
