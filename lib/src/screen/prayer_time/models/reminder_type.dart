import "package:al_furkan/l10n/app_localizations.dart";
import "package:flutter/material.dart";

enum PrayerReminderType { notification, alarm }

String localizedReminderName(BuildContext context, PrayerReminderType type) {
  switch (type) {
    case PrayerReminderType.alarm:
      return AppLocalizations.of(context).alarm;
    case PrayerReminderType.notification:
      return AppLocalizations.of(context).notification;
  }
}
