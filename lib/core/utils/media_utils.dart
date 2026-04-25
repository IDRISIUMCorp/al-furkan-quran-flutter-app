import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

import 'package:al_furkan/core/models/media_preview.dart';

/// Extracts rich preview data from any URL (YouTube, TikTok,
/// Instagram, Twitter, or generic Open Graph).
///
/// All methods are free and require no API keys (except Instagram
/// which falls back to OG tags).
class MediaPreviewService {
  MediaPreviewService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _userAgent = 'AlFurqanApp/2.0';
  static const _timeout = Duration(seconds: 8);

  // ─────────────────────────────────────────────────────────
  // MAIN ENTRY POINT
  // ─────────────────────────────────────────────────────────

  /// Extracts preview metadata from any URL.
  Future<MediaPreview> extractFromUrl(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return _fallback(url);

      final host = uri.host.toLowerCase();

      // YouTube
      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        return _extractYouTube(url);
      }

      // TikTok
      if (host.contains('tiktok.com')) {
        return _extractTikTok(url);
      }

      // Instagram
      if (host.contains('instagram.com')) {
        return _extractFromOpenGraph(
          url,
          'Instagram',
          const Color(0xFFE4405F),
          MediaType.instagram,
        );
      }

      // Twitter / X
      if (host.contains('twitter.com') || host.contains('x.com')) {
        return _extractFromOpenGraph(
          url,
          'X / Twitter',
          const Color(0xFF000000),
          MediaType.twitter,
        );
      }

      // Generic website
      return _extractFromOpenGraph(
        url,
        _extractDomain(url),
        null,
        MediaType.link,
      );
    } catch (e, st) {
      log('MediaPreview extraction failed: $e',
          name: 'MediaPreviewService', stackTrace: st);
      return _fallback(url);
    }
  }

  // ─────────────────────────────────────────────────────────
  // YOUTUBE — free, no API key needed
  // ─────────────────────────────────────────────────────────

  MediaPreview _extractYouTube(String url) {
    final videoId = extractYouTubeId(url);
    if (videoId.isEmpty) return _fallback(url);

    return MediaPreview(
      type: MediaType.youtube,
      videoId: videoId,
      thumbnailUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
      thumbnailFallback: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
      platform: 'YouTube',
      platformColor: const Color(0xFFFF0000),
      originalUrl: url,
    );
  }

  // ─────────────────────────────────────────────────────────
  // TIKTOK — oEmbed API (free, no key)
  // ─────────────────────────────────────────────────────────

  Future<MediaPreview> _extractTikTok(String url) async {
    try {
      final oembedUrl =
          'https://www.tiktok.com/oembed?url=${Uri.encodeComponent(url)}';
      final response = await _client
          .get(Uri.parse(oembedUrl))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return MediaPreview(
          type: MediaType.tiktok,
          title: data['title'] as String? ?? '',
          thumbnailUrl: data['thumbnail_url'] as String? ?? '',
          authorName: data['author_name'] as String? ?? '',
          platform: 'TikTok',
          platformColor: const Color(0xFF000000),
          originalUrl: url,
        );
      }
    } catch (e) {
      log('TikTok oEmbed failed: $e', name: 'MediaPreviewService');
    }
    return _fallback(url, platform: 'TikTok');
  }

  // ─────────────────────────────────────────────────────────
  // OPEN GRAPH — universal fallback
  // ─────────────────────────────────────────────────────────

  Future<MediaPreview> _extractFromOpenGraph(
    String url,
    String platform,
    Color? color,
    MediaType type,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(_timeout);

      if (response.statusCode != 200) return _fallback(url, platform: platform);

      final document = html_parser.parse(response.body);

      String? ogMeta(String property) => document
          .querySelector('meta[property="og:$property"]')
          ?.attributes['content'];

      final ogTitle = ogMeta('title');
      final ogImage = ogMeta('image');
      final ogDescription = ogMeta('description');
      final ogSiteName = ogMeta('site_name');

      return MediaPreview(
        type: type,
        title: ogTitle ?? _extractDomain(url),
        description: ogDescription ?? '',
        thumbnailUrl: ogImage ?? '',
        authorName: ogSiteName ?? platform,
        platform: platform,
        platformColor: color,
        originalUrl: url,
        domain: _extractDomain(url),
      );
    } catch (e) {
      log('OG extraction failed for $url: $e', name: 'MediaPreviewService');
      return _fallback(url, platform: platform);
    }
  }

  // ─────────────────────────────────────────────────────────
  // YOUTUBE ID EXTRACTION
  // ─────────────────────────────────────────────────────────

  /// Extracts the 11-char YouTube video ID from any URL format.
  static String extractYouTubeId(String url) {
    final patterns = [
      RegExp(r'v=([a-zA-Z0-9_-]{11})'),
      RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})'),
      RegExp(r'embed/([a-zA-Z0-9_-]{11})'),
      RegExp(r'shorts/([a-zA-Z0-9_-]{11})'),
      RegExp(r'live/([a-zA-Z0-9_-]{11})'),
    ];
    for (final regex in patterns) {
      final match = regex.firstMatch(url);
      if (match != null) return match.group(1)!;
    }
    return '';
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────

  static String _extractDomain(String url) {
    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  static MediaPreview _fallback(String url, {String? platform}) {
    return MediaPreview(
      type: MediaType.link,
      title: _extractDomain(url),
      originalUrl: url,
      platform: platform ?? _extractDomain(url),
    );
  }
}
