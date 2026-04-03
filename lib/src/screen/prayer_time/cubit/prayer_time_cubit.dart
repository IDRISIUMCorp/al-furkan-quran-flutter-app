import "package:al_quran_v3/src/core/settings/settings_repository.dart";
import "package:al_quran_v3/src/screen/prayer_time/models/prayer_enum.dart";
import "package:al_quran_v3/src/screen/prayer_time/cubit/prayer_time_state.dart";
import "package:al_quran_v3/src/screen/prayer_time/models/reminder_type.dart";
import "package:al_quran_v3/src/screen/prayer_time/models/reminder_type_with_pray_model.dart";
import "package:bloc/bloc.dart";

class PrayerReminderCubit extends Cubit<PrayerReminderState> {
  PrayerReminderCubit(this._settingsRepository)
    : super(_settingsRepository.loadPrayerReminderState());

  final SettingsRepository _settingsRepository;

  Future<void> addPrayerToRemember(ReminderTypeWithPrayModel prayer) async {
    final list = List<ReminderTypeWithPrayModel>.from(state.prayerToRemember)
      ..removeWhere((item) => item.prayerTimesType == prayer.prayerTimesType)
      ..add(prayer);
    await _saveAndEmit(state.copyWith(prayerToRemember: list));
  }

  Future<void> removePrayerToRemember(ReminderTypeWithPrayModel prayer) async {
    final list = List<ReminderTypeWithPrayModel>.from(state.prayerToRemember)
      ..remove(prayer);
    await _saveAndEmit(state.copyWith(prayerToRemember: list));
  }

  Future<void> setReminderMode(ReminderTypeWithPrayModel data) async {
    final modes = Map<Prayer, PrayerReminderType>.from(
      state.previousReminderModes,
    );
    modes[data.prayerTimesType] = data.reminderType;

    final reminders =
        List<ReminderTypeWithPrayModel>.from(state.prayerToRemember)
          ..removeWhere((item) => item.prayerTimesType == data.prayerTimesType)
          ..add(data);

    await _saveAndEmit(
      state.copyWith(previousReminderModes: modes, prayerToRemember: reminders),
    );
  }

  Future<void> setReminderTimeAdjustment(
    Prayer prayerType,
    int timeInMinutes,
  ) async {
    final adjustment = Map<Prayer, int>.from(state.reminderTimeAdjustment)
      ..[prayerType] = timeInMinutes;
    await _saveAndEmit(state.copyWith(reminderTimeAdjustment: adjustment));
  }

  void setUIReminderTimeAdjustment(Prayer prayerType, int timeInMinutes) {
    final adjustment = Map<Prayer, int>.from(state.reminderTimeAdjustment)
      ..[prayerType] = timeInMinutes;
    emit(state.copyWith(reminderTimeAdjustment: adjustment));
  }

  Future<void> setReminderEnforceSound(bool value) async {
    await _saveAndEmit(state.copyWith(enforceAlarmSound: value));
  }

  Future<void> setReminderSoundVolume(double value) async {
    await _saveAndEmit(state.copyWith(soundVolume: value));
  }

  Future<void> _saveAndEmit(PrayerReminderState newState) async {
    emit(newState);
    await _settingsRepository.savePrayerReminderState(newState);
  }
}
