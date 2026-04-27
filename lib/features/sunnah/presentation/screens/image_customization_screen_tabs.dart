import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../core/theme/sunnah_theme.dart';
import '../../models/image_customization_model.dart';
import '../widgets/customization_widgets.dart';

/// Extension للـ tabs
extension ImageCustomizationTabs on State {
  /// 📝 TEXT TAB
  Widget buildTextTab(
    ImageCustomizationSettings settings,
    Function(ImageCustomizationSettings) onUpdate,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(SunnahTheme.space24),
      children: [
        buildSectionTitle('نوع الخط', Icons.font_download_rounded, isDark),
        const Gap(16),
        FontFamilySelector(
          selected: settings.fontFamily,
          onChanged: (font) => onUpdate(settings.copyWith(fontFamily: font)),
          isDark: isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('أحجام النصوص', Icons.format_size_rounded, isDark),
        const Gap(16),
        buildSlider(
          'حجم العنوان',
          settings.titleFontSize,
          20.0,
          60.0,
          (value) => onUpdate(settings.copyWith(titleFontSize: value)),
          isDark,
        ),
        const Gap(16),
        buildSlider(
          'حجم الوصف',
          settings.descriptionFontSize,
          14.0,
          32.0,
          (value) => onUpdate(settings.copyWith(descriptionFontSize: value)),
          isDark,
        ),
        const Gap(16),
        buildSlider(
          'حجم الدليل',
          settings.evidenceFontSize,
          12.0,
          24.0,
          (value) => onUpdate(settings.copyWith(evidenceFontSize: value)),
          isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('ألوان النصوص', Icons.palette_rounded, isDark),
        const Gap(16),
        ColorPickerTile(
          label: 'لون العنوان',
          color: settings.titleColor,
          onChanged: (color) => onUpdate(settings.copyWith(titleColor: color)),
          isDark: isDark,
        ),
        const Gap(16),
        ColorPickerTile(
          label: 'لون الوصف',
          color: settings.descriptionColor,
          onChanged: (color) => onUpdate(settings.copyWith(descriptionColor: color)),
          isDark: isDark,
        ),
        const Gap(16),
        ColorPickerTile(
          label: 'لون الدليل',
          color: settings.evidenceColor,
          onChanged: (color) => onUpdate(settings.copyWith(evidenceColor: color)),
          isDark: isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('محاذاة النص', Icons.format_align_right_rounded, isDark),
        const Gap(16),
        buildTextAlignSelector(
          settings.textAlign,
          (align) => onUpdate(settings.copyWith(textAlign: align)),
          isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('تباعد الأسطر', Icons.format_line_spacing_rounded, isDark),
        const Gap(16),
        buildSlider(
          'المسافة بين الأسطر',
          settings.lineHeight,
          1.0,
          2.5,
          (value) => onUpdate(settings.copyWith(lineHeight: value)),
          isDark,
        ),
      ],
    );
  }

  /// 🎯 ELEMENTS TAB
  Widget buildElementsTab(
    ImageCustomizationSettings settings,
    Function(ImageCustomizationSettings) onUpdate,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(SunnahTheme.space24),
      children: [
        buildSectionTitle('الرأسية (Header)', Icons.title_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'إظهار الرأسية',
          settings.showHeader,
          (value) => onUpdate(settings.copyWith(showHeader: value)),
          isDark,
        ),
        if (settings.showHeader) ...[
          const Gap(16),
          buildHeaderStyleSelector(
            settings.headerStyle,
            (style) => onUpdate(settings.copyWith(headerStyle: style)),
            isDark,
          ),
          const Gap(16),
          ColorPickerTile(
            label: 'لون الرأسية',
            color: settings.headerColor,
            onChanged: (color) => onUpdate(settings.copyWith(headerColor: color)),
            isDark: isDark,
          ),
        ],
        
        const Gap(24),
        buildSectionTitle('الأيقونة', Icons.emoji_emotions_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'إظهار الأيقونة',
          settings.showIcon,
          (value) => onUpdate(settings.copyWith(showIcon: value)),
          isDark,
        ),
        if (settings.showIcon) ...[
          const Gap(16),
          buildIconStyleSelector(
            settings.iconStyle,
            (style) => onUpdate(settings.copyWith(iconStyle: style)),
            isDark,
          ),
        ],
        
        const Gap(24),
        buildSectionTitle('الشارة (Badge)', Icons.label_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'إظهار الشارة',
          settings.showBadge,
          (value) => onUpdate(settings.copyWith(showBadge: value)),
          isDark,
        ),
        if (settings.showBadge) ...[
          const Gap(16),
          buildBadgeStyleSelector(
            settings.badgeStyle,
            (style) => onUpdate(settings.copyWith(badgeStyle: style)),
            isDark,
          ),
          const Gap(16),
          ColorPickerTile(
            label: 'لون الشارة',
            color: settings.badgeColor,
            onChanged: (color) => onUpdate(settings.copyWith(badgeColor: color)),
            isDark: isDark,
          ),
        ],
        
        const Gap(24),
        buildSectionTitle('التذييل (Footer)', Icons.text_fields_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'إظهار التذييل',
          settings.showFooter,
          (value) => onUpdate(settings.copyWith(showFooter: value)),
          isDark,
        ),
        if (settings.showFooter) ...[
          const Gap(16),
          buildTextField(
            'نص التذييل',
            settings.footerText,
            (text) => onUpdate(settings.copyWith(footerText: text)),
            isDark,
          ),
          const Gap(16),
          ColorPickerTile(
            label: 'لون التذييل',
            color: settings.footerColor,
            onChanged: (color) => onUpdate(settings.copyWith(footerColor: color)),
            isDark: isDark,
          ),
          const Gap(16),
          buildSlider(
            'حجم خط التذييل',
            settings.footerFontSize,
            10.0,
            20.0,
            (value) => onUpdate(settings.copyWith(footerFontSize: value)),
            isDark,
          ),
        ],
      ],
    );
  }

  /// ✨ DECORATIONS TAB
  Widget buildDecorationsTab(
    ImageCustomizationSettings settings,
    Function(ImageCustomizationSettings) onUpdate,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(SunnahTheme.space24),
      children: [
        buildSectionTitle('الزخرفة العلوية', Icons.auto_awesome_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'إظهار الزخرفة العلوية',
          settings.showTopDecoration,
          (value) => onUpdate(settings.copyWith(showTopDecoration: value)),
          isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('الزخرفة السفلية', Icons.auto_awesome_rounded, isDark),
        const Gap(16),
        buildSwitch(
          'إظهار الزخرفة السفلية',
          settings.showBottomDecoration,
          (value) => onUpdate(settings.copyWith(showBottomDecoration: value)),
          isDark,
        ),
        
        if (settings.showTopDecoration || settings.showBottomDecoration) ...[
          const Gap(24),
          buildSectionTitle('نوع الزخرفة', Icons.category_rounded, isDark),
          const Gap(16),
          buildDecorationTypeSelector(
            settings.decorationType,
            (type) => onUpdate(settings.copyWith(decorationType: type)),
            isDark,
          ),
          const Gap(16),
          ColorPickerTile(
            label: 'لون الزخرفة',
            color: settings.decorationColor,
            onChanged: (color) => onUpdate(settings.copyWith(decorationColor: color)),
            isDark: isDark,
          ),
        ],
        
        const Gap(24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SunnahTheme.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
            border: Border.all(
              color: SunnahTheme.green.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: SunnahTheme.green,
                size: 32,
              ),
              const Gap(12),
              Text(
                'الزخارف تضيف لمسة جمالية إسلامية للصورة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: SunnahTheme.green,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📏 SIZE TAB
  Widget buildSizeTab(
    ImageCustomizationSettings settings,
    Function(ImageCustomizationSettings) onUpdate,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(SunnahTheme.space24),
      children: [
        buildSectionTitle('حجم الصورة', Icons.photo_size_select_large_rounded, isDark),
        const Gap(16),
        ImageSizeSelector(
          selected: settings.imageSize,
          onChanged: (size) => onUpdate(settings.copyWith(imageSize: size)),
          isDark: isDark,
        ),
        
        const Gap(24),
        buildSectionTitle('جودة الصورة', Icons.high_quality_rounded, isDark),
        const Gap(16),
        buildQualitySelector(
          settings.imageQuality,
          (quality) => onUpdate(settings.copyWith(imageQuality: quality)),
          isDark,
        ),
        
        const Gap(24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SunnahTheme.green.withValues(alpha: 0.1),
                SunnahTheme.gold.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
            border: Border.all(
              color: SunnahTheme.green.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.tips_and_updates_rounded,
                color: SunnahTheme.green,
                size: 32,
              ),
              const Gap(12),
              Text(
                'نصيحة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: SunnahTheme.green,
                ),
              ),
              const Gap(8),
              Text(
                'استخدم حجم إنستجرام للقصص، ومربع للمنشورات العادية',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SunnahTheme.getTextSecondaryColor(isDark),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════

  Widget buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: SunnahTheme.green, size: 24),
        const Gap(12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: SunnahTheme.getTextPrimaryColor(isDark),
          ),
        ),
      ],
    );
  }

  Widget buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: SunnahTheme.getTextSecondaryColor(isDark),
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: SunnahTheme.green,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: SunnahTheme.green,
          inactiveColor: SunnahTheme.green.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SunnahTheme.getTextPrimaryColor(isDark),
            ),
          ),
          Switch(
            value: value,
            activeColor: SunnahTheme.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    String value,
    Function(String) onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: SunnahTheme.getTextSecondaryColor(isDark),
          ),
        ),
        const Gap(8),
        TextField(
          controller: TextEditingController(text: value),
          onChanged: onChanged,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: SunnahTheme.getSurfaceColor(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              borderSide: BorderSide(
                color: SunnahTheme.getBorderColor(isDark),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              borderSide: BorderSide(
                color: SunnahTheme.getBorderColor(isDark),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
              borderSide: const BorderSide(
                color: SunnahTheme.green,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextAlignSelector(
    TextAlign selected,
    Function(TextAlign) onChanged,
    bool isDark,
  ) {
    return Row(
      children: [
        _buildAlignButton(TextAlign.right, Icons.format_align_right_rounded, selected, onChanged, isDark),
        const Gap(12),
        _buildAlignButton(TextAlign.center, Icons.format_align_center_rounded, selected, onChanged, isDark),
        const Gap(12),
        _buildAlignButton(TextAlign.left, Icons.format_align_left_rounded, selected, onChanged, isDark),
      ],
    );
  }

  Widget _buildAlignButton(
    TextAlign align,
    IconData icon,
    TextAlign selected,
    Function(TextAlign) onChanged,
    bool isDark,
  ) {
    final isSelected = align == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(align),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? SunnahTheme.green.withValues(alpha: 0.15)
                : SunnahTheme.getSurfaceColor(isDark),
            borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
            border: Border.all(
              color: isSelected
                  ? SunnahTheme.green
                  : SunnahTheme.getBorderColor(isDark),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? SunnahTheme.green
                : SunnahTheme.getTextSecondaryColor(isDark),
          ),
        ),
      ),
    );
  }

  Widget buildHeaderStyleSelector(
    HeaderStyle selected,
    Function(HeaderStyle) onChanged,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: HeaderStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withValues(alpha: 0.15)
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
              _getHeaderStyleLabel(style),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
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

  Widget buildIconStyleSelector(
    IconStyle selected,
    Function(IconStyle) onChanged,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: IconStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withValues(alpha: 0.15)
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
              _getIconStyleLabel(style),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
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

  Widget buildBadgeStyleSelector(
    BadgeStyle selected,
    Function(BadgeStyle) onChanged,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: BadgeStyle.values.map((style) {
        final isSelected = style == selected;
        return GestureDetector(
          onTap: () => onChanged(style),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withValues(alpha: 0.15)
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
              _getBadgeStyleLabel(style),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
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

  Widget buildDecorationTypeSelector(
    DecorationType selected,
    Function(DecorationType) onChanged,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: DecorationType.values.map((type) {
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SunnahTheme.green.withValues(alpha: 0.15)
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
              _getDecorationTypeLabel(type),
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
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

  Widget buildQualitySelector(
    ImageQuality selected,
    Function(ImageQuality) onChanged,
    bool isDark,
  ) {
    return Column(
      children: ImageQuality.values.map((quality) {
        final isSelected = quality == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onChanged(quality),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? SunnahTheme.green.withValues(alpha: 0.15)
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
                      _getQualityLabel(quality),
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
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

  // Label helpers
  String _getHeaderStyleLabel(HeaderStyle style) {
    switch (style) {
      case HeaderStyle.simple:
        return 'بسيط';
      case HeaderStyle.gradient:
        return 'متدرج';
      case HeaderStyle.outlined:
        return 'محدد';
      case HeaderStyle.filled:
        return 'ممتلئ';
    }
  }

  String _getIconStyleLabel(IconStyle style) {
    switch (style) {
      case IconStyle.filled:
        return 'ممتلئ';
      case IconStyle.outlined:
        return 'محدد';
      case IconStyle.gradient:
        return 'متدرج';
      case IconStyle.none:
        return 'بدون';
    }
  }

  String _getBadgeStyleLabel(BadgeStyle style) {
    switch (style) {
      case BadgeStyle.rounded:
        return 'دائري';
      case BadgeStyle.square:
        return 'مربع';
      case BadgeStyle.pill:
        return 'حبة';
      case BadgeStyle.minimal:
        return 'بسيط';
    }
  }

  String _getDecorationTypeLabel(DecorationType type) {
    switch (type) {
      case DecorationType.none:
        return 'بدون';
      case DecorationType.islamic:
        return 'إسلامي';
      case DecorationType.floral:
        return 'زهري';
      case DecorationType.geometric:
        return 'هندسي';
      case DecorationType.simple:
        return 'بسيط';
    }
  }

  String _getQualityLabel(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 'منخفضة (سريعة)';
      case ImageQuality.medium:
        return 'متوسطة';
      case ImageQuality.high:
        return 'عالية (موصى بها)';
      case ImageQuality.ultra:
        return 'فائقة الجودة';
    }
  }
}
