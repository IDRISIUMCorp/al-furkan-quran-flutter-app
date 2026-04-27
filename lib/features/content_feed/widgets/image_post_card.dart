import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:al_furkan/core/models/content_post.dart';
import 'pinned_badge.dart';
import 'post_interaction_row.dart';

/// Card for image posts — صورة بعرض كامل مع نصوص تحتها
class ImagePostCard extends StatelessWidget {
  const ImagePostCard({
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF222222) : Colors.white;
    final textColor = isDark ? const Color(0xFFF5F0EB) : const Color(0xFF212529);
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
            if (post.isPinned) const PinnedBadge(),

            // Image.
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(post.isPinned ? 0 : 16),
                topRight: Radius.circular(post.isPinned ? 0 : 16),
              ),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: post.hasThumbnail
                    ? CachedNetworkImage(
                        imageUrl: post.thumbnailUrl.isNotEmpty
                            ? post.thumbnailUrl
                            : post.mediaUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Shimmer.fromColors(
                          baseColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          highlightColor: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade100,
                          child: Container(color: Colors.grey),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF0F0F0),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 36,
                            color: isDark
                                ? const Color(0xFF4A4A4A)
                                : const Color(0xFFCCCCCC),
                          ),
                        ),
                      )
                    : Container(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0F0F0),
                        child: Icon(
                          Icons.image_outlined,
                          size: 44,
                          color: isDark
                              ? const Color(0xFF4A4A4A)
                              : const Color(0xFFCCCCCC),
                        ),
                      ),
              ),
            ),

            // Title + body.
            if (post.hasTitle || post.hasBody)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.hasTitle)
                      Text(
                        post.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1.4,
                          fontFamily: 'Cairo-Bold',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                    if (post.hasBody) ...[
                      const SizedBox(height: 6),
                      Text(
                        post.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withValues(alpha: 0.7),
                          height: 1.5,
                          fontFamily: 'Cairo-Regular',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ],
                ),
              ),

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
