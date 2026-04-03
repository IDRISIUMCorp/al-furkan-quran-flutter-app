import "package:al_quran_v3/src/utils/number_localization.dart";
import "package:dartx/dartx.dart";
import "package:flutter/material.dart";

String getAyahLocalized(BuildContext context, String ayahKey) {
  List<String> split = ayahKey.split(":");
  return "${localizedNumber(context, split.first.toInt())}:${localizedNumber(context, split.last.toInt())}";
}
