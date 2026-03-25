part of 'mushaf_screen.dart';

extension _MushafShareExtension on _MushafViewState {
  String _formatAyahTextForSharing({
    required String ayahKey,
    required String ayahText,
  }) {
    final parts = ayahKey.split(":");
    final verse = parts.length == 2 ? parts[1].trim() : "";
    final verseInBrackets = verse.isEmpty ? "" : "﴿${_toArabicDigits(verse)}﴾";

    var t = ayahText.trimRight();
    t = t.replaceAll(RegExp(r"[\s\u06DD۝]+$"), "");
    t = t.replaceAll(RegExp(r"[\s0-9٠-٩۰-۹]+$"), "");
    t = t.trimRight();

    return "$t $verseInBrackets".trim();
  }

  String _formatAyahTextForImage({required String ayahText}) {
    var t = ayahText.trimRight();
    t = t.replaceAll(RegExp(r"[\s\u06DD۝]+$"), "");
    t = t.replaceAll(RegExp(r"[\s0-9٠-٩۰-۹]+$"), "");
    t = t.trimRight();
    return t;
  }

  String _removeTashkeel(String text) {
    return text
        .replaceAll(RegExp(r"[\u064B-\u0652\u0670\u06D6-\u06ED]"), "")
        .replaceAll("\u0640", "");
  }

  String _formatAyahTextWithBrackets({
    required int verseNumber,
    required String ayahText,
  }) {
    final cleaned = _formatAyahTextForImage(ayahText: ayahText);
    return "$cleaned ﴿${_toArabicDigits(verseNumber.toString())}﴾".trim();
  }

  Future<void> _showShareDialog({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
  }) async {
    final l10n = AppLocalizations.of(context);
    final themeState = context.read<ThemeCubit>().state;
    final total = getVerseCount(surahNumber);

    int from = verseNumber;
    int to = verseNumber;
    int shareType = 0; // 0 image, 1 text, 2 plain

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            const bg = Color(0xFFF7F1E6);
            const card = Color(0xFFFFF9F2);
            final green = themeState.primary;

            Widget section({required Widget child}) {
              return Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: child,
              );
            }

            Future<void> doShare() async {
              final overlayContext =
                  navigatorKey.currentState?.overlay?.context;
              final shareContext = overlayContext ?? sheetContext;

              if (shareType == 0) {
                if (from != to) {
                  setSheetState(() {
                    shareType = 1;
                  });
                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "مشاركة الصورة متاحة لآية واحدة فقط — تم التحويل لمشاركة نص.",
                        textDirection: TextDirection.rtl,
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                final ayahText = _getAyahText(shareContext, surahNumber, from);
                await _shareAsImage(
                  shareContext,
                  "$surahNumber:$from",
                  ayahText,
                );
                return;
              }

              final buffer = StringBuffer();
              buffer.writeln("${getSurahNameArabic(surahNumber)}");
              buffer.writeln();

              for (int v = from; v <= to; v++) {
                final t = _getAyahText(shareContext, surahNumber, v);
                final line = _formatAyahTextWithBrackets(
                  verseNumber: v,
                  ayahText: t,
                );
                buffer.writeln(line);
                buffer.writeln();
              }

              var finalText = buffer.toString().trim();
              if (shareType == 2) {
                finalText = _removeTashkeel(finalText);
              }

              await SharePlus.instance.share(ShareParams(text: finalText));
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "مشاركة",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1B1B1B),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  section(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "من",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1B1B1B),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                DropdownButtonFormField<int>(
                                                  value: from,
                                                  decoration:
                                                      const InputDecoration(
                                                        isDense: true,
                                                        filled: true,
                                                        fillColor: Color(
                                                          0xFFF7F1E6,
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  12,
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                  items: List.generate(
                                                    total,
                                                    (i) => DropdownMenuItem(
                                                      value: i + 1,
                                                      child: Text(
                                                        "${getSurahNameArabic(surahNumber)}: ${_toArabicDigits((i + 1).toString())}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (v) {
                                                    if (v == null) return;
                                                    setSheetState(() {
                                                      from = v;
                                                      if (to < from) to = from;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "إلى",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1B1B1B),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                DropdownButtonFormField<int>(
                                                  value: to,
                                                  decoration:
                                                      const InputDecoration(
                                                        isDense: true,
                                                        filled: true,
                                                        fillColor: Color(
                                                          0xFFF7F1E6,
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  12,
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                  items: List.generate(
                                                    total,
                                                    (i) => DropdownMenuItem(
                                                      value: i + 1,
                                                      child: Text(
                                                        "${getSurahNameArabic(surahNumber)}: ${_toArabicDigits((i + 1).toString())}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  onChanged: (v) {
                                                    if (v == null) return;
                                                    setSheetState(() {
                                                      to = v;
                                                      if (to < from) from = to;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                  section(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          RadioListTile<int>(
                                            value: 0,
                                            groupValue: shareType,
                                            activeColor: green,
                                            title: const Text("مشاركة صورة"),
                                            onChanged: from == to
                                                ? (v) => setSheetState(
                                                    () => shareType = v ?? 0,
                                                  )
                                                : null,
                                          ),
                                          RadioListTile<int>(
                                            value: 1,
                                            groupValue: shareType,
                                            activeColor: green,
                                            title: const Text("مشاركة نص"),
                                            onChanged: (v) => setSheetState(
                                              () => shareType = v ?? 1,
                                            ),
                                          ),
                                          RadioListTile<int>(
                                            value: 2,
                                            groupValue: shareType,
                                            activeColor: green,
                                            title: const Text("نص بدون تشكيل"),
                                            onChanged: (v) => setSheetState(
                                              () => shareType = v ?? 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: card,
                                foregroundColor: const Color(0xFF1B1B1B),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.black.withValues(alpha: 0.10),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                await doShare();
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              },
                              child: Text(
                                l10n.shareButton,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _toArabicDigits(String number) {
    const arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buffer = StringBuffer();
    for (final ch in number.split('')) {
      final digit = int.tryParse(ch);
      if (digit == null) {
        buffer.write(ch);
      } else {
        buffer.write(arabics[digit]);
      }
    }
    return buffer.toString();
  }

  String _stripTrailingVerseNumber(String text) {
    var t = text.trimRight();
    t = t.replaceAll(RegExp(r"[\s\u06DD۝]+$"), "");
    t = t.replaceAll(RegExp(r"[\s0-9٠-٩۰-۹]+$"), "");
    return t.trimRight();
  }

  String? _sanitizeTafsirText(String? raw) {
    if (raw == null) return null;
    var t = raw.trim();
    if (t.isEmpty) return null;

    if (t.startsWith("Instance of ")) return null;

    // Some sources may return JSON/Map string; try to extract a `text` field.
    if ((t.startsWith("{") && t.endsWith("}")) ||
        (t.startsWith("[") && t.endsWith("]"))) {
      try {
        final decoded = jsonDecode(t);
        if (decoded is Map && decoded["text"] is String) {
          t = (decoded["text"] as String).trim();
        }
      } catch (_) {}
    }

    // Extract `text:` if it looks like a dart map toString.
    if (t.contains("text:") && t.contains("{")) {
      final m = RegExp(r"text:\s*([^,}]+)").firstMatch(t);
      if (m != null) {
        t = m.group(1)?.trim() ?? t;
      }
    }

    // Strip html tags if present.
    t = t.replaceAll(RegExp(r"<[^>]+>"), " ");
    t = t.replaceAll("\\n", "\n");
    t = t.replaceAll(RegExp(r"\n{3,}"), "\n\n");
    t = t.replaceAll(RegExp(r"\s{2,}"), " ");
    t = t.trim();
    return t.isEmpty ? null : t;
  }

  bool _allowTafsirImageShare(String tafsirTitle) {
    final t = tafsirTitle.trim();
    return t.contains("الميسر") || t.contains("المختصر");
  }

  TafsirBookModel? _findTafsirBookByNameContains(String needle) {
    final n = needle.trim();
    if (n.isEmpty) return null;
    for (final langKey in tafsirInformationWithScore.keys) {
      final rawList = tafsirInformationWithScore[langKey];
      if (rawList == null) continue;
      for (final raw in rawList) {
        try {
          final m = Map<String, dynamic>.from(raw);
          final b = TafsirBookModel.fromMap(m);
          if (b.name.contains(n)) return b;
        } catch (_) {}
      }
    }
    return null;
  }

  bool _isDownloadedByFullPath(
    String fullPath,
    List<TafsirBookModel> downloaded,
  ) {
    return downloaded.any((b) => b.fullPath == fullPath);
  }

  Future<void> _downloadAndSelectTafsir(
    BuildContext context,
    TafsirBookModel book,
  ) async {
    await QuranTafsirFunction.downloadResources(
      context: context,
      isSetupProcess: false,
      tafsirBook: book,
    );
    if (await QuranTafsirFunction.isAlreadyDownloaded(book)) {
      await QuranTafsirFunction.setTafsirSelection(book);
    }
  }

  Future<void> _shareLibraryAsText({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
    required String ayahText,
    required Future<List<MapEntry<String, String?>>> Function() loadTafsirs,
  }) async {
    final tafsirs = await loadTafsirs();
    final buffer = StringBuffer();

    final surahName = "سورة ${getSurahNameArabic(surahNumber)}";
    final verseMark = "﴿$verseNumber﴾";

    buffer.writeln(surahName);
    buffer.writeln();
    buffer.writeln("${_stripTrailingVerseNumber(ayahText)} ﴿$verseNumber﴾");

    final cleaned = tafsirs
        .map((e) => MapEntry(e.key, _sanitizeTafsirText(e.value)))
        .where((e) => e.value != null && e.value!.trim().isNotEmpty)
        .toList();

    if (cleaned.isNotEmpty) {
      for (final e in cleaned) {
        buffer.writeln();
        buffer.writeln("──────────────");
        buffer.writeln(e.key.trim());
        buffer.writeln();
        buffer.writeln(e.value!.trim());
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).copiedWithTafsir),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _openTafsirStyleShareOptions({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
    required String ayahText,
  }) async {
    final themeState = context.read<ThemeCubit>().state;
    final downloadedBooks = QuranTafsirFunction.getDownloadedTafsirBooks();
    final selectedBooksFuture = QuranTafsirFunction.getTafsirSelections();
    final String ayahKey = "$surahNumber:$verseNumber";

    Future<List<MapEntry<String, String?>>> loadAllSelectedTafsirs() async {
      final selectedBooks = await selectedBooksFuture;
      final books = (selectedBooks ?? []).toList();
      if (books.isEmpty) return [];
      final List<MapEntry<String, String?>> out = [];
      for (final b in books) {
        final t = await QuranTafsirFunction.getResolvedTafsirTextForBook(
          b,
          ayahKey,
        );
        out.add(MapEntry(b.name, t));
      }
      return out;
    }

    Future<String?> loadTafsir() async {
      final selectedBooks = await selectedBooksFuture;
      final selectedList = (selectedBooks ?? []).toList();
      TafsirBookModel? selectedBook;
      for (final b in selectedList) {
        if (b.name.contains("الميسر")) {
          selectedBook = b;
          break;
        }
      }
      selectedBook ??= (selectedList.isNotEmpty ? selectedList.first : null);
      if (selectedBook == null) return null;
      return QuranTafsirFunction.getResolvedTafsirTextForBook(
        selectedBook,
        ayahKey,
      );
    }

    final selectedBooks = await selectedBooksFuture;
    final selected = (selectedBooks ?? []).toList();
    final String tafsirTitle = selected.isNotEmpty
        ? selected.first.name
        : "التفسير";

    TafsirBookModel? muyassar = _findTafsirBookByNameContains("الميسر");
    final TafsirBookModel? mukhtasar = _findTafsirBookByNameContains("المختصر");

    // Ensure we treat the offline bundled Muyassar as the authoritative one.
    if (muyassar != null && muyassar.name.contains("الميسر")) {
      muyassar = DefaultOfflineResources.defaultTafsirMuyassar;
    }

    bool muyassarDownloaded =
        muyassar != null &&
        _isDownloadedByFullPath(muyassar.fullPath, downloadedBooks);
    final bool mukhtasarDownloaded =
        mukhtasar != null &&
        _isDownloadedByFullPath(mukhtasar.fullPath, downloadedBooks);

    // Extra safety: bundled offline Muyassar might not exist in downloadedBooks list.
    if (muyassar != null &&
        muyassar.fullPath ==
            DefaultOfflineResources.defaultTafsirMuyassar.fullPath) {
      final boxName = QuranTafsirFunction.getTafsirBoxName(
        tafsirBook: muyassar,
      );
      final exists = await Hive.boxExists(boxName);
      muyassarDownloaded = muyassarDownloaded || exists;
    }

    final bool selectedMuyassar = selected.any(
      (b) => b.name.contains("الميسر"),
    );
    final bool selectedMukhtasar = selected.any(
      (b) => b.name.contains("المختصر"),
    );
    final bool showPickBetweenImageBooks =
        selectedMuyassar && selectedMukhtasar;

    final bool isAyahDayn = ayahKey == "2:282";
    final bool isVeryLongAyah =
        isAyahDayn || ayahText.replaceAll(RegExp(r"\s+"), "").length > 280;
    final bool allowImageShareWithTafsir =
        !isVeryLongAyah &&
        (selectedMuyassar || selectedMukhtasar) &&
        (muyassarDownloaded || mukhtasarDownloaded);

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFFFF9F2),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.copy_rounded, color: themeState.primary),
                  title: const Text("كنص"),
                  subtitle: const Text(
                    "ينسخ الآية + كل التفاسير المختارة بشكل مرتب",
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _shareLibraryAsText(
                      context: context,
                      surahNumber: surahNumber,
                      verseNumber: verseNumber,
                      ayahText: ayahText,
                      loadTafsirs: loadAllSelectedTafsirs,
                    );
                  },
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.black.withValues(alpha: 0.06),
                ),
                ListTile(
                  leading: Icon(
                    Icons.image_outlined,
                    color: themeState.primary,
                  ),
                  title: const Text("كصورة (بدون تفسير)"),
                  subtitle: const Text(
                    "مشاركة الآية فقط كصورة — مناسب للآيات الطويلة",
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _shareAsImage(context, ayahKey, ayahText);
                  },
                ),
                if (allowImageShareWithTafsir && showPickBetweenImageBooks) ...[
                  ListTile(
                    leading: Icon(
                      Icons.image_outlined,
                      color: themeState.primary,
                    ),
                    title: const Text("كصورة - التفسير الميسر"),
                    subtitle: const Text("مشاركة صورة بالتفسير الميسر"),
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (selected.isEmpty) {
                        await _shareAsImage(context, ayahKey, ayahText);
                        return;
                      }
                      final b = selected.firstWhere(
                        (x) => x.name.contains("الميسر"),
                        orElse: () => selected.first,
                      );
                      await _shareLibraryAsImage(
                        context: context,
                        surahNumber: surahNumber,
                        verseNumber: verseNumber,
                        ayahKey: ayahKey,
                        tafsirTitle: "التفسير الميسر",
                        loadTafsir: () =>
                            QuranTafsirFunction.getResolvedTafsirTextForBook(
                              b,
                              ayahKey,
                            ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.image_outlined,
                      color: themeState.primary,
                    ),
                    title: const Text("كصورة - التفسير المختصر"),
                    subtitle: const Text("مشاركة صورة بالتفسير المختصر"),
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (selected.isEmpty) {
                        await _shareAsImage(context, ayahKey, ayahText);
                        return;
                      }
                      final b = selected.firstWhere(
                        (x) => x.name.contains("المختصر"),
                        orElse: () => selected.first,
                      );
                      await _shareLibraryAsImage(
                        context: context,
                        surahNumber: surahNumber,
                        verseNumber: verseNumber,
                        ayahKey: ayahKey,
                        tafsirTitle: "التفسير المختصر",
                        loadTafsir: () =>
                            QuranTafsirFunction.getResolvedTafsirTextForBook(
                              b,
                              ayahKey,
                            ),
                      );
                    },
                  ),
                ] else if (allowImageShareWithTafsir)
                  ListTile(
                    leading: Icon(
                      Icons.image_outlined,
                      color: themeState.primary,
                    ),
                    title: const Text("كصورة"),
                    subtitle: Text(
                      "يصنع صورة بنفس تنسيق المكتبة ($tafsirTitle)",
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _shareLibraryAsImage(
                        context: context,
                        surahNumber: surahNumber,
                        verseNumber: verseNumber,
                        ayahKey: ayahKey,
                        tafsirTitle: tafsirTitle,
                        loadTafsir: loadTafsir,
                      );
                    },
                  ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareLibraryAsImage({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
    required String ayahKey,
    required String tafsirTitle,
    required Future<String?> Function() loadTafsir,
  }) async {
    final MediaQueryData mq = MediaQuery.of(context);
    const double canvasWidth = 1400; // زودت العرض
    const double minCaptureHeight = 980;

    const double paddingH = 40;
    final double headerWidth = canvasWidth - (paddingH * 2);
    final double bannerWidth = headerWidth * 0.82; // صغرنا البانر شوية

    final int pageNumber = getPageNumber(ayahKey) ?? 1;
    final String pageFont = "QCF_P${pageNumber.toString().padLeft(3, '0')}";

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final qcfTheme = isDark
        ? QcfThemeData.dark().copyWith(
            pageBackgroundColor: Colors.black,
            headerBackgroundColor: const Color(0xFF111111),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,
            headerFontSizeLarge: 85, // أصغر للبانر
            headerFontSizeSmall: 85,
            headerTextColor: Colors.white,
            verseTextColor: Colors.white,
            verseNumberColor: Colors.white,
          )
        : QcfThemeData.sepia().copyWith(
            pageBackgroundColor: const Color(0xFFF7F1E6),
            headerBackgroundColor: const Color(0xFFEFE3D2),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,
            headerFontSizeLarge: 85, // أصغر للبانر
            headerFontSizeSmall: 85,
            headerTextColor: const Color(0xFF1B1B1B),
            verseTextColor: const Color(0xFF1B1B1B),
            verseNumberColor: const Color(0xFF1B1B1B),
          );

    final Color cardBgColor = isDark ? Colors.black : const Color(0xFFF7F1E6);
    final Color tafsirBgColor = isDark ? const Color(0xFF111111) : const Color(0xFFEFE3D2);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    final String? tafsirText = _sanitizeTafsirText(await loadTafsir());

    final double titleFontSize = (44 - (tafsirTitle.length * 0.35)).clamp(
      36,
      44,
    );
    final TextStyle titleStyle = TextStyle(
      fontSize: titleFontSize,
      fontWeight: FontWeight.w800,
      color: textColor.withValues(alpha: 0.55),
    );

    final tafsirStyle = TextStyle(
      fontSize: 48,
      height: 2.2,
      fontWeight: FontWeight.w600,
      color: textColor,
    );

    final String tafsirBody = (tafsirText == null || tafsirText.trim().isEmpty)
        ? "لا يوجد تفسير لهذه الآية في المصدر المحدد."
        : tafsirText.trim();

    final TextPainter tafsirPainter =
        TextPainter(
            text: TextSpan(text: "", style: tafsirStyle),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          )
          ..text = TextSpan(text: tafsirBody, style: tafsirStyle)
          ..layout(maxWidth: headerWidth - 36);

    final TextPainter titlePainter = TextPainter(
      text: TextSpan(text: tafsirTitle, style: titleStyle),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      maxLines: 2,
    )..layout(maxWidth: headerWidth);

    // ارتفاع الصورة = المحتوى + هامش بسيط فقط (يتغير حسب طول التفسير)
    final double estimatedHeight =
        30 +
        180 + // بانر كبير + تباعد
        540 + // كتلة الآية
        14 +
        titlePainter.height +
        14 + // فاصل
        (tafsirPainter.height + 20) + // صندوق التفسير
        30 + // مسافة سفلية
        120; // هامش إضافي

    // تصميم مثل الصورة المرجعية: بانر → آية → فاصل رفيع → عنوان التفسير (نص فقط على البيج) → صندوق التفسير
    final GlobalKey cardKey = GlobalKey();

    final Widget card = Material(
      color: Colors.transparent,
      child: RepaintBoundary(
        key: cardKey,
        child: Container(
          width: canvasWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: 22,
          ),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                // البانر الكبير من qcf_quran
                Center(
                  child: SizedBox(
                    width: bannerWidth,
                    child: Transform.scale(
                      scale: 1.22, // صغرنا شوية بسيطة
                      child: HeaderWidget(
                        suraNumber: surahNumber,
                        theme: qcfTheme,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // الآية الكريمة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: getVerseQCF(
                            surahNumber,
                            verseNumber,
                            verseEndSymbol: false,
                          ),
                        ),
                        const TextSpan(text: "\u200A"),
                        TextSpan(
                          text: getVerseNumberQCF(surahNumber, verseNumber),
                          style: TextStyle(
                            fontFamily: pageFont,
                            package: "qcf_quran",
                            color: qcfTheme.verseNumberColor,
                            height: qcfTheme.verseNumberHeight,
                          ),
                        ),
                      ],
                    ),
                    locale: const Locale("ar"),
                    textScaler: const TextScaler.linear(1),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: pageFont,
                      package: "qcf_quran",
                      fontSize: 75,
                      height: 2.1,
                      color: qcfTheme.verseTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // فاصل رفيع بين الآية ومنطقة التفسير
                Container(
                  width: double.infinity,
                  height: 1.2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: textColor.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 14),
                // اسم كتاب التفسير كنص فقط على خلفية البيج (بدون بار ملون)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(tafsirTitle, style: titleStyle),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: tafsirBgColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      tafsirBody,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: tafsirStyle,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );

    // render the card to an image using RepaintBoundary
    // نعرض الكارد بشكل مؤقت عشان يتصور (في مكان بعيد عشان ميبانش)
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: -10000, // مكان بعيد جداً عشان ميبانش
        left: -10000,
        child: card,
      ),
    );
    overlay.insert(overlayEntry);

    await Future.delayed(const Duration(milliseconds: 300));

    final boundary =
        cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    overlayEntry.remove();

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: "image/png")],
        fileNameOverrides: ["$ayahKey-tafsir.png"],
        downloadFallbackEnabled: false,
        mailToFallbackEnabled: false,
      ),
    );
  }

  Future<void> _shareAsText(
    BuildContext context,
    String ayahKey,
    String ayahText,
  ) async {
    final parts = ayahKey.split(":");
    final surahNum = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final verseNum = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (surahNum == null || verseNum == null) {
      final formatted = _formatAyahTextForSharing(
        ayahKey: ayahKey,
        ayahText: ayahText,
      );
      await SharePlus.instance.share(
        ShareParams(text: "$ayahKey\n\n$formatted"),
      );
      return;
    }
    final formatted = _formatAyahTextForSharing(
      ayahKey: ayahKey,
      ayahText: ayahText,
    );
    await SharePlus.instance.share(
      ShareParams(
        text: "${getSurahNameArabic(surahNum)} - $ayahKey\n\n$formatted",
      ),
    );
  }

  Future<void> _shareAsImage(
    BuildContext context,
    String ayahKey,
    String ayahText,
  ) async {
    final parts = ayahKey.split(":");
    final surahNumber = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final verseNumber = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (surahNumber == null || verseNumber == null) {
      await SharePlus.instance.share(
        ShareParams(
          text:
              "$ayahKey\n\n${_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: ayahText)}",
        ),
      );
      return;
    }

    final int pageNumber = getPageNumber(ayahKey) ?? 1;
    final String pageFont = "QCF_P${pageNumber.toString().padLeft(3, '0')}";
    final MediaQueryData mq = MediaQuery.of(context);
    const double canvasWidth = 1400; // زودت العرض
    const double canvasHeight = 1400; // ارتفاع كافي

    const double paddingH = 40;
    final double headerWidth = canvasWidth - (paddingH * 2);
    final double bannerWidth = headerWidth * 0.82; // صغرنا البانر شوية

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final qcfTheme = isDark
        ? QcfThemeData.dark().copyWith(
            pageBackgroundColor: Colors.black,
            headerBackgroundColor: const Color(0xFF111111),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,
            headerFontSizeLarge: 85, // أصغر للبانر
            headerFontSizeSmall: 85,
            headerTextColor: Colors.white,
            verseTextColor: Colors.white,
            verseNumberColor: Colors.white,
          )
        : QcfThemeData.sepia().copyWith(
            pageBackgroundColor: const Color(0xFFF7F1E6),
            headerBackgroundColor: const Color(0xFFEFE3D2),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,
            headerFontSizeLarge: 85, // أصغر للبانر
            headerFontSizeSmall: 85,
            headerTextColor: const Color(0xFF1B1B1B),
            verseTextColor: const Color(0xFF1B1B1B),
            verseNumberColor: const Color(0xFF1B1B1B),
          );

    final Color cardBgColor = isDark ? Colors.black : const Color(0xFFF7F1E6);

    // حساب ارتفاع الآية
    final TextPainter ayahPainter = TextPainter(
      text: TextSpan(
        text: getVerseQCF(surahNumber, verseNumber, verseEndSymbol: false),
        style: TextStyle(
          fontFamily: pageFont,
          package: "qcf_quran",
          fontSize: 75, // كبرنا حجم الآية
          height: 2.1, // طول سطر أطول
          color: qcfTheme.verseTextColor,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    )..layout(maxWidth: headerWidth);

    // حساب الارتفاع حسب المحتوى (بانر + آية + مسافة)
    // الارتفاع هيتزاد لو الآية طويلة
    final double estimatedHeight = 26 + 160 + ayahPainter.height + 12 + 150;

    final GlobalKey cardKey = GlobalKey();

    final Widget card = Material(
      color: Colors.transparent,
      child: RepaintBoundary(
        key: cardKey,
        child: Container(
          width: canvasWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: 22,
          ),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                const SizedBox(height: 26),
                // البانر الكبير من qcf_quran
                Center(
                  child: SizedBox(
                    width: bannerWidth,
                    child: Transform.scale(
                      scale: 1.22, // صغرنا شوية بسيطة
                      child: HeaderWidget(
                        suraNumber: surahNumber,
                        theme: qcfTheme,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // الآية الكريمة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: getVerseQCF(
                            surahNumber,
                            verseNumber,
                            verseEndSymbol: false,
                          ),
                        ),
                        const TextSpan(text: "\u200A"),
                        TextSpan(
                          text: getVerseNumberQCF(surahNumber, verseNumber),
                          style: TextStyle(
                            fontFamily: pageFont,
                            package: "qcf_quran",
                            color: qcfTheme.verseNumberColor,
                            height: qcfTheme.verseNumberHeight,
                          ),
                        ),
                      ],
                    ),
                    locale: const Locale("ar"),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: pageFont,
                      package: "qcf_quran",
                      fontSize: 75,
                      height: 2.1,
                      color: qcfTheme.verseTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );

    // render the card to an image using RepaintBoundary
    // نعرض الكارد بشكل مؤقت عشان يتصور (في مكان بعيد عشان ميبانش)
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      await SharePlus.instance.share(
        ShareParams(
          text:
              "$ayahKey\n\n${_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: ayahText)}",
        ),
      );
      return;
    }
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: -10000, // مكان بعيد جداً عشان ميبانش
        left: -10000,
        child: card,
      ),
    );
    overlay.insert(overlayEntry);

    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 120));

    final ctx = cardKey.currentContext;
    if (ctx == null) {
      overlayEntry.remove();
      await SharePlus.instance.share(
        ShareParams(
          text:
              "$ayahKey\n\n${_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: ayahText)}",
        ),
      );
      return;
    }

    final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      overlayEntry.remove();
      await SharePlus.instance.share(
        ShareParams(
          text:
              "$ayahKey\n\n${_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: ayahText)}",
        ),
      );
      return;
    }
    final bytes = byteData.buffer.asUint8List();

    overlayEntry.remove();

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$ayahKey.png");
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        fileNameOverrides: ["$ayahKey.png"],
        downloadFallbackEnabled: false,
        mailToFallbackEnabled: false,
      ),
    );
  }

  Future<void> _showLibrarySheet({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
  }) async {
    final themeState = context.read<ThemeCubit>().state;
    final total = getVerseCount(surahNumber);

    int currentVerse = verseNumber;
    final Map<String, Future<String?>> tafsirFutureByPath =
        <String, Future<String?>>{};

    List<TafsirBookModel>? cachedSelectedBooks;

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
            final bg = isDark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF7F1E6);
            final card = isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFFFF9F2);

            final downloadedBooks =
                QuranTafsirFunction.getDownloadedTafsirBooks();
            final selectedBooksFuture =
                QuranTafsirFunction.getTafsirSelections();

            final String ayahKey = "$surahNumber:$currentVerse";
            final String ayahTextRaw = _getAyahText(
              sheetContext,
              surahNumber,
              currentVerse,
            );
            final int ayahPageNumber = getPageNumber(ayahKey) ?? 1;
            final String ayahPageFont =
                "QCF_P${ayahPageNumber.toString().padLeft(3, '0')}";
            final String qcfAyah = getVerseQCF(
              surahNumber,
              currentVerse,
              verseEndSymbol: false,
            );

            Future<String?> loadTafsir() async {
              final selectedBooks = await selectedBooksFuture;
              final selectedList = (selectedBooks ?? []).toList();
              TafsirBookModel? selectedBook;
              for (final b in selectedList) {
                if (b.name.contains("الميسر")) {
                  selectedBook = b;
                  break;
                }
              }
              selectedBook ??= (selectedList.isNotEmpty
                  ? selectedList.first
                  : null);
              if (selectedBook == null) return null;
              return QuranTafsirFunction.getResolvedTafsirTextForBook(
                selectedBook,
                ayahKey,
              );
            }

            String? extractSectionHtml(String? html, String title) {
              if (html == null || html.trim().isEmpty) return null;
              final pattern = RegExp(
                r"<h3>\s*${RegExp.escape(title)}\s*<\/h3>([\s\S]*?)(?=<h3>|$)",
                caseSensitive: false,
              );
              final match = pattern.firstMatch(html);
              final content = match?.group(1);
              return content?.trim();
            }

            Future<List<MapEntry<String, String?>>>
            loadAllSelectedTafsirs() async {
              final selectedBooks = await selectedBooksFuture;
              final books = (selectedBooks ?? []).toList();
              if (books.isEmpty) return [];
              final List<MapEntry<String, String?>> out = [];
              for (final b in books) {
                final t =
                    await QuranTafsirFunction.getResolvedTafsirTextForBook(
                      b,
                      ayahKey,
                    );
                out.add(MapEntry(b.name, t));
              }
              return out;
            }

            Future<void> openShareOptions() async {
              final selectedBooks = await selectedBooksFuture;
              final selected = (selectedBooks ?? []).toList();
              final String tafsirTitle = selected.isNotEmpty
                  ? selected.first.name
                  : "التفسير";

              TafsirBookModel? muyassar = _findTafsirBookByNameContains(
                "الميسر",
              );
              final TafsirBookModel? mukhtasar = _findTafsirBookByNameContains(
                "المختصر",
              );

              // Ensure we treat the offline bundled Muyassar as the authoritative one.
              if (muyassar != null && muyassar.name.contains("الميسر")) {
                muyassar = DefaultOfflineResources.defaultTafsirMuyassar;
              }

              bool muyassarDownloaded =
                  muyassar != null &&
                  _isDownloadedByFullPath(muyassar.fullPath, downloadedBooks);
              final bool mukhtasarDownloaded =
                  mukhtasar != null &&
                  _isDownloadedByFullPath(mukhtasar.fullPath, downloadedBooks);

              // Extra safety: bundled offline Muyassar might not exist in downloadedBooks list.
              if (muyassar != null &&
                  muyassar.fullPath ==
                      DefaultOfflineResources.defaultTafsirMuyassar.fullPath) {
                final boxName = QuranTafsirFunction.getTafsirBoxName(
                  tafsirBook: muyassar,
                );
                final exists = await Hive.boxExists(boxName);
                muyassarDownloaded = muyassarDownloaded || exists;
              }

              final bool showDownloadMuyassar =
                  muyassar != null &&
                  !muyassarDownloaded &&
                  muyassar.fullPath !=
                      DefaultOfflineResources.defaultTafsirMuyassar.fullPath;
              // Intentionally no "download mukhtasar" from share sheet (download happens from Resources only).
              const bool showDownloadMukhtasar = false;

              final bool selectedMuyassar = selected.any(
                (b) => b.name.contains("الميسر"),
              );
              final bool selectedMukhtasar = selected.any(
                (b) => b.name.contains("المختصر"),
              );
              final bool showPickBetweenImageBooks =
                  selectedMuyassar && selectedMukhtasar;

              final bool isAyahDayn = ayahKey == "2:282";
              final bool isVeryLongAyah =
                  isAyahDayn ||
                  ayahTextRaw.replaceAll(RegExp(r"\s+"), "").length > 280;
              final bool allowImageShareWithTafsir =
                  !isVeryLongAyah &&
                  (selectedMuyassar || selectedMukhtasar) &&
                  (muyassarDownloaded || mukhtasarDownloaded);

              await showModalBottomSheet(
                context: sheetContext,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).brightness == Brightness.dark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFFFF9F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.copy_rounded,
                              color: themeState.primary,
                            ),
                            title: const Text("كنص"),
                            subtitle: const Text(
                              "ينسخ الآية + كل التفاسير المختارة بشكل مرتب",
                            ),
                            onTap: () async {
                              Navigator.pop(ctx);
                              await _shareLibraryAsText(
                                context: sheetContext,
                                surahNumber: surahNumber,
                                verseNumber: currentVerse,
                                ayahText: ayahTextRaw,
                                loadTafsirs: loadAllSelectedTafsirs,
                              );
                            },
                          ),
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.black.withValues(alpha: 0.06),
                          ),

                          if (showDownloadMuyassar || showDownloadMukhtasar)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: Column(
                                children: [
                                  if (showDownloadMuyassar)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          final TafsirBookModel? book =
                                              muyassar;
                                          if (book == null) return;
                                          await _downloadAndSelectTafsir(
                                            sheetContext,
                                            book,
                                          );
                                          if (ctx.mounted) Navigator.pop(ctx);
                                          setSheetState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.download_rounded,
                                        ),
                                        label: const Text(
                                          "تحميل التفسير الميسر",
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          ListTile(
                            leading: Icon(
                              Icons.image_outlined,
                              color: themeState.primary,
                            ),
                            title: const Text("كصورة (بدون تفسير)"),
                            subtitle: const Text(
                              "مشاركة الآية فقط كصورة — مناسب للآيات الطويلة",
                            ),
                            onTap: () async {
                              Navigator.pop(ctx);
                              await _shareAsImage(
                                sheetContext,
                                ayahKey,
                                ayahTextRaw,
                              );
                            },
                          ),

                          if (allowImageShareWithTafsir &&
                              showPickBetweenImageBooks) ...[
                            ListTile(
                              leading: Icon(
                                Icons.image_outlined,
                                color: themeState.primary,
                              ),
                              title: const Text("كصورة - التفسير الميسر"),
                              subtitle: const Text(
                                "مشاركة صورة بالتفسير الميسر",
                              ),
                              onTap: () async {
                                Navigator.pop(ctx);
                                final b = selected.firstWhere(
                                  (x) => x.name.contains("الميسر"),
                                  orElse: () => selected.first,
                                );
                                await _shareLibraryAsImage(
                                  context: sheetContext,
                                  surahNumber: surahNumber,
                                  verseNumber: currentVerse,
                                  ayahKey: ayahKey,
                                  tafsirTitle: "التفسير الميسر",
                                  loadTafsir: () =>
                                      QuranTafsirFunction.getResolvedTafsirTextForBook(
                                        b,
                                        ayahKey,
                                      ),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.image_outlined,
                                color: themeState.primary,
                              ),
                              title: const Text("كصورة - التفسير المختصر"),
                              subtitle: const Text(
                                "مشاركة صورة بالتفسير المختصر",
                              ),
                              onTap: () async {
                                Navigator.pop(ctx);
                                final b = selected.firstWhere(
                                  (x) => x.name.contains("المختصر"),
                                  orElse: () => selected.first,
                                );
                                await _shareLibraryAsImage(
                                  context: sheetContext,
                                  surahNumber: surahNumber,
                                  verseNumber: currentVerse,
                                  ayahKey: ayahKey,
                                  tafsirTitle: "التفسير المختصر",
                                  loadTafsir: () =>
                                      QuranTafsirFunction.getResolvedTafsirTextForBook(
                                        b,
                                        ayahKey,
                                      ),
                                );
                              },
                            ),
                          ] else if (allowImageShareWithTafsir)
                            ListTile(
                              leading: Icon(
                                Icons.image_outlined,
                                color: themeState.primary,
                              ),
                              title: const Text("كصورة"),
                              subtitle: Text(
                                "يصنع صورة بنفس تنسيق المكتبة ($tafsirTitle)",
                              ),
                              onTap: () async {
                                Navigator.pop(ctx);
                                await _shareLibraryAsImage(
                                  context: sheetContext,
                                  surahNumber: surahNumber,
                                  verseNumber: currentVerse,
                                  ayahKey: ayahKey,
                                  tafsirTitle: tafsirTitle,
                                  loadTafsir: loadTafsir,
                                );
                              },
                            ),

                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                height: MediaQuery.of(sheetContext).size.height * 0.92,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                await Navigator.of(
                                  sheetContext,
                                  rootNavigator: true,
                                ).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const QuranResourcesView(initTab: 1),
                                  ),
                                );
                                setSheetState(() {});
                              },
                              child: Text(
                                "تحرير",
                                style: TextStyle(
                                  color: themeState.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "المكتبة",
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                color:
                                    Theme.of(sheetContext).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : const Color(0xFF1B1B1B),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              icon: const Icon(Icons.close_rounded),
                              color: themeState.primary,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        color:
                            Theme.of(sheetContext).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16), // قللنا الحواف لزيادة المساحة للآيات
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12), // قللنا الحواف لزيادة المساحة للآيات
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(sheetContext).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF1E1E1E)
                                      : const Color(0xFFF1E9DD),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: qcfAyah),
                                          const TextSpan(text: "\u200A"),
                                          TextSpan(
                                            text: getVerseNumberQCF(
                                              surahNumber,
                                              currentVerse,
                                            ),
                                            style: TextStyle(
                                              fontFamily: ayahPageFont,
                                              package: "qcf_quran",
                                              height: 1,
                                              color:
                                                  Theme.of(
                                                        sheetContext,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.70,
                                                    )
                                                  : const Color(
                                                      0xFF1B1B1B,
                                                    ).withValues(alpha: 0.70),
                                            ),
                                          ),
                                        ],
                                      ),
                                      locale: const Locale("ar"),
                                      textScaler: const TextScaler.linear(1),
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      strutStyle: StrutStyle(
                                        fontFamily: ayahPageFont,
                                        package: "qcf_quran",
                                        fontSize: 15, // تصغير للتأكد من عدم الإلتفاف
                                        height: 1.80, // تباعد سطور أفضل
                                        forceStrutHeight: true,
                                      ),
                                      style: TextStyle(
                                        fontFamily: ayahPageFont,
                                        package: "qcf_quran",
                                        fontSize: 15, // تصغير
                                        height: 1.80,
                                        color:
                                            Theme.of(sheetContext).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : const Color(0xFF1B1B1B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: openShareOptions,
                                    icon: const Icon(Icons.share_rounded),
                                    color: themeState.primary,
                                  ),
                                  const Spacer(),
                                  FutureBuilder<List<TafsirBookModel>?>(
                                    future: selectedBooksFuture,
                                    builder: (context, snap) {
                                      final books =
                                          snap.connectionState ==
                                              ConnectionState.done
                                          ? (snap.data ??
                                                const <TafsirBookModel>[])
                                          : (cachedSelectedBooks ??
                                                const <TafsirBookModel>[]);

                                      if (snap.connectionState ==
                                              ConnectionState.done &&
                                          snap.data != null) {
                                        cachedSelectedBooks = snap.data;
                                      }

                                      final String label;
                                      if (books.isEmpty) {
                                        label = "التفسير";
                                      } else if (books.length == 1) {
                                        label = books.first.name;
                                      } else {
                                        label =
                                            "${_toArabicDigits(books.length.toString())} تفاسير";
                                      }

                                      log(
                                        "[Library] header ayahKey=$ayahKey selectedCount=${books.length}",
                                        name: "LibrarySheet",
                                      );

                                      return Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              Theme.of(
                                                    sheetContext,
                                                  ).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withValues(
                                                  alpha: 0.60,
                                                )
                                              : const Color(
                                                  0xFF1B1B1B,
                                                ).withValues(alpha: 0.60),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              FutureBuilder<List<TafsirBookModel>?>(
                                future: selectedBooksFuture,
                                builder: (context, booksSnap) {
                                  final books =
                                      booksSnap.connectionState ==
                                          ConnectionState.done
                                      ? (booksSnap.data ??
                                            const <TafsirBookModel>[])
                                      : (cachedSelectedBooks ??
                                            const <TafsirBookModel>[]);

                                  if (booksSnap.connectionState ==
                                          ConnectionState.done &&
                                      booksSnap.data != null) {
                                    cachedSelectedBooks = booksSnap.data;
                                  }

                                  log(
                                    "[Library] ayahKey=$ayahKey selectedTafsirs=${books.map((e) => e.fullPath).toList()}",
                                    name: "LibrarySheet",
                                  );

                                  if (books.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: card,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 14,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        "مفيش تفسير مختار حالياً. اضغط تحرير واختار التفاسير اللي عايزها.",
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.6,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Theme.of(
                                                    sheetContext,
                                                  ).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : const Color(0xFF1B1B1B),
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children:
                                        books.map<Widget>((book) {
                                          final Future<String?>
                                          ayahTafsirFuture = tafsirFutureByPath
                                              .putIfAbsent(
                                                "${book.fullPath}|$ayahKey",
                                                () =>
                                                    QuranTafsirFunction.getResolvedTafsirTextForBook(
                                                      book,
                                                      ayahKey,
                                                    ),
                                              );

                                          final bool isMuyassarBook = book.name
                                              .contains("الميسر");
                                          final Future<List<String?>>
                                          mergedFuture;
                                          if (isMuyassarBook) {
                                            final Future<String?> introFuture =
                                                tafsirFutureByPath.putIfAbsent(
                                                  "${book.fullPath}|$surahNumber:1",
                                                  () =>
                                                      QuranTafsirFunction.getResolvedTafsirTextForBook(
                                                        book,
                                                        "$surahNumber:1",
                                                      ),
                                                );
                                            mergedFuture = Future.wait([
                                              introFuture,
                                              ayahTafsirFuture,
                                            ]);
                                          } else {
                                            mergedFuture = Future.wait([
                                              Future<String?>.value(null),
                                              ayahTafsirFuture,
                                            ]);
                                          }

                                          return Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: card,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
                                                  blurRadius: 14,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${book.name} (العربية)",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color:
                                                            Theme.of(
                                                                  sheetContext,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                                  .withValues(
                                                                    alpha: 0.70,
                                                                  )
                                                            : const Color(
                                                                0xFF1B1B1B,
                                                              ).withValues(
                                                                alpha: 0.70,
                                                              ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                FutureBuilder<List<String?>>(
                                                  future: mergedFuture,
                                                  builder: (context, mergedSnap) {
                                                    if (mergedSnap
                                                            .connectionState !=
                                                        ConnectionState.done) {
                                                      return const SizedBox.shrink();
                                                    }
                                                    final introRaw =
                                                        mergedSnap.data?.first
                                                            ?.trim() ??
                                                        "";
                                                    final ayahRaw =
                                                        mergedSnap.data?.last
                                                            ?.trim() ??
                                                        "";

                                                    final String shown;
                                                    if (isMuyassarBook) {
                                                      final naming =
                                                          extractSectionHtml(
                                                            introRaw,
                                                            "تسمية السورة",
                                                          ) ??
                                                          "";
                                                      final objectives =
                                                          extractSectionHtml(
                                                            introRaw,
                                                            "من مقاصد السورة",
                                                          ) ??
                                                          "";

                                                      final buffer =
                                                          StringBuffer();
                                                      if (naming
                                                          .trim()
                                                          .isNotEmpty) {
                                                        buffer.writeln(
                                                          "تسمية السورة:\n${_stripHtml(naming)}\n",
                                                        );
                                                      }
                                                      if (objectives
                                                          .trim()
                                                          .isNotEmpty) {
                                                        buffer.writeln(
                                                          "من مقاصد السورة:\n${_stripHtml(objectives)}\n",
                                                        );
                                                      }
                                                      if (ayahRaw
                                                          .trim()
                                                          .isNotEmpty) {
                                                        buffer.writeln(
                                                          _stripHtml(ayahRaw),
                                                        );
                                                      }
                                                      shown = buffer
                                                          .toString()
                                                          .trim();
                                                    } else {
                                                      shown = _stripHtml(
                                                        ayahRaw,
                                                      ).trim();
                                                    }

                                                    if (shown.isEmpty) {
                                                      return const Text(
                                                        "لا يوجد تفسير لهذه الآية.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        textDirection:
                                                            TextDirection.rtl,
                                                      );
                                                    }

                                                    return Text(
                                                      shown,
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        height: 1.7,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Theme.of(
                                                                  sheetContext,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFF1B1B1B,
                                                              ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList()..add(
                                          FutureBuilder<String?>(
                                            future:
                                                QuranIrabFunction.getIrabText(
                                                  ayahKey,
                                                ),
                                            builder: (context, irabSnap) {
                                              if (irabSnap.connectionState !=
                                                      ConnectionState.done ||
                                                  irabSnap.data == null ||
                                                  irabSnap.data!
                                                      .trim()
                                                      .isEmpty) {
                                                return const SizedBox.shrink();
                                              }
                                              return Container(
                                                width: double.infinity,
                                                margin: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: card,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.05,
                                                          ),
                                                      blurRadius: 14,
                                                      offset: const Offset(
                                                        0,
                                                        8,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "إعراب القرآن الكريم",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color:
                                                                Theme.of(
                                                                      sheetContext,
                                                                    ).brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? Colors.white
                                                                      .withValues(
                                                                        alpha:
                                                                            0.70,
                                                                      )
                                                                : const Color(
                                                                    0xFF1B1B1B,
                                                                  ).withValues(
                                                                    alpha: 0.70,
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      _stripHtml(
                                                        irabSnap.data!,
                                                      ),
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        height: 1.7,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Theme.of(
                                                                  sheetContext,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFF1B1B1B,
                                                              ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Colors.black.withValues(alpha: 0.06),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: currentVerse > 1
                                  ? () => setSheetState(() => currentVerse -= 1)
                                  : null,
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: themeState.primary,
                            ),
                            Expanded(
                              child: Text(
                                "${getSurahNameArabic(surahNumber)}: ${_toArabicDigits(currentVerse.toString())}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B1B1B),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: currentVerse < total
                                  ? () => setSheetState(() => currentVerse += 1)
                                  : null,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              color: themeState.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

}
