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

    List<String> words = QuranScriptFunction.getWordListOfAyah(
      QuranScriptType.tajweed,
      surah.toString(),
      verse.toString(),
    ).map(sanitizeToken).where((w) => w.isNotEmpty).toList();

    if (words.isEmpty) {
      final userBox = Hive.box("user");
      final bool isProcessed =
          userBox.get("writeQuranScript", defaultValue: false) == true;
      final String? version = userBox.get("writeQuranScriptVersion");
      final bool scriptBoxExists = await Hive.boxExists(
        "script_${QuranScriptType.tajweed.name}",
      );

      final bool needsWrite =
          !isProcessed ||
          version != QuranScriptFunction.quranScriptVersion ||
          !scriptBoxExists;

      if (needsWrite) {
        if (!context.mounted) return;
        // Show non-blocking loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        color: themeState.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "جاري تجهيز سكربت القرآن...",
                        style: TextStyle(fontWeight: FontWeight.w800),
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

        words = QuranScriptFunction.getWordListOfAyah(
          QuranScriptType.tajweed,
          surah.toString(),
          verse.toString(),
        ).map(sanitizeToken).where((w) => w.isNotEmpty).toList();
      }
    }

    if (words.isEmpty && currentScriptType != QuranScriptType.tajweed) {
      words = QuranScriptFunction.getWordListOfAyah(
        currentScriptType,
        surah.toString(),
        verse.toString(),
      ).map(sanitizeToken).where((w) => w.isNotEmpty).toList();
    }

    final wordKeys = List.generate(
      words.length,
      (i) => "$surah:$verse:${i + 1}",
    );

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
              Timer? ayahHighlightTimer;
              int highlightedIndex = -1;
              bool ayahModeActive = false;
              final bool isDark = Theme.of(ctx).brightness == Brightness.dark;

              void stopAyahHighlight() {
                ayahHighlightTimer?.cancel();
                ayahHighlightTimer = null;
              }

              return Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFFFF9F2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: StatefulBuilder(
                    builder: (ctx, setSheetState) {
                      Future<void> playAyahWordByWord() async {
                        if (!mounted) return;

                        stopAyahHighlight();
                        setSheetState(() {
                          ayahModeActive = true;
                          highlightedIndex = 0;
                        });

                        await audioPlaybackService.playWordsSequence(
                          wordKeys,
                          onWordStart: (i, _) {
                            if (!mounted) return;
                            setSheetState(() {
                              highlightedIndex = i;
                            });
                          },
                        );

                        if (!mounted) return;
                        setSheetState(() {
                          ayahModeActive = false;
                          highlightedIndex = -1;
                        });
                      }

                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "نطق الكلمات",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1B1B1B),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeState.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: playAyahWordByWord,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text(
                                  "تشغيل الآية كلمة كلمة",
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: List.generate(words.length, (i) {
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
                                        ayahModeActive && i == highlightedIndex;
                                    final isActive =
                                        isPlayingWord || isHighlighted;

                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? themeState.primary.withValues(
                                                alpha: 0.08,
                                              )
                                            : (isDark
                                                  ? const Color(0xFF2C2C2C)
                                                  : const Color(0xFFF7F1E6)),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isActive
                                              ? themeState.primary.withValues(
                                                  alpha: 0.38,
                                                )
                                              : themeState.primary.withValues(
                                                  alpha: 0.18,
                                                ),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            words[i],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1B1B1B),
                                              height: 1.25,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor:
                                                  themeState.primary,
                                              backgroundColor: isPlayingWord
                                                  ? themeState.primary
                                                        .withValues(alpha: 0.06)
                                                  : null,
                                              side: BorderSide(
                                                color: themeState.primary
                                                    .withValues(alpha: 0.25),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            onPressed: k == null
                                                ? null
                                                : () {
                                                    setSheetState(() {
                                                      ayahModeActive = false;
                                                      highlightedIndex = -1;
                                                    });
                                                    stopAyahHighlight();
                                                    audioPlaybackService
                                                        .playWord(k);
                                                  },
                                            icon: AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 160,
                                              ),
                                              child: Icon(
                                                isPlayingWord
                                                    ? Icons.graphic_eq_rounded
                                                    : Icons.volume_up_rounded,
                                                key: ValueKey(isPlayingWord),
                                                size: 18,
                                              ),
                                            ),
                                            label: Text(
                                              isPlayingWord ? "شغال" : "تشغيل",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
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
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
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
