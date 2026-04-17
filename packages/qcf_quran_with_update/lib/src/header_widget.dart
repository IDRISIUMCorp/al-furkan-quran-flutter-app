import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qcf_quran/qcf_quran.dart';

class HeaderWidget extends StatelessWidget {
  final int suraNumber;

  /// Optional theme configuration for customizing header appearance.
  /// If null, uses default theme values.
  final QcfThemeData? theme;

  const HeaderWidget({super.key, required this.suraNumber, this.theme});

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final effectiveTheme = theme ?? const QcfThemeData();

    // If custom header builder is provided, use it
    if (effectiveTheme.customHeaderBuilder != null) {
      return effectiveTheme.customHeaderBuilder!(suraNumber);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(effectiveTheme.headerBorderRadius),
      child: Container(
        decoration: BoxDecoration(color: effectiveTheme.headerBackgroundColor),
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image(
              image: AssetImage(
                ThemeData.estimateBrightnessForColor(effectiveTheme.pageBackgroundColor) == Brightness.dark 
                  ? "assets/Darkmainframe.png" 
                  : "assets/mainframe.png",
                package: 'qcf_quran',
              ),
              width:
                  (isPortrait
                      ? (getScreenType(context) == ScreenType.large
                          ? effectiveTheme.headerWidthLarge.w
                          : effectiveTheme.headerWidthSmall.w)
                      : (MediaQuery.of(context).size.width * 0.6).clamp(
                        0.0,
                        700.0.w,
                      )) *
                  effectiveTheme.headerScale,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "surah-icon",
                  style: TextStyle(
                    fontFamily: "surah-name-v1",
                    fontSize: isPortrait
                        ? (getScreenType(context) == ScreenType.large ? 24.0.sp : 30.0.sp)
                        : 34.0.sp,
                    color: effectiveTheme.headerTextColor,
                  ),
                ),
                Text(
                  "surah${suraNumber.toString().padLeft(3, '0')}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "surah-name-v1",
                    fontSize: isPortrait
                        ? (getScreenType(context) == ScreenType.large ? 28.0.sp : 34.0.sp)
                        : 38.0.sp,
                    color: effectiveTheme.headerTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
