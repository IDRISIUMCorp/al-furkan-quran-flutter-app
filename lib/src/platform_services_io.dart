import "dart:io";

import "package:al_furkan/src/core/notifications/wahy_notification_service.dart";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import "package:window_manager/window_manager.dart";

void hideLoadingIndicator() {
  // no-op
}

Future<void> initAwesomeNotification() async {
  await WahyNotificationService.instance.init();
  await WahyNotificationService.instance.restoreScheduledNotifications();
}

Future<void> initializePlatform() async {
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      title: "الفُرقان",
      minimumSize: Size(400, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

Future<String?> getApplicationDataPath() async {
  Directory? directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    directory = await getDownloadsDirectory();
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
  return directory?.path;
}

enum PlatformOwn {
  isIos,
  isAndroid,
  isLinux,
  isMac,
  isWeb,
  isWasm,
  isWindows,
  isFuchsia,
  unknown,
}

PlatformOwn getPlatform() {
  if (Platform.isAndroid) {
    return PlatformOwn.isAndroid;
  } else if (Platform.isIOS) {
    return PlatformOwn.isIos;
  } else if (Platform.isLinux) {
    return PlatformOwn.isLinux;
  } else if (Platform.isMacOS) {
    return PlatformOwn.isMac;
  } else if (Platform.isWindows) {
    return PlatformOwn.isWindows;
  } else if (Platform.isFuchsia) {
    return PlatformOwn.isFuchsia;
  } else {
    return PlatformOwn.unknown;
  }
}
