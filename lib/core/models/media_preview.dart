import 'package:flutter/material.dart';

/// Types of media content that can be extracted from a URL.
enum MediaType { youtube, tiktok, instagram, twitter, link, image, video }

/// Extracted preview data from a URL (YouTube, TikTok, OG tags, etc.).
class MediaPreview {
  const MediaPreview({
    required this.type,
    this.videoId = '',
    this.title = '',
    this.description = '',
    this.thumbnailUrl = '',
    this.thumbnailFallback = '',
    this.authorName = '',
    this.platform = '',
    this.platformColor,
    this.originalUrl = '',
    this.domain = '',
    this.duration = '',
  });

  final MediaType type;
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String thumbnailFallback;
  final String authorName;
  final String platform;
  final Color? platformColor;
  final String originalUrl;
  final String domain;
  final String duration;

  /// Best available thumbnail.
  String get bestThumbnail =>
      thumbnailUrl.isNotEmpty ? thumbnailUrl : thumbnailFallback;

  /// Whether we have a usable preview image.
  bool get hasImage => bestThumbnail.isNotEmpty;
}
