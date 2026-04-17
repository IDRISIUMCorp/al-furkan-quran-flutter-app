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

  // Advanced Settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _ledEnabled = true;
  String _notificationPriority = "high";
  bool _showOnLockScreen = true;
  bool _persistentNotification = false;
  int _reminderInterval = 1;
  bool _weekendMode = false;
  
  // NEW: Extra Advanced Features
  bool _doNotDisturbMode = false;
  TimeOfDay _dndStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _dndEndTime = const TimeOfDay(hour: 7, minute: 0);
  bool _smartNotifications = true;
  bool _groupNotifications = true;
  String _notificationStyle = "expanded";
  bool _showPreview = true;
  bool _badgeCount = true;
  int _maxNotificationsPerDay = 10;
  bool _adaptiveTiming = true;
  final List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // All days
  bool _locationBasedNotifications = false;
  bool _quietHours = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 15, minute: 0);
  double _notificationVolume = 0.8;
  String _vibrationPattern = "default";
  bool _flashScreen = false;
  bool _repeatNotification = false;
  int _repeatInterval = 5; // minutes
  int _repeatCount = 3;

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
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.06);

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

  Widget _buildBasicNotifications(
    Color cardBg,
    Color textColor,
    Color subtitleColor,
    Color borderColor,
    Color primary,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        // Header
        _buildSectionHeader("إدارة الإشعارات اليومية", Icons.schedule_rounded, primary, textColor),
        const SizedBox(height: 16),

        // Khatma Reminder
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
        const SizedBox(height: 12),

        // Daily Verse
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
        const SizedBox(height: 12),

        // Morning Azkar
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
        const SizedBox(height: 12),

        // Evening Azkar
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
    );
  }

  Widget _buildAdvancedSettings(
    Color cardBg,
    Color textColor,
    Color subtitleColor,
    Color borderColor,
    Color primary,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionHeader("تخصيصات متقدمة", Icons.tune_rounded, primary, textColor),
        const SizedBox(height: 16),

        // Sound & Vibration Section
        _buildAdvancedCard(
          title: "الصوت والاهتزاز",
          icon: Icons.volume_up_rounded,
          iconColor: const Color(0xFF3B82F6),
          cardBg: cardBg,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
          primary: primary,
          isDark: isDark,
          children: [
            _buildSwitchTile(
              "تفعيل الصوت",
              "تشغيل صوت مع الإشعارات",
              _soundEnabled,
              (v) => setState(() => _soundEnabled = v),
              Icons.volume_up_rounded,
              primary,
              textColor,
              subtitleColor,
            ),
            const Divider(height: 24),
            _buildSwitchTile(
              "تفعيل الاهتزاز",
              "اهتزاز الجهاز عند وصول الإشعار",
              _vibrationEnabled,
              (v) => setState(() => _vibrationEnabled = v),
              Icons.vibration_rounded,
              primary,
              textColor,
              subtitleColor,
            ),
            const Divider(height: 24),
            _buildSwitchTile(
              "إضاءة LED",
              "إضاءة LED للإشعارات (إن وجدت)",
              _ledEnabled,
              (v) => setState(() => _ledEnabled = v),
              Icons.lightbulb_rounded,
              primary,
              textColor,
              subtitleColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Display Settings
        _buildAdvancedCard(
          title: "إعدادات العرض",
          icon: Icons.display_settings_rounded,
          iconColor: const Color(0xFF8B5CF6),
          cardBg: cardBg,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
          primary: primary,
          isDark: isDark,
          children: [
            _buildSwitchTile(
              "عرض على شاشة القفل",
              "إظهار الإشعارات على شاشة القفل",
              _showOnLockScreen,
              (v) => setState(() => _showOnLockScreen = v),
              Icons.lock_rounded,
              primary,
              textColor,
              subtitleColor,
            ),
            const Divider(height: 24),
            _buildSwitchTile(
              "إشعار دائم",
              "إبقاء الإشعار حتى يتم قراءته",
              _persistentNotification,
              (v) => setState(() => _persistentNotification = v),
              Icons.push_pin_rounded,
              primary,
              textColor,
              subtitleColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Priority Settings
        _buildAdvancedCard(
          title: "الأولوية والتكرار",
          icon: Icons.priority_high_rounded,
          iconColor: const Color(0xFFEF4444),
          cardBg: cardBg,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
          primary: primary,
          isDark: isDark,
          children: [
            _buildDropdownTile(
              "أولوية الإشعار",
              "تحديد أهمية الإشعار",
              _notificationPriority,
              ["high", "default", "low"],
              {"high": "عالية", "default": "عادية", "low": "منخفضة"},
              (v) => setState(() => _notificationPriority = v!),
              Icons.flag_rounded,
              primary,
              textColor,
              subtitleColor,
              isDark,
            ),
            const Divider(height: 24),
            _buildSliderTile(
              "فترة التذكير",
              "عدد الأيام بين التذكيرات",
              _reminderInterval.toDouble(),
              1,
              7,
              (v) => setState(() => _reminderInterval = v.toInt()),
              Icons.calendar_today_rounded,
              primary,
              textColor,
              subtitleColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Weekend Mode
        _buildAdvancedCard(
          title: "وضع نهاية الأسبوع",
          icon: Icons.weekend_rounded,
          iconColor: const Color(0xFF10B981),
          cardBg: cardBg,
          textColor: textColor,
          subtitleColor: subtitleColor,
          borderColor: borderColor,
          primary: primary,
          isDark: isDark,
          children: [
            _buildSwitchTile(
              "تفعيل وضع نهاية الأسبوع",
              "إيقاف الإشعارات في الجمعة والسبت",
              _weekendMode,
              (v) => setState(() => _weekendMode = v),
              Icons.weekend_rounded,
              primary,
              textColor,
              subtitleColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color primary, Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.7)],
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
            color: Colors.black.withOpacity(0.04),
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
                    color: iconColor.withOpacity(0.12),
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
                  activeColor: primary,
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
                            color: primary.withOpacity(0.08),
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
                              Icon(Icons.edit_rounded, color: primary.withOpacity(0.5), size: 18),
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

  Widget _buildAdvancedCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color cardBg,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
    required Color primary,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Stats Card
  Widget _buildStatsCard(Color cardBg, Color textColor, Color subtitleColor, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.15), primary.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: primary, size: 28),
              const SizedBox(width: 12),
              Text(
                "إحصائيات الإشعارات",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem("المرسلة اليوم", "12", Icons.send_rounded, primary, textColor, subtitleColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem("المقروءة", "8", Icons.done_all_rounded, const Color(0xFF10B981), textColor, subtitleColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem("المعلقة", "4", Icons.pending_rounded, const Color(0xFFF59E0B), textColor, subtitleColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, Color textColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  // Smart Features Card
  Widget _buildSmartFeaturesCard(Color cardBg, Color textColor, Color subtitleColor, Color borderColor, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            "الإشعارات الذكية",
            "تحليل سلوكك لإرسال الإشعارات في الوقت المناسب",
            _smartNotifications,
            (v) => setState(() => _smartNotifications = v),
            Icons.psychology_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            "تجميع الإشعارات",
            "دمج الإشعارات المتشابهة في إشعار واحد",
            _groupNotifications,
            (v) => setState(() => _groupNotifications = v),
            Icons.group_work_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            "التوقيت التكيفي",
            "ضبط أوقات الإشعارات بناءً على نشاطك",
            _adaptiveTiming,
            (v) => setState(() => _adaptiveTiming = v),
            Icons.schedule_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
        ],
      ),
    );
  }

  // DND Card
  Widget _buildDNDCard(Color cardBg, Color textColor, Color subtitleColor, Color borderColor, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            "تفعيل عدم الإزعاج",
            "إيقاف جميع الإشعارات في فترة محددة",
            _doNotDisturbMode,
            (v) => setState(() => _doNotDisturbMode = v),
            Icons.do_not_disturb_on_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          if (_doNotDisturbMode) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    "من",
                    _dndStartTime,
                    (t) => setState(() => _dndStartTime = t),
                    primary,
                    textColor,
                    subtitleColor,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSelector(
                    "إلى",
                    _dndEndTime,
                    (t) => setState(() => _dndEndTime = t),
                    primary,
                    textColor,
                    subtitleColor,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, ValueChanged<TimeOfDay> onChanged, Color primary, Color textColor, Color subtitleColor, bool isDark) {
    return InkWell(
      onTap: () => _pickTime(current: time, onPicked: onChanged),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sound Card
  Widget _buildSoundCard(Color cardBg, Color textColor, Color subtitleColor, Color borderColor, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            "تفعيل الصوت",
            "تشغيل صوت مع الإشعارات",
            _soundEnabled,
            (v) => setState(() => _soundEnabled = v),
            Icons.volume_up_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          if (_soundEnabled) ...[
            const SizedBox(height: 16),
            _buildVolumeSlider(primary, textColor, subtitleColor),
          ],
          const Divider(height: 24),
          _buildSwitchTile(
            "تفعيل الاهتزاز",
            "اهتزاز الجهاز عند وصول الإشعار",
            _vibrationEnabled,
            (v) => setState(() => _vibrationEnabled = v),
            Icons.vibration_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          if (_vibrationEnabled) ...[
            const SizedBox(height: 16),
            _buildVibrationPatternSelector(primary, textColor, subtitleColor, isDark),
          ],
          const Divider(height: 24),
          _buildSwitchTile(
            "إضاءة LED",
            "إضاءة LED للإشعارات (إن وجدت)",
            _ledEnabled,
            (v) => setState(() => _ledEnabled = v),
            Icons.lightbulb_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider(Color primary, Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.volume_down_rounded, color: primary, size: 20),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: primary,
                  inactiveTrackColor: primary.withOpacity(0.2),
                  thumbColor: primary,
                  overlayColor: primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: _notificationVolume,
                  onChanged: (v) => setState(() => _notificationVolume = v),
                ),
              ),
            ),
            Icon(Icons.volume_up_rounded, color: primary, size: 20),
          ],
        ),
        Center(
          child: Text(
            "${(_notificationVolume * 100).toInt()}%",
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVibrationPatternSelector(Color primary, Color textColor, Color subtitleColor, bool isDark) {
    final patterns = {
      "default": "عادي",
      "double": "مزدوج",
      "triple": "ثلاثي",
      "long": "طويل",
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _vibrationPattern,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: isDark ? const Color(0xFF2A2A2F) : Colors.white,
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        items: patterns.entries.map((e) {
          return DropdownMenuItem<String>(
            value: e.key,
            child: Text(e.value),
          );
        }).toList(),
        onChanged: (v) => setState(() => _vibrationPattern = v!),
      ),
    );
  }

  // Display Card
  Widget _buildDisplayCard(Color cardBg, Color textColor, Color subtitleColor, Color borderColor, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            "عرض على شاشة القفل",
            "إظهار الإشعارات على شاشة القفل",
            _showOnLockScreen,
            (v) => setState(() => _showOnLockScreen = v),
            Icons.lock_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            "معاينة المحتوى",
            "عرض محتوى الإشعار في المعاينة",
            _showPreview,
            (v) => setState(() => _showPreview = v),
            Icons.preview_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            "عداد الشارة",
            "عرض عدد الإشعارات على أيقونة التطبيق",
            _badgeCount,
            (v) => setState(() => _badgeCount = v),
            Icons.notifications_active_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          const Divider(height: 24),
          _buildDropdownTile(
            "نمط الإشعار",
            "اختيار شكل عرض الإشعار",
            _notificationStyle,
            ["expanded", "compact", "minimal"],
            {"expanded": "موسع", "compact": "مضغوط", "minimal": "بسيط"},
            (v) => setState(() => _notificationStyle = v!),
            Icons.style_rounded,
            primary,
            textColor,
            subtitleColor,
            isDark,
          ),
        ],
      ),
    );
  }

  // Schedule Card
  Widget _buildScheduleCard(Color cardBg, Color textColor, Color subtitleColor, Color borderColor, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "أيام الإشعارات",
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildDaySelector(primary, textColor, isDark),
          const SizedBox(height: 20),
          _buildSwitchTile(
            "الساعات الهادئة",
            "تقليل الإشعارات في أوقات محددة",
            _quietHours,
            (v) => setState(() => _quietHours = v),
            Icons.nightlight_round,
            primary,
            textColor,
            subtitleColor,
          ),
          if (_quietHours) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    "من",
                    _quietStart,
                    (t) => setState(() => _quietStart = t),
                    primary,
                    textColor,
                    subtitleColor,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSelector(
                    "إلى",
                    _quietEnd,
                    (t) => setState(() => _quietEnd = t),
                    primary,
                    textColor,
                    subtitleColor,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _buildSliderTile(
            "الحد الأقصى للإشعارات",
            "عدد الإشعارات المسموح بها يومياً",
            _maxNotificationsPerDay.toDouble(),
            1,
            20,
            (v) => setState(() => _maxNotificationsPerDay = v.toInt()),
            Icons.filter_list_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector(Color primary, Color textColor, bool isDark) {
    final days = ["الأحد", "الإثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (i) {
        final dayNum = i + 1;
        final isSelected = _selectedDays.contains(dayNum);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(dayNum);
              } else {
                _selectedDays.add(dayNum);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primary : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
              ),
            ),
            child: Text(
              days[i],
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : textColor,
              ),
            ),
          ),
        );
      }),
    );
  }

  // Behavior Card
  Widget _buildBehaviorCard(Color cardBg, Color textColor, Color subtitleColor, Color borderColor, Color primary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            "تكرار الإشعار",
            "إعادة إرسال الإشعار إذا لم يتم قراءته",
            _repeatNotification,
            (v) => setState(() => _repeatNotification = v),
            Icons.repeat_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          if (_repeatNotification) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberSelector(
                    "الفترة (دقائق)",
                    _repeatInterval,
                    (v) => setState(() => _repeatInterval = v),
                    1,
                    60,
                    primary,
                    textColor,
                    subtitleColor,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberSelector(
                    "عدد المرات",
                    _repeatCount,
                    (v) => setState(() => _repeatCount = v),
                    1,
                    10,
                    primary,
                    textColor,
                    subtitleColor,
                    isDark,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          _buildSwitchTile(
            "وميض الشاشة",
            "وميض الشاشة عند وصول الإشعار",
            _flashScreen,
            (v) => setState(() => _flashScreen = v),
            Icons.flash_on_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
          const Divider(height: 24),
          _buildSwitchTile(
            "إشعارات حسب الموقع",
            "تخصيص الإشعارات بناءً على موقعك",
            _locationBasedNotifications,
            (v) => setState(() => _locationBasedNotifications = v),
            Icons.location_on_rounded,
            primary,
            textColor,
            subtitleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberSelector(String label, int value, ValueChanged<int> onChanged, int min, int max, Color primary, Color textColor, Color subtitleColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? const Color(0xFF2A2A2F) : Colors.white,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            items: List.generate(max - min + 1, (i) => min + i).map((n) {
              return DropdownMenuItem<int>(
                value: n,
                child: Text("$n"),
              );
            }).toList(),
            onChanged: (v) => onChanged(v!),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
    Color primary,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: primary,
        ),
      ],
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    Map<String, String> labels,
    ValueChanged<String?> onChanged,
    IconData icon,
    Color primary,
    Color textColor,
    Color subtitleColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? const Color(0xFF2A2A2F) : Colors.white,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(labels[option] ?? option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    IconData icon,
    Color primary,
    Color textColor,
    Color subtitleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${value.toInt()} يوم",
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: primary,
            inactiveTrackColor: primary.withOpacity(0.2),
            thumbColor: primary,
            overlayColor: primary.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
