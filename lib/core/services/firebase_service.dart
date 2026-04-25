import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Centralized Firebase initialization and setup.
class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  bool _initialized = false;

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    log('Handling a background message: ${message.messageId}', name: 'FirebaseService');
  }

  /// Initialize Firebase + FCM + timeago locale.
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();

      // Setup FCM.
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Subscribe to "all" topic for broadcast notifications.
      await messaging.subscribeToTopic('all');

      // Set foreground notification presentation options.
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Got a message whilst in the foreground!', name: 'FirebaseService');
        log('Message data: ${message.data}', name: 'FirebaseService');
        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}', name: 'FirebaseService');
        }
      });

      // Setup Arabic timeago locale.
      timeago.setLocaleMessages('ar', timeago.ArMessages());
      timeago.setDefaultLocale('ar');

      _initialized = true;
      log('✅ FirebaseService initialized', name: 'FirebaseService');
    } catch (e, st) {
      log('❌ FirebaseService init error: $e',
          name: 'FirebaseService', stackTrace: st);
    }
  }

  /// Gets the current FCM token for this device.
  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}
