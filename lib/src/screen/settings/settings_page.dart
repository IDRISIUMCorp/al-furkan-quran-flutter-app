import "dart:ui";

import "package:al_quran_v3/l10n/app_localizations.dart";
import "package:al_quran_v3/src/core/unified_quran_settings/quran_settings_bottom_sheet.dart";
import "package:al_quran_v3/src/screen/quran_script_view/settings/quran_script_settings.dart";
import "package:al_quran_v3/src/screen/settings/app_language_settings.dart";
import "package:al_quran_v3/src/screen/settings/notification_settings_page.dart";
import "package:al_quran_v3/src/screen/settings/theme_preview_sheet.dart";
import "package:al_quran_v3/src/screen/settings/theme_settings.dart";
import "package:al_quran_v3/src/screen/settings/widgets/ayah_widget_settings_page.dart";
import "package:al_quran_v3/src/widget/theme/theme_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:gap/gap.dart";

import "../../theme/controller/theme_cubit.dart";
import "../../theme/controller/theme_state.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: isDark
              ? const Color(0xFF0D0D0D)
              : const Color(0xFFF7F1E7),
          appBar: AppBar(
            title: Text(l10n.settings),
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
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.05),
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
                    ? [const Color(0xFF121212), const Color(0xFF090909)]
                    : [const Color(0xFFF7F1E7), const Color(0xFFFBF8F1)],
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                physics: const BouncingScrollPhysics(),
                children: [
                  _SettingsHero(themeState: themeState, isDark: isDark),
                  Gap(18.h),
                  _SettingsSectionCard(
                    title: "المظهر العام",
                    icon: Icons.palette_rounded,
                    themeState: themeState,
                    isDark: isDark,
                    child: Column(
                      children: [
                        const ThemeSettings(),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: () => ThemePreviewSheet.show(context),
                            icon: Icon(
                              Icons.color_lens_outlined,
                              color: themeState.primary,
                            ),
                            label: Text(
                              "معاينة جميع السمات",
                              style: TextStyle(
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
                  _SettingsSectionCard(
                    title: "القراءة والمصحف",
                    icon: Icons.menu_book_rounded,
                    themeState: themeState,
                    isDark: isDark,
                    child: Column(
                      children: [
                        const QuranScriptSettings(),
                        Gap(10.h),
                        _SettingsShortcutTile(
                          icon: Icons.auto_awesome_rounded,
                          title: "إعدادات المصحف",
                          subtitle:
                              "الثيم، أحجام الخطوط، التجويد، التظليل وسلوك القراءة.",
                          themeState: themeState,
                          isDark: isDark,
                          onTap: () => QuranSettingsBottomSheet.show(context),
                        ),
                      ],
                    ),
                  ),
                  Gap(14.h),
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
                          subtitle:
                              "تصميم حي، ثيمات، تحديث تلقائي، وآية أو فئة مخصصة.",
                          themeState: themeState,
                          isDark: isDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AyahWidgetSettingsPage(),
                            ),
                          ),
                        ),
                        Gap(10.h),
                        _SettingsShortcutTile(
                          icon: Icons.language_rounded,
                          title: "لغة التطبيق",
                          subtitle:
                              "اختيار اللغة الأساسية للتجربة والمحتوى المدعوم.",
                          themeState: themeState,
                          isDark: isDark,
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
                          subtitle:
                              "إدارة آية اليوم، الأذكار، والتنبيهات المرتبطة.",
                          themeState: themeState,
                          isDark: isDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationSettingsPage(),
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
  }
}

class _SettingsHero extends StatelessWidget {
  final ThemeState themeState;
  final bool isDark;

  const _SettingsHero({required this.themeState, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : themeState.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: themeState.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "لوحة الإعدادات",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 21.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Gap(8.h),
          Text(
            "خصص القراءة، الثيمات، الويدجيت، والإشعارات من مكان واحد بشكل أسرع وأنظف.",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.7,
              color: isDark ? Colors.white60 : Colors.black54,
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : themeState.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: themeState.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: themeState.primary),
              ),
              Gap(10.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Gap(14.h),
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

  const _SettingsShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.themeState,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : themeState.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: themeState.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: themeState.primary),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.6,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: themeState.primary),
          ],
        ),
      ),
    );
  }
}
