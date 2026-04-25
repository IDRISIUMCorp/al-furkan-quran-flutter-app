import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:al_furkan/core/models/content_post.dart';

/// Interaction row — مشاهدات · وقت | ❤️ إعجاب | ↗ مشاركة
/// تصميم نظيف وخفيف بدون ثقل بصري
class PostInteractionRow extends StatelessWidget {
  const PostInteractionRow({
    super.key,
    required this.post,
    required this.isLiked,
    this.onLike,
    this.onShare,
  });

  final ContentPost post;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onShare;

  String _timeAgo() {
    if (post.publishedAt == null) return '';
    return timeago.format(post.publishedAt!, locale: 'ar');
  }

  String _viewsLabel() {
    if (post.viewCount == 0) return '';
    if (post.viewCount < 1000) return '${post.viewCount} مشاهدة';
    return '${(post.viewCount / 1000).toStringAsFixed(1)}k مشاهدة';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? const Color(0xFF6B6B6B) : const Color(0xFFAAAAAA);
    final accentColor = isDark ? const Color(0xFF839788) : const Color(0xFF73877B);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);

    final metaText = [_viewsLabel(), _timeAgo()]
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return Column(
      children: [
        // Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 0.5,
          color: dividerColor,
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Meta text (views + time)
              if (metaText.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      metaText,
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedColor,
                        fontFamily: 'Cairo-Regular',
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              else
                const Spacer(),

              // Like button
              _InteractionButton(
                icon: isLiked
                    ? FluentIcons.heart_24_filled
                    : FluentIcons.heart_24_regular,
                label: post.likeCount > 0 ? '${post.likeCount}' : '',
                color: isLiked ? const Color(0xFFE55B5B) : mutedColor,
                onTap: onLike,
              ),

              const SizedBox(width: 2),

              // Share button
              _InteractionButton(
                icon: FluentIcons.share_24_regular,
                label: post.shareCount > 0 ? '${post.shareCount}' : '',
                color: accentColor,
                onTap: onShare,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo-Regular',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
