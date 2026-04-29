import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qcf_quran/qcf_quran.dart' hide getPageNumber;
import 'package:share_plus/share_plus.dart';

import 'package:al_furkan/src/utils/quran_ayahs_function/get_page_number.dart';

class AyahImageGenerator {
  /// شارك الآية كصورة فقط (بدون تفسير)
  static Future<void> shareAsImage({
    required BuildContext context,
    required String ayahKey,
    required String ayahText,
  }) async {
    final parts = ayahKey.split(":");
    final surahNumber = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final verseNumber = parts.length == 2 ? int.tryParse(parts[1]) : null;

    if (surahNumber == null || verseNumber == null) {
      await SharePlus.instance.share(
        ShareParams(
          text:
              "$ayahKey\n\n${_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: ayahText)}",
        ),
      );
      return;
    }

    final int pageNumber = getPageNumber(ayahKey) ?? 1;
    final String pageFont = "QCF_P${pageNumber.toString().padLeft(3, '0')}";
    const double canvasWidth = 1400;

    const double paddingH = 40;
    final double headerWidth = canvasWidth - (paddingH * 2);
    final double bannerWidth = headerWidth * 0.82;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final qcfTheme = isDark
        ? QcfThemeData.dark().copyWith(
            pageBackgroundColor: Colors.black,
            headerBackgroundColor: const Color(0xFF111111),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,

            headerTextColor: Colors.white,
            verseTextColor: Colors.white,
            verseNumberColor: Colors.white,
          )
        : QcfThemeData.sepia().copyWith(
            pageBackgroundColor: const Color(0xFFEDE4D4),
            headerBackgroundColor: const Color(0xFFEFE3D2),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,

            headerTextColor: const Color(0xFF1B1B1B),
            verseTextColor: const Color(0xFF1B1B1B),
            verseNumberColor: const Color(0xFF1B1B1B),
          );

    final Color cardBgColor = isDark ? Colors.black : const Color(0xFFEDE4D4);

    final GlobalKey cardKey = GlobalKey();

    final Widget card = Material(
      color: Colors.transparent,
      child: RepaintBoundary(
        key: cardKey,
        child: Container(
          width: canvasWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: 22,
          ),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 26),
                Center(
                  child: SizedBox(
                    width: bannerWidth,
                    child: Transform.scale(
                      scale: 1.22,
                      child: HeaderWidget(
                        suraNumber: surahNumber,
                        theme: qcfTheme,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: getVerseQCF(
                            surahNumber,
                            verseNumber,
                            verseEndSymbol: false,
                          ),
                        ),
                        const TextSpan(text: "\u200A"),
                        TextSpan(
                          text: getVerseNumberQCF(surahNumber, verseNumber),
                          style: TextStyle(
                            fontFamily: pageFont,
                            color: qcfTheme.verseNumberColor,
                            height: qcfTheme.verseNumberHeight,
                          ),
                        ),
                      ],
                    ),
                    locale: const Locale("ar"),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: pageFont,
                      fontSize: 75,
                      height: 2.1,
                      color: qcfTheme.verseTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      await SharePlus.instance.share(
        ShareParams(
          text:
              "$ayahKey\n\n${_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: ayahText)}",
        ),
      );
      return;
    }
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(top: -10000, left: -10000, child: card),
    );
    overlay.insert(overlayEntry);

    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 120));

    final ctx = cardKey.currentContext;
    if (ctx == null) {
      overlayEntry.remove();
      await SharePlus.instance.share(
        ShareParams(
          text:
              "$ayahKey\n\n${_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: ayahText)}",
        ),
      );
      return;
    }

    // ignore: use_build_context_synchronously
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      overlayEntry.remove();
      await SharePlus.instance.share(
        ShareParams(
          text:
              "$ayahKey\n\n${_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: ayahText)}",
        ),
      );
      return;
    }
    final bytes = byteData.buffer.asUint8List();

    overlayEntry.remove();

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$ayahKey.png");
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        fileNameOverrides: ["$ayahKey.png"],
        downloadFallbackEnabled: false,
        mailToFallbackEnabled: false,
      ),
    );
  }

  /// شارك الآية كصورة مدمجة مع التفسير
  static Future<void> shareLibraryAsImage({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
    required String ayahKey,
    required String tafsirTitle,
    required String? tafsirTextRaw,
  }) async {
    const double canvasWidth = 1400;
    const double paddingH = 40;
    final double headerWidth = canvasWidth - (paddingH * 2);
    final double bannerWidth = headerWidth * 0.82;

    final int pageNumber = getPageNumber(ayahKey) ?? 1;
    final String pageFont = "QCF_P${pageNumber.toString().padLeft(3, '0')}";

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final qcfTheme = isDark
        ? QcfThemeData.dark().copyWith(
            pageBackgroundColor: Colors.black,
            headerBackgroundColor: const Color(0xFF111111),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,

            headerTextColor: Colors.white,
            verseTextColor: Colors.white,
            verseNumberColor: Colors.white,
          )
        : QcfThemeData.sepia().copyWith(
            pageBackgroundColor: const Color(0xFFEDE4D4),
            headerBackgroundColor: const Color(0xFFEFE3D2),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,

            headerTextColor: const Color(0xFF1B1B1B),
            verseTextColor: const Color(0xFF1B1B1B),
            verseNumberColor: const Color(0xFF1B1B1B),
          );

    final Color cardBgColor = isDark ? Colors.black : const Color(0xFFEDE4D4);
    final Color tafsirBgColor = isDark
        ? const Color(0xFF111111)
        : const Color(0xFFEFE3D2);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    final String? tafsirText = _sanitizeTafsirText(tafsirTextRaw);

    final double titleFontSize = (44 - (tafsirTitle.length * 0.35)).clamp(
      36,
      44,
    );
    final TextStyle titleStyle = TextStyle(
      fontSize: titleFontSize,
      fontWeight: FontWeight.w800,
      color: textColor.withValues(alpha: 0.55),
    );

    final String tafsirBody = (tafsirText == null || tafsirText.trim().isEmpty)
        ? "لا يوجد تفسير لهذه الآية في المصدر المحدد."
        : tafsirText.trim();

    final int charCount = tafsirBody.length;
    final double dynamicFontSize = charCount > 800 ? 46.0 : charCount > 500 ? 52.0 : charCount > 300 ? 58.0 : 64.0;

    final tafsirStyle = TextStyle(
      fontSize: dynamicFontSize,
      height: 1.9,
      fontWeight: FontWeight.w600,
      color: textColor,
    );

    final GlobalKey cardKey = GlobalKey();

    final Widget card = Material(
      color: Colors.transparent,
      child: RepaintBoundary(
        key: cardKey,
        child: Container(
          width: canvasWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: 22,
          ),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: bannerWidth,
                    child: Transform.scale(
                      scale: 1.22,
                      child: HeaderWidget(
                        suraNumber: surahNumber,
                        theme: qcfTheme,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: getVerseQCF(
                            surahNumber,
                            verseNumber,
                            verseEndSymbol: false,
                          ),
                        ),
                        const TextSpan(text: "\u200A"),
                        TextSpan(
                          text: getVerseNumberQCF(surahNumber, verseNumber),
                          style: TextStyle(
                            fontFamily: pageFont,
                            color: qcfTheme.verseNumberColor,
                            height: qcfTheme.verseNumberHeight,
                          ),
                        ),
                      ],
                    ),
                    locale: const Locale("ar"),
                    textScaler: const TextScaler.linear(1),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: pageFont,
                      fontSize: 75,
                      height: 2.1,
                      color: qcfTheme.verseTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  height: 1.2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: textColor.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(tafsirTitle, style: titleStyle),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: tafsirBgColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildRichTafsirTextForImage(
                      tafsirBody,
                      tafsirStyle,
                      isDark,
                      textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(top: -10000, left: -10000, child: card),
    );
    overlay.insert(overlayEntry);

    await Future.delayed(const Duration(milliseconds: 300));

    final ctx = cardKey.currentContext;
    if (ctx == null) return;
    // ignore: use_build_context_synchronously
    final boundary = ctx.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    overlayEntry.remove();

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: "image/png")],
        fileNameOverrides: ["$ayahKey-tafsir.png"],
        downloadFallbackEnabled: false,
        mailToFallbackEnabled: false,
      ),
    );
  }

  // Helpers
  static String _formatAyahTextForSharing({
    required String ayahKey,
    required String ayahText,
  }) {
    final parts = ayahKey.split(":");
    final verse = parts.length == 2 ? parts[1].trim() : "";
    final verseInBrackets = verse.isEmpty ? "" : "﴿${_toArabicDigits(verse)}﴾";
    var t = ayahText.trimRight();
    t = t.replaceAll(RegExp(r"[\s\u06DD\u06DD۝]+$"), "");
    t = t.replaceAll(RegExp(r"[\s0-9٠-٩۰-۹]+$"), "");
    t = t.trimRight();
    return "$t $verseInBrackets".trim();
  }

  static String _toArabicDigits(String number) {
    const arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buffer = StringBuffer();
    for (final ch in number.split('')) {
      final digit = int.tryParse(ch);
      if (digit == null) {
        buffer.write(ch);
      } else {
        buffer.write(arabics[digit]);
      }
    }
    return buffer.toString();
  }

  static String? _sanitizeTafsirText(String? raw) {
    if (raw == null) return null;
    var t = raw.trim();
    if (t.isEmpty) return null;
    if (t.startsWith("Instance of ")) return null;
    t = t.replaceAll(RegExp(r"<[^>]+>"), " ");
    t = t.replaceAll("\\n", "\n");
    t = t.replaceAll(RegExp(r"\n{3,}"), "\n\n");
    t = t.replaceAll(RegExp(r"\s{2,}"), " ");
    t = t.trim();
    return t.isEmpty ? null : t;
  }

  /// Rich tafsir text for image generation with bracket-aware styling:
  /// - ﴿...﴾ / ﴁ...ﴂ → Uthmani font + golden color (Quran ayah)
  /// - {...} → Uthmani font + golden yellow (curly brackets)
  /// - [...] → warm amber + bold (square brackets)
  static Widget _buildRichTafsirTextForImage(
    String text,
    TextStyle baseStyle,
    bool isDark,
    Color fallbackColor,
  ) {
    if (text.isEmpty) return Text(text, style: baseStyle);

    const quranFontFamily = "KFGQPC-Uthmanic-HAFS-Regular";
    final curlyColor = isDark ? const Color(0xFFE6B422) : const Color(0xFF9E7C0A);
    final squareColor = isDark ? const Color(0xFFCD853F) : const Color(0xFF8B5E3C);
    final quranColor = isDark ? fallbackColor : curlyColor;

    final quranPattern = RegExp(r'[﴿ﴁ][\s\S]*?[﴾ﴂ]', unicode: true);
    final curlyPattern = RegExp(r'\{[^\}]+\}');
    final squarePattern = RegExp(r'\[[^\]]+\]');

    final allMatches = <({int start, int end, String text, _ImageBracketKind kind})>[];

    for (final m in quranPattern.allMatches(text)) {
      allMatches.add((start: m.start, end: m.end, text: m.group(0)!, kind: _ImageBracketKind.quran));
    }
    for (final m in curlyPattern.allMatches(text)) {
      final overlaps = allMatches.any((e) => m.start < e.end && m.end > e.start);
      if (!overlaps) allMatches.add((start: m.start, end: m.end, text: m.group(0)!, kind: _ImageBracketKind.curly));
    }
    for (final m in squarePattern.allMatches(text)) {
      final overlaps = allMatches.any((e) => m.start < e.end && m.end > e.start);
      if (!overlaps) allMatches.add((start: m.start, end: m.end, text: m.group(0)!, kind: _ImageBracketKind.square));
    }
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    if (allMatches.isEmpty) {
      return Text(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: baseStyle,
      );
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in allMatches) {
      if (match.start > lastEnd) {
        final before = text.substring(lastEnd, match.start);
        if (before.isNotEmpty) spans.add(TextSpan(text: before, style: baseStyle));
      }

      switch (match.kind) {
        case _ImageBracketKind.quran:
          spans.add(TextSpan(
            text: match.text,
            style: baseStyle.copyWith(
              color: quranColor,
              fontFamily: quranFontFamily,
              fontSize: baseStyle.fontSize! * 1.05,
              fontWeight: FontWeight.w500,
            ),
          ));
        case _ImageBracketKind.curly:
          spans.add(TextSpan(
            text: match.text,
            style: baseStyle.copyWith(
              color: curlyColor,
              fontFamily: quranFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ));
        case _ImageBracketKind.square:
          spans.add(TextSpan(
            text: match.text,
            style: baseStyle.copyWith(
              color: squareColor,
              fontWeight: FontWeight.w700,
            ),
          ));
      }
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd);
      if (remaining.isNotEmpty) spans.add(TextSpan(text: remaining, style: baseStyle));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }
}

enum _ImageBracketKind { quran, curly, square }
