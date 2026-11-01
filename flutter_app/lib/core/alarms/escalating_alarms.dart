import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';

class EscalatingAlarmsService {
  static const int baseId = 100;

  /// Initializes the Alarm subsystem
  static Future<void> init() async {
    await Alarm.init();
  }

  /// Schedules 4 escalating alarms for a given prayer time (IDs 101, 102, 103, 104)
  static Future<void> scheduleEscalation({
    required DateTime prayerTime,
    required String prayerNameAr,
    required String targetHifzVerses,
  }) async {
    final stages = [
      {'id': 101, 'delayMin': 0, 'title': 'تنبيه صلاة $prayerNameAr وورد الحفظ'},
      {'id': 102, 'delayMin': 5, 'title': 'تذكير متصاعد (+5 دقائق): $targetHifzVerses'},
      {'id': 103, 'delayMin': 10, 'title': 'نداء حازم للقيام (+10 دقائق): $targetHifzVerses'},
      {'id': 104, 'delayMin': 15, 'title': 'الإنذار الأقصى! إيقاف عبر إنجاز الحفظ فقط'},
    ];

    for (final stage in stages) {
      final alarmTime = prayerTime.add(Duration(minutes: stage['delayMin'] as int));
      if (alarmTime.isBefore(DateTime.now())) continue;

      final settings = AlarmSettings(
        id: stage['id'] as int,
        dateTime: alarmTime,
        assetAudioPath: 'assets/adhan/adhan.mp3',
        loopAudio: true,
        vibrate: true,
        volume: 1.0,
        fadeDuration: 3.0,
        notificationSettings: NotificationSettings(
          title: stage['title'] as String,
          body: 'شرط الإلغاء: تسميع وإنجاز ورد الحفظ',
          stopButton: 'بدء الحفظ الآن',
          icon: 'ic_launcher',
        ),
      );

      await Alarm.set(alarmSettings: settings);
    }
  }

  /// Dismisses all 4 escalating stages once Hifz loop is verified
  static Future<void> dismissAllStages() async {
    for (int id = 101; id <= 104; id++) {
      await Alarm.stop(id);
    }
  }
}
