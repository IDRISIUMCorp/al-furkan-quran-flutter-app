import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:al_furkan/core/models/content_post.dart';
import 'pinned_badge.dart';
import 'post_interaction_row.dart';

/// Card for YouTube / TikTok / video / reel content.
/// تصميم نظيف مع Thumbnail و Play button وبادج المنصة
class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.post,
    required this.isLiked,
    this.onTap,
    this.onLike,
    this.onShare,
  });

  final ContentPost post;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onShare;

  Color _platformColor() => switch (post.type) {
        ContentType.youtube => const Color(0xFFFF0000),
        ContentType.tiktok => const Color(0xFF000000),
        ContentType.instagram => const Color(0xFFE4405F),
        _ => const Color(0xFF6B7280),
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF222222) : Colors.white;
    final textColor = isDark ? const Color(0xFFF5F0EB) : const Color(0xFF212529);
    final subtitleColor = isDark ? const Color(0xFF8A8A8A) : const Color(0xFF9E9E9E);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pinned badge.
            if (post.isPinned) const PinnedBadge(),

            // Thumbnail with play button.
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(post.isPinned ? 0 : 16),
                topRight: Radius.circular(post.isPinned ? 0 : 16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail image.
                    if (post.hasThumbnail)
                      CachedNetworkImage(
                        imageUrl: post.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          highlightColor: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                          child: Container(color: Colors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF0F0F0),
                          child: Icon(
                            FluentIcons.play_circle_24_regular,
                            size: 44,
                            color: subtitleColor,
                          ),
                        ),
                      )
                    else
                      Container(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0F0F0),
                        child: Icon(
                          FluentIcons.video_24_regular,
                          size: 44,
                          color: subtitleColor,
                        ),
                      ),

                    // Gradient overlay for readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Play button overlay.
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          FluentIcons.play_24_filled,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Platform badge.
                    if (post.type.platformLabel.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _platformColor().withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            post.type.platformLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                    // Duration badge.
                    if (post.duration.isNotEmpty)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Cairo-Regular',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Title + author.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.hasTitle)
                    Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.4,
                        fontFamily: 'Cairo-Bold',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                  if (post.authorName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.authorName,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                        fontFamily: 'Cairo-Regular',
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ],
              ),
            ),

            // Interaction row.
            PostInteractionRow(
              post: post,
              isLiked: isLiked,
              onLike: onLike,
              onShare: onShare,
            ),
          ],
        ),
      ),
    );
  }
}
