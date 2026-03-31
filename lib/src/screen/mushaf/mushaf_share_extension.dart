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
        if (b.name.contains("السعدي")) {
          selectedBook = b;
          break;
        }
      }
      for (final b in selectedList) {
        if (selectedBook != null) break;
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

    bool muyassarDownloaded =
        muyassar != null &&
        _isDownloadedByFullPath(muyassar.fullPath, downloadedBooks);
    final bool mukhtasarDownloaded =
        mukhtasar != null &&
        _isDownloadedByFullPath(mukhtasar.fullPath, downloadedBooks);

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
    await AyahImageGenerator.shareLibraryAsImage(
      context: context,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      ayahKey: ayahKey,
      tafsirTitle: tafsirTitle,
      tafsirTextRaw: await loadTafsir(),
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
    await AyahImageGenerator.shareAsImage(
      context: context,
      ayahKey: ayahKey,
      ayahText: ayahText,
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
    int? selectedWordNumber;

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
            final List<String> ayahWords = _splitAyahWordsForChips(qcfAyah);

            return DefaultTabController(
              length: 4,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  height: MediaQuery.of(sheetContext).size.height * 0.92,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        // Header
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
                                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
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
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                        // Condensed Ayah display (vertical scroll)
                        Container(
                          margin: const EdgeInsets.fromLTRB(10, 12, 10, 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF1E9DD),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 70),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: qcfAyah),
                                    const TextSpan(text: "\u200A"),
                                    TextSpan(
                                      text: getVerseNumberQCF(surahNumber, currentVerse),
                                      style: TextStyle(
                                        fontFamily: ayahPageFont,
                                        package: "qcf_quran",
                                        height: 1,
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.70)
                                            : const Color(0xFF1B1B1B)
                                                .withValues(alpha: 0.70),
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
                                  fontSize: 14,
                                  height: 1.70,
                                  forceStrutHeight: true,
                                ),
                                style: TextStyle(
                                  fontFamily: ayahPageFont,
                                  package: "qcf_quran",
                                  fontSize: 14,
                                  height: 1.70,
                                  color:
                                      isDark ? Colors.white : const Color(0xFF1B1B1B),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Word chips selector (shows tabs only after selection)
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: ayahWords.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final wordNumber = i + 1;
                              final isSelected = selectedWordNumber == wordNumber;
                              return InkWell(
                                onTap: () {
                                  setSheetState(() {
                                    selectedWordNumber = isSelected ? null : wordNumber;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? themeState.primary.withValues(alpha: 0.14)
                                        : (isDark
                                            ? const Color(0xFF1E1E1E)
                                            : const Color(0xFFF1E9DD)),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? themeState.primary.withValues(alpha: 0.40)
                                          : Colors.black.withValues(alpha: 0.06),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    ayahWords[i],
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1B1B1B),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        if (selectedWordNumber == null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "اختار كلمة عشان تظهر المكتبة",
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.55)
                                      : const Color(0xFF1B1B1B)
                                          .withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ),

                        if (selectedWordNumber != null) ...[
                        // TabBar (بدون التفسير)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFEFE3D2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TabBar(
                            labelColor: isDark ? Colors.white : const Color(0xFF1B1B1B),
                            unselectedLabelColor: isDark
                                ? Colors.white.withValues(alpha: 0.50)
                                : const Color(0xFF1B1B1B).withValues(alpha: 0.50),
                            labelStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            indicator: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFF7F1E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorPadding: const EdgeInsets.all(4),
                            dividerColor: Colors.transparent,
                            overlayColor: MaterialStatePropertyAll(
                              Colors.black.withValues(alpha: 0.03),
                            ),
                            tabs: const [
                              Tab(text: "ترجمة"),
                              Tab(text: "إعراب"),
                              Tab(text: "صرف"),
                              Tab(text: "قراءات"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Tabs + Tafsir تحتهم (زي الصورة)
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                SizedBox(
                                  height:
                                      (MediaQuery.of(sheetContext).size.height * 0.26)
                                          .clamp(210.0, 320.0),
                                  child: TabBarView(
                                    children: [
                                      // Translation Tab
                                      _TranslationTabContent(
                                        ayahKey: ayahKey,
                                        card: card,
                                        isDark: isDark,
                                      ),
                                      // I'rab Tab
                                      _IrabTabContent(
                                        ref: WordRef(
                                          surahNumber: surahNumber,
                                          ayahNumber: currentVerse,
                                          wordNumber: selectedWordNumber!,
                                        ),
                                        card: card,
                                        isDark: isDark,
                                        themeState: themeState,
                                      ),
                                      // Sarf Tab
                                      _SarfTabContent(
                                        ref: WordRef(
                                          surahNumber: surahNumber,
                                          ayahNumber: currentVerse,
                                          wordNumber: selectedWordNumber!,
                                        ),
                                        card: card,
                                        isDark: isDark,
                                        themeState: themeState,
                                      ),
                                      // Qiraat Tab
                                      _QiraatTabContent(
                                        ref: WordRef(
                                          surahNumber: surahNumber,
                                          ayahNumber: currentVerse,
                                          wordNumber: selectedWordNumber!,
                                        ),
                                        card: card,
                                        isDark: isDark,
                                        themeState: themeState,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "التفسير",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1B1B1B),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () async {
                                          await Share.share(
                                            _formatAyahTextForSharing(
                                              ayahKey: ayahKey,
                                              ayahText: ayahTextRaw,
                                            ),
                                          );
                                        },
                                        icon:
                                            const Icon(Icons.share_outlined),
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.70)
                                            : const Color(0xFF1B1B1B)
                                                .withValues(alpha: 0.70),
                                      ),
                                    ],
                                  ),
                                ),
                                _TafsirTabContent(
                                  ayahKey: ayahKey,
                                  surahNumber: surahNumber,
                                  card: card,
                                  isDark: isDark,
                                  embedded: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ],
                        // Navigation arrows
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
                                    ? () => setSheetState(() {
                                          currentVerse -= 1;
                                          selectedWordNumber = null;
                                        })
                                    : null,
                                icon: const Icon(Icons.arrow_back_rounded),
                                color: themeState.primary,
                              ),
                              Expanded(
                                child: Text(
                                  "${getSurahNameArabic(surahNumber)}: ${_toArabicDigits(currentVerse.toString())}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.2,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: currentVerse < total
                                    ? () => setSheetState(() {
                                          currentVerse += 1;
                                          selectedWordNumber = null;
                                        })
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
              ),
            );
          },
        );
      },
    );
  }

  /// Tafsir Tab Content Widget
  Widget _TafsirTabContent({
    required String ayahKey,
    required int surahNumber,
    required Color card,
    required bool isDark,
    bool embedded = false,
  }) {
    final Map<String, Future<String?>> tafsirFutureByPath = <String, Future<String?>>{};
    List<TafsirBookModel>? cachedSelectedBooks;

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

    return FutureBuilder<List<TafsirBookModel>?>(
      future: QuranTafsirFunction.getTafsirSelections(),
      builder: (context, booksSnap) {
        final rawBooks = booksSnap.connectionState == ConnectionState.done
            ? (booksSnap.data ?? const <TafsirBookModel>[])
            : (cachedSelectedBooks ?? const <TafsirBookModel>[]);

        // Dedupe (fix duplicated Saadi وغيره)
        final seenKeys = <String>{};
        final books = <TafsirBookModel>[];
        for (final b in rawBooks) {
          final key = (b.fullPath.isNotEmpty ? b.fullPath : b.name).trim();
          if (key.isEmpty) continue;
          if (seenKeys.add(key)) {
            books.add(b);
          }
        }

        if (booksSnap.connectionState == ConnectionState.done && booksSnap.data != null) {
          cachedSelectedBooks = booksSnap.data;
        }

        if (books.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                "مفيش تفسير مختار حالياً. اضغط تحرير واختار التفاسير اللي عايزها.",
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
          shrinkWrap: embedded,
          physics: embedded ? const NeverScrollableScrollPhysics() : null,
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final ayahTafsirFuture = tafsirFutureByPath.putIfAbsent(
              "${book.fullPath}|$ayahKey",
              () => QuranTafsirFunction.getResolvedTafsirTextForBook(book, ayahKey),
            );

            final bool isMuyassarBook = book.name.contains("الميسر");
            final Future<List<String?>> mergedFuture;
            if (isMuyassarBook) {
              final introFuture = tafsirFutureByPath.putIfAbsent(
                "${book.fullPath}|$surahNumber:1",
                () => QuranTafsirFunction.getResolvedTafsirTextForBook(book, "$surahNumber:1"),
              );
              mergedFuture = Future.wait([introFuture, ayahTafsirFuture]);
            } else {
              mergedFuture = Future.wait([Future<String?>.value(null), ayahTafsirFuture]);
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "${book.name} (العربية)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.70)
                          : const Color(0xFF1B1B1B).withValues(alpha: 0.70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<String?>>(
                    future: mergedFuture,
                    builder: (context, mergedSnap) {
                      if (mergedSnap.connectionState != ConnectionState.done) {
                        return const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final introRaw = mergedSnap.data?.first?.trim() ?? "";
                      final ayahRaw = mergedSnap.data?.last?.trim() ?? "";

                      final String shown;
                      if (isMuyassarBook) {
                        final naming = extractSectionHtml(introRaw, "تسمية السورة") ?? "";
                        final objectives = extractSectionHtml(introRaw, "من مقاصد السورة") ?? "";
                        final buffer = StringBuffer();
                        if (naming.trim().isNotEmpty) {
                          buffer.writeln("تسمية السورة:\n${_stripHtml(naming)}\n");
                        }
                        if (objectives.trim().isNotEmpty) {
                          buffer.writeln("من مقاصد السورة:\n${_stripHtml(objectives)}\n");
                        }
                        if (ayahRaw.trim().isNotEmpty) {
                          buffer.writeln(_stripHtml(ayahRaw));
                        }
                        shown = buffer.toString().trim();
                      } else {
                        shown = _stripHtml(ayahRaw).trim();
                      }

                      if (shown.isEmpty) {
                        return const Text(
                          "لا يوجد تفسير لهذه الآية.",
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        );
                      }

                      return Text(
                        shown,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.7,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Translation Tab Content Widget
  Widget _TranslationTabContent({
    required String ayahKey,
    required Color card,
    required bool isDark,
  }) {
    return FutureBuilder<List<TranslationOfAyah>>(
      future: QuranTranslationFunction.getTranslation(ayahKey),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final translations = snap.data ?? [];

        if (translations.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                "مفيش ترجمة مختارة. اضغط تحرير واختار الترجمات.",
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
          itemCount: translations.length,
          itemBuilder: (context, index) {
            final item = translations[index];
            final transMap = item.translation;
            final text = transMap != null ? (transMap['t'] ?? '').toString().trim() : '';
            final bookName = item.bookInfo?.name ?? "ترجمة";
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    bookName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.70)
                          : const Color(0xFF1B1B1B).withValues(alpha: 0.70),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (text.isEmpty || text.contains("Not Found"))
                    const Text(
                      "لا توجد ترجمة لهذه الآية.",
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    )
                  else
                    Text(
                      text,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// I'rab Tab Content Widget - Updated
  Widget _IrabTabContent({
    required WordRef ref,
    required Color card,
    required bool isDark,
    required ThemeState themeState,
  }) {
    return FutureBuilder<bool>(
      future: Future.value(_wordInfoRepo.isKindDownloaded(WordInfoKind.eerab)),
      builder: (context, downloadSnap) {
        final isDownloaded = downloadSnap.data ?? false;

        if (!isDownloaded) {
          return _buildDownloadPrompt(
            card: card,
            isDark: isDark,
            themeState: themeState,
            title: "بيانات الإعراب",
            description: "حمّل بيانات الإعراب لعرض التحليل الإعرابي للكلمات",
            icon: Icons.text_fields,
            kind: WordInfoKind.eerab,
          );
        }

        return FutureBuilder<QiraatWordInfo?>(
          future: _wordInfoRepo.getWordInfo(kind: WordInfoKind.eerab, ref: ref),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final word = snap.data;
            if (word == null || word.content.trim().isEmpty) {
              return _buildEmptyState(
                card: card,
                isDark: isDark,
                themeState: themeState,
                message: "لا توجد بيانات إعراب لهذه الآية",
              );
            }

            return _buildWordInfoCard(
              card: card,
              isDark: isDark,
              themeState: themeState,
              word: word,
              title: "الإعراب",
            );
          },
        );
      },
    );
  }

  /// Qiraat Tab Content Widget
  Widget _QiraatTabContent({
    required WordRef ref,
    required Color card,
    required bool isDark,
    required ThemeState themeState,
  }) {
    return FutureBuilder<bool>(
      future: Future.value(_wordInfoRepo.isKindDownloaded(WordInfoKind.recitations)),
      builder: (context, downloadSnap) {
        final isDownloaded = downloadSnap.data ?? false;

        if (!isDownloaded) {
          return _buildDownloadPrompt(
            card: card,
            isDark: isDark,
            themeState: themeState,
            title: "بيانات القراءات",
            description: "حمّل بيانات القراءات (قراءات عشر) لعرض اختلافات الروايات للكلمات",
            icon: Icons.record_voice_over_outlined,
            kind: WordInfoKind.recitations,
          );
        }

        return FutureBuilder<QiraatWordInfo?>(
          future: _wordInfoRepo.getWordInfo(kind: WordInfoKind.recitations, ref: ref),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final word = snap.data;
            if (word == null || word.content.trim().isEmpty) {
              return _buildEmptyState(
                card: card,
                isDark: isDark,
                themeState: themeState,
                message: "لا توجد بيانات قراءات لهذه الآية",
              );
            }

            return _buildWordInfoCard(
              card: card,
              isDark: isDark,
              themeState: themeState,
              word: word,
              title: "القراءات",
            );
          },
        );
      },
    );
  }

  /// Sarf Tab Content Widget - Updated
  Widget _SarfTabContent({
    required WordRef ref,
    required Color card,
    required bool isDark,
    required ThemeState themeState,
  }) {
    return FutureBuilder<bool>(
      future: Future.value(_wordInfoRepo.isKindDownloaded(WordInfoKind.tasreef)),
      builder: (context, downloadSnap) {
        final isDownloaded = downloadSnap.data ?? false;

        if (!isDownloaded) {
          return _buildDownloadPrompt(
            card: card,
            isDark: isDark,
            themeState: themeState,
            title: "بيانات الصرف",
            description: "حمّل بيانات التصريف لعرض التحليل الصرفي للكلمات",
            icon: Icons.auto_stories_outlined,
            kind: WordInfoKind.tasreef,
          );
        }

        return FutureBuilder<QiraatWordInfo?>(
          future: _wordInfoRepo.getWordInfo(kind: WordInfoKind.tasreef, ref: ref),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final word = snap.data;
            if (word == null || word.content.trim().isEmpty) {
              return _buildEmptyState(
                card: card,
                isDark: isDark,
                themeState: themeState,
                message: "لا توجد بيانات صرف لهذه الآية",
              );
            }

            return _buildWordInfoCard(
              card: card,
              isDark: isDark,
              themeState: themeState,
              word: word,
              title: "الصرف",
            );
          },
        );
      },
    );
  }

  /// Build download prompt widget
  Widget _buildDownloadPrompt({
    required Color card,
    required bool isDark,
    required ThemeState themeState,
    required String title,
    required String description,
    required IconData icon,
    required WordInfoKind kind,
  }) {
    double progress = 0.0;
    bool downloading = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: themeState.primary.withValues(alpha: 0.60),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.60)
                        : const Color(0xFF1B1B1B).withValues(alpha: 0.60),
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<int?>(
                  future: _wordInfoRepo.getRemoteZipSizeBytes(kind),
                  builder: (context, sizeSnap) {
                    final bytes = sizeSnap.data;
                    final label = bytes == null
                        ? ""
                        : "(${_formatBytes(bytes)})";
                    return Text(
                      label,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.55)
                            : const Color(0xFF1B1B1B).withValues(alpha: 0.55),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: downloading
                      ? null
                      : () async {
                    try {
                      downloading = true;
                      progress = 0.0;
                      setState(() {});
                      await _wordInfoRepo.downloadKind(
                        kind: kind,
                        onProgress: (p) {
                          progress = p;
                          setState(() {});
                        },
                      );
                      downloading = false;
                      progress = 100.0;
                      setState(() {});
                    } catch (e) {
                      downloading = false;
                      progress = 0.0;
                      debugPrint('Download error: $e');
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text("تحميل"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeState.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                if (downloading || progress > 0) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (progress / 100.0).clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: Colors.black.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(themeState.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    downloading
                        ? "جاري التحميل ${progress.toStringAsFixed(0)}%"
                        : "",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : const Color(0xFF1B1B1B).withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState({
    required Color card,
    required bool isDark,
    required ThemeState themeState,
    required String message,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: themeState.primary.withValues(alpha: 0.60),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordInfoCard({
    required Color card,
    required bool isDark,
    required ThemeState themeState,
    required QiraatWordInfo word,
    required String title,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: word.hasKhilaf
              ? Border.all(color: themeState.primary.withValues(alpha: 0.30), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.70)
                        : const Color(0xFF1B1B1B).withValues(alpha: 0.70),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeState.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    word.word,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              word.content,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.85)
                    : const Color(0xFF1B1B1B).withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _splitAyahWordsForChips(String qcfAyah) {
    final cleaned = qcfAyah
        .replaceAll(RegExp(r"\s+"), " ")
        .replaceAll(RegExp(r"[\u200A\u200B\u200C\u200D]"), " ")
        .trim();
    final words = cleaned.split(' ').where((e) => e.trim().isNotEmpty).toList();
    return words;
  }

  String _formatBytes(int bytes) {
    final kb = bytes / 1024.0;
    if (kb < 1024) return "${kb.toStringAsFixed(0)} KB";
    final mb = kb / 1024.0;
    return "${mb.toStringAsFixed(1)} MB";
  }

}
