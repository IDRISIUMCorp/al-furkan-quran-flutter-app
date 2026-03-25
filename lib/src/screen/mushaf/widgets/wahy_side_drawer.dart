import "dart:ui" as ui;
import "package:flutter/material.dart";

import "package:al_quran_v3/src/screen/about/about_the_app.dart";
import "package:al_quran_v3/src/screen/smart_khatma/smart_khatma_page.dart";
import "package:al_quran_v3/src/screen/qibla/qibla_direction.dart";
import "package:al_quran_v3/src/screen/settings/settings_page.dart";
import "package:al_quran_v3/src/screen/prayer_time/prayer_time_page.dart";

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
      duration: const Duration(milliseconds: 600),
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
        final double delay = index * 0.08;
        final double curveValue = Curves.easeOutCubic.transform(
          ((_controller.value - delay) / (1 - delay)).clamp(0.0, 1.0),
        );
        return Transform.translate(
          offset: Offset(-30 * (1 - curveValue), 0),
          child: Opacity(opacity: curveValue, child: c),
        );
      },
      child: child,
    );
  }

  void _closeThen(
    BuildContext context,
    VoidCallback action,
  ) {
    Navigator.pop(context);
    action();
  }

  Future<void> _closeThenPush(BuildContext context, Widget page) async {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0A0A0A);
    const card = Color(0xFF161616);
    const onBg = Colors.white;

    int i = 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        width: 320,
        backgroundColor: bg,
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: bg.withValues(alpha: 0.8),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutAppPage(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "مركز الخدمات",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: onBg,
                                      ),
                                    ),
                                    Text(
                                      "IDRISIUM STANDARD",
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 2,
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
                            icon: const Icon(Icons.close_rounded),
                            color: widget.primary,
                            style: IconButton.styleFrom(
                              backgroundColor: widget.primary.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildAnimItem(
                            i++,
                            Text(
                              "الرئيسية",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAnimItem(
                            i++,
                            WahyDrawerItem(
                              title: "المصحف المعلم",
                              subtitle: "تلاوة وتفسير",
                              icon: Icons.menu_book_rounded,
                              primary: widget.primary,
                              onTap: () => Navigator.pop(context),
                              cardColor: card,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildAnimItem(
                            i++,
                            Text(
                              "الخدمات الإسلامية",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAnimItem(
                            i++,
                            Container(
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  WahyDrawerItem(
                                    title: "مواقيت الصلاة",
                                    subtitle: "مواعيد وتنبيهات",
                                    icon: Icons.access_time_filled_rounded,
                                    primary: widget.primary,
                                    onTap: () => _closeThenPush(
                                      context,
                                      const PrayerTimePage(),
                                    ),
                                  ),
                                  const WahyDrawerDivider(),
                                  WahyDrawerItem(
                                    title: "اتجاه القبلة",
                                    subtitle: "البوصلة الذكية",
                                    icon: Icons.explore_rounded,
                                    primary: widget.primary,
                                    onTap: () => _closeThenPush(
                                      context,
                                      const QiblaDirection(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildAnimItem(
                            i++,
                            Text(
                              "الإدارة السريعة",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildAnimItem(
                            i++,
                            Container(
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                children: [
                                  WahyDrawerItem(
                                    title: "الفهرس والانتقال",
                                    subtitle: "سورة / آية / صفحة",
                                    icon: Icons.format_list_bulleted_rounded,
                                    primary: widget.primary,
                                    onTap: () =>
                                        _closeThen(context, widget.onOpenIndex),
                                  ),
                                  const WahyDrawerDivider(),
                                  WahyDrawerItem(
                                    title: "مساحة الختمة",
                                    subtitle: "متابعة الحفظ",
                                    icon: Icons.auto_awesome_rounded,
                                    primary: widget.primary,
                                    onTap: () => _closeThenPush(
                                      context,
                                      const SmartKhatmaPage(),
                                    ),
                                  ),
                                  const WahyDrawerDivider(),
                                  WahyDrawerItem(
                                    title: "الإعدادات",
                                    subtitle: "تخصيص التطبيق",
                                    icon: Icons.settings_rounded,
                                    primary: widget.primary,
                                    onTap: () => _closeThenPush(
                                      context,
                                      const SettingsPage(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
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
}

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
    return Material(
      color: cardColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8F8F8F),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: Colors.white.withValues(alpha: 0.3),
              ),
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
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: Colors.white.withValues(alpha: 0.05),
    );
  }
}
