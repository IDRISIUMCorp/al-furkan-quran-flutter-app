import "package:flutter/material.dart";

import "library_sheet_view.dart";

class WahyLibrarySheet extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;

  const WahyLibrarySheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
  });

  static Future<void> show({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
  }) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          WahyLibrarySheet(surahNumber: surahNumber, verseNumber: verseNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WahyLibrarySheetView(
      surahNumber: surahNumber,
      verseNumber: verseNumber,
    );
  }
}
