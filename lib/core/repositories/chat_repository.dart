import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:al_furkan/core/models/chat_models.dart';

/// Repository for support chat operations.
class ChatRepository {
  ChatRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _threadsCol =>
      _db.collection('support_chat');

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _db.collection('app_config').doc('chat_settings');

  DocumentReference<Map<String, dynamic>> get _presenceDoc =>
      _db.collection('app_config').doc('admin_presence');

  // ── Settings ────────────────────────────────────────────

  Stream<ChatSettings> watchSettings() {
    return _settingsDoc.snapshots().map(
          (snap) => ChatSettings.fromFirestore(snap.data()),
        );
  }

  Future<ChatSettings> getSettings() async {
    final snap = await _settingsDoc.get();
    return ChatSettings.fromFirestore(snap.data());
  }

  Future<void> updateSettings(ChatSettings settings) async {
    await _settingsDoc.set(settings.toFirestore(), SetOptions(merge: true));
  }

  // ── Admin Presence ──────────────────────────────────────

  Future<void> setAdminOnline({String? statusMessage}) async {
    await _presenceDoc.set({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'statusMessage': ?statusMessage,
    }, SetOptions(merge: true));
  }

  Future<void> setAdminOffline() async {
    await _presenceDoc.set({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<AdminPresence> watchAdminPresence() {
    return _presenceDoc.snapshots().map((snap) {
      return AdminPresence.fromFirestore(snap.data());
    });
  }

  // ── Threads ─────────────────────────────────────────────

  Stream<List<ChatThread>> watchThreads() {
    return _threadsCol
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatThread.fromFirestore(d)).toList());
  }

  Future<void> createOrUpdateThread({
    required String userId,
    required String userName,
    required String userEmail,
    required String lastMessage,
    String? userPhotoUrl,
  }) async {
    await _threadsCol.doc(userId).set({
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhotoUrl': ?userPhotoUrl,
      'lastMessage': lastMessage,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
      'isClosed': false,
    }, SetOptions(merge: true));
  }

  Future<void> markThreadRead(String threadId) async {
    await _threadsCol.doc(threadId).update({'unreadCount': 0});
  }

  Future<void> closeThread(String threadId) async {
    await _threadsCol.doc(threadId).update({'isClosed': true});
  }

  // ── Messages ────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _messagesCol(String threadId) =>
      _threadsCol.doc(threadId).collection('messages');

  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return _messagesCol(threadId)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromFirestore(d)).toList());
  }

  Future<void> sendMessage({
    required String threadId,
    required ChatMessage message,
  }) async {
    await _messagesCol(threadId).add(message.toFirestore());

    // Update thread metadata.
    final isAdmin = message.isAdmin;
    await _threadsCol.doc(threadId).update({
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      if (!isAdmin) 'unreadCount': FieldValue.increment(1),
    });
  }

  // ── Edit Message ────────────────────────────────────────

  Future<void> editMessage({
    required String threadId,
    required String messageId,
    required String newText,
    required String originalText,
  }) async {
    await _messagesCol(threadId).doc(messageId).update({
      'text': newText,
      'isEdited': true,
      'originalText': originalText,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Delete Message (soft delete) ────────────────────────

  Future<void> deleteMessage({
    required String threadId,
    required String messageId,
  }) async {
    await _messagesCol(threadId).doc(messageId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── User Profile ────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> userProfileDoc(String uid) =>
      _db.collection('user_profiles').doc(uid);

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final doc = userProfileDoc(uid);
    final snap = await doc.get();

    final data = <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': ?photoUrl,
      'lastOpenedAt': FieldValue.serverTimestamp(),
    };

    // Only set installedAt on first creation.
    if (!snap.exists) {
      data['installedAt'] = FieldValue.serverTimestamp();
      data['usageTimeSeconds'] = 0;
      data['currentPage'] = 1;
      data['khatmaCount'] = 0;
    }

    await doc.set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snap = await userProfileDoc(uid).get();
    return snap.data();
  }

  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return userProfileDoc(uid).snapshots().map((snap) => snap.data());
  }
}
