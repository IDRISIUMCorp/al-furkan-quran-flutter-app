import "package:flutter/foundation.dart";
import "package:al_furkan/src/screen/prayer_time/models/prayer_enum.dart";
import "package:al_furkan/src/screen/prayer_time/models/reminder_type.dart";
import "package:al_furkan/src/screen/prayer_time/models/reminder_type_with_pray_model.dart";

@immutable
class PrayerReminderState {
  final List<ReminderTypeWithPrayModel> prayerToRemember;
  final Map<Prayer, PrayerReminderType> previousReminderModes;
  final Map<Prayer, int> reminderTimeAdjustment;
  final bool enforceAlarmSound;
  final double soundVolume;

  PrayerReminderState({
    List<ReminderTypeWithPrayModel> prayerToRemember = const [],
    Map<Prayer, PrayerReminderType> previousReminderModes = const {},
    Map<Prayer, int> reminderTimeAdjustment = const {},
    this.enforceAlarmSound = false,
    this.soundVolume = 1.0,
  }) : prayerToRemember = List.unmodifiable(prayerToRemember),
       previousReminderModes = Map.unmodifiable(previousReminderModes),
       reminderTimeAdjustment = Map.unmodifiable(reminderTimeAdjustment);

  PrayerReminderState copyWith({
    List<ReminderTypeWithPrayModel>? prayerToRemember,
    Map<Prayer, PrayerReminderType>? previousReminderModes,
    Map<Prayer, int>? reminderTimeAdjustment,
    bool? enforceAlarmSound,
    double? soundVolume,
  }) {
    return PrayerReminderState(
      prayerToRemember: prayerToRemember ?? this.prayerToRemember,
      previousReminderModes:
          previousReminderModes ?? this.previousReminderModes,
      reminderTimeAdjustment:
          reminderTimeAdjustment ?? this.reminderTimeAdjustment,
      enforceAlarmSound: enforceAlarmSound ?? this.enforceAlarmSound,
      soundVolume: soundVolume ?? this.soundVolume,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PrayerReminderState &&
        listEquals(other.prayerToRemember, prayerToRemember) &&
        mapEquals(other.previousReminderModes, previousReminderModes) &&
        mapEquals(other.reminderTimeAdjustment, reminderTimeAdjustment) &&
        other.enforceAlarmSound == enforceAlarmSound &&
        other.soundVolume == soundVolume;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(prayerToRemember),
      Object.hashAll(previousReminderModes.entries),
      Object.hashAll(reminderTimeAdjustment.entries),
      enforceAlarmSound,
      soundVolume,
    );
  }
}
