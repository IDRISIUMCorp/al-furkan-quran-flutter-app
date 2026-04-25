import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

import 'package:al_furkan/core/models/notification_model.dart';
import 'package:al_furkan/core/repositories/notification_repository.dart';
import 'package:al_furkan/core/constants/service_account_key.dart';

/// Service for sending push notifications via FCM HTTP v1 API.
class FcmService {
  FcmService({
    NotificationRepository? repository,
  }) : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  static const _projectId = 'al-furkan-app';
  static const _fcmUrl = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  Future<String?> _getAccessToken() async {
    try {
      final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
      final authClient = await clientViaServiceAccount(accountCredentials, _scopes);
      final token = authClient.credentials.accessToken.data;
      authClient.close();
      return token;
    } catch (e) {
      log('Error getting access token: $e', name: 'FcmService');
      return null;
    }
  }

  /// Sends a notification to all users (topic: "all") and logs it to Firestore.
  Future<bool> sendToAll({
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    return _send(
      target: 'all',
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      audience: NotificationAudience.all,
      isTopic: true,
    );
  }

  /// Sends to a specific topic.
  Future<bool> sendToTopic({
    required String topic,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    return _send(
      target: topic,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      audience: NotificationAudience.topic,
      isTopic: true,
    );
  }

  /// Sends to a specific device token.
  Future<bool> sendToDevice({
    required String token,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
  }) async {
    return _send(
      target: token,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      audience: NotificationAudience.individual,
      isTopic: false,
    );
  }

  Future<bool> _send({
    required String target,
    required String title,
    required String body,
    String? imageUrl,
    Map<String, String>? data,
    required NotificationAudience audience,
    required bool isTopic,
  }) async {
    try {
      final token = await _getAccessToken();
      if (token == null) return false;

      final message = <String, dynamic>{
        if (isTopic) 'topic': target else 'token': target,
        'notification': {
          'title': title,
          'body': body,
          if (imageUrl != null && imageUrl.isNotEmpty) 'image': imageUrl,
        },
        if (data != null && data.isNotEmpty) 'data': data,
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': 'alfurkan_updates',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'sound': 'default',
          },
        },
      };

      final payload = {'message': message};

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      final success = response.statusCode == 200;

      if (!success) {
        log('FCM Error Response: ${response.body}', name: 'FcmService');
      }

      // Log to Firestore.
      final logEntry = NotificationLog.create(
        title: title,
        body: body,
        imageUrl: imageUrl ?? '',
        audience: audience,
        topicOrToken: target,
        data: data ?? {},
        sentCount: success ? 1 : 0, 
        failedCount: success ? 0 : 1,
      );

      await _repository.logNotification(logEntry);

      log(
        'FCM v1 ${success ? "✅" : "❌"}: $title → $target',
        name: 'FcmService',
      );

      return success;
    } catch (e, st) {
      log('FCM send error: $e', name: 'FcmService', stackTrace: st);
      return false;
    }
  }
}

