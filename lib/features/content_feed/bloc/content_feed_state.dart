import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:al_furkan/core/models/content_post.dart';

/// States for the Content Feed BLoC.
sealed class ContentFeedState {
  const ContentFeedState();
}

/// Initial state before any data is loaded.
final class ContentFeedInitial extends ContentFeedState {
  const ContentFeedInitial();
}

/// Feed is loading for the first time.
final class ContentFeedLoading extends ContentFeedState {
  const ContentFeedLoading();
}

/// Feed loaded successfully.
final class ContentFeedLoaded extends ContentFeedState {
  const ContentFeedLoaded({
    required this.posts,
    this.lastDocument,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.activeCategory,
    this.likedPostIds = const {},
  });

  final List<ContentPost> posts;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final bool isLoadingMore;
  final ContentCategory? activeCategory;
  final Set<String> likedPostIds;

  ContentFeedLoaded copyWith({
    List<ContentPost>? posts,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
    bool? isLoadingMore,
    ContentCategory? activeCategory,
    bool clearCategory = false,
    Set<String>? likedPostIds,
  }) {
    return ContentFeedLoaded(
      posts: posts ?? this.posts,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activeCategory: clearCategory ? null : (activeCategory ?? this.activeCategory),
      likedPostIds: likedPostIds ?? this.likedPostIds,
    );
  }
}

/// Feed failed to load.
final class ContentFeedError extends ContentFeedState {
  const ContentFeedError(this.message);
  final String message;
}

/// Feed is empty (no posts found).
final class ContentFeedEmpty extends ContentFeedState {
  const ContentFeedEmpty({this.activeCategory});
  final ContentCategory? activeCategory;
}
