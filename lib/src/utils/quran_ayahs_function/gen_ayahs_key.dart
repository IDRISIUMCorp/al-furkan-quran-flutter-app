import "package:al_furkan/src/resources/quran_resources/quran_ayah_count.dart";

List getListOfAyahKey({
  required String startAyahKey,
  required String endAyahKey,
}) {
  final List ayahKeysList = [];
  final int startSurahNumber = int.parse(startAyahKey.split(":")[0]);
  final int startAyahNumber = int.parse(startAyahKey.split(":")[1]);
  final int endSurahNumber = int.parse(endAyahKey.split(":")[0]);
  final int endAyahNumber = int.parse(endAyahKey.split(":")[1]);

  for (int surah = startSurahNumber; surah <= endSurahNumber; surah++) {
    int startAyah = 1;
    if (surah == startSurahNumber) startAyah = startAyahNumber;
    int endAyah = quranAyahCount[surah - 1];
    if (surah == endSurahNumber) {
      endAyah = endAyahNumber;
    }
    for (int ayah = startAyah; ayah <= endAyah; ayah++) {
      if (ayah == 1) {
        ayahKeysList.add(surah);
      }
      ayahKeysList.add("$surah:$ayah");
    }
  }
  return ayahKeysList;
}

List<String> getListOfAyahKeyExperimental({
  required String startAyahKey,
  required String endAyahKey,
}) {
  final List<String> ayahKeysList = [];
  final int startSurahNumber = int.parse(startAyahKey.split(":")[0]);
  final int startAyahNumber = int.parse(startAyahKey.split(":")[1]);
  final int endSurahNumber = int.parse(endAyahKey.split(":")[0]);
  final int endAyahNumber = int.parse(endAyahKey.split(":")[1]);

  for (int surah = startSurahNumber; surah <= endSurahNumber; surah++) {
    int startAyah = 1;
    if (surah == startSurahNumber) startAyah = startAyahNumber;
    int endAyah = quranAyahCount[surah - 1];
    if (surah == endSurahNumber) {
      endAyah = endAyahNumber;
    }
    for (int ayah = startAyah; ayah <= endAyah; ayah++) {
      ayahKeysList.add("$surah:$ayah");
    }
  }
  return ayahKeysList;
}

String getEndAyahKeyFromSurahNumber(int surahNumber) {
  return "$surahNumber:${quranAyahCount[surahNumber - 1]}";
}

