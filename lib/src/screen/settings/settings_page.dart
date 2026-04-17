import "dart:ui";

import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/resources/translation/language_cubit.dart";
import "package:al_furkan/src/resources/translation/languages.dart";
import "package:al_furkan/src/screen/settings/app_language_settings.dart";
import "package:al_furkan/src/screen/settings/notification_settings_page_enhanced.dart";
import "package:al_furkan/src/screen/settings/theme_preview_sheet.dart";
import "package:al_furkan/src/screen/settings/theme_settings_enhanced.dart";
import "package:al_furkan/src/screen/settings/widgets/home_widget_studio_screen.dart";
import "package:al_furkan/src/widget/theme/theme_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:gap/gap.dart";
import "package:google_fonts/google_fonts.dart";

import "../../theme/controller/theme_cubit.dart";
import "../../theme/controller/theme_state.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _autoScrollEnabled = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return BlocBuilder<LanguageCubit, MyAppLocalization>(
          builder: (context, languageState) {
            final isArabic = languageState.locale.languageCode == 'ar';
            
            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF7F1E7),
              appBar: AppBar(
                title: Text(
                  l10n.settings,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                ),
                actions: [themeIconButton(context)],
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface]
                        : [const Color(0xFFF7F1E7), const Color(0xFFFBF8F1)],
                  ),
                ),
                child: SafeArea(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Language Suggestion Banner (if not Arabic)
                      if (!isArabic)
                        _buildLanguageSuggestionBanner(
                          context,
                          themeState,
                          isDark,
                          languageState,
                        ),
                      if (!isArabic) Gap(14.h),
                      
                      // Theme & Appearance Section
                      _SettingsSectionCard(
                        title: "المظهر العام",
                        icon: Icons.palette_rounded,
                        themeState: themeState,
                        isDark: isDark,
                        child: Column(
                          children: [
                            const ThemeSettingsEnhanced(),
                            Gap(12.h),
                            _buildThemeModeSelector(context, themeState, isDark),
                            Gap(10.h),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton.icon(
                                onPressed: () => ThemePreviewSheet.show(context),
                                icon: Icon(Icons.color_lens_outlined, color: themeState.primary),
                                label: Text(
                                  "معاينة جميع السمات",
                                  style: GoogleFonts.cairo(
                                    color: themeState.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(14.h),
                      
                      // Auto Scroll Settings
                      _SettingsSectionCard(
                        title: "التمرير التلقائي",
                        icon: Icons.auto_mode_rounded,
                        themeState: themeState,
                        isDark: isDark,
                        child: _buildAutoScrollSettings(themeState, isDark),
                      ),
                      Gap(14.h),
                      
                      // Quick Shortcuts Section
                      _SettingsSectionCard(
                        title: "اختصارات سريعة",
                        icon: Icons.dashboard_customize_rounded,
                        themeState: themeState,
                        isDark: isDark,
                        child: Column(
                          children: [
                            _SettingsShortcutTile(
                              icon: Icons.widgets_rounded,
                              title: "ويدجيت آية اليوم",
                              subtitle: "تصميم حي، ثيمات، تحديث تلقائي، وآية أو فئة مخصصة.",
                              themeState: themeState,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeWidgetStudioScreen(),
                                ),
                              ),
                            ),
                            Gap(10.h),
                            _SettingsShortcutTile(
                              icon: Icons.language_rounded,
                              title: "لغة التطبيق",
                              subtitle: "اختيار اللغة الأساسية للتجربة والمحتوى المدعوم.",
                              themeState: themeState,
                              isDark: isDark,
                              trailing: _buildLanguageFlag(languageState),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AppLanguageSettings(),
                                ),
                              ),
                            ),
                            Gap(10.h),
                            _SettingsShortcutTile(
                              icon: Icons.notifications_active_rounded,
                              title: "الإشعارات",
                              subtitle: "تحكم كامل في جميع أنواع الإشعارات والتنبيهات.",
                              themeState: themeState,
                              isDark: isDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationSettingsPageEnhanced(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageSuggestionBanner(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
    MyAppLocalization currentLang,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.15),
            const Color(0xFF8B5CF6).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: Color(0xFF3B82F6),
              size: 28,
            ),
          ),
          Gap(14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "💡 اقتراح",
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                Gap(4.h),
                Text(
                  "يبدو أنك تستخدم اللغة ${currentLang.native}. هل تريد تفعيل المكتبة الخاصة بهذه اللغة؟",
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF3B82F6), size: 18),
        ],
      ),
    );
  }

  Widget _buildLanguageFlag(MyAppLocalization lang) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        lang.native,
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    ThemeState themeState,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildThemeModeButton(
              context,
              icon: Icons.light_mode_rounded,
              label: "فاتح",
              isSelected: themeState.themeMode == ThemeMode.light,
              themeState: themeState,
              isDark: isDark,
              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.light),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: _buildThemeModeButton(
              context,
              icon: Icons.dark_mode_rounded,
              label: "داكن",
              isSelected: themeState.themeMode == ThemeMode.dark,
              themeState: themeState,
              isDark: isDark,
              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.dark),
            ),
          ),
          Gap(4.w),
          Expanded(
            child: _buildThemeModeButton(
              context,
              icon: Icons.brightness_auto_rounded,
              label: "تلقائي",
              isSelected: themeState.themeMode == ThemeMode.system,
              themeState: themeState,
              isDark: isDark,
              onTap: () => context.read<ThemeCubit>().setTheme(ThemeMode.system),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required ThemeState themeState,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? themeState.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
              size: 22,
            ),
            Gap(4.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoScrollSettings(ThemeState themeState, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "تفعيل التمرير التلقائي",
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    "التمرير التلقائي أثناء القراءة دائماً مفعّل",
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _autoScrollEnabled,
              onChanged: (v) => setState(() => _autoScrollEnabled = v),
              activeColor: themeState.primary,
            ),
          ],
        ),
        if (_autoScrollEnabled) ...[
          Gap(12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: themeState.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: themeState.primary, size: 20),
                Gap(10.w),
                Expanded(
                  child: Text(
                    "التمرير التلقائي مفعّل ويعمل بشكل سلس",
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: themeState.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SettingsHero extends StatelessWidget {
  final ThemeState themeState;
  final bool isDark;

  const _SettingsHero({required this.themeState, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surfaceContainer]
              : [Colors.white, const Color(0xFFFFFBF5)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white10 : themeState.primary.withOpacity(0.08),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeState.primary.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themeState.primary, themeState.primary.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeState.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.settings_rounded, color: Colors.white, size: 28),
              ),
              Gap(14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "لوحة الإعدادات",
                      style: GoogleFonts.cairo(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "تحكم كامل في تجربتك",
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(14.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : themeState.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              "خصص القراءة، الثيمات، الويدجيت، والإشعارات من مكان واحد بشكل أسرع وأنظف.",
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                height: 1.7,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeState themeState;
  final bool isDark;
  final Widget child;

  const _SettingsSectionCard({
    required this.title,
    required this.icon,
    required this.themeState,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? Colors.white10 : themeState.primary.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeState.primary.withOpacity(0.15),
                      themeState.primary.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: themeState.primary, size: 22),
              ),
              Gap(12.w),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Gap(16.h),
          child,
        ],
      ),
    );
  }
}

class _SettingsShortcutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeState themeState;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.themeState,
    required this.isDark,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
                : [themeState.primary.withOpacity(0.05), themeState.primary.withOpacity(0.02)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : themeState.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeState.primary, themeState.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: themeState.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Gap(14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(6.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      height: 1.6,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Gap(10.w),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: themeState.primary,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }
}
