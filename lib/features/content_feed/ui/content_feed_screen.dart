import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import 'package:al_furkan/core/models/content_post.dart';
import 'package:al_furkan/features/content_feed/bloc/content_feed_bloc.dart';
import 'package:al_furkan/features/content_feed/bloc/content_feed_event.dart';
import 'package:al_furkan/features/content_feed/bloc/content_feed_state.dart';
import 'package:al_furkan/features/content_feed/widgets/content_card_factory.dart';
import 'package:al_furkan/features/content_feed/widgets/category_filter_chips.dart';
import 'package:al_furkan/features/content_feed/widgets/content_shimmer.dart';

/// شاشة عرض المحتوى الإسلامي للمستخدمين
/// تصميم Organic Minimalism — نظيف، بسيط، وفخم
class ContentFeedScreen extends StatelessWidget {
  const ContentFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContentFeedBloc()
        ..add(const ContentFeedLoadRequested()),
      child: const _ContentFeedView(),
    );
  }
}

class _ContentFeedView extends StatefulWidget {
  const _ContentFeedView();

  @override
  State<_ContentFeedView> createState() => _ContentFeedViewState();
}

class _ContentFeedViewState extends State<_ContentFeedView> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _viewedPostIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ContentFeedBloc>().add(const ContentFeedLoadMoreRequested());
    }
  }

  void _onPostVisible(String postId) {
    if (_viewedPostIds.contains(postId)) return;
    _viewedPostIds.add(postId);
    context.read<ContentFeedBloc>().add(ContentFeedPostViewed(postId));
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _sharePost(ContentPost post) {
    final text = [
      if (post.hasTitle) post.title,
      if (post.hasBody) post.body,
      if (post.hasMedia) post.mediaUrl,
      '\n— تطبيق الفُرقان 📖',
    ].join('\n');
    SharePlus.instance.share(ShareParams(text: text));
    context.read<ContentFeedBloc>().add(ContentFeedPostShared(post.id));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: isDark ? const Color(0xFF839788) : const Color(0xFF73877B),
          backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          onRefresh: () async {
            context.read<ContentFeedBloc>().add(const ContentFeedRefreshRequested());
            await Future<void>.delayed(const Duration(milliseconds: 800));
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header ──────────────────────────────────
              SliverToBoxAdapter(
                child: _buildHeader(isDark),
              ),

              // ── Category chips ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  child: BlocBuilder<ContentFeedBloc, ContentFeedState>(
                    buildWhen: (prev, curr) {
                      final prevCat = prev is ContentFeedLoaded ? prev.activeCategory : null;
                      final currCat = curr is ContentFeedLoaded ? curr.activeCategory : null;
                      return prevCat != currCat || prev.runtimeType != curr.runtimeType;
                    },
                    builder: (context, state) {
                      if (state is ContentFeedLoading) {
                        return const CategoryChipsShimmer();
                      }
                      final activeCat =
                          state is ContentFeedLoaded ? state.activeCategory : null;
                      return CategoryFilterChips(
                        activeCategory: activeCat,
                        onChanged: (cat) {
                          context
                              .read<ContentFeedBloc>()
                              .add(ContentFeedCategoryChanged(cat));
                        },
                      );
                    },
                  ),
                ),
              ),

              // ── Content ─────────────────────────────────
              BlocBuilder<ContentFeedBloc, ContentFeedState>(
                builder: (context, state) {
                  return switch (state) {
                    ContentFeedInitial() || ContentFeedLoading() =>
                      const ContentFeedShimmer(),

                    ContentFeedError(:final message) =>
                      _buildErrorSliver(message, isDark),

                    ContentFeedEmpty() =>
                      _buildEmptySliver(isDark),

                    ContentFeedLoaded(
                      :final posts,
                      :final isLoadingMore,
                      :final hasMore,
                      :final likedPostIds,
                    ) =>
                      _buildPostsSliver(posts, isLoadingMore, hasMore, likedPostIds, isDark),
                  };
                },
              ),

              // Bottom padding.
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    final headerColor = isDark ? const Color(0xFFF5F0EB) : const Color(0xFF212529);
    final subtitleColor = isDark ? const Color(0xFF8A8A8A) : const Color(0xFF9E9E9E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Back button
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FluentIcons.arrow_right_24_regular,
                  size: 20,
                  color: headerColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'المحتوى',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: headerColor,
              fontFamily: 'Cairo-Bold',
              height: 1.1,
              letterSpacing: -0.5,
            ),
            textDirection: TextDirection.rtl,
          ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.03),

          const SizedBox(height: 4),

          Text(
            'تابع أحدث المنشورات والمقاطع الإسلامية',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: subtitleColor,
              fontFamily: 'Cairo-Regular',
              height: 1.4,
            ),
            textDirection: TextDirection.rtl,
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
        ],
      ),
    );
  }

  // ── Posts sliver ─────────────────────────────────────────

  Widget _buildPostsSliver(
    List<ContentPost> posts,
    bool isLoadingMore,
    bool hasMore,
    Set<String> likedPostIds,
    bool isDark,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Loading more indicator at the bottom.
          if (index == posts.length) {
            if (!hasMore) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? const Color(0xFF839788) : const Color(0xFF73877B),
                  ),
                ),
              ),
            );
          }

          final post = posts[index];

          return VisibilityDetector(
            key: Key('content_post_${post.id}'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.5) {
                _onPostVisible(post.id);
              }
            },
            child: RepaintBoundary(
              child: ContentCardFactory(
                post: post,
                isLiked: likedPostIds.contains(post.id),
                onTap: post.hasMedia ? () => _openUrl(post.mediaUrl) : null,
                onLike: () => context
                    .read<ContentFeedBloc>()
                    .add(ContentFeedPostLiked(post.id)),
                onShare: () => _sharePost(post),
              ).animate()
                  .fadeIn(duration: 400.ms, delay: (60 * (index % 5)).ms)
                  .slideY(begin: 0.03, duration: 400.ms, curve: Curves.easeOutCubic),
            ),
          );
        },
        childCount: posts.length + (hasMore ? 1 : 0),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────

  Widget _buildEmptySliver(bool isDark) {
    final iconColor = isDark ? const Color(0xFF4A4A4A) : const Color(0xFFD6CCC2);
    final titleColor = isDark ? const Color(0xFF8A8A8A) : const Color(0xFF6B6B6B);
    final subtitleColor = isDark ? const Color(0xFF5A5A5A) : const Color(0xFF9E9E9E);

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF5EBE0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                FluentIcons.document_text_24_regular,
                size: 36,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا يوجد محتوى حالياً',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: titleColor,
                fontFamily: 'Cairo-Bold',
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 6),
            Text(
              'ترقبوا محتوى جديد قريباً إن شاء الله',
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
                fontFamily: 'Cairo-Regular',
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.96, 0.96)),
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────

  Widget _buildErrorSliver(String message, bool isDark) {
    final accentColor = isDark ? const Color(0xFF839788) : const Color(0xFF73877B);

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.red.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                FluentIcons.wifi_off_24_regular,
                size: 36,
                color: isDark ? const Color(0xFF5A5A5A) : Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ في التحميل',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF8A8A8A) : const Color(0xFF6B6B6B),
                fontFamily: 'Cairo-Bold',
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                context
                    .read<ContentFeedBloc>()
                    .add(const ContentFeedLoadRequested());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
