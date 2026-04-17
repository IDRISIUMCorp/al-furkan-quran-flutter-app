import "package:al_furkan/src/core/notifications/khatma_notification_service.dart";
import "package:al_furkan/src/platform_services.dart" as platform_services;

abstract class NotificationScheduler {
  Future<void> initialize();
}

class LocalNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> initialize() async {
    await KhatmaNotificationService.instance.init();

    final platform = platform_services.getPlatform();
    if (platform != platform_services.PlatformOwn.isLinux &&
        platform != platform_services.PlatformOwn.isWindows) {
      await platform_services.initAwesomeNotification();
    }
  }
}
