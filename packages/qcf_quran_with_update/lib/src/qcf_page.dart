import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:qcf_quran/src/helpers/qcf_font_ready.dart';
import 'package:qcf_quran/src/widgets/classic_mushaf_border.dart';
import 'package:qcf_quran/src/widgets/classic_mushaf_header_footer.dart';
// ignore: implementation_imports

///
/// Use this if you want to build your own [PageView] or layout
/// and need granular control over each page's state and rendering.
class QcfPage extends StatefulWidget {
  /// The 1-based page number (1..604).
  final int pageNumber;

  /// Theme configuration for styling the page.
  final QcfThemeData theme;

  /// Optional font size override.
  final double? fontSize;

  /// Scaling factor for screen width/pixel density (default 1.0).
  /// Used for responsive sizing of fonts and layout.
  final double sp;

  /// Scaling factor for screen height (default 1.0).
  /// Used for responsive vertical spacing.
  final double h;

  /// Callback when a verse is long-pressed.
  final void Function(int surahNumber, int verseNumber)? onLongPress;

  /// Callback when long-press ends.
  final void Function(int surahNumber, int verseNumber)? onLongPressUp;

  /// Callback when long-press is cancelled.
  final void Function(int surahNumber, int verseNumber)? onLongPressCancel;

  /// Callback when long-press starts (includes details).
  final void Function(
    int surahNumber,
    int verseNumber,
    LongPressStartDetails details,
  )?
  onLongPressDown;

  /// Callback when a verse is tapped.
  final void Function(int surahNumber, int verseNumber)? onTap;

  /// Callback when a verse is double-tapped.
  final void Function(int surahNumber, int verseNumber)? onDoubleTap;

  /// Callback when a verse is touched down (finger placed).
  /// Useful for immediate highlighting.
  final void Function(int surahNumber, int verseNumber, TapDownDetails details)?
  onTapDown;

  /// Optional callback to customize verse background color dynamically.
  /// This takes precedence over [theme.verseBackgroundColor] if provided.
  final Color? Function(int surahNumber, int verseNumber)? verseBackgroundColor;

  /// Whether to render the page using Tajweed colored text.
  final bool showTajweed;

  /// Callback to get Tajweed words list for a specific verse.
  final List<String> Function(int surahNumber, int verseNumber)?
      tajweedWordsBuilder;

  /// Callback to get highlights for a specific verse.
  final List<HighlightRange> Function(int surahNumber, int verseNumber)?
      highlightsBuilder;

  const QcfPage({
    super.key,
    required this.pageNumber,
    this.theme = const QcfThemeData(),
    this.fontSize,
    this.sp = 1.0,
    this.h = 1.0,
    this.onLongPress,
    this.onLongPressUp,
    this.onLongPressCancel,
    this.onLongPressDown,
    this.onTap,
    this.onDoubleTap,
    this.onTapDown,
    this.verseBackgroundColor,
    this.showTajweed = false,
    this.tajweedWordsBuilder,
    this.highlightsBuilder,
  });

  @override
  State<QcfPage> createState() => _QcfPageState();
}

class _QcfPageState extends State<QcfPage> {
  /// Cached gesture recognizers keyed by "surah:verse".
  /// Prevents creating 45+ recognizer objects per page per build.
  final Map<String, _VerseGestureRecognizer> _recognizers = {};

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  /// Get or create a cached gesture recognizer for a verse.
  GestureRecognizer? _getRecognizer(int surah, int v) {
    final bool hasAnyGesture =
        widget.onTap != null ||
        widget.onTapDown != null ||
        widget.onDoubleTap != null ||
        widget.onLongPress != null ||
        widget.onLongPressDown != null ||
        widget.onLongPressUp != null ||
        widget.onLongPressCancel != null;
    if (!hasAnyGesture) return null;

    final key = '$surah:$v';
    final existing = _recognizers[key];
    if (existing != null) {
      // Update callbacks on existing recognizer (cheap pointer swap)
      existing.updateCallbacks(
        onTap: widget.onTap != null ? () => widget.onTap!.call(surah, v) : null,
        onDoubleTap: widget.onDoubleTap != null ? () => widget.onDoubleTap!.call(surah, v) : null,
        onTapDown: widget.onTapDown != null ? (d) => widget.onTapDown!.call(surah, v, d) : null,
        onLongPress: widget.onLongPress != null ? () => widget.onLongPress!.call(surah, v) : null,
        onLongPressDown: widget.onLongPressDown != null ? (d) => widget.onLongPressDown!.call(surah, v, d) : null,
        onLongPressUp: widget.onLongPressUp != null ? () => widget.onLongPressUp!.call(surah, v) : null,
        onLongPressCancel: widget.onLongPressCancel != null ? () => widget.onLongPressCancel!.call(surah, v) : null,
      );
      return existing;
    }

    final recognizer = _VerseGestureRecognizer(
      onTap: widget.onTap != null ? () => widget.onTap!.call(surah, v) : null,
      onDoubleTap: widget.onDoubleTap != null ? () => widget.onDoubleTap!.call(surah, v) : null,
      onTapDown: widget.onTapDown != null ? (d) => widget.onTapDown!.call(surah, v, d) : null,
      onLongPress: widget.onLongPress != null ? () => widget.onLongPress!.call(surah, v) : null,
      onLongPressDown: widget.onLongPressDown != null ? (d) => widget.onLongPressDown!.call(surah, v, d) : null,
      onLongPressUp: widget.onLongPressUp != null ? () => widget.onLongPressUp!.call(surah, v) : null,
      onLongPressCancel: widget.onLongPressCancel != null ? () => widget.onLongPressCancel!.call(surah, v) : null,
    );
    _recognizers[key] = recognizer;
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    // Local aliases for widget properties (StatefulWidget pattern)
    final pageNumber = widget.pageNumber;
    final theme = widget.theme;
    final fontSize = widget.fontSize;
    final sp = widget.sp;
    final h = widget.h;
    final showTajweed = widget.showTajweed;
    final tajweedWordsBuilder = widget.tajweedWordsBuilder;
    final highlightsBuilder = widget.highlightsBuilder;
    final verseBackgroundColor = widget.verseBackgroundColor;

    // Validate page number
    if (pageNumber < 1 || pageNumber > 604) {
      return Center(child: Text('Invalid page number: $pageNumber'));
    }

    return QcfFontReady(
      pages: <int>{1, pageNumber},
      placeholder: ColoredBox(color: theme.pageBackgroundColor),
      builder: (context) {
        final ranges = getPageData(pageNumber);
        final pageFont = "QCF_P${pageNumber.toString().padLeft(3, '0')}";

        final size = MediaQuery.sizeOf(context);
        final isTablet = size.shortestSide >= 600;

        final double baselineWidth = isTablet ? 640 : 470;
        final double fontScale = isTablet ? 1.30 : 1.18;
        final double baseFontSize =
            (fontSize ?? getFontSize(pageNumber, baselineWidth)) * fontScale;

        final double minAllPagesFontSize =
            (size.width * (isTablet ? 0.048 : 0.045)).clamp(18.0, 34.0);
        final double minFirstPagesFontSize =
            (size.width * 0.075).clamp(26.0, 36.0);

        final bool isFirstPages = pageNumber == 1 || pageNumber == 2;
        final double finalFontSize = isFirstPages
            ? baseFontSize.clamp(minFirstPagesFontSize, 44.0)
            : baseFontSize.clamp(minAllPagesFontSize, 44.0);
        final double finalHeight =
            isFirstPages ? 2.15 : (theme.verseHeight * (isTablet ? 0.93 : 0.96));

        final verseSpans = <InlineSpan>[];
        final firstPagesSpacer =
            (pageNumber == 1 || pageNumber == 2)
                ? theme.firstPagesTopSpacerFactor
                : 0.0;
        if (firstPagesSpacer > 0) {
          verseSpans.add(
            WidgetSpan(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * firstPagesSpacer,
              ),
            ),
          );
        }
        for (final r in ranges) {
          final surah = int.parse(r['surah'].toString());
          final start = int.parse(r['start'].toString());
          final end = int.parse(r['end'].toString());

          for (int v = start; v <= end; v++) {
            if (v == start && v == 1) {
              if (theme.showHeader) {
                verseSpans.add(
                  WidgetSpan(
                    child: HeaderWidget(suraNumber: surah, theme: theme),
                  ),
                );
              }
              if (theme.showBasmala && pageNumber != 1 && pageNumber != 187) {
                // Check for custom Basmala builder
                if (theme.basmalaBuilder != null) {
                  verseSpans.add(
                    WidgetSpan(
                      child: theme.basmalaBuilder!(surah),
                      alignment: PlaceholderAlignment.middle,
                    ),
                  );
                  // Add a newline after custom builder to maintain layout flow if needed
                  // or let the builder handle it. Usually basmala is a block.
                  // We'll add a newline ensuring separation.
                  verseSpans.add(const TextSpan(text: "\n"));
                } else {
                  if (surah != 97 && surah != 95) {
                    verseSpans.add(
                      TextSpan(
                        text: " ﱁ  ﱂﱃﱄ\n",
                        style: TextStyle(
                          fontFamily: "QCF_P001",
                          fontSize:
                              getScreenType(context) == ScreenType.large
                                  ? (theme.basmalaFontSizeLarge * sp).sp
                                  : (theme.basmalaFontSizeSmall * sp).sp,
                          color: theme.basmalaColor,
                        ),
                      ),
                    );
                  } else {
                    verseSpans.add(
                      TextSpan(
                        text: "齃𧻓𥳐龎\n",
                        style: TextStyle(
                          fontFamily: "QCF_BSML",
                          package: 'qcf_quran',
                          fontSize:
                              getScreenType(context) == ScreenType.large
                                  ? (theme.basmalaSpecialFontSizeLarge * sp).sp
                                  : (theme.basmalaSpecialFontSizeSmall * sp).sp,
                          color: theme.basmalaColor,
                        ),
                      ),
                    );
                  }
                }
              }
            }

            // Gesture Handling — uses cached recognizers
            final recognizer = _getRecognizer(surah, v);

            final verseBgColor =
                theme.verseBackgroundColor?.call(surah, v) ??
                verseBackgroundColor?.call(surah, v);

            // Verse Number Logic
            InlineSpan verseNumberSpan;
            if (theme.verseNumberBuilder != null) {
              verseNumberSpan = theme.verseNumberBuilder!(
                surah,
                v,
                getVerseNumberQCF(surah, v),
              );
            } else {
              verseNumberSpan = TextSpan(
                text: getVerseNumberQCF(surah, v),
                style: TextStyle(
                  fontFamily: pageFont,
                  color: theme.verseNumberColor,
                  height: (theme.verseNumberHeight * h).h,
                  backgroundColor:
                      theme.verseNumberBackgroundColor ?? verseBgColor,
                ),
              );
            }

            if (showTajweed && tajweedWordsBuilder != null) {
              final words = tajweedWordsBuilder(surah, v);

              // Important: if tajweed words aren't available (empty), fallback to
              // standard QCF rendering. Otherwise only the verse number glyph will
              // be rendered which makes the mushaf look like "numbers only".
              if (words.isNotEmpty) {
                final isLightMode =
                    Theme.of(context).brightness == Brightness.light;
                final defaultStyle = TextStyle(
                  fontFamily: "QPC_Hafs",
                  fontSize: finalFontSize,
                  height: finalHeight.h,
                  color: theme.verseTextColor,
                );

                final highlights = highlightsBuilder?.call(surah, v);
                final spans = List<InlineSpan>.generate(words.length, (index) {
                  final hl =
                      highlights
                          ?.where((h) => h.wordIndex == index)
                          .firstOrNull;

                  final tajweedSpan = parseTajweedWord(
                    wordWithTajweed: words[index],
                    wordIndex: index,
                    baseStyle: defaultStyle.copyWith(
                      backgroundColor: hl?.color,
                    ),
                    isLight: isLightMode,
                    enableTajweed: true, // It is already checked by showTajweed
                  );

                  return TextSpan(
                    children: [tajweedSpan, const TextSpan(text: " ")],
                    recognizer: recognizer,
                    style:
                        verseBgColor != null
                            ? TextStyle(backgroundColor: verseBgColor)
                            : null,
                  );
                });

                verseSpans.addAll(spans);
              } else {
                final highlights = highlightsBuilder?.call(surah, v);
                final rawQcf = getVerseQCF(surah, v, verseEndSymbol: false);
                final isFirstVerseOnPage = (v == ranges[0]["start"]);
                final String qcfText =
                    isFirstVerseOnPage
                        ? "${rawQcf.substring(0, 1)}\u200A${rawQcf.substring(1)}"
                        : rawQcf;

                if (highlights != null && highlights.isNotEmpty) {
                  int charIndex = 0;
                  for (int i = 0; i < qcfText.length; i++) {
                    final char = qcfText[i];
                    final isSpacer = isFirstVerseOnPage && i == 1;
                    final hl =
                        isSpacer
                            ? null
                            : highlights
                                .where((h) => h.wordIndex == charIndex)
                                .firstOrNull;

                    verseSpans.add(
                      TextSpan(
                        text: char,
                        recognizer: recognizer,
                        style: TextStyle(
                          fontFamily: pageFont,
                          fontSize: finalFontSize,
                          color: theme.verseTextColor,
                          height: finalHeight,
                          backgroundColor: hl?.color ?? verseBgColor,
                        ),
                      ),
                    );

                    if (!isSpacer) {
                      charIndex++;
                    }
                  }
                } else {
                  verseSpans.add(
                    TextSpan(
                      text: qcfText,
                      recognizer: recognizer,
                      style: TextStyle(
                        fontFamily: pageFont,
                        fontSize: finalFontSize,
                        color: theme.verseTextColor,
                        height: finalHeight,
                        backgroundColor: verseBgColor,
                      ),
                    ),
                  );
                }
              }
            } else {
              final highlights = highlightsBuilder?.call(surah, v);
              final rawQcf = getVerseQCF(surah, v, verseEndSymbol: false);
              final isFirstVerseOnPage = (v == ranges[0]['start']);
              final String qcfText =
                  isFirstVerseOnPage
                      ? "${rawQcf.substring(0, 1)}\u200A${rawQcf.substring(1)}"
                      : rawQcf;

              if (highlights != null && highlights.isNotEmpty) {
                // Since QCF font maps 1 char to 1 word approximately, we split by characters.
                int charIndex = 0;
                for (int i = 0; i < qcfText.length; i++) {
                  final char = qcfText[i];
                  // If it's the zero-width space we added for the first verse, skip highlight indexing
                  final isSpacer = isFirstVerseOnPage && i == 1;
                  final hl =
                      isSpacer
                          ? null
                          : highlights
                              .where((h) => h.wordIndex == charIndex)
                              .firstOrNull;

                  verseSpans.add(
                    TextSpan(
                      text: char,
                      recognizer: recognizer,
                      style: TextStyle(
                        fontFamily: pageFont,
                        fontSize: finalFontSize,
                        color: theme.verseTextColor,
                        height: finalHeight,
                        backgroundColor: hl?.color ?? verseBgColor,
                      ),
                    ),
                  );

                  if (!isSpacer) {
                    charIndex++;
                  }
                }
              } else {
                verseSpans.add(
                  TextSpan(
                    text: qcfText,
                    recognizer: recognizer,
                    style: TextStyle(
                      fontFamily: pageFont,
                      fontSize: finalFontSize,
                      color: theme.verseTextColor,
                      height: finalHeight,
                      backgroundColor: verseBgColor,
                    ),
                  ),
                );
              }
            }

            verseSpans.add(verseNumberSpan);

            // Sajda indicator — small ۩ symbol after verse number
            if (theme.showSajdaIndicator && isSajdaVerse(surah, v)) {
              verseSpans.add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      '۩',
                      style: TextStyle(
                        fontSize: finalFontSize * 0.55,
                        color: theme.sajdaIndicatorColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        }

        final pageOverlayTop = theme.pageTopOverlayBuilder?.call(
          pageNumber,
          int.parse(ranges.first['surah'].toString()),
          int.parse(ranges.first['start'].toString()),
        );

        final pageOverlayBottom = theme.pageBottomOverlayBuilder?.call(
          pageNumber,
          int.parse(ranges.first['surah'].toString()),
          int.parse(ranges.first['start'].toString()),
        );

        // Get first surah/verse for classic header/footer
        final firstSurah = int.parse(ranges.first['surah'].toString());
        final firstVerse = int.parse(ranges.first['start'].toString());

        return LayoutBuilder(
          builder: (context, constraints) {
            // Using a fixed standard width (400) creates a perfect baseline rendering
            // that FittedBox will then cleanly scale to any screen (tablet, web, mobile).
            return ColoredBox(
              color: theme.useClassicBorder
                  ? theme.classicPageBackground
                  : theme.pageBackgroundColor,
              child: SizedBox.expand(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Classic header (top)
                    if (theme.useClassicBorder)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ClassicMushafHeader(
                          surahNumber: firstSurah,
                          theme: theme,
                        ),
                      ),
                    // Main content
                    Align(
                      alignment: theme.useClassicBorder
                          ? const Alignment(0.0, 0.05)
                          : const Alignment(0.0, 0.1),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: baselineWidth,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: theme.useClassicBorder ? 60.0 : 30.0,
                              bottom: theme.useClassicBorder ? 60.0 : 15.0,
                              left: 4.0,
                              right: 4.0,
                            ),
                            child: ColoredBox(
                              color: theme.useClassicBorder
                                  ? Colors.transparent
                                  : theme.pageBackgroundColor,
                              child: ClassicMushafBorder(
                                theme: theme,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: ExcludeSemantics(
                                    child: Text.rich(
                                      TextSpan(children: verseSpans),
                                      locale: const Locale("ar"),
                                      textAlign: TextAlign.center,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        fontSize: finalFontSize,
                                        color: theme.verseTextColor,
                                        height: finalHeight,
                                        letterSpacing: theme.letterSpacing,
                                        wordSpacing: theme.wordSpacing,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Classic footer (bottom)
                    if (theme.useClassicBorder)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClassicMushafFooter(
                          pageNumber: pageNumber,
                          surahNumber: firstSurah,
                          startVerse: firstVerse,
                          theme: theme,
                        ),
                      ),
                    // Original overlay builders (if not using classic design)
                    if (!theme.useClassicBorder) ...[
                      if (pageOverlayTop != null)
                        Positioned(
                          top: 8.0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: pageOverlayTop,
                          ),
                        ),
                      if (pageOverlayBottom != null)
                        Positioned(
                          bottom: 20.0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: pageOverlayBottom,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _VerseGestureRecognizer extends GestureRecognizer {
  VoidCallback? onTap;
  VoidCallback? onDoubleTap;
  GestureTapDownCallback? onTapDown;
  VoidCallback? onLongPress;
  GestureLongPressStartCallback? onLongPressDown;
  VoidCallback? onLongPressUp;
  VoidCallback? onLongPressCancel;

  late final TapGestureRecognizer _tap;
  late final DoubleTapGestureRecognizer _doubleTap;
  late final LongPressGestureRecognizer _longPress;
  late final GestureArenaTeam _team;

  _VerseGestureRecognizer({
    this.onTap,
    this.onDoubleTap,
    this.onTapDown,
    this.onLongPress,
    this.onLongPressDown,
    this.onLongPressUp,
    this.onLongPressCancel,
  }) {
    _team = GestureArenaTeam();

    _tap =
        TapGestureRecognizer()
          ..team = _team
          ..onTap = onTap
          ..onTapDown = onTapDown;

    _doubleTap = DoubleTapGestureRecognizer()..onDoubleTap = onDoubleTap;

    _longPress =
        LongPressGestureRecognizer(duration: const Duration(milliseconds: 160))
          ..team = _team
          ..onLongPress = onLongPress
          ..onLongPressStart = onLongPressDown
          ..onLongPressUp = onLongPressUp
          ..onLongPressCancel = onLongPressCancel;
  }

  /// Efficiently update callbacks on both this recognizer and its sub-recognizers.
  /// Avoids disposing and recreating the entire gesture recognizer tree.
  void updateCallbacks({
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    GestureTapDownCallback? onTapDown,
    VoidCallback? onLongPress,
    GestureLongPressStartCallback? onLongPressDown,
    VoidCallback? onLongPressUp,
    VoidCallback? onLongPressCancel,
  }) {
    this.onTap = onTap;
    this.onDoubleTap = onDoubleTap;
    this.onTapDown = onTapDown;
    this.onLongPress = onLongPress;
    this.onLongPressDown = onLongPressDown;
    this.onLongPressUp = onLongPressUp;
    this.onLongPressCancel = onLongPressCancel;

    _tap.onTap = onTap;
    _tap.onTapDown = onTapDown;
    _doubleTap.onDoubleTap = onDoubleTap;
    _longPress.onLongPress = onLongPress;
    _longPress.onLongPressStart = onLongPressDown;
    _longPress.onLongPressUp = onLongPressUp;
    _longPress.onLongPressCancel = onLongPressCancel;
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _tap.addPointer(event);
    _doubleTap.addPointer(event);
    _longPress.addPointer(event);
  }

  @override
  void acceptGesture(int pointer) {
    // No-op: inner recognizers participate in the arena.
  }

  @override
  void rejectGesture(int pointer) {
    // No-op: inner recognizers participate in the arena.
  }

  void handleEvent(PointerEvent event) {
    // no-op: inner recognizers handle events
  }

  void didStopTrackingLastPointer(int pointer) {
    // no-op
  }

  @override
  void dispose() {
    _tap.dispose();
    _doubleTap.dispose();
    _longPress.dispose();
    super.dispose();
  }

  @override
  String get debugDescription => '_VerseGestureRecognizer';
}
