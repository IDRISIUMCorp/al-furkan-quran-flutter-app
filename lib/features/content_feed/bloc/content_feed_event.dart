import 'package:al_furkan/core/models/content_post.dart';

/// Events for the Content Feed BLoC.
sealed class ContentFeedEvent {
  const ContentFeedEvent();
}

/// Initial load or refresh.
final class ContentFeedLoadRequested extends ContentFeedEvent {
  const ContentFeedLoadRequested({this.category});
  final ContentCategory? category;
}

/// Load the next page.
final class ContentFeedLoadMoreRequested extends ContentFeedEvent {
  const ContentFeedLoadMoreRequested();
}

/// Change the active category filter.
final class ContentFeedCategoryChanged extends ContentFeedEvent {
  const ContentFeedCategoryChanged(this.category);
  final ContentCategory? category;
}

/// Pull-to-refresh.
final class ContentFeedRefreshRequested extends ContentFeedEvent {
  const ContentFeedRefreshRequested();
}

/// A post was viewed — increment counter.
final class ContentFeedPostViewed extends ContentFeedEvent {
  const ContentFeedPostViewed(this.postId);
  final String postId;
}

/// Toggle like on a post.
final class ContentFeedPostLiked extends ContentFeedEvent {
  const ContentFeedPostLiked(this.postId);
  final String postId;
}

/// Share button pressed — increment counter.
final class ContentFeedPostShared extends ContentFeedEvent {
  const ContentFeedPostShared(this.postId);
  final String postId;
}
