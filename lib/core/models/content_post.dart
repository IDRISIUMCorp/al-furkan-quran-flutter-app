import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────

/// The visual type of a content post (determines which card widget to use).
enum ContentType {
  video,
  image,
  text,
  link,
  youtube,
  tiktok,
  instagram,
  tweet,
  reel;

  /// Whether this type has an associated media thumbnail.
  bool get hasThumbnail => switch (this) {
        ContentType.text => false,
        _ => true,
      };

  /// Whether this type is a social-media video type.
  bool get isSocialVideo => switch (this) {
        ContentType.youtube ||
        ContentType.tiktok ||
        ContentType.instagram ||
        ContentType.reel =>
          true,
        _ => false,
      };

  /// Platform badge label (e.g. "YouTube", "TikTok").
  String get platformLabel => switch (this) {
        ContentType.youtube => 'YouTube',
        ContentType.tiktok => 'TikTok',
        ContentType.instagram => 'Instagram',
        ContentType.tweet => 'X / Twitter',
        ContentType.reel => 'Reels',
        _ => '',
      };
}

/// Content category used for filtering.
enum ContentCategory {
  tilawa('تلاوة'),
  tafsir('تفسير'),
  fiqh('فقه'),
  duaa('دعاء'),
  mawa3iz('مواعظ'),
  general('عام');

  const ContentCategory(this.arabicLabel);

  /// Arabic UI label.
  final String arabicLabel;

  /// Parse from Firestore string (case-insensitive, Arabic-safe).
  static ContentCategory fromString(String? value) {
    if (value == null || value.isEmpty) return ContentCategory.general;

    // Try matching by name first.
    for (final cat in ContentCategory.values) {
      if (cat.name == value) return cat;
    }

    // Try matching by Arabic label.
    for (final cat in ContentCategory.values) {
      if (cat.arabicLabel == value) return cat;
    }

    return ContentCategory.general;
  }
}

/// Platform that originally hosted the media.
enum ContentPlatform {
  youtube,
  tiktok,
  instagram,
  facebook,
  twitter,
  custom,
  none;

  static ContentPlatform fromString(String? value) {
    if (value == null || value.isEmpty) return ContentPlatform.none;
    for (final p in ContentPlatform.values) {
      if (p.name == value) return p;
    }
    return ContentPlatform.none;
  }
}

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

/// Represents a single post in the `/content_feed` Firestore collection.
///
/// Immutable data class with factory constructors for Firestore
/// serialization / deserialization.
class ContentPost {
  const ContentPost({
    required this.id,
    required this.type,
    this.title = '',
    this.body = '',
    this.mediaUrl = '',
    this.thumbnailUrl = '',
    this.platform = ContentPlatform.none,
    this.platformVideoId = '',
    this.duration = '',
    this.authorName = '',
    this.tags = const [],
    this.category = ContentCategory.general,
    this.isActive = true,
    this.isPinned = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.createdAt,
    this.publishedAt,
    this.expiresAt,
    this.publishedBy = '',
  });

  // ── Fields ──────────────────────────────────────────────────

  /// Firestore document ID.
  final String id;

  /// The visual type of this post.
  final ContentType type;

  /// Optional title shown above the body.
  final String title;

  /// Body text — supports Markdown.
  final String body;

  /// Original media URL (video link, image URL, etc.).
  final String mediaUrl;

  /// Preview image URL (auto-generated for YouTube, oEmbed, etc.).
  final String thumbnailUrl;

  /// The hosting platform (YouTube, TikTok, etc.).
  final ContentPlatform platform;

  /// Platform-specific video/content ID.
  final String platformVideoId;

  /// Human-readable duration string (e.g. "12:34").
  final String duration;

  /// The original author / channel name.
  final String authorName;

  /// Searchable tags.
  final List<String> tags;

  /// Content category for filtering.
  final ContentCategory category;

  /// Whether this post is visible to users.
  final bool isActive;

  /// Pinned posts appear at the top of the feed.
  final bool isPinned;

  /// Interaction counters (atomically incremented via FieldValue).
  final int viewCount;
  final int likeCount;
  final int shareCount;

  /// Timestamps.
  final DateTime? createdAt;
  final DateTime? publishedAt;
  final DateTime? expiresAt;

  /// UID of the admin who published this post.
  final String publishedBy;

  // ── Firestore Serialization ─────────────────────────────────

  /// Create a [ContentPost] from a Firestore [DocumentSnapshot].
  factory ContentPost.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ContentPost(
      id: doc.id,
      type: _parseContentType(data['type']),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      platform: ContentPlatform.fromString(data['platform'] as String?),
      platformVideoId: data['platformVideoId'] as String? ?? '',
      duration: data['duration'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      tags: _parseStringList(data['tags']),
      category: ContentCategory.fromString(data['category'] as String?),
      isActive: data['isActive'] as bool? ?? true,
      isPinned: data['isPinned'] as bool? ?? false,
      viewCount: (data['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (data['likeCount'] as num?)?.toInt() ?? 0,
      shareCount: (data['shareCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseTimestamp(data['createdAt']),
      publishedAt: _parseTimestamp(data['publishedAt']),
      expiresAt: _parseTimestamp(data['expiresAt']),
      publishedBy: data['publishedBy'] as String? ?? '',
    );
  }

  /// Convert to a Firestore-ready map (for creating / updating documents).
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'title': title,
      'body': body,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'platform': platform.name,
      'platformVideoId': platformVideoId,
      'duration': duration,
      'authorName': authorName,
      'tags': tags,
      'category': category.name,
      'isActive': isActive,
      'isPinned': isPinned,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'shareCount': shareCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'publishedAt': publishedAt != null
          ? Timestamp.fromDate(publishedAt!)
          : FieldValue.serverTimestamp(),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'publishedBy': publishedBy,
    };
  }

  /// Produces a map of **only** the provided overrides — used for
  /// partial updates with `FirebaseFirestore.instance.doc(...).update(...)`.
  Map<String, dynamic> toUpdateMap({
    String? title,
    String? body,
    String? mediaUrl,
    String? thumbnailUrl,
    ContentPlatform? platform,
    String? platformVideoId,
    String? duration,
    String? authorName,
    List<String>? tags,
    ContentCategory? category,
    bool? isActive,
    bool? isPinned,
    DateTime? expiresAt,
    bool clearExpiry = false,
  }) {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (body != null) map['body'] = body;
    if (mediaUrl != null) map['mediaUrl'] = mediaUrl;
    if (thumbnailUrl != null) map['thumbnailUrl'] = thumbnailUrl;
    if (platform != null) map['platform'] = platform.name;
    if (platformVideoId != null) map['platformVideoId'] = platformVideoId;
    if (duration != null) map['duration'] = duration;
    if (authorName != null) map['authorName'] = authorName;
    if (tags != null) map['tags'] = tags;
    if (category != null) map['category'] = category.name;
    if (isActive != null) map['isActive'] = isActive;
    if (isPinned != null) map['isPinned'] = isPinned;
    if (expiresAt != null) {
      map['expiresAt'] = Timestamp.fromDate(expiresAt);
    } else if (clearExpiry) {
      map['expiresAt'] = FieldValue.delete();
    }
    return map;
  }

  // ── Convenience Constructors ────────────────────────────────

  /// Creates a new post ready for publishing (server timestamps applied).
  factory ContentPost.create({
    required ContentType type,
    required String publishedBy,
    String title = '',
    String body = '',
    String mediaUrl = '',
    String thumbnailUrl = '',
    ContentPlatform platform = ContentPlatform.none,
    String platformVideoId = '',
    String duration = '',
    String authorName = '',
    List<String> tags = const [],
    ContentCategory category = ContentCategory.general,
    bool isPinned = false,
    DateTime? expiresAt,
  }) {
    return ContentPost(
      id: '', // Firestore will assign
      type: type,
      title: title,
      body: body,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      platform: platform,
      platformVideoId: platformVideoId,
      duration: duration,
      authorName: authorName,
      tags: tags,
      category: category,
      isPinned: isPinned,
      expiresAt: expiresAt,
      publishedBy: publishedBy,
    );
  }

  // ── CopyWith ────────────────────────────────────────────────

  ContentPost copyWith({
    String? id,
    ContentType? type,
    String? title,
    String? body,
    String? mediaUrl,
    String? thumbnailUrl,
    ContentPlatform? platform,
    String? platformVideoId,
    String? duration,
    String? authorName,
    List<String>? tags,
    ContentCategory? category,
    bool? isActive,
    bool? isPinned,
    int? viewCount,
    int? likeCount,
    int? shareCount,
    DateTime? createdAt,
    DateTime? publishedAt,
    DateTime? expiresAt,
    String? publishedBy,
  }) {
    return ContentPost(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      platform: platform ?? this.platform,
      platformVideoId: platformVideoId ?? this.platformVideoId,
      duration: duration ?? this.duration,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isPinned: isPinned ?? this.isPinned,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      publishedBy: publishedBy ?? this.publishedBy,
    );
  }

  // ── Computed Properties ─────────────────────────────────────

  /// Whether this post has expired.
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Whether this post should be visible to users.
  bool get isVisible => isActive && !isExpired;

  /// Whether this post has a non-empty title.
  bool get hasTitle => title.isNotEmpty;

  /// Whether this post has body text.
  bool get hasBody => body.isNotEmpty;

  /// Whether this post has an associated media URL.
  bool get hasMedia => mediaUrl.isNotEmpty;

  /// Whether this post has a thumbnail.
  bool get hasThumbnail => thumbnailUrl.isNotEmpty;

  /// Simple engagement score (for sorting content performance).
  double get engagementScore {
    if (viewCount == 0) return 0;
    return ((likeCount + shareCount * 2) / viewCount) * 100;
  }

  // ── Private Helpers ─────────────────────────────────────────

  static ContentType _parseContentType(dynamic value) {
    if (value is! String) return ContentType.text;
    for (final t in ContentType.values) {
      if (t.name == value) return t;
    }
    return ContentType.text;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // ── Equality & Debug ────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentPost &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ContentPost(id: $id, type: ${type.name}, title: "$title", '
      'pinned: $isPinned, views: $viewCount)';
}
