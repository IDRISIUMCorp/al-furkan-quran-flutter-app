import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:al_furkan/core/models/content_post.dart';
import 'pinned_badge.dart';
import 'post_interaction_row.dart';

/// Card for external links, Instagram posts, and tweets — OG preview style.
/// تصميم نظيف مع عرض الدومين والمحتوى
class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({
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

  String get _domain {
    try {
      return Uri.parse(post.mediaUrl).host.replaceFirst('www.', '');
    } catch (_) {
      return post.mediaUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF222222) : Colors.white;
    final textColor = isDark ? const Color(0xFFF5F0EB) : const Color(0xFF212529);
    final subtitleColor = isDark ? const Color(0xFF8A8A8A) : const Color(0xFF9E9E9E);
    final accentColor = isDark ? const Color(0xFF839788) : const Color(0xFF73877B);
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

            // OG image (if available).
            if (post.hasThumbnail)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(post.isPinned ? 0 : 16),
                  topRight: Radius.circular(post.isPinned ? 0 : 16),
                ),
                child: AspectRatio(
                  aspectRatio: 2 / 1,
                  child: CachedNetworkImage(
                    imageUrl: post.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain row.
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        FluentIcons.globe_24_regular,
                        size: 14,
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _domain,
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                            fontFamily: 'Cairo-Regular',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        FluentIcons.open_24_regular,
                        size: 14,
                        color: accentColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Title.
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

                  // Body / description.
                  if (post.hasBody) ...[
                    const SizedBox(height: 4),
                    Text(
                      post.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withValues(alpha: 0.65),
                        height: 1.5,
                        fontFamily: 'Cairo-Regular',
                      ),
                      maxLines: 2,
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
