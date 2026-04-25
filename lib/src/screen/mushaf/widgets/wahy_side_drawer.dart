import "dart:ui" as ui;
import "package:flutter/material.dart";

import "package:al_furkan/src/theme/app_colors.dart";
import "package:al_furkan/src/screen/about/about_the_app.dart";
import "package:al_furkan/src/screen/smart_khatma/smart_khatma_page.dart";
import "package:al_furkan/src/screen/qibla/qibla_direction.dart";
import "package:al_furkan/src/screen/settings/settings_page.dart";
import "package:al_furkan/src/screen/reading_stats/reading_stats_screen.dart";
import "package:al_furkan/src/screen/custom_playlist/custom_playlist_screen.dart";
import "package:al_furkan/src/screen/prayer_time/prayer_time_page.dart";
import "package:al_furkan/src/screen/azkar/azkar_categories_screen.dart";
import "package:al_furkan/src/screen/quran_resources/quran_resources_view.dart";
import "package:al_furkan/src/screen/settings/widgets/home_widget_studio_screen.dart";
import "package:al_furkan/features/sunnah/presentation/screens/sunnah_prayer_screen_v2.dart";
import "package:al_furkan/src/screen/offline_player/offline_player_screen.dart";
import "package:al_furkan/src/screen/mushaf/widgets/wahy_feedback_dialog.dart";

class WahySideDrawer extends StatefulWidget {
  final Color primary;
  final VoidCallback onOpenIndex;
  final VoidCallback onOpenBookmarks;
  final VoidCallback onOpenStarred;
  final VoidCallback onOpenNotes;
  final void Function(int) onJumpToAyah;

  const WahySideDrawer({
    super.key,
    required this.primary,
    required this.onOpenIndex,
    required this.onOpenBookmarks,
    required this.onOpenStarred,
    required this.onOpenNotes,
    required this.onJumpToAyah,
  });

  @override
  State<WahySideDrawer> createState() => _WahySideDrawerState();
}

class _WahySideDrawerState extends State<WahySideDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, c) {
        final double delay = index * 0.06;
        final double curveValue = Curves.easeOutCubic.transform(
          ((_controller.value - delay) / (1 - delay)).clamp(0.0, 1.0),
        );
        return Transform.translate(
          offset: Offset(-20 * (1 - curveValue), 0),
          child: Opacity(opacity: curveValue, child: c),
        );
      },
      child: child,
    );
  }

  void _closeThen(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    action();
  }

  Future<void> _closeThenPush(BuildContext context, Widget page) async {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.ayaSurface;
    final card = isDark ? AppColors.darkCard : const Color(0xFFFFFFFF);
    final onBg = isDark ? const Color(0xFFF0EDE8) : AppColors.ayaTextMain;
    final subtitleColor = isDark ? Colors.white54 : AppColors.ayaTextSecondary;
    final sectionLabelColor = isDark ? Colors.white38 : AppColors.ayaTextMuted;
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.ayaBorder;
    final chevronColor = isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.15);

    int i = 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        width: 310,
        backgroundColor: bg,
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: bg.withValues(alpha: 0.85),
              child: SafeArea(
                child: Column(
                  children: [
                    // ── Header ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _closeThenPush(context, const AboutAppPage()),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "الفرقان",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: onBg,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "IDRISIUM STANDARD",
                                      style: TextStyle(
                                        fontSize: 9,
                                        letterSpacing: 2.5,
                                        fontWeight: FontWeight.w700,
                                        color: widget.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            color: widget.primary,
                            style: IconButton.styleFrom(
                              backgroundColor: widget.primary.withValues(alpha: 0.1),
                              minimumSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── Body ──
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // ── القسم الرئيسي ──
                          _buildAnimItem(i++, _sectionLabel("الرئيسية", sectionLabelColor)),
                          const SizedBox(height: 6),
                          _buildAnimItem(
                            i++,
                            _AyahDrawerCard(
                              cardColor: card,
                              dividerColor: dividerColor,
                              chevronColor: chevronColor,
                              items: [
                                _AyahDrawerItemData(
                                  title: "المصحف المعلم",
                                  subtitle: "تلاوة وتفسير",
                                  icon: Icons.menu_book_rounded,
                                  primary: widget.primary,
                                  onTap: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ── الخدمات والمميزات ──
                          _buildAnimItem(i++, _sectionLabel("الخدمات والمميزات", sectionLabelColor)),
                          const SizedBox(height: 6),
                          _buildAnimItem(
                            i++,
                            _AyahDrawerCard(
                              cardColor: card,
                              dividerColor: dividerColor,
                              chevronColor: chevronColor,
                              items: [
                                _AyahDrawerItemData(
                                  title: "المكتبة",
                                  subtitle: "ترجمات وتفاسير ومصادر",
                                  icon: Icons.library_books_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const QuranResourcesView()),
                                ),
                                _AyahDrawerItemData(
                                  title: "المشغّل الأوفلاين",
                                  subtitle: "تحميل التلاوات",
                                  icon: Icons.download_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const OfflinePlayerScreen()),
                                ),
                                _AyahDrawerItemData(
                                  title: "مواقيت الصلاة",
                                  subtitle: "مواعيد وتنبيهات",
                                  icon: Icons.access_time_filled_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const PrayerTimePage()),
                                ),
                                _AyahDrawerItemData(
                                  title: "اتجاه القبلة",
                                  subtitle: "البوصلة الذكية",
                                  icon: Icons.explore_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const QiblaDirection()),
                                ),
                                _AyahDrawerItemData(
                                  title: "الأذكار",
                                  subtitle: "أذكار الصباح والمساء",
                                  icon: Icons.auto_stories_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const AzkarCategoriesScreen()),
                                ),
                                _AyahDrawerItemData(
                                  title: "ويدجت آية اليوم",
                                  subtitle: "تخصيص الشكل والتحديث",
                                  icon: Icons.widgets_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const HomeWidgetStudioScreen()),
                                ),
                                _AyahDrawerItemData(
                                  title: "السنن",
                                  subtitle: "سنن الصلاة والوضوء",
                                  icon: Icons.favorite_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const SunnahPrayerScreenV2()),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ─ـ الإدارة السريعة ──
                          _buildAnimItem(i++, _sectionLabel("الإدارة السريعة", sectionLabelColor)),
                          const SizedBox(height: 6),
                          _buildAnimItem(
                            i++,
                            _AyahDrawerCard(
                              cardColor: card,
                              dividerColor: dividerColor,
                              chevronColor: chevronColor,
                              items: [
                                _AyahDrawerItemData(
                                  title: "الفهرس والانتقال",
                                  subtitle: "سورة / آية / صفحة",
                                  icon: Icons.format_list_bulleted_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThen(context, widget.onOpenIndex),
                                ),
                                _AyahDrawerItemData(
                                  title: "مساحة الختمة",
                                  subtitle: "متابعة الحفظ",
                                  icon: Icons.auto_awesome_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const SmartKhatmaPage()),
                                ),
                                _AyahDrawerItemData(
                                  title: "إحصائيات القراءة",
                                  subtitle: "صفحات وآيات وسلسلة",
                                  icon: Icons.bar_chart_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const ReadingStatsScreen()),
                                ),
                                _AyahDrawerItemData(
                                  title: "قوائم التشغيل",
                                  subtitle: "إنشاء وتشغيل قوائم مخصصة",
                                  icon: Icons.queue_music_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const CustomPlaylistScreen()),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ─ـ فاصل ──
                          _buildAnimItem(
                            i++,
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Divider(color: dividerColor, thickness: 1, height: 1),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ─ـ النظام ──
                          _buildAnimItem(i++, _sectionLabel("النظام", sectionLabelColor)),
                          const SizedBox(height: 6),
                          _buildAnimItem(
                            i++,
                            _AyahDrawerCard(
                              cardColor: card,
                              dividerColor: dividerColor,
                              chevronColor: chevronColor,
                              items: [
                                _AyahDrawerItemData(
                                  title: "الإعدادات",
                                  subtitle: "تخصيص التطبيق",
                                  icon: Icons.settings_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const SettingsPage()),
                                ),
                                _AyahDrawerItemData(
                                  title: "عن التطبيق",
                                  subtitle: "الإصدار والمطور",
                                  icon: Icons.info_outline_rounded,
                                  primary: widget.primary,
                                  onTap: () => _closeThenPush(context, const AboutAppPage()),
                                ),
                                _AyahDrawerItemData(
                                  title: "إرسال ملاحظة",
                                  subtitle: "ساعدنا في التحسن",
                                  icon: Icons.bug_report_rounded,
                                  primary: widget.primary,
                                  onTap: () {
                                    Navigator.pop(context);
                                    final primaryColor = widget.primary;
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: "إغلاق الملاحظة",
                                      transitionDuration: const Duration(milliseconds: 320),
                                      pageBuilder: (ctx, anim1, anim2) =>
                                          WahyFeedbackDialog(primary: primaryColor),
                                      transitionBuilder: (ctx, anim1, anim2, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 0.4),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
                                          ),
                                          child: FadeTransition(opacity: anim1, child: child),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Ayah-style card container ──

class _AyahDrawerItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;
  const _AyahDrawerItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primary,
    required this.onTap,
  });
}

class _AyahDrawerCard extends StatelessWidget {
  final Color cardColor;
  final Color dividerColor;
  final Color chevronColor;
  final List<_AyahDrawerItemData> items;

  const _AyahDrawerCard({
    required this.cardColor,
    required this.dividerColor,
    required this.chevronColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF0EDE8) : AppColors.ayaTextMain;
    final subtitleColor = isDark ? Colors.white54 : AppColors.ayaTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          for (int j = 0; j < items.length; j++) ...[
            if (j > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: dividerColor, thickness: 0.5, height: 0),
              ),
            _AyahDrawerItem(
              item: items[j],
              titleColor: titleColor,
              subtitleColor: subtitleColor,
              chevronColor: chevronColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _AyahDrawerItem extends StatelessWidget {
  final _AyahDrawerItemData item;
  final Color titleColor;
  final Color subtitleColor;
  final Color chevronColor;

  const _AyahDrawerItem({
    required this.item,
    required this.titleColor,
    required this.subtitleColor,
    required this.chevronColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: chevronColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Legacy compatibility (used by other screens) ──

class WahyDrawerItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;
  final Color? cardColor;

  const WahyDrawerItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primary,
    required this.onTap,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF0EDE8) : AppColors.ayaTextMain;
    final subtitleColor = isDark ? Colors.white54 : AppColors.ayaTextSecondary;
    final chevronColor = isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.15);

    return Material(
      color: cardColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.3,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: chevronColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class WahyDrawerDivider extends StatelessWidget {
  const WahyDrawerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.ayaBorder,
    );
  }
}
