import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:al_furkan/core/models/content_post.dart';

/// Firestore repository for the `/content_feed` collection.
///
/// Handles all CRUD operations, pagination, filtering, and
/// atomic counter increments for content posts.
class ContentRepository {
  ContentRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Reference to the content_feed collection.
  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('content_feed');

  // ─────────────────────────────────────────────────────────
  // READ — paginated feed
  // ─────────────────────────────────────────────────────────

  /// Fetches the first page of active, non-expired posts.
  ///
  /// Returns pinned posts first, then sorts by [publishedAt] descending.
  /// [limit] defaults to 10 posts per page.
  /// [category] optionally filters by a specific category.
  Future<ContentFeedPage> fetchFeed({
    int limit = 10,
    ContentCategory? category,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .where('isActive', isEqualTo: true)
          .orderBy('isPinned', descending: true)
          .orderBy('publishedAt', descending: true)
          .limit(limit);

      if (category != null && category != ContentCategory.general) {
        query = _collection
            .where('isActive', isEqualTo: true)
            .where('category', isEqualTo: category.name)
            .orderBy('isPinned', descending: true)
            .orderBy('publishedAt', descending: true)
            .limit(limit);
      }

      final snapshot = await query.get();
      final posts = snapshot.docs
          .map(ContentPost.fromFirestore)
          .where((p) => !p.isExpired)
          .toList();

      return ContentFeedPage(
        posts: posts,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == limit,
      );
    } catch (e, st) {
      log('fetchFeed error: $e', name: 'ContentRepository', stackTrace: st);
      rethrow;
    }
  }

  /// Fetches the next page after [lastDocument].
  Future<ContentFeedPage> fetchMoreFeed({
    required DocumentSnapshot lastDocument,
    int limit = 10,
    ContentCategory? category,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .where('isActive', isEqualTo: true)
          .orderBy('isPinned', descending: true)
          .orderBy('publishedAt', descending: true)
          .startAfterDocument(lastDocument)
          .limit(limit);

      if (category != null && category != ContentCategory.general) {
        query = _collection
            .where('isActive', isEqualTo: true)
            .where('category', isEqualTo: category.name)
            .orderBy('isPinned', descending: true)
            .orderBy('publishedAt', descending: true)
            .startAfterDocument(lastDocument)
            .limit(limit);
      }

      final snapshot = await query.get();
      final posts = snapshot.docs
          .map(ContentPost.fromFirestore)
          .where((p) => !p.isExpired)
          .toList();

      return ContentFeedPage(
        posts: posts,
        lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
        hasMore: snapshot.docs.length == limit,
      );
    } catch (e, st) {
      log('fetchMoreFeed error: $e',
          name: 'ContentRepository', stackTrace: st);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────
  // READ — single post
  // ─────────────────────────────────────────────────────────

  /// Fetches a single post by ID.
  Future<ContentPost?> getPost(String postId) async {
    final doc = await _collection.doc(postId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ContentPost.fromFirestore(doc);
  }

  // ─────────────────────────────────────────────────────────
  // READ — admin: all posts (including inactive)
  // ─────────────────────────────────────────────────────────

  /// Fetches all posts for the admin panel (no isActive filter).
  Future<ContentFeedPage> fetchAdminFeed({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final posts = snapshot.docs.map(ContentPost.fromFirestore).toList();

    return ContentFeedPage(
      posts: posts,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == limit,
    );
  }

  // ─────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────

  /// Creates a new post. Returns the generated document ID.
  Future<String> createPost(ContentPost post) async {
    try {
      final docRef = await _collection.add(post.toFirestore());
      log('Post created: ${docRef.id}', name: 'ContentRepository');
      return docRef.id;
    } catch (e, st) {
      log('createPost error: $e', name: 'ContentRepository', stackTrace: st);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────

  /// Updates specific fields of a post (partial update).
  Future<void> updatePost(
    String postId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _collection.doc(postId).update(updates);
      log('Post updated: $postId', name: 'ContentRepository');
    } catch (e, st) {
      log('updatePost error: $e', name: 'ContentRepository', stackTrace: st);
      rethrow;
    }
  }

  /// Toggles the pinned status of a post.
  Future<void> togglePin(String postId, bool isPinned) =>
      updatePost(postId, {'isPinned': isPinned});

  /// Toggles the active status (soft delete / restore).
  Future<void> toggleActive(String postId, bool isActive) =>
      updatePost(postId, {'isActive': isActive});

  // ─────────────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────────────

  /// Permanently deletes a post from Firestore.
  Future<void> deletePost(String postId) async {
    try {
      await _collection.doc(postId).delete();
      log('Post deleted: $postId', name: 'ContentRepository');
    } catch (e, st) {
      log('deletePost error: $e', name: 'ContentRepository', stackTrace: st);
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────
  // COUNTERS — atomic increments
  // ─────────────────────────────────────────────────────────

  /// Atomically increments the view count by 1.
  Future<void> incrementViews(String postId) =>
      _collection.doc(postId).update({
        'viewCount': FieldValue.increment(1),
      });

  /// Atomically increments the like count by [delta] (±1).
  Future<void> incrementLikes(String postId, {int delta = 1}) =>
      _collection.doc(postId).update({
        'likeCount': FieldValue.increment(delta),
      });

  /// Atomically increments the share count by 1.
  Future<void> incrementShares(String postId) =>
      _collection.doc(postId).update({
        'shareCount': FieldValue.increment(1),
      });

  // ─────────────────────────────────────────────────────────
  // SEARCH — local filter on loaded posts
  // ─────────────────────────────────────────────────────────

  /// Filters a list of posts by a search query (title + body + tags).
  List<ContentPost> searchLocally(
    List<ContentPost> posts,
    String query,
  ) {
    if (query.isEmpty) return posts;
    final q = query.toLowerCase();
    return posts.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.body.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  // ─────────────────────────────────────────────────────────
  // REAL-TIME STREAM (optional)
  // ─────────────────────────────────────────────────────────

  /// Streams active posts in real-time (for admin live view).
  Stream<List<ContentPost>> watchFeed({int limit = 20}) {
    return _collection
        .where('isActive', isEqualTo: true)
        .orderBy('isPinned', descending: true)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map(ContentPost.fromFirestore)
            .where((p) => !p.isExpired)
            .toList());
  }
}

// ─────────────────────────────────────────────────────────────
// PAGINATION HELPER
// ─────────────────────────────────────────────────────────────

/// Wraps a page of content posts with pagination metadata.
class ContentFeedPage {
  const ContentFeedPage({
    required this.posts,
    this.lastDocument,
    this.hasMore = false,
  });

  /// The posts in this page.
  final List<ContentPost> posts;

  /// Cursor for the next page (pass to [fetchMoreFeed]).
  final DocumentSnapshot? lastDocument;

  /// Whether there might be more pages available.
  final bool hasMore;
}
