import "dart:ui" as ui;

import "package:flutter/material.dart";

enum WahyMushafMenuAction {
  quranSettings,
  azkar,
  prayerTimes,
  qibla,
  library,
  offlinePlayer,
  settings,
  about,
  feedback,
}

class WahyMushafTopHeader extends StatelessWidget {
  final bool showHeader;
  final double headerHeight;
  final double topInset;
  final Color topBarColor;
  final Color topBarBorderColor;
  final bool isMushafMode;
  final Color iconPrimaryColor;
  final Color menuPrimaryColor;
  final bool isDark;
  final VoidCallback onOpenIndex;
  final VoidCallback onOpenSearch;
  final VoidCallback onToggleViewMode;
  final VoidCallback onOpenKhatma;
  final ValueChanged<WahyMushafMenuAction> onMenuSelected;

  const WahyMushafTopHeader({
    super.key,
    required this.showHeader,
    required this.headerHeight,
    required this.topInset,
    required this.topBarColor,
    required this.topBarBorderColor,
    required this.isMushafMode,
    required this.iconPrimaryColor,
    required this.menuPrimaryColor,
    required this.isDark,
    required this.onOpenIndex,
    required this.onOpenSearch,
    required this.onToggleViewMode,
    required this.onOpenKhatma,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: Duration(milliseconds: showHeader ? 320 : 520),
      curve: Curves.easeInOutCubic,
      offset: showHeader ? Offset.zero : const Offset(0, -1.15),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: showHeader ? 240 : 420),
        opacity: showHeader ? 1 : 0,
        child: AnimatedScale(
          duration: Duration(milliseconds: showHeader ? 320 : 520),
          curve: Curves.easeInOutCubic,
          scale: showHeader ? 1.0 : 0.985,
          child: SizedBox(
            height: headerHeight + topInset,
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.only(top: topInset, left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: topBarColor,
                    border: Border(
                      bottom: BorderSide(color: topBarBorderColor, width: 1.0),
                    ),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HeaderIconPill(
                          tooltip: "\u0627\u0644\u0641\u0647\u0631\u0633",
                          icon: Icons.notes_rounded,
                          primary: iconPrimaryColor,
                          onTap: onOpenIndex,
                        ),
                        _HeaderIconPill(
                          tooltip: "\u0627\u0644\u0628\u062d\u062b",
                          icon: Icons.search_rounded,
                          primary: iconPrimaryColor,
                          onTap: onOpenSearch,
                        ),
                        _HeaderIconPill(
                          tooltip:
                              "\u0637\u0631\u064a\u0642\u0629 \u0627\u0644\u0639\u0631\u0636",
                          icon: isMushafMode
                              ? Icons.chrome_reader_mode_outlined
                              : Icons.menu_book_rounded,
                          primary: iconPrimaryColor,
                          onTap: onToggleViewMode,
                        ),
                        _HeaderIconPill(
                          tooltip: "\u0627\u0644\u062e\u062a\u0645\u0629",
                          icon: Icons.bookmark_border_rounded,
                          primary: iconPrimaryColor,
                          onTap: onOpenKhatma,
                        ),
                        WahyMushafMoreMenuButton(
                          primaryColor: menuPrimaryColor,
                          isDark: isDark,
                          onSelected: onMenuSelected,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WahyMushafMoreMenuButton extends StatelessWidget {
  final Color primaryColor;
  final bool isDark;
  final ValueChanged<WahyMushafMenuAction> onSelected;

  const WahyMushafMoreMenuButton({
    super.key,
    required this.primaryColor,
    required this.isDark,
    required this.onSelected,
  });

  static const List<
    ({WahyMushafMenuAction action, IconData icon, String label})
  >
  _menuItems = [
    // ── المميزات ──
    (
      action: WahyMushafMenuAction.offlinePlayer,
      icon: Icons.download_rounded,
      label: "المشغّل الأوفلاين",
    ),
    (
      action: WahyMushafMenuAction.library,
      icon: Icons.library_books_rounded,
      label: "المكتبة",
    ),
    (
      action: WahyMushafMenuAction.quranSettings,
      icon: Icons.auto_awesome_rounded,
      label: "إعدادات المصحف",
    ),
    (
      action: WahyMushafMenuAction.azkar,
      icon: Icons.auto_stories_rounded,
      label: "أذكار المسلم",
    ),
    (
      action: WahyMushafMenuAction.prayerTimes,
      icon: Icons.access_time_filled_rounded,
      label: "مواقيت الصلاة",
    ),
    (
      action: WahyMushafMenuAction.qibla,
      icon: Icons.explore_rounded,
      label: "القبلة",
    ),
    // ── النظام ──
    (
      action: WahyMushafMenuAction.settings,
      icon: Icons.settings_rounded,
      label: "الإعدادات",
    ),
    (
      action: WahyMushafMenuAction.about,
      icon: Icons.info_outline_rounded,
      label: "عن التطبيق",
    ),
    (
      action: WahyMushafMenuAction.feedback,
      icon: Icons.bug_report_rounded,
      label: "إرسال ملاحظة",
    ),
  ];

  PopupMenuItem<WahyMushafMenuAction> _buildMenuItem(
    ({WahyMushafMenuAction action, IconData icon, String label}) entry,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    return PopupMenuItem<WahyMushafMenuAction>(
      value: entry.action,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
              ),
              child: Icon(
                entry.icon,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              entry.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF7F5EC);

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE5E0CF),
              width: 1,
            ),
          ),
          elevation: isDark ? 16 : 30,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PopupMenuButton<WahyMushafMenuAction>(
          offset: const Offset(0, 50),
          icon: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF222222)
                  : primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.transparent,
              ),
            ),
            child: Icon(
              Icons.more_horiz_rounded,
              color: isDark ? Colors.white : primaryColor,
            ),
          ),
          itemBuilder: (context) => [
            // ── المميزات ──
            _buildMenuItem(_menuItems[0]), // المشغل الأوفلاين
            _buildMenuItem(_menuItems[1]), // المكتبة
            _buildMenuItem(_menuItems[2]), // إعدادات المصحف
            _buildMenuItem(_menuItems[3]), // أذكار المسلم
            _buildMenuItem(_menuItems[4]), // مواقيت الصلاة
            _buildMenuItem(_menuItems[5]), // القبلة
            const PopupMenuDivider(height: 16),
            // ── النظام ──
            _buildMenuItem(_menuItems[6]), // الإعدادات
            _buildMenuItem(_menuItems[7]), // عن التطبيق
            _buildMenuItem(_menuItems[8]), // إرسال ملاحظة
          ],
          onSelected: onSelected,
        ),
      ),
    );
  }
}

class _HeaderIconPill extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color primary;
  final VoidCallback onTap;

  const _HeaderIconPill({
    required this.tooltip,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        splashColor: primary.withValues(alpha: 0.1),
        highlightColor: primary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Icon(icon, color: primary, size: 26),
        ),
      ),
    );
  }
}
