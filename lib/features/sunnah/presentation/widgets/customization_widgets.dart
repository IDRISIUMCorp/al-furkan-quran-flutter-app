import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../core/theme/sunnah_theme.dart';
import '../../models/image_customization_model.dart';

/// 🎨 Color Picker Widget
class ColorPickerTile extends StatelessWidget {
  final String label;
  final Color color;
  final Function(Color) onChanged;
  final bool isDark;

  const ColorPickerTile({
    super.key,
    required this.label,
    required this.color,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SunnahTheme.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
        border: Border.all(
          color: SunnahTheme.getBorderColor(isDark),
          width: SunnahTheme.borderStandard,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: SunnahTheme.getTextPrimaryColor(isDark),
              ),
            ),
          ),
          const Gap(12),
          GestureDetector(
            onTap: () => _showColorPicker(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(SunnahTheme.radiusSmall),
                border: Border.all(
                  color: SunnahTheme.getBorderColor(isDark),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'اختر اللون',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _getPredefinedColors(context).map((c) {
              return GestureDetector(
                onTap: () {
                  onChanged(c);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: c == color ? Colors.black : Colors.grey.shade300,
                      width: c == color ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  static List<Color> _getPredefinedColors(BuildContext context) => [
    // 6. Very Dark Mode (Charcoal equivalent)
    Theme.of(context).colorScheme.surface,
    const Color(0xFF4A7C59),
    const Color(0xFFC9A84C),
    const Color(0xFF2C2C2C),
    const Color(0xFF6B6B6B),
    const Color(0xFFDDD9CC),
    
    // Additional colors
    const Color(0xFFFFFFFF),
    const Color(0xFF000000),
    const Color(0xFF2D7A4F),
    const Color(0xFF10B981),
    const Color(0xFF3B82F6),
    const Color(0xFFEC4899),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    
    // Pastels
    const Color(0xFFFEF3C7),
    const Color(0xFFD1FAE5),
    const Color(0xFFDBEAFE),
    const Color(0xFFFCE7F3),
    const Color(0xFFFEE2E2),
    const Color(0xFFEDE9FE),
  ];
}

/// 📐 Background Type Selector
class BackgroundTypeSelector extends StatelessWidget {
  final BackgroundType selected;
  final Function(BackgroundType) onChanged;
  final bool isDark;

  const BackgroundTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: BackgroundType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withOpacity(0.15)
                  : SunnahTheme.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getBorderColor(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              type.label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getTextSecondaryColor(isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 🎯 Layout Style Selector
class LayoutStyleSelector extends StatelessWidget {
  final LayoutStyle selected;
  final Function(LayoutStyle) onChanged;
  final bool isDark;

  const LayoutStyleSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: LayoutStyle.values.length,
      itemBuilder: (context, index) {
        final style = LayoutStyle.values[index];
        final isSelected = style == selected;
        
        return GestureDetector(
          onTap: () => onChanged(style),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withOpacity(0.15)
                  : SunnahTheme.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getBorderColor(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getLayoutIcon(style),
                  color: isSelected
                      ? SunnahTheme.green
                      : SunnahTheme.getTextSecondaryColor(isDark),
                  size: 32,
                ),
                const Gap(8),
                Text(
                  style.label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? SunnahTheme.green
                        : SunnahTheme.getTextSecondaryColor(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getLayoutIcon(LayoutStyle style) {
    switch (style) {
      case LayoutStyle.modern:
        return Icons.auto_awesome_rounded;
      case LayoutStyle.classic:
        return Icons.menu_book_rounded;
      case LayoutStyle.minimal:
        return Icons.minimize_rounded;
      case LayoutStyle.elegant:
        return Icons.diamond_rounded;
      case LayoutStyle.bold:
        return Icons.format_bold_rounded;
      case LayoutStyle.card:
        return Icons.credit_card_rounded;
    }
  }
}

/// 🎨 Pattern Selector
class PatternSelector extends StatelessWidget {
  final PatternType selected;
  final Function(PatternType) onChanged;
  final bool isDark;

  const PatternSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: PatternType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withOpacity(0.15)
                  : SunnahTheme.getSurfaceColor(isDark),
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              border: Border.all(
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getBorderColor(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              _getPatternLabel(type),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? SunnahTheme.green
                    : SunnahTheme.getTextSecondaryColor(isDark),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getPatternLabel(PatternType type) {
    switch (type) {
      case PatternType.none:
        return 'بدون';
      case PatternType.geometric:
        return 'هندسي';
      case PatternType.islamic:
        return 'إسلامي';
      case PatternType.dots:
        return 'نقاط';
      case PatternType.lines:
        return 'خطوط';
      case PatternType.waves:
        return 'موجات';
    }
  }
}

/// 📏 Image Size Selector
class ImageSizeSelector extends StatelessWidget {
  final ImageSize selected;
  final Function(ImageSize) onChanged;
  final bool isDark;

  const ImageSizeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ImageSize.values.map((size) {
        final isSelected = size == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              if (size == ImageSize.custom) {
                _showCustomSizeDialog(context);
              } else {
                onChanged(size);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? SunnahTheme.green.withOpacity(0.15)
                    : SunnahTheme.getSurfaceColor(isDark),
                borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? SunnahTheme.green
                      : SunnahTheme.getBorderColor(isDark),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSizeIcon(size),
                    color: isSelected
                        ? SunnahTheme.green
                        : SunnahTheme.getTextSecondaryColor(isDark),
                    size: 24,
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          size.label,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w700,
                            color: isSelected
                                ? SunnahTheme.green
                                : SunnahTheme.getTextPrimaryColor(isDark),
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '${size.dimensions.width.toInt()} × ${size.dimensions.height.toInt()}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: SunnahTheme.getTextSecondaryColor(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: SunnahTheme.green,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showCustomSizeDialog(BuildContext context) {
    final saved = ImageSizeExtension.customSize;
    final widthController = TextEditingController(text: saved.width.toInt().toString());
    final heightController = TextEditingController(text: saved.height.toInt().toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'حجم مخصص',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widthController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'العرض (px)',
                labelStyle: GoogleFonts.cairo(),
                border: const OutlineInputBorder(),
              ),
            ),
            const Gap(16),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الارتفاع (px)',
                labelStyle: GoogleFonts.cairo(),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              final w = int.tryParse(widthController.text) ?? 1080;
              final h = int.tryParse(heightController.text) ?? 1080;
              ImageSizeExtension.setCustomSize(w.toDouble(), h.toDouble());
              Navigator.pop(context);
              onChanged(ImageSize.custom);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SunnahTheme.green,
            ),
            child: Text('تطبيق', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  IconData _getSizeIcon(ImageSize size) {
    switch (size) {
      case ImageSize.square1080:
      case ImageSize.square800:
      case ImageSize.square1200:
        return Icons.crop_square_rounded;
      case ImageSize.instagram:
        return Icons.phone_android_rounded;
      case ImageSize.facebook:
        return Icons.facebook_rounded;
      case ImageSize.twitter:
        return Icons.tag_rounded;
      case ImageSize.custom:
        return Icons.settings_rounded;
    }
  }
}

/// 🎯 Font Family Selector
class FontFamilySelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;
  final bool isDark;

  const FontFamilySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  static const List<String> fonts = [
    'Cairo',
    'Amiri',
    'Aref Ruqaa',
    'Noto Sans Arabic',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: fonts.map((font) {
        final isSelected = font == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onChanged(font),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? SunnahTheme.green.withOpacity(0.15)
                    : SunnahTheme.getSurfaceColor(isDark),
                borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? SunnahTheme.green
                      : SunnahTheme.getBorderColor(isDark),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'نموذج نص بخط $font',
                      style: GoogleFonts.getFont(
                        font.replaceAll(' ', ''),
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? SunnahTheme.green
                            : SunnahTheme.getTextPrimaryColor(isDark),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: SunnahTheme.green,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

