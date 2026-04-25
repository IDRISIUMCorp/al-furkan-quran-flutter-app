import 'package:flutter/material.dart';
import 'package:al_furkan/core/models/content_post.dart';
import 'video_card.dart';
import 'image_post_card.dart';
import 'text_post_card.dart';
import 'link_preview_card.dart';

/// Factory widget that selects the correct card based on [ContentType].
class ContentCardFactory extends StatelessWidget {
  const ContentCardFactory({
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
    return switch (post.type) {
      ContentType.youtube ||
      ContentType.tiktok ||
      ContentType.video ||
      ContentType.reel =>
        VideoCard(post: post, isLiked: isLiked, onTap: onTap, onLike: onLike, onShare: onShare),
      ContentType.image =>
        ImagePostCard(post: post, isLiked: isLiked, onTap: onTap, onLike: onLike, onShare: onShare),
      ContentType.text =>
        TextPostCard(post: post, isLiked: isLiked, onLike: onLike, onShare: onShare),
      ContentType.link ||
      ContentType.instagram ||
      ContentType.tweet =>
        LinkPreviewCard(post: post, isLiked: isLiked, onTap: onTap, onLike: onLike, onShare: onShare),
    };
  }
}
