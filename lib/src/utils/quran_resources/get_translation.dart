import "package:al_furkan/src/utils/quran_resources/quran_translation_function.dart";
 
import "../../resources/quran_resources/models/translation_book_model.dart";
 
final Map<String, List<TranslationOfAyah>> _translationCacheByAyahKey =
    <String, List<TranslationOfAyah>>{};
 
void clearTranslationCache() {
  _translationCacheByAyahKey.clear();
}

List<TranslationOfAyah>? getTranslationFromCache(String ayahKey) {
  return _translationCacheByAyahKey[ayahKey];
}
 
Future<List<TranslationOfAyah>> getTranslation(String ayahKey) async {
  final cached = _translationCacheByAyahKey[ayahKey];
  if (cached != null) return cached;
 
  final translationList = await QuranTranslationFunction.getTranslation(ayahKey);
  _translationCacheByAyahKey[ayahKey] = translationList;
  return translationList;
}
 
class TranslationOfAyah {
  final Map? translation;
  final TranslationBookModel? bookInfo;
  TranslationOfAyah({this.translation, required this.bookInfo});
}
