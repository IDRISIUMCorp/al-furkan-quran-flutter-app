import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/theme/app_colors.dart';
import 'package:al_furkan/src/utils/number_localization.dart';
import 'package:al_furkan/src/utils/quran_ayahs_function/get_page_number.dart';
import 'package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart';
import 'package:qcf_quran/qcf_quran.dart' hide getPageNumber;

Future<void> showNotesSheet({
  required BuildContext context,
  required Color bg,
  required Color onBg,
  required List<dynamic> Function() loadNotes,
  required Future<void> Function(int) removeNoteAt,
  required Future<void> Function(String) showAddNotePopup,
  required ({int surah, int verse})? Function(String) parseKey,
  required String Function(String) ayahPreviewForKey,
  required void Function(int page, String key) onTapNote,
}) async {
  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
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
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.86,
              child: StatefulBuilder(
                builder: (ctx, setState) {
                  final themeState = context.read<ThemeCubit>().state;
                  final notes = loadNotes();

                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "الملاحظات",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: onBg,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final currentAyahKey = context
                                    .read<AyahKeyCubit>()
                                    .state
                                    .current;
                                if (currentAyahKey.isNotEmpty) {
                                  Navigator.pop(ctx);
                                  await showAddNotePopup(currentAyahKey);
                                }
                              },
                              child: Text(
                                "إضافة",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: themeState.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: notes.isEmpty
                            ? const Center(
                                child: Text(
                                  "لا توجد ملاحظات",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ayaTextMuted,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  90,
                                ),
                                itemCount: notes.length,
                                separatorBuilder: (_, _) => Divider(
                                  height: 14,
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                                itemBuilder: (context, index) {
                                  final n = notes[index] as Map;
                                  final key = (n["ayahKey"] as String?) ?? "";
                                  final text = (n["text"] as String?) ?? "";
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
                                      "${text.isEmpty ? preview : text}\nالصفحة ${localizedNumber(ctx, page)}",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      onPressed: () async {
                                        await removeNoteAt(index);
                                        setState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                      ),
                                    ),
                                    onTap: key.isEmpty
                                        ? null
                                        : () {
                                            Navigator.pop(ctx);
                                            onTapNote(page, key);
                                          },
                                  );
                                },
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
