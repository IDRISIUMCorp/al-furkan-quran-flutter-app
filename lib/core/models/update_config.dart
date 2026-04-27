import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
// DIALOG STYLE ENUM
// ─────────────────────────────────────────────────────────────

/// Visual styles for the update dialog.
enum DialogStyle {
  liquidGlass('بلور سائل'),
  frostedGlass('زجاج مصنفر'),
  material3('Material 3'),
  amoled('AMOLED'),
  minimal('بسيط'),
  islamicGold('ذهبي إسلامي');

  const DialogStyle(this.arabicLabel);
  final String arabicLabel;

  static DialogStyle fromString(String? value) {
    if (value == null) return DialogStyle.liquidGlass;
    for (final s in DialogStyle.values) {
      if (s.name == value) return s;
    }
    return DialogStyle.liquidGlass;
  }
}

// ─────────────────────────────────────────────────────────────
// UPDATE CONFIG MODEL
// ─────────────────────────────────────────────────────────────

/// Represents the `/update_config/current` Firestore document.
///
/// Fully customizable update dialog configuration that the admin
/// can modify in real-time through the Update Manager screen.
class UpdateConfig {
  const UpdateConfig({
    this.isEnabled = false,
    this.isForce = false,
    this.currentVersion = '1.0.0',
    this.minRequiredVersion = '1.0.0',
    this.title = 'تحديث جديد متاح',
    this.description = '',
    this.changelogItems = const [],
    this.storeUrl = '',
    this.style = DialogStyle.liquidGlass,
    this.primaryColor = const Color(0xFF4CAF72),
    this.dismissAfterSeconds = 5,
    this.dismissible = true,
    this.showCountdown = true,
    this.redirectDelay = 0,
    this.backgroundBlur = 20.0,
    this.backgroundOpacity = 0.6,
    this.cornerRadius = 24.0,
    this.showChangelogInDialog = true,
    this.updatedAt,
  });

  final bool isEnabled;
  final bool isForce;
  final String currentVersion;
  final String minRequiredVersion;
  final String title;
  final String description;
  final List<String> changelogItems;
  final String storeUrl;
  final DialogStyle style;
  final Color primaryColor;
  final int dismissAfterSeconds;
  final bool dismissible;
  final bool showCountdown;
  final int redirectDelay;
  final double backgroundBlur;
  final double backgroundOpacity;
  final double cornerRadius;
  final bool showChangelogInDialog;
  final DateTime? updatedAt;

  // ── Firestore ───────────────────────────────────────────────

  factory UpdateConfig.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UpdateConfig.fromMap(data);
  }

  factory UpdateConfig.fromMap(Map<String, dynamic> data) {
    return UpdateConfig(
      isEnabled: data['isEnabled'] as bool? ?? false,
      isForce: data['isForce'] as bool? ?? false,
      currentVersion: data['currentVersion'] as String? ?? '1.0.0',
      minRequiredVersion: data['minRequiredVersion'] as String? ?? '1.0.0',
      title: data['title'] as String? ?? 'تحديث جديد متاح',
      description: data['description'] as String? ?? '',
      changelogItems: _parseStringList(data['changelogItems']),
      storeUrl: data['storeUrl'] as String? ?? '',
      style: DialogStyle.fromString(data['style'] as String?),
      primaryColor: _parseColor(data['primaryColor']),
      dismissAfterSeconds:
          (data['dismissAfterSeconds'] as num?)?.toInt() ?? 5,
      dismissible: data['dismissible'] as bool? ?? true,
      showCountdown: data['showCountdown'] as bool? ?? true,
      redirectDelay: (data['redirectDelay'] as num?)?.toInt() ?? 0,
      backgroundBlur: (data['backgroundBlur'] as num?)?.toDouble() ?? 20.0,
      backgroundOpacity:
          (data['backgroundOpacity'] as num?)?.toDouble() ?? 0.6,
      cornerRadius: (data['cornerRadius'] as num?)?.toDouble() ?? 24.0,
      showChangelogInDialog:
          data['showChangelogInDialog'] as bool? ?? true,
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'isEnabled': isEnabled,
        'isForce': isForce,
        'currentVersion': currentVersion,
        'minRequiredVersion': minRequiredVersion,
        'title': title,
        'description': description,
        'changelogItems': changelogItems,
        'storeUrl': storeUrl,
        'style': style.name,
        'primaryColor':
            '#${primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        'dismissAfterSeconds': dismissAfterSeconds,
        'dismissible': dismissible,
        'showCountdown': showCountdown,
        'redirectDelay': redirectDelay,
        'backgroundBlur': backgroundBlur,
        'backgroundOpacity': backgroundOpacity,
        'cornerRadius': cornerRadius,
        'showChangelogInDialog': showChangelogInDialog,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  // ── CopyWith ────────────────────────────────────────────────

  UpdateConfig copyWith({
    bool? isEnabled,
    bool? isForce,
    String? currentVersion,
    String? minRequiredVersion,
    String? title,
    String? description,
    List<String>? changelogItems,
    String? storeUrl,
    DialogStyle? style,
    Color? primaryColor,
    int? dismissAfterSeconds,
    bool? dismissible,
    bool? showCountdown,
    int? redirectDelay,
    double? backgroundBlur,
    double? backgroundOpacity,
    double? cornerRadius,
    bool? showChangelogInDialog,
    DateTime? updatedAt,
  }) {
    return UpdateConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      isForce: isForce ?? this.isForce,
      currentVersion: currentVersion ?? this.currentVersion,
      minRequiredVersion: minRequiredVersion ?? this.minRequiredVersion,
      title: title ?? this.title,
      description: description ?? this.description,
      changelogItems: changelogItems ?? this.changelogItems,
      storeUrl: storeUrl ?? this.storeUrl,
      style: style ?? this.style,
      primaryColor: primaryColor ?? this.primaryColor,
      dismissAfterSeconds: dismissAfterSeconds ?? this.dismissAfterSeconds,
      dismissible: dismissible ?? this.dismissible,
      showCountdown: showCountdown ?? this.showCountdown,
      redirectDelay: redirectDelay ?? this.redirectDelay,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      showChangelogInDialog:
          showChangelogInDialog ?? this.showChangelogInDialog,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<String>().toList();
  }

  static Color _parseColor(dynamic value) {
    if (value is String && value.startsWith('#') && value.length >= 7) {
      final hex = value.replaceFirst('#', '');
      final intVal = int.tryParse(hex, radix: 16);
      if (intVal != null) {
        return Color(intVal | 0xFF000000);
      }
    }
    return const Color(0xFF4CAF72);
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

// ─────────────────────────────────────────────────────────────
// UPDATE CHECK RESULT
// ─────────────────────────────────────────────────────────────

/// Result of comparing the installed app version against [UpdateConfig].
class UpdateCheckResult {
  const UpdateCheckResult({
    required this.hasUpdate,
    required this.isForced,
    required this.config,
  });

  /// Whether a newer version is available.
  final bool hasUpdate;

  /// Whether the update is mandatory (cannot be dismissed).
  final bool isForced;

  /// The full update configuration.
  final UpdateConfig config;
}
