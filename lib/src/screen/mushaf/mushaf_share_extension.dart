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
            const bg = Color(0xFFEDE4D4);
            const card = Color(0xFFF5EBE0);
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
                                                  initialValue: from,
                                                  decoration:
                                                      const InputDecoration(
                                                        isDense: true,
                                                        filled: true,
                                                        fillColor: Color(
                                                          0xFFEDE4D4,
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
                                                  initialValue: to,
                                                  decoration:
                                                      const InputDecoration(
                                                        isDense: true,
                                                        filled: true,
                                                        fillColor: Color(
                                                          0xFFEDE4D4,
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
                                      child: RadioGroup<int>(
                                        groupValue: shareType,
                                        onChanged: (int? value) {
                                          setSheetState(() => shareType = value ?? 0);
                                        },
                                        child: Column(
                                          children: [
                                            RadioListTile<int>(
                                              value: 0,
                                              activeColor: Colors.green,
                                              title: const Text("مشاركة صورة"),
                                            ),
                                            RadioListTile<int>(
                                              value: 1,
                                              activeColor: Colors.green,
                                              title: const Text("مشاركة نص"),
                                            ),
                                            RadioListTile<int>(
                                              value: 2,
                                              activeColor: Colors.green,
                                              title: const Text("نص بدون تشكيل"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
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
                  : const Color(0xFFF5EBE0),
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
                  title: const Text("كصورة"),
                  subtitle: const Text(
                    "مشاركة الآية كصورة مجهزة بألوان هادئة",
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _shareAsImage(context, ayahKey, ayahText);
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

}
