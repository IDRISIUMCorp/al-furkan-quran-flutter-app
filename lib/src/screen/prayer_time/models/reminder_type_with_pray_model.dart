import "package:al_quran_v3/src/screen/prayer_time/models/prayer_enum.dart";
import "package:al_quran_v3/src/screen/prayer_time/models/reminder_type.dart";

class ReminderTypeWithPrayModel {
  final PrayerReminderType reminderType;
  final Prayer prayerTimesType;

  const ReminderTypeWithPrayModel({
    required this.reminderType,
    required this.prayerTimesType,
  });

  // Factory constructor for deserialization
  factory ReminderTypeWithPrayModel.fromJson(Map<String, dynamic> json) {
    return ReminderTypeWithPrayModel(
      reminderType: PrayerReminderType.values.byName(
        json["reminderType"] as String,
      ),
      prayerTimesType: Prayer.values.byName(json["prayerTimesType"] as String),
    );
  }

  // Method for serialization
  Map<String, dynamic> toJson() {
    return {
      "reminderType": reminderType.name,
      "prayerTimesType": prayerTimesType.name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ReminderTypeWithPrayModel &&
        other.reminderType == reminderType &&
        other.prayerTimesType == prayerTimesType;
  }

  @override
  int get hashCode => Object.hash(reminderType, prayerTimesType);
}
