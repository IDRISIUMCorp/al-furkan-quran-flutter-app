import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// Pinned badge — شريط ذهبي دقيق ونظيف يظهر فوق البوست المثبت
class PinnedBadge extends StatelessWidget {
  const PinnedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3D3520), const Color(0xFF2E2918)]
              : [const Color(0xFFF5EBD7), const Color(0xFFF0E4CC)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            FluentIcons.pin_24_filled,
            size: 13,
            color: isDark ? const Color(0xFFE8D48B) : const Color(0xFFA58B42),
          ),
          const SizedBox(width: 5),
          Text(
            'مثبت',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFE8D48B) : const Color(0xFF7A6526),
              fontFamily: 'Cairo-Bold',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
