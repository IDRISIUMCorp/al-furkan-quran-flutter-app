import "package:al_furkan/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_furkan/src/resources/quran_resources/models/translation_book_model.dart";
import "package:al_furkan/src/screen/setup/cubit/resources_progress_cubit_state.dart";
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
    final Map<String, double> newProgressMap = Map.of(state.progressMap);
    final Map<String, int> newTransferredBytesMap = Map.of(state.transferredBytesMap);
    final Map<String, int> newTotalBytesMap = Map.of(state.totalBytesMap);

    if (activeResourceId != null) {
      if (percentage != null) newProgressMap[activeResourceId] = percentage;
      if (transferredBytes != null) newTransferredBytesMap[activeResourceId] = transferredBytes;
      if (totalBytes != null) newTotalBytesMap[activeResourceId] = totalBytes;
    }

    emit(
      state.copyWith(
        percentage: percentage,
        processName: processName,
        onProcess: true,
        transferredBytes: transferredBytes,
        totalBytes: totalBytes,
        activeResourceId: activeResourceId,
        progressMap: newProgressMap,
        transferredBytesMap: newTransferredBytesMap,
        totalBytesMap: newTotalBytesMap,
      ),
    );
  }

  void success({String? activeResourceId}) {
    if (activeResourceId != null) {
      final Map<String, double> newProgressMap = Map.of(state.progressMap)..remove(activeResourceId);
      final Map<String, int> newTransferredBytesMap = Map.of(state.transferredBytesMap)..remove(activeResourceId);
      final Map<String, int> newTotalBytesMap = Map.of(state.totalBytesMap)..remove(activeResourceId);
      emit(state.copyWith(
        progressMap: newProgressMap,
        transferredBytesMap: newTransferredBytesMap,
        totalBytesMap: newTotalBytesMap,
        onProcess: newProgressMap.isNotEmpty,
      ));
    } else {
      emit(ResourcesProgressCubitState());
    }
  }

  void failure(String errorMessage, {String? activeResourceId}) {
    if (activeResourceId != null) {
      final Map<String, double> newProgressMap = Map.of(state.progressMap)..remove(activeResourceId);
      final Map<String, int> newTransferredBytesMap = Map.of(state.transferredBytesMap)..remove(activeResourceId);
      final Map<String, int> newTotalBytesMap = Map.of(state.totalBytesMap)..remove(activeResourceId);
      emit(
        state.copyWith(
          isSuccess: false,
          errorMessage: errorMessage,
          progressMap: newProgressMap,
          transferredBytesMap: newTransferredBytesMap,
          totalBytesMap: newTotalBytesMap,
          onProcess: newProgressMap.isNotEmpty,
        ),
      );
    } else {
      emit(state.copyWith(isSuccess: false, errorMessage: errorMessage));
    }
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
