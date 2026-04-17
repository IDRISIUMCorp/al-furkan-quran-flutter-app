import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_furkan/src/core/audio/services/audio_playback_service_access.dart';
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart';
import 'package:qcf_quran/qcf_quran.dart' hide getPageNumber;

Future<void> showListenRangeSheet({
  required BuildContext context,
  required int surah,
  required int verse,
  required int totalVerses,
  required String Function(String) toArabicDigits,
}) async {
  int from = verse;
  int to = verse;

  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final bg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F1E6);
          final card = isDark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFFFF9F2);
          final themeState = context.read<ThemeCubit>().state;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.only(
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
                          "تشغيل",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(14),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "من",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1B1B1B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<int>(
                                      value: from,
                                      dropdownColor: isDark
                                          ? const Color(0xFF2A2A2A)
                                          : const Color(0xFFF7F1E6),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1B1B1B),
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: isDark
                                            ? const Color(0xFF333333)
                                            : const Color(0xFFF7F1E6),
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12),
                                          ),
                                        ),
                                      ),
                                      items: List.generate(
                                        totalVerses,
                                        (i) => DropdownMenuItem(
                                          value: i + 1,
                                          child: Text(
                                            "${getSurahNameArabic(surah)}: ${toArabicDigits((i + 1).toString())}",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "إلى",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1B1B1B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<int>(
                                      value: to,
                                      dropdownColor: isDark
                                          ? const Color(0xFF2A2A2A)
                                          : const Color(0xFFF7F1E6),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1B1B1B),
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: isDark
                                            ? const Color(0xFF333333)
                                            : const Color(0xFFF7F1E6),
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(12),
                                          ),
                                        ),
                                      ),
                                      items: List.generate(
                                        totalVerses,
                                        (i) => DropdownMenuItem(
                                          value: i + 1,
                                          child: Text(
                                            "${getSurahNameArabic(surah)}: ${toArabicDigits((i + 1).toString())}",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      onChanged: (v) {
                                        if (v == null) return;
                                        setState(() {
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

                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeState.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final reciter = context
                                  .read<SegmentedQuranReciterCubit>()
                                  .state;
                              await audioPlaybackService.playPlaylist(
                                startAyahKey: "$surah:$from",
                                endAyahKey: "$surah:$to",
                                isInsideQuran: true,
                                reciterInfoModel: reciter,
                                initialIndex: 0,
                                instantPlay: true,
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text(
                              "تشغيل",
                              style: TextStyle(fontWeight: FontWeight.w900),
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
