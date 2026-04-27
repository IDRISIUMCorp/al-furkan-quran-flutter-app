import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/utils/reciter_name_translations.dart";
import "package:al_furkan/src/widget/audio/reciter_picker_bottom_sheet.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:url_launcher/url_launcher.dart";

import "package:al_furkan/l10n/app_localizations.dart";
import "../../utils/basic_functions.dart";
import "../../theme/values/values.dart";

Widget getReciterWidget({
  required ReciterInfoModel audioTabScreenState,
  required BuildContext context,
  AyahKeyManagement? ayahKeyState,
  Function(ReciterInfoModel reciterInfoModel)? onReciterChanged,
  int? currentIndex,
  bool? isWordByWord,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).languageCode;
  
  // ترجمة اسم القارئ ونوع القراءة للعربية
  final translatedName = ReciterNameTranslations.getArabicName(
    audioTabScreenState.name,
    locale,
  );
  final translatedStyle = ReciterNameTranslations.getArabicStyle(
    audioTabScreenState.style ?? "",
    locale,
  );
  
  return Material(
    color: Colors.transparent,
    child: InkWell(
    borderRadius: BorderRadius.circular(roundedRadius),
    onTap: () {
      // Removed reciter change functionality
    },

    child: Row(
      children: [
        SizedBox(
          height: 100,
          width: 80,
          child:
              audioTabScreenState.img != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(roundedRadius),
                    child: CachedNetworkImage(
                      imageUrl: audioTabScreenState.img!,
                      cacheManager: ReciterImageCacheManager(),
                      errorWidget:
                          (context, url, error) => const Icon(
                            FluentIcons.person_24_regular,
                            size: 60,
                            color: Colors.grey,
                          ),
                      progressIndicatorBuilder:
                          (context, url, progress) => Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              backgroundColor:
                                  context
                                      .read<ThemeCubit>()
                                      .state
                                      .primaryShade100,
                            ),
                          ),
                      fit: BoxFit.cover,
                    ),
                  )
                  : const Icon(
                    FluentIcons.person_24_regular,
                    size: 60,
                    color: Colors.grey,
                  ),
        ),
        const Gap(10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  safeSubString(translatedName, 20, replacer: "..."),
                  style: const TextStyle(fontSize: 16),
                ),
                const Gap(5),
                const Icon(Icons.arrow_drop_down_rounded, size: 30),
              ],
            ),
            Text('أسلوب: $translatedStyle'),
            Text(l10n.source(audioTabScreenState.source ?? "")),
            if (audioTabScreenState.bio != null)
              Row(
                children: [
                  Text(l10n.more),
                  SizedBox(
                    height: 20,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        launchUrl(
                          Uri.parse(audioTabScreenState.bio!),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Text(Uri.parse(audioTabScreenState.bio!).host),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
    ),
  );
}
