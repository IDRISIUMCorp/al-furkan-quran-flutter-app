import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:al_furkan/src/utils/number_localization.dart';
import 'package:al_furkan/src/utils/quran_ayahs_function/get_page_number.dart';
import 'package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart';
import 'package:qcf_quran/qcf_quran.dart' hide getPageNumber;
import 'package:al_furkan/src/theme/app_colors.dart';

Future<void> showStarredSheet({
  required BuildContext context,
  required Color bg,
  required Color onBg,
  required List<String> Function() loadStarred,
  required ({int surah, int verse})? Function(String) parseKey,
  required String Function(String) ayahPreviewForKey,
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
                  final starred = loadStarred();

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
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "مميزة بنجمة",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: onBg,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: starred.isEmpty
                            ? const Center(
                                child: Text(
                                  "لا توجد آيات مميزة بنجمة",
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
                                itemCount: starred.length,
                                separatorBuilder: (_, _) => Divider(
                                  height: 14,
                                  color: Colors.black.withValues(alpha: 0.06),
                                ),
                                itemBuilder: (context, index) {
                                  final key = starred[index];
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
                                        final box = Hive.box("user");
                                        final list = loadStarred();
                                        list.remove(key);
                                        await box.put("wahy_starred", list);
                                        setState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.star_outline_rounded,
                                      ),
                                    ),
                                    onTap: () {
                                      context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                                      context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
                                      Navigator.pop(ctx);
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
