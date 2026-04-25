import 'package:flutter/material.dart';
import 'package:al_furkan/core/models/content_post.dart';
import 'pinned_badge.dart';
import 'post_interaction_row.dart';

/// Card for text-only posts — تصميم نظيف بتدرج دافئ إسلامي
class TextPostCard extends StatefulWidget {
  const TextPostCard({
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

  @override
  State<TextPostCard> createState() => _TextPostCardState();
}

class _TextPostCardState extends State<TextPostCard> {
  bool _expanded = false;
  static const _collapsedMaxLines = 6;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF5F0EB) : const Color(0xFF212529);
    final accentColor = isDark ? const Color(0xFF839788) : const Color(0xFF73877B);

    final cardBg = isDark ? const Color(0xFF222222) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.isPinned) const PinnedBadge(),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip.
                if (widget.post.category != ContentCategory.general)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.post.category.arabicLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                          fontFamily: 'Cairo-SemiBold',
                        ),
                      ),
                    ),
                  ),

                // Title.
                if (widget.post.hasTitle)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      widget.post.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.5,
                        fontFamily: 'Cairo-Bold',
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),

                // Body text.
                if (widget.post.hasBody)
                  Text(
                    widget.post.body,
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor.withValues(alpha: 0.8),
                      height: 1.75,
                      fontFamily: 'Cairo-Regular',
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: _expanded ? null : _collapsedMaxLines,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  ),

                // "Read more" button.
                if (widget.post.body.length > 200 && !_expanded)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GestureDetector(
                      onTap: () => setState(() => _expanded = true),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'اقرأ المزيد',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                            fontFamily: 'Cairo-SemiBold',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          PostInteractionRow(
            post: widget.post,
            isLiked: widget.isLiked,
            onLike: widget.onLike,
            onShare: widget.onShare,
          ),
        ],
      ),
    );
  }
}
