import "package:al_furkan/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_furkan/src/resources/quran_resources/models/translation_book_model.dart";

class ResourcesProgressCubitState {
  double? percentage;
  String? processName;
  bool? onProcess;
  bool? isSuccess;
  String? errorMessage;
  int? transferredBytes;
  int? totalBytes;
  String? activeResourceId;
  TranslationBookModel? translationBookModel;
  TafsirBookModel? tafsirBookModel;

  final Map<String, double> progressMap;
  final Map<String, int> transferredBytesMap;
  final Map<String, int> totalBytesMap;

  ResourcesProgressCubitState({
    this.percentage,
    this.processName,
    this.onProcess,
    this.isSuccess,
    this.errorMessage,
    this.transferredBytes,
    this.totalBytes,
    this.activeResourceId,
    this.translationBookModel,
    this.tafsirBookModel,
    Map<String, double>? progressMap,
    Map<String, int>? transferredBytesMap,
    Map<String, int>? totalBytesMap,
  })  : progressMap = progressMap ?? const {},
        transferredBytesMap = transferredBytesMap ?? const {},
        totalBytesMap = totalBytesMap ?? const {};

  ResourcesProgressCubitState copyWith({
    double? percentage,
    String? processName,
    bool? onProcess,
    bool? isSuccess,
    String? errorMessage,
    int? transferredBytes,
    int? totalBytes,
    String? activeResourceId,
    TranslationBookModel? translationBookModel,
    TafsirBookModel? tafsirBookModel,
    Map<String, double>? progressMap,
    Map<String, int>? transferredBytesMap,
    Map<String, int>? totalBytesMap,
  }) {
    return ResourcesProgressCubitState(
      percentage: percentage ?? this.percentage,
      processName: processName ?? this.processName,
      onProcess: onProcess ?? this.onProcess,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      activeResourceId: activeResourceId ?? this.activeResourceId,
      translationBookModel: translationBookModel ?? this.translationBookModel,
      tafsirBookModel: tafsirBookModel ?? this.tafsirBookModel,
      progressMap: progressMap ?? this.progressMap,
      transferredBytesMap: transferredBytesMap ?? this.transferredBytesMap,
      totalBytesMap: totalBytesMap ?? this.totalBytesMap,
    );
  }
}
