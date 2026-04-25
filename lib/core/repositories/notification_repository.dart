import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:al_furkan/core/models/notification_model.dart';

/// Firestore repository for the `/notifications` collection.
class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('notifications');

  /// Logs a sent notification.
  Future<void> logNotification(NotificationLog log) async {
    try {
      await _col.doc(log.id).set(log.toFirestore());
    } catch (e, st) {
      _log('logNotification error: $e', stackTrace: st);
    }
  }

  /// Fetches notification history (paginated, newest first).
  Future<List<NotificationLog>> fetchHistory({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      var query = _col
          .orderBy('sentAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snap = await query.get();
      return snap.docs.map(NotificationLog.fromFirestore).toList();
    } catch (e, st) {
      _log('fetchHistory error: $e', stackTrace: st);
      return [];
    }
  }

  /// Deletes a notification log entry.
  Future<void> deleteLog(String id) async {
    try {
      await _col.doc(id).delete();
    } catch (e, st) {
      _log('deleteLog error: $e', stackTrace: st);
    }
  }

  void _log(String msg, {StackTrace? stackTrace}) =>
      log(msg, name: 'NotificationRepository', stackTrace: stackTrace);
}
