import "package:flex_color_scheme/flex_color_scheme.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_fonts/google_fonts.dart";

import "../../theme/controller/theme_cubit.dart";
import "../../theme/controller/theme_state.dart";

class ThemeSettingsEnhanced extends StatelessWidget {
  const ThemeSettingsEnhanced({super.key});

  static List<Map<String, dynamic>> appSchemes = [
    {"scheme": FlexScheme.tealM3, "name": "تركواز", "icon": "🌊"},
    {"scheme": FlexScheme.blue, "name": "أزرق", "icon": "💙"},
    {"scheme": FlexScheme.deepPurple, "name": "بنفسجي", "icon": "💜"},
    {"scheme": FlexScheme.orangeM3, "name": "برتقالي", "icon": "🧡"},
    {"scheme": FlexScheme.blueWhale, "name": "حوت أزرق", "icon": "🐋"},
    {"scheme": FlexScheme.mandyRed, "name": "أحمر", "icon": "❤️"},
    {"scheme": FlexScheme.red, "name": "قرمزي", "icon": "🔴"},
    {"scheme": FlexScheme.indigo, "name": "نيلي", "icon": "🔵"},
    {"scheme": FlexScheme.espresso, "name": "قهوة", "icon": "☕"},
    {"scheme": FlexScheme.sakura, "name": "ساكورا", "icon": "🌸"},
    {"scheme": FlexScheme.amber, "name": "كهرماني", "icon": "🟡"},
    {"scheme": FlexScheme.cyanM3, "name": "سماوي", "icon": "🩵"},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "اختر لونك المفضل",
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appSchemes.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final schemeData = appSchemes[index];
                  final FlexScheme currentScheme = schemeData["scheme"];
                  final String name = schemeData["name"];
                  final String icon = schemeData["icon"];
                  final Color currentPrimaryColor = FlexColor.schemes[currentScheme]!.light.primary;
                  final bool isSelected = themeState.flexScheme == currentScheme;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        context.read<ThemeCubit>().changeFlexScheme(currentScheme);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        width: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              currentPrimaryColor,
                              currentPrimaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: currentPrimaryColor.withOpacity(isSelected ? 0.4 : 0.2),
                              blurRadius: isSelected ? 16 : 8,
                              offset: Offset(0, isSelected ? 6 : 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              icon,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
