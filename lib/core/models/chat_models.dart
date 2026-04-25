import 'package:cloud_firestore/cloud_firestore.dart';

/// رسالة واحدة في الشات.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.text,
    required this.isAdmin,
    this.imageUrl,
    this.sentAt,
    this.isEdited = false,
    this.isDeleted = false,
    this.originalText,
    this.editedAt,
    this.deletedAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String text;
  final bool isAdmin;
  final String? imageUrl;
  final DateTime? sentAt;

  // ── Edit / Delete support ──
  final bool isEdited;
  final bool isDeleted;
  final String? originalText;
  final DateTime? editedAt;
  final DateTime? deletedAt;

  factory ChatMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ChatMessage(
      id: doc.id,
      senderId: d['senderId'] as String? ?? '',
      senderName: d['senderName'] as String? ?? '',
      senderEmail: d['senderEmail'] as String? ?? '',
      text: d['text'] as String? ?? '',
      isAdmin: d['isAdmin'] as bool? ?? false,
      imageUrl: d['imageUrl'] as String?,
      sentAt: (d['sentAt'] as Timestamp?)?.toDate(),
      isEdited: d['isEdited'] as bool? ?? false,
      isDeleted: d['isDeleted'] as bool? ?? false,
      originalText: d['originalText'] as String?,
      editedAt: (d['editedAt'] as Timestamp?)?.toDate(),
      deletedAt: (d['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'senderName': senderName,
        'senderEmail': senderEmail,
        'text': text,
        'isAdmin': isAdmin,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'sentAt': FieldValue.serverTimestamp(),
        'isEdited': isEdited,
        'isDeleted': isDeleted,
        if (originalText != null) 'originalText': originalText,
      };

  ChatMessage copyWith({
    String? text,
    bool? isEdited,
    bool? isDeleted,
    String? originalText,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderEmail: senderEmail,
      text: text ?? this.text,
      isAdmin: isAdmin,
      imageUrl: imageUrl,
      sentAt: sentAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      originalText: originalText ?? this.originalText,
      editedAt: editedAt,
      deletedAt: deletedAt,
    );
  }
}

/// محادثة كاملة (Thread) لمستخدم واحد.
class ChatThread {
  const ChatThread({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl,
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isClosed = false,
  });

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isClosed;

  factory ChatThread.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ChatThread(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      userName: d['userName'] as String? ?? '',
      userEmail: d['userEmail'] as String? ?? '',
      userPhotoUrl: d['userPhotoUrl'] as String?,
      lastMessage: d['lastMessage'] as String? ?? '',
      lastMessageAt: (d['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: (d['unreadCount'] as num?)?.toInt() ?? 0,
      isClosed: d['isClosed'] as bool? ?? false,
    );
  }
}

/// إعدادات الشات العامة (مفتوح / مغلق / مغلق بمؤقت).
enum ChatAvailability { open, closedManual, closedTimed }

class ChatSettings {
  const ChatSettings({
    this.availability = ChatAvailability.open,
    this.reopenAt,
  });

  final ChatAvailability availability;
  final DateTime? reopenAt;

  bool get isOpen {
    if (availability == ChatAvailability.open) return true;
    if (availability == ChatAvailability.closedTimed && reopenAt != null) {
      return DateTime.now().isAfter(reopenAt!);
    }
    return false;
  }

  factory ChatSettings.fromFirestore(Map<String, dynamic>? d) {
    if (d == null) return const ChatSettings();
    final avStr = d['availability'] as String? ?? 'open';
    final av = ChatAvailability.values.firstWhere(
      (e) => e.name == avStr,
      orElse: () => ChatAvailability.open,
    );
    final reopen = (d['reopenAt'] as Timestamp?)?.toDate();
    return ChatSettings(availability: av, reopenAt: reopen);
  }

  Map<String, dynamic> toFirestore() => {
        'availability': availability.name,
        if (reopenAt != null) 'reopenAt': Timestamp.fromDate(reopenAt!),
      };
}

/// حالة تواجد الأدمن (أونلاين/أوفلاين).
class AdminPresence {
  const AdminPresence({
    this.isOnline = false,
    this.lastSeen,
    this.statusMessage,
  });

  final bool isOnline;
  final DateTime? lastSeen;
  final String? statusMessage;

  factory AdminPresence.fromFirestore(Map<String, dynamic>? d) {
    if (d == null) return const AdminPresence();
    return AdminPresence(
      isOnline: d['isOnline'] as bool? ?? false,
      lastSeen: (d['lastSeen'] as Timestamp?)?.toDate(),
      statusMessage: d['statusMessage'] as String?,
    );
  }
}
