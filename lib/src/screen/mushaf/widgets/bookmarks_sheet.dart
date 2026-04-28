import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_furkan/src/utils/number_localization.dart';
import 'package:al_furkan/src/utils/quran_ayahs_function/get_page_number.dart';
import 'package:al_furkan/src/theme/app_colors.dart';
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart';
import 'package:qcf_quran/qcf_quran.dart' hide getPageNumber;

Future<void> showBookmarksSheet({
  required BuildContext context,
  required Color bg,
  required Color onBg,
  required List<Map<String, dynamic>> Function() loadBookmarks,
  required Future<void> Function(String) setBookmarkColorForCurrentAyah,
  required ({int surah, int verse})? Function(String) parseKey,
  required Future<void> Function(String) removeBookmark,
  required String Function(String) ayahPreviewForKey,
}) async {
  final themeState = context.read<ThemeCubit>().state;
  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      const card = AppColors.lightCard;
      final colors = <String, ({String name, Color color})>{
        "red": (name: "الأحمر", color: const Color(0xFFB3261E)),
        "yellow": (name: "الأصفر", color: const Color(0xFFB68A00)),
        "green": (name: "الأخضر", color: themeState.primary),
        "blue": (name: "الأزرق", color: const Color(0xFF2962FF)),
      };

      String formatTime(String iso) {
        final dt = DateTime.tryParse(iso)?.toLocal();
        if (dt == null) return "";
        final hourOfPeriod = dt.hour % 12;
        final h = hourOfPeriod == 0 ? 12 : hourOfPeriod;
        final mm = dt.minute.toString().padLeft(2, "0");
        final suffix = dt.hour < 12 ? "ص" : "م";
        return "${localizedNumber(ctx, h)}:$mm $suffix";
      }

      return Directionality(
        textDirection: TextDirection.rtl,
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
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: StatefulBuilder(
                builder: (ctx, setState) {
                  bool editMode = false;
                  final all = loadBookmarks();
                  final grouped = <String, List<Map<String, dynamic>>>{
                    for (final k in colors.keys) k: <Map<String, dynamic>>[],
                  };
                  for (final e in all) {
                    final c = (e["color"] as String?) ?? "green";
                    if (grouped.containsKey(c)) grouped[c]!.add(e);
                  }

                  Future<void> onTapColor(String colorId) async {
                    final list = grouped[colorId] ?? const <Map<String, dynamic>>[];
                    if (list.isEmpty) {
                      await setBookmarkColorForCurrentAyah(colorId);
                      setState(() {});
                      return;
                    }

                    final key = (list.first["ayahKey"] as String?) ?? "";
                    if (key.isEmpty) return;
                    final page = getPageNumber(key) ?? 1;
                    context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                    context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
                    Navigator.pop(ctx);
                  }

                  Widget wahyColorRow(String colorId) {
                    final meta = colors[colorId]!;
                    final list = grouped[colorId] ?? const <Map<String, dynamic>>[];

                    String? subtitle;
                    if (list.isNotEmpty) {
                      final e = list.first;
                      final key = (e["ayahKey"] as String?) ?? "";
                      final page = getPageNumber(key) ?? 1;
                      final parsed = parseKey(key);
                      final time = formatTime((e["createdAt"] as String?) ?? "");
                      if (parsed != null && time.isNotEmpty) {
                        subtitle = "$time ${getSurahNameArabic(parsed.surah)}: ${localizedNumber(ctx, parsed.verse)} - الصفحة ${localizedNumber(ctx, page)}";
                      } else if (parsed != null) {
                        subtitle = "${getSurahNameArabic(parsed.surah)}: ${localizedNumber(ctx, parsed.verse)} - الصفحة ${localizedNumber(ctx, page)}";
                      } else {
                        subtitle = "الصفحة ${localizedNumber(ctx, page)}";
                      }
                    }

                    return ListTile(
                      dense: true,
                      title: Text(
                        meta.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: subtitle == null
                          ? null
                          : Text(
                              subtitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.lightTextMuted,
                              ),
                            ),
                      trailing: Icon(
                        Icons.bookmark_rounded,
                        color: meta.color,
                      ),
                      onTap: () async => onTapColor(colorId),
                    );
                  }

                  Widget section(String colorId) {
                    final meta = colors[colorId]!;
                    final list = grouped[colorId] ?? const <Map<String, dynamic>>[];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              meta.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            trailing: Icon(
                              Icons.bookmark_rounded,
                              color: meta.color,
                            ),
                          ),
                          if (list.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 14),
                              child: Text(
                                "لا توجد فواصل",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lightTextMuted,
                                ),
                              ),
                            )
                          else
                            ...list.map((e) {
                              final key = (e["ayahKey"] as String?) ?? "";
                              final parsed = parseKey(key);
                              final page = getPageNumber(key) ?? 1;
                              final title = parsed == null
                                  ? key
                                  : "${getSurahNameArabic(parsed.surah)}: ${localizedNumber(ctx, parsed.verse)}";
                              final preview = ayahPreviewForKey(key);

                              return ListTile(
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                subtitle: Text(
                                  "${preview.isEmpty ? key : preview}\nالصفحة ${localizedNumber(ctx, page)}",
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    await removeBookmark(key);
                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                ),
                                onTap: key.isEmpty
                                    ? null
                                    : () {
                                        context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                                        context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
                                        Navigator.pop(ctx);
                                      },
                              );
                            }),
                        ],
                      ),
                    );
                  }

                  return Column(
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
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "الفواصل",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: onBg,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                editMode = !editMode;
                              });
                            },
                            child: Text(
                              "تحرير",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: themeState.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (!editMode)
                        Container(
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Column(
                            children: [
                              wahyColorRow("red"),
                              wahyColorRow("yellow"),
                              wahyColorRow("green"),
                              wahyColorRow("blue"),
                            ],
                          ),
                        )
                      else
                        Flexible(
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: [
                              section("red"),
                              section("yellow"),
                              section("green"),
                              section("blue"),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
