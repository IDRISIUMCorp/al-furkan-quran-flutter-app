import 'package:flutter/material.dart';
import '../core/theme/zen_theme.dart';
import '../core/alarms/escalating_alarms.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  final List<Map<String, dynamic>> _prayers = [
    {
      'nameAr': 'الفجر',
      'nameEn': 'Fajr',
      'time': '05:12',
      'target': 'سورة البقرة • الآيات (1-5) [حفظ جديد]',
      'enabled': true,
    },
    {
      'nameAr': 'الظهر',
      'nameEn': 'Dhuhr',
      'time': '12:28',
      'target': 'سورة البقرة • مراجعة ورد الصباح',
      'enabled': false,
    },
    {
      'nameAr': 'العصر',
      'nameEn': 'Asr',
      'time': '15:35',
      'target': 'سورة البقرة • الآيات (6-10) [ربط وتثبيت]',
      'enabled': true,
    },
    {
      'nameAr': 'المغرب',
      'nameEn': 'Maghrib',
      'time': '18:15',
      'target': 'أذكار المساء وسماع تلاوة قالون',
      'enabled': false,
    },
    {
      'nameAr': 'العشاء',
      'nameEn': 'Isha',
      'time': '19:42',
      'target': 'مراجعة الثمن الكامل قبل النوم',
      'enabled': true,
    },
  ];

  void _triggerTestAlarm(Map<String, dynamic> prayer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('منبه ${prayer['nameAr']} المتصاعد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('المرحلة 1 من 4 (معرف 101 - طريقة تونس 18°)'),
            const SizedBox(height: 8),
            Text(
              'شرط الإيقاف: ${prayer['target']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('غفوة 5 دقائق'),
          ),
          ElevatedButton(
            onPressed: () {
              EscalatingAlarmsService.dismissAllStages();
              Navigator.pop(ctx);
            },
            child: const Text('إنجاز الحفظ وإلغاء الرنين'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ZenTheme.darkAmberText : ZenTheme.lightText;
    final sageColor = isDark ? ZenTheme.darkSage : ZenTheme.lightSage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول الصلوات والمنبهات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Text(
              'توقيت تونس (زاوية الفجر 18° • زاوية العشاء 18°)',
              style: TextStyle(fontSize: 12, color: sageColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ..._prayers.map((prayer) {
            final enabled = prayer['enabled'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? ZenTheme.darkSurface : ZenTheme.lightSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: enabled ? sageColor.withValues(alpha: 0.4) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: enabled ? sageColor : Colors.grey.withValues(alpha: 0.2),
                    child: Text(
                      prayer['nameAr'] as String,
                      style: TextStyle(
                        color: enabled ? Colors.white : textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayer['time'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          prayer['target'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (enabled)
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20),
                      onPressed: () => _triggerTestAlarm(prayer),
                      tooltip: 'تجربة الرنين',
                    ),
                  Switch(
                    value: enabled,
                    activeColor: sageColor,
                    onChanged: (val) {
                      setState(() {
                        prayer['enabled'] = val;
                      });
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
