import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:al_furkan/core/models/update_config.dart';

/// Firestore repository for the `/update_config/current` document.
class UpdateRepository {
  UpdateRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('update_config').doc('current');

  /// Fetches the current update config.
  Future<UpdateConfig> getConfig() async {
    try {
      final snap = await _doc.get();
      if (!snap.exists || snap.data() == null) return const UpdateConfig();
      return UpdateConfig.fromFirestore(snap);
    } catch (e, st) {
      log('getConfig error: $e', name: 'UpdateRepository', stackTrace: st);
      return const UpdateConfig();
    }
  }

  /// Saves the full update config (admin only).
  Future<void> saveConfig(UpdateConfig config) async {
    try {
      await _doc.set(config.toFirestore(), SetOptions(merge: true));
      log('Config saved', name: 'UpdateRepository');
    } catch (e, st) {
      log('saveConfig error: $e', name: 'UpdateRepository', stackTrace: st);
      rethrow;
    }
  }

  /// Streams config changes in real-time (for live preview).
  Stream<UpdateConfig> watchConfig() {
    return _doc.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return const UpdateConfig();
      return UpdateConfig.fromFirestore(snap);
    });
  }
}
