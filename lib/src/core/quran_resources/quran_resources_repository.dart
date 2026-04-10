import "dart:ui";

import "package:al_quran_v3/src/core/services/ayah_of_the_day_service.dart";
import "package:al_quran_v3/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_quran_v3/src/utils/quran_resources/default_offline_resources.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_irab_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_script_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_tafsir_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_translation_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/segmented_resources_manager.dart";
 
import "package:al_quran_v3/src/widget/quran_script/model/script_info.dart";

abstract class QuranResourcesRepository {
  Future<void> initialize({required Locale locale});
  Future<void> warmDeferredResources({
    required QuranScriptType scriptType,
    required bool enableBackgroundUpdates,
  });
}

class LocalQuranResourcesRepository implements QuranResourcesRepository {
  @override
  Future<void> initialize({required Locale locale}) async {
    await Future.wait([
      QuranTranslationFunction.init(locale: locale),
      SegmentedResourcesManager.init(),
    ]);
  }

  @override
  Future<void> warmDeferredResources({
    required QuranScriptType scriptType,
    required bool enableBackgroundUpdates,
  }) async {
    await DefaultOfflineResources.ensureInstalled();
    await QuranTafsirFunction.init();
    await QuranIrabFunction.setDefaultSelected();
    await QuranScriptFunction.initQuranScript(scriptType);
    await loadMetaSurah();

    if (enableBackgroundUpdates) {
      await AyahOfTheDayService.setupBackgroundUpdates();
    }
  }
}
