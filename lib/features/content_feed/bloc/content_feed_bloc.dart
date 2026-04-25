import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

import 'package:al_furkan/core/repositories/content_repository.dart';
import 'package:al_furkan/core/models/content_post.dart';
import 'content_feed_event.dart';
import 'content_feed_state.dart';

/// Manages the content feed lifecycle: load, paginate, filter, interact.
/// يدعم الكاشينج المحلي عبر Hive لتقليل طلبات الإنترنت.
class ContentFeedBloc extends Bloc<ContentFeedEvent, ContentFeedState> {
  ContentFeedBloc({ContentRepository? repository})
      : _repository = repository ?? ContentRepository(),
        super(const ContentFeedInitial()) {
    on<ContentFeedLoadRequested>(_onLoad);
    on<ContentFeedLoadMoreRequested>(_onLoadMore);
    on<ContentFeedCategoryChanged>(_onCategoryChanged);
    on<ContentFeedRefreshRequested>(_onRefresh);
    on<ContentFeedPostViewed>(_onPostViewed);
    on<ContentFeedPostLiked>(_onPostLiked);
    on<ContentFeedPostShared>(_onPostShared);

    // Load liked posts from local storage.
    _likedPostIds = _loadLikedPosts();
  }

  final ContentRepository _repository;
  late Set<String> _likedPostIds;

  // ── Local cache for posts per category ──────────────────
  final Map<String, List<ContentPost>> _cache = {};
  static const _cacheKey = 'all';

  String _categoryKey(ContentCategory? cat) => cat?.name ?? _cacheKey;

  // ── Load first page ─────────────────────────────────────

  Future<void> _onLoad(
    ContentFeedLoadRequested event,
    Emitter<ContentFeedState> emit,
  ) async {
    final key = _categoryKey(event.category);

    // Show cached data immediately if available
    if (_cache.containsKey(key) && _cache[key]!.isNotEmpty) {
      emit(ContentFeedLoaded(
        posts: _cache[key]!,
        hasMore: true,
        activeCategory: event.category,
        likedPostIds: _likedPostIds,
      ));
      // Still fetch fresh data in background
      try {
        final page = await _repository.fetchFeed(category: event.category);
        _cache[key] = page.posts;
        if (!emit.isDone) {
          if (page.posts.isEmpty) {
            emit(ContentFeedEmpty(activeCategory: event.category));
          } else {
            emit(ContentFeedLoaded(
              posts: page.posts,
              lastDocument: page.lastDocument,
              hasMore: page.hasMore,
              activeCategory: event.category,
              likedPostIds: _likedPostIds,
            ));
          }
        }
      } catch (e) {
        // Keep showing cached data on error
        log('ContentFeedBloc._onLoad bg refresh: $e');
      }
      return;
    }

    emit(const ContentFeedLoading());
    try {
      final page = await _repository.fetchFeed(category: event.category);
      _cache[key] = page.posts;

      if (page.posts.isEmpty) {
        emit(ContentFeedEmpty(activeCategory: event.category));
        return;
      }
      emit(ContentFeedLoaded(
        posts: page.posts,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
        activeCategory: event.category,
        likedPostIds: _likedPostIds,
      ));
    } catch (e, st) {
      log('ContentFeedBloc._onLoad: $e', stackTrace: st);
      emit(ContentFeedError('فشل تحميل المحتوى: $e'));
    }
  }

  // ── Load more (pagination) ──────────────────────────────

  Future<void> _onLoadMore(
    ContentFeedLoadMoreRequested event,
    Emitter<ContentFeedState> emit,
  ) async {
    final current = state;
    if (current is! ContentFeedLoaded || !current.hasMore || current.isLoadingMore) {
      return;
    }
    if (current.lastDocument == null) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final page = await _repository.fetchMoreFeed(
        lastDocument: current.lastDocument!,
        category: current.activeCategory,
      );
      final allPosts = [...current.posts, ...page.posts];
      final key = _categoryKey(current.activeCategory);
      _cache[key] = allPosts;

      emit(current.copyWith(
        posts: allPosts,
        lastDocument: page.lastDocument ?? current.lastDocument,
        hasMore: page.hasMore,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      log('ContentFeedBloc._onLoadMore: $e', stackTrace: st);
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  // ── Category filter ─────────────────────────────────────
  // Uses LOCAL filtering from the cached 'all' data to avoid
  // Firestore composite index requirements.

  Future<void> _onCategoryChanged(
    ContentFeedCategoryChanged event,
    Emitter<ContentFeedState> emit,
  ) async {
    final cat = event.category;

    // If "all" / null, just load everything normally
    if (cat == null || cat == ContentCategory.general) {
      add(const ContentFeedLoadRequested());
      return;
    }

    // Try to filter locally from the 'all' cache first
    final allCached = _cache[_cacheKey];
    if (allCached != null && allCached.isNotEmpty) {
      final filtered = allCached.where((p) => p.category == cat).toList();
      if (filtered.isNotEmpty) {
        emit(ContentFeedLoaded(
          posts: filtered,
          hasMore: false,
          activeCategory: cat,
          likedPostIds: _likedPostIds,
        ));
        return;
      }
    }

    // If no local cache, try fetching from Firestore
    emit(const ContentFeedLoading());
    try {
      final page = await _repository.fetchFeed(category: cat);
      if (page.posts.isEmpty) {
        // Fallback: try filtering from all posts
        if (allCached == null || allCached.isEmpty) {
          final allPage = await _repository.fetchFeed();
          _cache[_cacheKey] = allPage.posts;
          final filtered = allPage.posts.where((p) => p.category == cat).toList();
          if (filtered.isEmpty) {
            emit(ContentFeedEmpty(activeCategory: cat));
          } else {
            emit(ContentFeedLoaded(
              posts: filtered,
              hasMore: false,
              activeCategory: cat,
              likedPostIds: _likedPostIds,
            ));
          }
        } else {
          emit(ContentFeedEmpty(activeCategory: cat));
        }
        return;
      }
      emit(ContentFeedLoaded(
        posts: page.posts,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
        activeCategory: cat,
        likedPostIds: _likedPostIds,
      ));
    } catch (e, st) {
      log('ContentFeedBloc._onCategoryChanged Firestore error: $e', stackTrace: st);
      // Fallback: filter locally from 'all' cache
      if (allCached != null && allCached.isNotEmpty) {
        final filtered = allCached.where((p) => p.category == cat).toList();
        if (filtered.isEmpty) {
          emit(ContentFeedEmpty(activeCategory: cat));
        } else {
          emit(ContentFeedLoaded(
            posts: filtered,
            hasMore: false,
            activeCategory: cat,
            likedPostIds: _likedPostIds,
          ));
        }
      } else {
        // Try loading all first, then filter
        try {
          final allPage = await _repository.fetchFeed();
          _cache[_cacheKey] = allPage.posts;
          final filtered = allPage.posts.where((p) => p.category == cat).toList();
          if (filtered.isEmpty) {
            emit(ContentFeedEmpty(activeCategory: cat));
          } else {
            emit(ContentFeedLoaded(
              posts: filtered,
              hasMore: false,
              activeCategory: cat,
              likedPostIds: _likedPostIds,
            ));
          }
        } catch (e2) {
          emit(ContentFeedError('فشل تحميل المحتوى: $e2'));
        }
      }
    }
  }

  // ── Pull to refresh ─────────────────────────────────────

  Future<void> _onRefresh(
    ContentFeedRefreshRequested event,
    Emitter<ContentFeedState> emit,
  ) async {
    final currentCategory =
        state is ContentFeedLoaded ? (state as ContentFeedLoaded).activeCategory : null;

    // Always show loading state first (especially from error state)
    emit(const ContentFeedLoading());

    // Clear all caches to force fresh load
    _cache.clear();

    // Fetch fresh data
    try {
      final page = await _repository.fetchFeed(category: currentCategory);
      _cache[_categoryKey(currentCategory)] = page.posts;

      if (page.posts.isEmpty) {
        emit(ContentFeedEmpty(activeCategory: currentCategory));
        return;
      }
      emit(ContentFeedLoaded(
        posts: page.posts,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
        activeCategory: currentCategory,
        likedPostIds: _likedPostIds,
      ));
    } catch (e, st) {
      log('ContentFeedBloc._onRefresh: $e', stackTrace: st);
      emit(ContentFeedError('فشل تحميل المحتوى: $e'));
    }
  }

  // ── Post interactions ───────────────────────────────────

  Future<void> _onPostViewed(
    ContentFeedPostViewed event,
    Emitter<ContentFeedState> emit,
  ) async {
    try {
      await _repository.incrementViews(event.postId);
    } catch (_) {}
  }

  Future<void> _onPostLiked(
    ContentFeedPostLiked event,
    Emitter<ContentFeedState> emit,
  ) async {
    final current = state;
    if (current is! ContentFeedLoaded) return;

    final alreadyLiked = _likedPostIds.contains(event.postId);
    final newSet = Set<String>.from(_likedPostIds);

    if (alreadyLiked) {
      newSet.remove(event.postId);
    } else {
      newSet.add(event.postId);
    }

    _likedPostIds = newSet;
    _saveLikedPosts(newSet);

    emit(current.copyWith(likedPostIds: newSet));

    try {
      await _repository.incrementLikes(
        event.postId,
        delta: alreadyLiked ? -1 : 1,
      );
    } catch (_) {}
  }

  Future<void> _onPostShared(
    ContentFeedPostShared event,
    Emitter<ContentFeedState> emit,
  ) async {
    try {
      await _repository.incrementShares(event.postId);
    } catch (_) {}
  }

  // ── Local liked posts persistence (Hive) ────────────────

  Set<String> _loadLikedPosts() {
    try {
      final box = Hive.box('user');
      final list = box.get('liked_content_posts') as List?;
      if (list == null) return {};
      return Set<String>.from(list.whereType<String>());
    } catch (_) {
      return {};
    }
  }

  void _saveLikedPosts(Set<String> ids) {
    try {
      final box = Hive.box('user');
      box.put('liked_content_posts', ids.toList());
    } catch (_) {}
  }
}
