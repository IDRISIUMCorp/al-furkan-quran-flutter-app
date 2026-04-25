import "package:auto_size_text/auto_size_text.dart";
import "package:flutter/material.dart";

/// تصميم المصغر للويدجيت - مخصص أكثر لشاشة القفل أو المساحات الصغيرة
class ZekrMiniWidgetDesign extends StatelessWidget {
  static const Size canvasSize = Size(400, 200);

  final String zekrText;
  final String reference;
  final String fontFamily;
  final String themeId;
  final bool isDark;
  final double fontSizeMultiplier;

  const ZekrMiniWidgetDesign({
    super.key,
    required this.zekrText,
    required this.reference,
    required this.fontFamily,
    required this.themeId,
    required this.isDark,
    this.fontSizeMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // Custom logic to pick a mini theme based on existing isDark
    final Color bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA);
    final Color textColor = isDark ? const Color(0xFFE3D5CA) : const Color(0xFF2C2A29);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E4DF);
    final Color refColor = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF8B8178);

    final resolvedFontFamily = fontFamily.isEmpty ? "Cairo-Bold" : fontFamily;

    return Container(
      width: canvasSize.width,
      height: canvasSize.height,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AutoSizeText(
                  zekrText,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  minFontSize: 16,
                  maxFontSize: (40 * fontSizeMultiplier).roundToDouble(),
                  maxLines: 4,
                  stepGranularity: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: resolvedFontFamily,
                    fontFamilyFallback: const ["Amiri"],
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                    fontSize: (32.0 * fontSizeMultiplier).roundToDouble(),
                  ),
                ),
              ),
            ),
            if (reference.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reference,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: refColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Cairo-SemiBold",
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
