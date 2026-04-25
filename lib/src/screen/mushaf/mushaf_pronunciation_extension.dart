part of 'mushaf_screen.dart';

extension _MushafPronunciationExtension on _MushafViewState {
  Future<void> _showWordsPronunciationSheet({
    required BuildContext context,
    required int surah,
    required int verse,
  }) async {
    final themeState = context.read<ThemeCubit>().state;
    final currentScriptType = context
        .read<QuranViewCubit>()
        .state
        .quranScriptType;

    String sanitizeToken(String token) {
      return token
          .replaceAll(RegExp(r"<[^>]+>"), "")
          .replaceAll("﴿", "")
          .replaceAll("﴾", "")
          .replaceAll(RegExp(r"[0-9٠-٩]+"), "")
          .trim();
    }

    final rawWords = QuranScriptFunction.getWordListOfAyah(
      currentScriptType,
      surah.toString(),
      verse.toString(),
    );

    final tokens = <({int wordNumber, String text})>[];
    for (int i = 0; i < rawWords.length; i++) {
      final sanitized = sanitizeToken(rawWords[i]);
      if (sanitized.isEmpty) continue;
      tokens.add((wordNumber: i + 1, text: sanitized));
    }

    List<String> words = tokens.map((e) => e.text).toList();

    // Fallback: try writing script data if empty
    if (words.isEmpty) {
      final userBox = Hive.box("user");
      final bool isProcessed =
          userBox.get("writeQuranScript", defaultValue: false) == true;
      final String? version = userBox.get("writeQuranScriptVersion");
      final bool scriptBoxExists = await Hive.boxExists(
        "script_${currentScriptType.name}",
      );

      final bool needsWrite =
          !isProcessed ||
          version != QuranScriptFunction.quranScriptVersion ||
          !scriptBoxExists;

      if (needsWrite) {
        if (!context.mounted) return;

        // ─── Premium Loading Dialog ───
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFF5EBE0),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: themeState.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "تحضير ملفات النطق",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1B1B1B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "يتم تهيئة بيانات الكلمات لأول مرة فقط.\nهذا يحتاج اتصال بالإنترنت وقد يستغرق بضع ثوانٍ.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.55,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        try {
          await QuranScriptFunction.writeQuranScript();
          await QuranScriptFunction.initQuranScript(currentScriptType);
        } finally {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }

        final rewrittenRawWords = QuranScriptFunction.getWordListOfAyah(
          currentScriptType,
          surah.toString(),
          verse.toString(),
        );

        tokens
          ..clear()
          ..addAll(
            List<({int wordNumber, String text})>.generate(
              rewrittenRawWords.length,
              (i) => (
                wordNumber: i + 1,
                text: sanitizeToken(rewrittenRawWords[i]),
              ),
            ).where((e) => e.text.isNotEmpty),
          );

        words = tokens.map((e) => e.text).toList();
      }
    }

    // Fallback to Tajweed if user's script type returned empty
    if (words.isEmpty && currentScriptType != QuranScriptType.tajweed) {
      final fallbackRawWords = QuranScriptFunction.getWordListOfAyah(
        QuranScriptType.tajweed,
        surah.toString(),
        verse.toString(),
      );

      tokens
        ..clear()
        ..addAll(
          List<({int wordNumber, String text})>.generate(
            fallbackRawWords.length,
            (i) => (wordNumber: i + 1, text: sanitizeToken(fallbackRawWords[i])),
          ).where((e) => e.text.isNotEmpty),
        );

      words = tokens.map((e) => e.text).toList();
    }

    final wordKeys = tokens.map((e) => "$surah:$verse:${e.wordNumber}").toList();

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: DraggableScrollableSheet(
            initialChildSize: 0.62,
            minChildSize: 0.38,
            maxChildSize: 0.95,
            builder: (ctx, scrollController) {
              int highlightedIndex = -1;
              bool ayahModeActive = false;
              final bool isDark = Theme.of(ctx).brightness == Brightness.dark;
              final surface = isDark
                  ? const Color(0xFF1A1A1C)
                  : const Color(0xFFF5EBE0);
              final cardColor = isDark
                  ? const Color(0xFF2A2A2C)
                  : const Color(0xFFF5EDE0);
              final stroke = isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05);
              final textColor = isDark
                  ? Colors.white
                  : const Color(0xFF1B1B1B);
              final subtitleColor = (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.50);

              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.97),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      border: Border(top: BorderSide(color: stroke)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: StatefulBuilder(
                        builder: (ctx, setSheetState) {
                          Future<void> playAyahWordByWord() async {
                            if (!mounted) return;

                            if (ayahModeActive) {
                              await audioPlaybackService.stopPlaybackKeepUi();
                              if (!mounted) return;
                              setSheetState(() {
                                ayahModeActive = false;
                                highlightedIndex = -1;
                              });
                              return;
                            }

                            setSheetState(() {
                              ayahModeActive = true;
                              highlightedIndex = 0;
                            });

                            try {
                              await audioPlaybackService.playWordsSequence(
                                wordKeys,
                                onWordStart: (i, _) {
                                  if (!mounted) return;
                                  setSheetState(() {
                                    highlightedIndex = i;
                                  });
                                },
                              );
                            } catch (_) {
                              // UI state is reset in finally.
                            } finally {
                              if (mounted) {
                                setSheetState(() {
                                  ayahModeActive = false;
                                  highlightedIndex = -1;
                                });
                              }
                            }
                          }

                          return SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              12,
                              20,
                              24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ─── Handle ───
                                Center(
                                  child: Container(
                                    width: 44,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.black12,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // ─── Header ───
                                Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: themeState.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.record_voice_over_rounded,
                                        color: themeState.primary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "نطق الكلمات",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "سورة ${getSurahNameArabic(surah)} • الآية $verse • ${words.length} كلمة",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: subtitleColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // ─── Divider ───
                                Container(
                                  height: 1,
                                  color: stroke,
                                ),
                                const SizedBox(height: 14),

                                // ─── Play All Button ───
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeState.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: playAyahWordByWord,
                                    icon: Icon(
                                      ayahModeActive
                                          ? Icons.stop_rounded
                                          : Icons.play_arrow_rounded,
                                    ),
                                    label: Text(
                                      ayahModeActive
                                          ? "إيقاف التشغيل"
                                          : "تشغيل الآية كلمة كلمة",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ─── Word Cards Grid ───
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children:
                                      List.generate(words.length, (i) {
                                        final k = i < wordKeys.length
                                            ? wordKeys[i]
                                            : null;
                                        return BlocBuilder<
                                          WordPlayingStateCubit,
                                          String?
                                        >(
                                          builder: (context, playingKey) {
                                            final isPlayingWord =
                                                k != null && playingKey == k;
                                            final isHighlighted =
                                                ayahModeActive &&
                                                i == highlightedIndex;
                                            final isActive =
                                                isPlayingWord || isHighlighted;

                                            return AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              curve: Curves.easeOutCubic,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? themeState.primary
                                                          .withValues(
                                                            alpha: 0.10,
                                                          )
                                                    : cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: isActive
                                                      ? themeState.primary
                                                            .withValues(
                                                              alpha: 0.35,
                                                            )
                                                      : stroke,
                                                  width: isActive ? 1.5 : 1,
                                                ),
                                                boxShadow: isActive
                                                    ? [
                                                        BoxShadow(
                                                          color: themeState
                                                              .primary
                                                              .withValues(
                                                                alpha: 0.12,
                                                              ),
                                                          blurRadius: 12,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    words[i],
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "KFGQPC-Uthmanic-HAFS-Regular",
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: isActive
                                                          ? themeState.primary
                                                          : textColor,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  InkWell(
                                                    onTap: k == null
                                                        ? null
                                                        : () {
                                                            setSheetState(() {
                                                              ayahModeActive =
                                                                  false;
                                                              highlightedIndex =
                                                                  -1;
                                                            });
                                                            audioPlaybackService
                                                                .playWord(k);
                                                          },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: AnimatedContainer(
                                                      duration: const Duration(
                                                        milliseconds: 150,
                                                      ),
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                      decoration: BoxDecoration(
                                                        color: isPlayingWord
                                                            ? themeState.primary
                                                                  .withValues(
                                                                    alpha: 0.12,
                                                                  )
                                                            : Colors
                                                                .transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: Border.all(
                                                          color: themeState
                                                              .primary
                                                              .withValues(
                                                                alpha: 0.22,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            isPlayingWord
                                                                ? Icons
                                                                    .graphic_eq_rounded
                                                                : Icons
                                                                    .volume_up_rounded,
                                                            size: 16,
                                                            color: themeState
                                                                .primary,
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            isPlayingWord
                                                                ? "شغال"
                                                                : "نطق",
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: themeState
                                                                  .primary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
