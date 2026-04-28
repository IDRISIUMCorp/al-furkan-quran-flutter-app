import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_fonts/google_fonts.dart";

import "../../core/notifications/wahy_notification_service.dart";
import "../../theme/controller/theme_cubit.dart";

/// Ultimate Enhanced notification settings page with TONS of features
class NotificationSettingsPageEnhanced extends StatefulWidget {
  const NotificationSettingsPageEnhanced({super.key});

  @override
  State<NotificationSettingsPageEnhanced> createState() => _NotificationSettingsPageEnhancedState();
}

class _NotificationSettingsPageEnhancedState extends State<NotificationSettingsPageEnhanced> {
  final _svc = WahyNotificationService.instance;

  // Basic Notifications
  late bool _khatmaEnabled;
  late TimeOfDay _khatmaTime;
  late bool _dailyVerseEnabled;
  late TimeOfDay _dailyVerseTime;
  late bool _morningAzkarEnabled;
  late TimeOfDay _morningAzkarTime;
  late bool _eveningAzkarEnabled;
  late TimeOfDay _eveningAzkarTime;

  @override
  void initState() {
    super.initState();
    _khatmaEnabled = _svc.isKhatmaEnabled();
    _khatmaTime = _svc.getKhatmaTime() ?? const TimeOfDay(hour: 20, minute: 0);
    _dailyVerseEnabled = _svc.isDailyVerseEnabled();
    _dailyVerseTime = _svc.getDailyVerseTime() ?? const TimeOfDay(hour: 8, minute: 0);
    _morningAzkarEnabled = _svc.isMorningAzkarEnabled();
    _morningAzkarTime = _svc.getMorningAzkarTime() ?? const TimeOfDay(hour: 6, minute: 0);
    _eveningAzkarEnabled = _svc.isEveningAzkarEnabled();
    _eveningAzkarTime = _svc.getEveningAzkarTime() ?? const TimeOfDay(hour: 17, minute: 0);
  }

  Future<void> _pickTime({
    required TimeOfDay current,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
      builder: (ctx, child) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: context.read<ThemeCubit>().state.primary,
                    surface: Theme.of(context).colorScheme.surface,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: context.read<ThemeCubit>().state.primary,
                  ),
                ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, "0");
    final period = t.period == DayPeriod.am ? "ص" : "م";
    return "$h:$m $period";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF7F1E6);
    final cardBg = isDark ? const Color(0xFF0A0A0A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final primary = context.read<ThemeCubit>().state.primary;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            "الإشعارات",
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: textColor),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.transparent),
            ),
          ),
          iconTheme: IconThemeData(color: primary),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            physics: const BouncingScrollPhysics(),
            children: [
              // Basic Notifications
              _buildSectionHeader("الإشعارات الأساسية", Icons.notifications_rounded, primary, textColor),
              const SizedBox(height: 12),
              _buildNotifCard(
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF1B8A6B),
                title: "تذكير الختمة",
                subtitle: "تذكير يومي بورد القراءة",
                enabled: _khatmaEnabled,
                time: _khatmaTime,
                cardBg: cardBg,
                textColor: textColor,
                subtitleColor: subtitleColor,
                borderColor: borderColor,
                primary: primary,
                onToggle: (v) async {
                  setState(() => _khatmaEnabled = v);
                  if (v) {
                    await _svc.scheduleKhatmaReminder(hour: _khatmaTime.hour, minute: _khatmaTime.minute);
                  } else {
                    await _svc.cancelKhatmaReminder();
                  }
                },
                onTimeTap: () => _pickTime(
                  current: _khatmaTime,
                  onPicked: (t) async {
                    setState(() => _khatmaTime = t);
                    if (_khatmaEnabled) {
                      await _svc.scheduleKhatmaReminder(hour: t.hour, minute: t.minute);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildNotifCard(
                icon: Icons.auto_awesome_rounded,
                iconColor: const Color(0xFFC18D3E),
                title: "آية اليوم",
                subtitle: "آية عشوائية يومياً مع تفسيرها",
                enabled: _dailyVerseEnabled,
                time: _dailyVerseTime,
                cardBg: cardBg,
                textColor: textColor,
                subtitleColor: subtitleColor,
                borderColor: borderColor,
                primary: primary,
                onToggle: (v) async {
                  setState(() => _dailyVerseEnabled = v);
                  if (v) {
                    await _svc.scheduleDailyVerse(hour: _dailyVerseTime.hour, minute: _dailyVerseTime.minute);
                  } else {
                    await _svc.cancelDailyVerse();
                  }
                },
                onTimeTap: () => _pickTime(
                  current: _dailyVerseTime,
                  onPicked: (t) async {
                    setState(() => _dailyVerseTime = t);
                    if (_dailyVerseEnabled) {
                      await _svc.scheduleDailyVerse(hour: t.hour, minute: t.minute);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildNotifCard(
                icon: Icons.wb_sunny_rounded,
                iconColor: const Color(0xFFFF9800),
                title: "أذكار الصباح",
                subtitle: "تذكير بأذكار الصباح يومياً",
                enabled: _morningAzkarEnabled,
                time: _morningAzkarTime,
                cardBg: cardBg,
                textColor: textColor,
                subtitleColor: subtitleColor,
                borderColor: borderColor,
                primary: primary,
                onToggle: (v) async {
                  setState(() => _morningAzkarEnabled = v);
                  if (v) {
                    await _svc.scheduleMorningAzkar(hour: _morningAzkarTime.hour, minute: _morningAzkarTime.minute);
                  } else {
                    await _svc.cancelMorningAzkar();
                  }
                },
                onTimeTap: () => _pickTime(
                  current: _morningAzkarTime,
                  onPicked: (t) async {
                    setState(() => _morningAzkarTime = t);
                    if (_morningAzkarEnabled) {
                      await _svc.scheduleMorningAzkar(hour: t.hour, minute: t.minute);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              _buildNotifCard(
                icon: Icons.nights_stay_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: "أذكار المساء",
                subtitle: "تذكير بأذكار المساء يومياً",
                enabled: _eveningAzkarEnabled,
                time: _eveningAzkarTime,
                cardBg: cardBg,
                textColor: textColor,
                subtitleColor: subtitleColor,
                borderColor: borderColor,
                primary: primary,
                onToggle: (v) async {
                  setState(() => _eveningAzkarEnabled = v);
                  if (v) {
                    await _svc.scheduleEveningAzkar(hour: _eveningAzkarTime.hour, minute: _eveningAzkarTime.minute);
                  } else {
                    await _svc.cancelEveningAzkar();
                  }
                },
                onTimeTap: () => _pickTime(
                  current: _eveningAzkarTime,
                  onPicked: (t) async {
                    setState(() => _eveningAzkarTime = t);
                    if (_eveningAzkarEnabled) {
                      await _svc.scheduleEveningAzkar(hour: t.hour, minute: t.minute);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _svc.sendTestNotification();
            if (!mounted) return;
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "تم إرسال إشعار تجريبي ✅",
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                ),
                backgroundColor: primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          backgroundColor: primary,
          icon: const Icon(Icons.notifications_active_rounded, color: Colors.white),
          label: Text(
            "جرب الإشعار",
            style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(String title, IconData icon, Color primary, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNotifCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool enabled,
    required TimeOfDay time,
    required Color cardBg,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color primary,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: enabled,
                  onChanged: onToggle,
                  activeThumbColor: primary,
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: enabled
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
                        onTap: onTimeTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, color: primary, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "الوقت: ${_formatTime(time)}",
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.edit_rounded, color: primary.withValues(alpha: 0.5), size: 18),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
