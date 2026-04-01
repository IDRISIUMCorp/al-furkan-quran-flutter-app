import "package:al_quran_v3/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_quran_v3/src/resources/quran_resources/models/translation_book_model.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:bloc/bloc.dart";

class ResourcesProgressCubit extends Cubit<ResourcesProgressCubitState> {
  ResourcesProgressCubit() : super(ResourcesProgressCubitState());

  void updateProgress(
    double? percentage,
    String processName, {
    int? transferredBytes,
    int? totalBytes,
    String? activeResourceId,
  }) {
    emit(
      state.copyWith(
        percentage: percentage,
        processName: processName,
        onProcess: true,
        transferredBytes: transferredBytes,
        totalBytes: totalBytes,
        activeResourceId: activeResourceId,
      ),
    );
  }

  void success() {
    emit(ResourcesProgressCubitState());
  }

  void failure(String errorMessage) {
    emit(
      ResourcesProgressCubitState(isSuccess: false, errorMessage: errorMessage),
    );
  }

  void onProcess() {
    emit(state.copyWith(onProcess: true, isSuccess: null, errorMessage: null));
  }

  void changeTranslationBook(TranslationBookModel? translationBookModel) {
    emit(state.copyWith(translationBookModel: translationBookModel));
  }

  void changeTafsirBook(TafsirBookModel? tafsirBookModel) {
    emit(state.copyWith(tafsirBookModel: tafsirBookModel));
  }
}
