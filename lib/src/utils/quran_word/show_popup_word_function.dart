import "package:al_furkan/src/screen/surah_list_view/model/surah_info_model.dart";
import "package:al_furkan/src/widget/quran_script_words/show_popup_of_word.dart";
import "package:flutter/material.dart";

import "../../resources/quran_resources/meta/meta_data_surah.dart";

void showPopupWordFunction({
  required BuildContext context,
  required List<String> wordKeys,
  required int initWordIndex,
  required List wordByWordList,
}) {
  SurahInfoModel surahInfoModel = SurahInfoModel.fromMap(
    metaDataSurah[wordKeys.first.split(":").first]!,
  );
  showModalBottomSheet(
    context: context,
    builder:
        (context) => ShowPopupOfWord(
          wordKeys: wordKeys,
          initWordIndex: initWordIndex,
          surahInfoModel: surahInfoModel,
          wordByWord: wordByWordList,
        ),
  );
}
