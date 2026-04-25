
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:al_furkan/core/models/update_config.dart';
import 'dialog_styles.dart';
import 'countdown_dismiss_button.dart';

/// The main Update Dialog — supports 6 visual styles.
///
/// Usage:
/// ```dart
/// UpdateDialog.show(context, result);
/// ```
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({
    super.key,
    required this.config,
    required this.isForced,
    this.onDismiss,
  });

  final UpdateConfig config;
  final bool isForced;
  final VoidCallback? onDismiss;

  /// Shows the update dialog with the appropriate style.
  static Future<void> show(
    BuildContext context,
    UpdateCheckResult result,
  ) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: !result.isForced && result.config.dismissible,
      barrierLabel: 'update_dialog',
      barrierColor: DialogStyleBuilder.barrierColor(
        result.config.style,
        result.config,
      ),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, anim, secondAnim, child) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curve),
          child: FadeTransition(opacity: curve, child: child),
        );
      },
      pageBuilder: (context, _, __) => UpdateDialog(
        config: result.config,
        isForced: result.isForced,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _openStore() async {
    if (config.storeUrl.isEmpty) return;
    final uri = Uri.tryParse(config.storeUrl);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final style = config.style;
    final blur = DialogStyleBuilder.blurSigma(style, config);

    return WillPopScope(
      onWillPop: () async => !isForced,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(24),
            decoration: DialogStyleBuilder.decoration(style, config),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Top icon ──────────────────────────
                _buildIcon(style)
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 16),

                // ── Title ─────────────────────────────
                Text(
                  config.title,
                  style: DialogStyleBuilder.titleStyle(style, config),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms),

                if (config.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    config.description,
                    style: DialogStyleBuilder.bodyStyle(style),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 150.ms),
                ],

                // ── Version badge ─────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _buildVersionBadge(style),
                ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                // ── Changelog ─────────────────────────
                if (config.showChangelogInDialog &&
                    config.changelogItems.isNotEmpty) ...[
                  _buildChangelog(style)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 250.ms)
                      .slideY(begin: 0.05),
                  const SizedBox(height: 16),
                ],

                // ── Buttons ───────────────────────────
                _buildButtons(style)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top icon per style ──────────────────────────────────

  Widget _buildIcon(DialogStyle style) {
    final iconData = isForced ? Icons.system_update_alt_rounded : Icons.upgrade_rounded;

    return switch (style) {
      DialogStyle.liquidGlass => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                config.primaryColor.withValues(alpha: 0.3),
                config.primaryColor.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(iconData, size: 30, color: Colors.white.withValues(alpha: 0.9)),
        ),

      DialogStyle.frostedGlass => Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: config.primaryColor.withValues(alpha: 0.2),
          ),
          child: Icon(iconData, size: 28, color: config.primaryColor),
        ),

      DialogStyle.material3 => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: config.primaryColor.withValues(alpha: 0.12),
          ),
          child: Icon(iconData, size: 32, color: config.primaryColor),
        ),

      DialogStyle.amoled => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: config.primaryColor, width: 2),
          ),
          child: Icon(iconData, size: 26, color: config.primaryColor),
        ),

      DialogStyle.minimal => Icon(iconData, size: 40, color: const Color(0xFF1E1E1E)),

      DialogStyle.islamicGold => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFC9A84C), Color(0xFFE8D48B)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC9A84C).withValues(alpha: 0.3),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded, size: 28, color: Color(0xFF1A1A0F)),
        ),
    };
  }

  // ── Version badge ───────────────────────────────────────

  Widget _buildVersionBadge(DialogStyle style) {
    final isLight = style == DialogStyle.material3 || style == DialogStyle.minimal;
    final bgColor = isLight
        ? Colors.grey.shade100
        : Colors.white.withValues(alpha: 0.08);
    final textColor = isLight ? Colors.grey.shade700 : Colors.white.withValues(alpha: 0.7);

    if (style == DialogStyle.islamicGold) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.3)),
        ),
        child: Text(
          'الإصدار ${config.currentVersion}',
          style: const TextStyle(fontSize: 12, color: Color(0xFFE8D48B), fontWeight: FontWeight.w600),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'الإصدار ${config.currentVersion}',
        style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Changelog list ──────────────────────────────────────

  Widget _buildChangelog(DialogStyle style) {
    final iconColor = DialogStyleBuilder.changelogIconColor(style);
    final textStyle = DialogStyleBuilder.bodyStyle(style).copyWith(fontSize: 13);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (style == DialogStyle.material3 || style == DialogStyle.minimal)
            ? Colors.grey.shade50
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: style == DialogStyle.islamicGold
              ? const Color(0xFFC9A84C).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: config.changelogItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.check_circle_rounded, size: 14, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item, style: textStyle, textDirection: TextDirection.rtl),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Action buttons ──────────────────────────────────────

  Widget _buildButtons(DialogStyle style) {
    return Column(
      children: [
        // Update button.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _openStore,
            style: DialogStyleBuilder.primaryButton(style, config),
            child: const Text(
              'تحديث الآن',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        // Dismiss button (only for non-forced updates).
        if (!isForced && config.dismissible) ...[
          const SizedBox(height: 8),
          CountdownDismissButton(
            seconds: config.showCountdown ? config.dismissAfterSeconds : 0,
            onDismiss: onDismiss ?? () {},
            showCountdown: config.showCountdown,
            color: style == DialogStyle.islamicGold
                ? const Color(0xFFC9A84C).withValues(alpha: 0.6)
                : (style == DialogStyle.minimal || style == DialogStyle.material3)
                    ? Colors.grey.shade500
                    : Colors.white.withValues(alpha: 0.4),
          ),
        ],

        // Forced update message.
        if (isForced) ...[
          const SizedBox(height: 12),
          Text(
            'هذا التحديث إجباري لاستمرار استخدام التطبيق',
            style: TextStyle(
              fontSize: 11,
              color: style == DialogStyle.islamicGold
                  ? const Color(0xFFC9A84C).withValues(alpha: 0.5)
                  : Colors.red.shade300.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ],
      ],
    );
  }
}
