import "package:al_furkan/src/core/settings/settings_repository.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_state.dart";
import "package:al_furkan/src/widget/quran_script/model/script_info.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class QuranViewCubit extends Cubit<QuranViewState> {
  QuranViewCubit(this._settingsRepository)
    : super(_settingsRepository.loadQuranViewState());

  final SettingsRepository _settingsRepository;

  Future<void> changeAyah(String ayah) async {
    await _saveAndEmit(state.copyWith(ayahKey: ayah));
  }

  Future<void> changeFontSize(double fontSize) async {
    await _saveAndEmit(state.copyWith(fontSize: fontSize));
  }

  Future<void> changeLineHeight(double lineHeight) async {
    await _saveAndEmit(state.copyWith(lineHeight: lineHeight));
  }

  Future<void> changeQuranScriptType(QuranScriptType quranScriptType) async {
    await _saveAndEmit(state.copyWith(quranScriptType: quranScriptType));
  }

  Future<void> changeTranslationFontSize(double fontSize) async {
    await _saveAndEmit(state.copyWith(translationFontSize: fontSize));
  }

  Future<bool> setViewOptions({
    bool? hideFootnote,
    bool? hideTranslation,
    bool? hideToolbar,
    bool? hideQuranAyah,
    bool? enableWordByWordHighlight,
    bool? scrollWithRecitation,
    bool? useAudioStream,
    double? playbackSpeed,
  }) async {
    final newState = state.copyWith(
      hideFootnote: hideFootnote,
      hideTranslation: hideTranslation,
      hideToolbar: hideToolbar,
      hideQuranAyah: hideQuranAyah,
      enableWordByWordHighlight: enableWordByWordHighlight,
      scrollWithRecitation: scrollWithRecitation,
      useAudioStream: useAudioStream,
      playbackSpeed: playbackSpeed,
    );
    if (newState.hideTranslation == true && newState.hideQuranAyah == true) {
      return false;
    }

    await _saveAndEmit(newState);
    return true;
  }

  Future<void> _saveAndEmit(QuranViewState newState) async {
    emit(newState);
    await _settingsRepository.saveQuranViewState(newState);
  }
}
