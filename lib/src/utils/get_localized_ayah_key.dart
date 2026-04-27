import "package:al_furkan/src/utils/number_localization.dart";
import "package:dartx/dartx.dart";
import "package:flutter/material.dart";

String getAyahLocalized(BuildContext context, String ayahKey) {
  final List<String> split = ayahKey.split(":");
  return "${localizedNumber(context, split.first.toInt())}:${localizedNumber(context, split.last.toInt())}";
}
