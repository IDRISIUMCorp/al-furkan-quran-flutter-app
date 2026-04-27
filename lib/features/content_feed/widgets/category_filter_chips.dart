import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:al_furkan/core/models/content_post.dart';

/// Horizontal scrollable category filter chips.
/// تصميم نظيف ومتناسق مع روح التطبيق
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.activeCategory,
    required this.onChanged,
  });

  final ContentCategory? activeCategory;
  final ValueChanged<ContentCategory?> onChanged;

  IconData _categoryIcon(ContentCategory? cat) => switch (cat) {
        null => FluentIcons.grid_24_regular,
        ContentCategory.tilawa => FluentIcons.book_open_24_regular,
        ContentCategory.tafsir => FluentIcons.text_description_24_regular,
        ContentCategory.fiqh => FluentIcons.scales_24_regular,
        ContentCategory.duaa => FluentIcons.hand_right_24_regular,
        ContentCategory.mawa3iz => FluentIcons.heart_24_regular,
        ContentCategory.general => FluentIcons.star_24_regular,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? const Color(0xFF839788) : const Color(0xFF73877B);

    final categories = [null, ...ContentCategory.values];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = cat == activeCategory;
          final label = cat?.arabicLabel ?? 'الكل';

          return GestureDetector(
            onTap: () => onChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? accentColor
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? accentColor
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06)),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categoryIcon(cat),
                    size: 16,
                    color: isActive
                        ? Colors.white
                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                      fontFamily: 'Cairo-Regular',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
