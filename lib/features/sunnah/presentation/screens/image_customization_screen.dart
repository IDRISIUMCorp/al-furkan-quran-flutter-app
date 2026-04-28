import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/sunnah_theme.dart';
import '../../models/image_customization_model.dart';
import '../../services/sunnah_share_service.dart';
import '../widgets/customization_widgets.dart';

/// 🎨 شاشة تخصيص الصورة - تصميم احترافي كامل متكامل
/// 
/// المميزات:
/// ✅ معاينة حية ديناميكية
/// ✅ 6 تابات للتخصيص الكامل
/// ✅ تصميم responsive للموبايل والتابلت
/// ✅ حفظ وتحميل الإعدادات
/// ✅ قوالب جاهزة
/// ✅ تصدير بجودة عالية
class ImageCustomizationScreen extends StatefulWidget {
  final String title;
  final String description;
  final String? evidence;
  final String type;
  final String? badgeText;
  final Color? badgeColor;

  const ImageCustomizationScreen({
    super.key,
    required this.title,
    required this.description,
    this.evidence,
    required this.type,
    this.badgeText,
    this.badgeColor,
  });

  @override
  State<ImageCustomizationScreen> createState() => _ImageCustomizationScreenState();
}

class _ImageCustomizationScreenState extends State<ImageCustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ImageCustomizationSettings _settings;
  bool _isGenerating = false;
  Uint8List? _previewImageBytes; // للمعاينة الحية
  bool _isGeneratingPreview = false;
  
  // للتحكم في تحديث المعاينة
  DateTime? _lastPreviewUpdate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _settings = ImageCustomizationSettings();
    
    // توليد المعاينة الأولية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generatePreview();
    });
    
    // استماع للتغييرات في التابات
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  /// توليد معاينة حية للصورة
  Future<void> _generatePreview() async {
    // منع التحديثات المتكررة جداً
    final now = DateTime.now();
    if (_lastPreviewUpdate != null && 
        now.difference(_lastPreviewUpdate!).inMilliseconds < 300) {
      return;
    }
    _lastPreviewUpdate = now;
    
    if (_isGeneratingPreview) return;
    
    setState(() => _isGeneratingPreview = true);
    
    try {
      debugPrint('🎨 Generating preview with size: ${_settings.imageSize.label}');
      
      final bytes = await SunnahShareService.generateImageBytes(
        title: widget.title,
        description: widget.description,
        evidence: widget.evidence,
        type: widget.type,
        badgeText: widget.badgeText,
        badgeColor: widget.badgeColor,
        settings: _settings,
      );
      
      debugPrint('✅ Preview generated: ${bytes.length} bytes');
      
      if (mounted) {
        setState(() {
          _previewImageBytes = bytes;
          _isGeneratingPreview = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error generating preview: $e');
      if (mounted) {
        setState(() => _isGeneratingPreview = false);
      }
    }
  }
  
  /// تحديث الإعدادات وإعادة توليد المعاينة
  void _updateSettings(ImageCustomizationSettings newSettings) {
    debugPrint('🔄 Updating settings...');
    setState(() => _settings = newSettings);
    
    // تحديث المعاينة بعد delay صغير
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _generatePreview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E14) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: isWide ? _buildWideLayout(isDark) : _buildNarrowLayout(isDark),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // LAYOUTS
  // ═══════════════════════════════════════════

  /// تخطيط للشاشات الكبيرة (Tablet/Desktop)
  Widget _buildWideLayout(bool isDark) {
    return Row(
      children: [
        // المعاينة الحية على اليسار (دائماً ظاهرة)
        Expanded(
          flex: 2,
          child: _buildLivePreviewPanel(isDark),
        ),
        // الإعدادات على اليمين
        Expanded(
          flex: 3,
          child: _buildSettingsPanel(isDark),
        ),
      ],
    );
  }

  /// تخطيط للشاشات الصغيرة (Mobile)
  Widget _buildNarrowLayout(bool isDark) {
    return Column(
      children: [
        // هيدر صغير
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showTemplatesDialog(isDark),
                icon: const Icon(Icons.dashboard_customize_rounded, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _resetSettings,
                icon: const Icon(Icons.refresh_rounded, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        // المعاينة
        Expanded(
          flex: 2,
          child: _buildLargePreviewPanel(isDark),
        ),
        // الإعدادات
        Expanded(
          flex: 3,
          child: _buildSettingsPanel(isDark),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // TAB CONTENT HELPERS
  // ═══════════════════════════════════════════
  
  // ═══════════════════════════════════════════
  // HEADER & PREVIEW PANELS
  // ═══════════════════════════════════════════

  /// معاينة كبيرة للموبايل (دائماً ظاهرة)
  Widget _buildLargePreviewPanel(bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF0A0E14) : const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(8),
      child: _buildPreviewContent(isDark),
    );
  }

  /// معاينة كاملة للشاشات الكبيرة
  Widget _buildLivePreviewPanel(bool isDark) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? const Color(0xFF0A0E14) : const Color(0xFFF5F7FA),
      child: _buildPreviewContent(isDark),
    );
  }
  
  /// محتوى المعاينة (الصورة الفعلية)
  Widget _buildPreviewContent(bool isDark) {
    if (_isGeneratingPreview) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(SunnahTheme.green),
            ),
            const Gap(16),
            Text(
              'جاري إنشاء المعاينة...',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_previewImageBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: 64,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
            const Gap(16),
            Text(
              'لا توجد معاينة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }
    
    // حساب الـ aspect ratio من حجم الصورة المختار
    final imageSize = _settings.imageSize.dimensions;
    final aspectRatio = imageSize.width / imageSize.height;
    
    // عرض الصورة بالـ aspect ratio الصحيح
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Image.memory(
              key: ValueKey('${_settings.imageSize.label}_${_previewImageBytes!.length}'),
              _previewImageBytes!,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // SETTINGS PANEL
  // ═══════════════════════════════════════════

  /// لوحة الإعدادات
  Widget _buildSettingsPanel(bool isDark) {
    return Column(
      children: [
        _buildTabBar(isDark),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBackgroundTab(isDark),
              _buildLayoutTab(isDark),
              _buildTextTab(isDark),
              _buildElementsTab(isDark),
              _buildDecorationsTab(isDark),
              _buildSizeTab(isDark),
            ],
          ),
        ),
        _buildBottomBar(isDark),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: SunnahTheme.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: SunnahTheme.green,
        unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
        labelStyle: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.all(6),
        tabs: const [
          Tab(icon: Icon(Icons.palette_rounded, size: 20), text: 'الخلفية'),
          Tab(icon: Icon(Icons.dashboard_rounded, size: 20), text: 'التخطيط'),
          Tab(icon: Icon(Icons.text_fields_rounded, size: 20), text: 'النصوص'),
          Tab(icon: Icon(Icons.widgets_rounded, size: 20), text: 'العناصر'),
          Tab(icon: Icon(Icons.auto_awesome_rounded, size: 20), text: 'الزخارف'),
          Tab(icon: Icon(Icons.photo_size_select_large_rounded, size: 20), text: 'الحجم'),
        ],
      ),
    );
  }
  // ═══════════════════════════════════════════
  // TABS
  // ═══════════════════════════════════════════

  /// تاب الخلفية
  Widget _buildBackgroundTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          isDark: isDark,
          title: 'نوع الخلفية',
          icon: Icons.layers_rounded,
          child: BackgroundTypeSelector(
            selected: _settings.backgroundType,
            onChanged: (type) => _updateSettings(_settings.copyWith(backgroundType: type)),
            isDark: isDark,
          ),
        ),
        const Gap(16),
        if (_settings.backgroundType == BackgroundType.solid)
          _buildSectionCard(
            isDark: isDark,
            title: 'لون الخلفية',
            icon: Icons.color_lens_rounded,
            child: ColorPickerTile(
              label: 'اللون',
              color: _settings.backgroundColor,
              onChanged: (color) => _updateSettings(_settings.copyWith(backgroundColor: color)),
              isDark: isDark,
            ),
          ),
        if (_settings.backgroundType == BackgroundType.gradient) ...[
          _buildSectionCard(
            isDark: isDark,
            title: 'ألوان التدرج',
            icon: Icons.gradient_rounded,
            child: Column(
              children: [
                ColorPickerTile(
                  label: 'اللون الأول',
                  color: _settings.gradientStartColor,
                  onChanged: (color) => _updateSettings(_settings.copyWith(gradientStartColor: color)),
                  isDark: isDark,
                ),
                const Gap(12),
                ColorPickerTile(
                  label: 'اللون الثاني',
                  color: _settings.gradientEndColor,
                  onChanged: (color) => _updateSettings(_settings.copyWith(gradientEndColor: color)),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
        if (_settings.backgroundType == BackgroundType.pattern) ...[
          _buildSectionCard(
            isDark: isDark,
            title: 'النمط',
            icon: Icons.pattern_rounded,
            child: Column(
              children: [
                ColorPickerTile(
                  label: 'لون الخلفية',
                  color: _settings.backgroundColor,
                  onChanged: (color) => _updateSettings(_settings.copyWith(backgroundColor: color)),
                  isDark: isDark,
                ),
                const Gap(16),
                PatternSelector(
                  selected: _settings.patternType,
                  onChanged: (type) => _updateSettings(_settings.copyWith(patternType: type)),
                  isDark: isDark,
                ),
                const Gap(16),
                _buildSliderTile(
                  label: 'شفافية النمط',
                  value: _settings.patternOpacity * 100,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  unit: '%',
                  onChanged: (value) => _updateSettings(_settings.copyWith(patternOpacity: value / 100)),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// تاب التخطيط
  Widget _buildLayoutTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          isDark: isDark,
          title: 'نمط التخطيط',
          icon: Icons.dashboard_customize_rounded,
          child: LayoutStyleSelector(
            selected: _settings.layoutStyle,
            onChanged: (style) => _updateSettings(_settings.copyWith(layoutStyle: style)),
            isDark: isDark,
          ),
        ),
        const Gap(16),
        _buildSectionCard(
          isDark: isDark,
          title: 'استدارة الزوايا',
          icon: Icons.rounded_corner_rounded,
          child: _buildSliderTile(
            label: 'الاستدارة',
            value: _settings.cardRadius,
            min: 0,
            max: 40,
            divisions: 20,
            unit: 'px',
            onChanged: (value) => _updateSettings(_settings.copyWith(cardRadius: value)),
            isDark: isDark,
          ),
        ),
        const Gap(16),
        _buildSectionCard(
          isDark: isDark,
          title: 'المسافات',
          icon: Icons.space_bar_rounded,
          child: _buildSliderTile(
            label: 'المسافة الداخلية',
            value: _settings.cardPadding,
            min: 12,
            max: 48,
            divisions: 18,
            unit: 'px',
            onChanged: (value) => _updateSettings(_settings.copyWith(cardPadding: value)),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  /// تاب النصوص
  Widget _buildTextTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          isDark: isDark,
          title: 'نوع الخط',
          icon: Icons.font_download_rounded,
          child: FontFamilySelector(
            selected: _settings.fontFamily,
            onChanged: (font) => _updateSettings(_settings.copyWith(fontFamily: font)),
            isDark: isDark,
          ),
        ),
        const Gap(16),
        _buildSectionCard(
          isDark: isDark,
          title: 'خط العنوان',
          icon: Icons.title_rounded,
          child: Column(
            children: [
              _buildSliderTile(
                label: 'الحجم',
                value: _settings.titleFontSize,
                min: 20,
                max: 48,
                divisions: 28,
                unit: 'px',
                onChanged: (value) => _updateSettings(_settings.copyWith(titleFontSize: value)),
                isDark: isDark,
              ),
              const Gap(12),
              ColorPickerTile(
                label: 'اللون',
                color: _settings.titleColor,
                onChanged: (color) => _updateSettings(_settings.copyWith(titleColor: color)),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const Gap(16),
        _buildSectionCard(
          isDark: isDark,
          title: 'خط الوصف',
          icon: Icons.description_rounded,
          child: Column(
            children: [
              _buildSliderTile(
                label: 'الحجم',
                value: _settings.descriptionFontSize,
                min: 14,
                max: 32,
                divisions: 18,
                unit: 'px',
                onChanged: (value) => _updateSettings(_settings.copyWith(descriptionFontSize: value)),
                isDark: isDark,
              ),
              const Gap(12),
              ColorPickerTile(
                label: 'اللون',
                color: _settings.descriptionColor,
                onChanged: (color) => _updateSettings(_settings.copyWith(descriptionColor: color)),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const Gap(16),
        _buildSectionCard(
          isDark: isDark,
          title: 'خط الدليل',
          icon: Icons.menu_book_rounded,
          child: Column(
            children: [
              _buildSliderTile(
                label: 'الحجم',
                value: _settings.evidenceFontSize,
                min: 12,
                max: 24,
                divisions: 12,
                unit: 'px',
                onChanged: (value) => _updateSettings(_settings.copyWith(evidenceFontSize: value)),
                isDark: isDark,
              ),
              const Gap(12),
              ColorPickerTile(
                label: 'اللون',
                color: _settings.evidenceColor,
                onChanged: (color) => _updateSettings(_settings.copyWith(evidenceColor: color)),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// تاب العناصر
  Widget _buildElementsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          isDark: isDark,
          title: 'الهيدر',
          icon: Icons.view_headline_rounded,
          child: _buildSwitchTile(
            title: 'إظهار الهيدر',
            value: _settings.showHeader,
            onChanged: (value) => _updateSettings(_settings.copyWith(showHeader: value)),
            isDark: isDark,
          ),
        ),
        const Gap(16),
        _buildSectionCard(
          isDark: isDark,
          title: 'البادج',
          icon: Icons.label_rounded,
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'إظهار البادج',
                value: _settings.showBadge,
                onChanged: (value) => _updateSettings(_settings.copyWith(showBadge: value)),
                isDark: isDark,
              ),
              if (_settings.showBadge) ...[
                const Gap(12),
                ColorPickerTile(
                  label: 'لون البادج',
                  color: _settings.badgeColor,
                  onChanged: (color) => _updateSettings(_settings.copyWith(badgeColor: color)),
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
        const Gap(16),
        _buildSectionCard(
          isDark: isDark,
          title: 'الفوتر',
          icon: Icons.view_agenda_rounded,
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'إظهار الفوتر',
                value: _settings.showFooter,
                onChanged: (value) => _updateSettings(_settings.copyWith(showFooter: value)),
                isDark: isDark,
              ),
              if (_settings.showFooter) ...[
                const Gap(12),
                ColorPickerTile(
                  label: 'لون الفوتر',
                  color: _settings.footerColor,
                  onChanged: (color) => _updateSettings(_settings.copyWith(footerColor: color)),
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// تاب الزخارف
  Widget _buildDecorationsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          isDark: isDark,
          title: 'الزخارف',
          icon: Icons.auto_awesome_rounded,
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'زخرفة علوية',
                value: _settings.showTopDecoration,
                onChanged: (value) => _updateSettings(_settings.copyWith(showTopDecoration: value)),
                isDark: isDark,
              ),
              const Gap(12),
              _buildSwitchTile(
                title: 'زخرفة سفلية',
                value: _settings.showBottomDecoration,
                onChanged: (value) => _updateSettings(_settings.copyWith(showBottomDecoration: value)),
                isDark: isDark,
              ),
            ],
          ),
        ),
        const Gap(16),
        _buildSectionCard(
          isDark: isDark,
          title: 'لون الزخرفة',
          icon: Icons.color_lens_rounded,
          child: ColorPickerTile(
            label: 'اللون',
            color: _settings.decorationColor,
            onChanged: (color) => _updateSettings(_settings.copyWith(decorationColor: color)),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  /// تاب الحجم
  Widget _buildSizeTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          isDark: isDark,
          title: 'حجم الصورة',
          icon: Icons.photo_size_select_large_rounded,
          child: ImageSizeSelector(
            selected: _settings.imageSize,
            onChanged: (size) => _updateSettings(_settings.copyWith(imageSize: size)),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // BOTTOM BAR
  // ═══════════════════════════════════════════

  /// Bottom Bar - بدون زر المعاينة
  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : () => _generateAndShare(isDark),
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.share_rounded, size: 20),
        label: Text(
          _isGenerating ? 'جاري الإنشاء...' : 'إنشاء ومشاركة',
          style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: SunnahTheme.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
        ),
      ).animate(target: _isGenerating ? 1 : 0).shimmer(
        duration: 1500.ms,
        color: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SunnahTheme.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: SunnahTheme.green, size: 18),
              ),
              const Gap(12),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required Function(double) onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: SunnahTheme.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toInt()}$unit',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: SunnahTheme.green,
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: SunnahTheme.green,
            inactiveTrackColor: SunnahTheme.green.withValues(alpha: 0.2),
            thumbColor: SunnahTheme.green,
            overlayColor: SunnahTheme.green.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1F2E),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: SunnahTheme.green,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════

  /// إعادة تعيين الإعدادات
  void _resetSettings() {
    _updateSettings(ImageCustomizationSettings());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh_rounded, color: Colors.white),
            const Gap(12),
            Text('تم إعادة تعيين الإعدادات', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: SunnahTheme.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// إنشاء ومشاركة الصورة
  Future<void> _generateAndShare(bool isDark) async {
    setState(() => _isGenerating = true);

    try {
      await SunnahShareService.shareAsImage(
        context: context,
        title: widget.title,
        description: widget.description,
        evidence: widget.evidence,
        type: widget.type,
        badgeText: widget.badgeText,
        badgeColor: widget.badgeColor,
        settings: _settings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const Gap(12),
                Expanded(
                  child: Text(
                    'تم إنشاء الصورة ومشاركتها بنجاح',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const Gap(12),
                Expanded(
                  child: Text('حدث خطأ: ${e.toString()}', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  /// عرض القوالب الجاهزة
  void _showTemplatesDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.dashboard_customize_rounded, color: SunnahTheme.gold),
                  const Gap(12),
                  Text(
                    'قوالب جاهزة',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1F2E),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Gap(16),
              Expanded(
                child: ListView(
                  children: [
                    _buildTemplateCard(
                      isDark: isDark,
                      title: 'كلاسيكي',
                      description: 'تصميم تقليدي أنيق',
                      icon: Icons.menu_book_rounded,
                      onTap: () {
                        _applyTemplate(_getClassicTemplate());
                        Navigator.pop(context);
                      },
                    ),
                    const Gap(12),
                    _buildTemplateCard(
                      isDark: isDark,
                      title: 'عصري',
                      description: 'تصميم حديث وجذاب',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () {
                        _applyTemplate(_getModernTemplate());
                        Navigator.pop(context);
                      },
                    ),
                    const Gap(12),
                    _buildTemplateCard(
                      isDark: isDark,
                      title: 'بسيط',
                      description: 'تصميم نظيف ومباشر',
                      icon: Icons.minimize_rounded,
                      onTap: () {
                        _applyTemplate(_getMinimalTemplate());
                        Navigator.pop(context);
                      },
                    ),
                    const Gap(12),
                    _buildTemplateCard(
                      isDark: isDark,
                      title: 'فاخر',
                      description: 'تصميم راقي بألوان ذهبية',
                      icon: Icons.diamond_rounded,
                      onTap: () {
                        _applyTemplate(_getLuxuryTemplate());
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildTemplateCard({
    required bool isDark,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2F3E) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SunnahTheme.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: SunnahTheme.gold, size: 24),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1F2E),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    description,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  /// تطبيق قالب
  void _applyTemplate(ImageCustomizationSettings template) {
    _updateSettings(template);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const Gap(12),
            Text('تم تطبيق القالب', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: SunnahTheme.gold,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // TEMPLATES
  // ═══════════════════════════════════════════

  ImageCustomizationSettings _getClassicTemplate() {
    return ImageCustomizationSettings(
      fontFamily: 'Amiri',
      layoutStyle: LayoutStyle.classic,
      cardRadius: 16,
    );
  }

  ImageCustomizationSettings _getModernTemplate() {
    return ImageCustomizationSettings(
      backgroundType: BackgroundType.gradient,
      gradientEndColor: const Color(0xFF2D7A4F),
      gradientDirection: GradientDirection.diagonal,
      titleFontSize: 36,
      descriptionFontSize: 22,
      evidenceFontSize: 18,
      titleColor: Colors.white,
      descriptionColor: Colors.white.withValues(alpha: 0.9),
      evidenceColor: const Color(0xFFC9A84C),
      cardRadius: 24,
      showTopDecoration: false,
      showBottomDecoration: false,
    );
  }

  ImageCustomizationSettings _getMinimalTemplate() {
    return ImageCustomizationSettings(
      backgroundColor: Colors.white,
      titleFontSize: 28,
      descriptionFontSize: 18,
      evidenceFontSize: 14,
      titleColor: const Color(0xFF1A1F2E),
      descriptionColor: const Color(0xFF6B7280),
      layoutStyle: LayoutStyle.minimal,
      cardRadius: 12,
      showTopDecoration: false,
      showBottomDecoration: false,
      showBorder: false,
    );
  }

  ImageCustomizationSettings _getLuxuryTemplate() {
    return ImageCustomizationSettings(
      backgroundType: BackgroundType.gradient,
      gradientStartColor: const Color(0xFF1A1F2E),
      gradientEndColor: const Color(0xFF2A2F3E),
      fontFamily: 'Aref Ruqaa',
      titleFontSize: 38,
      descriptionFontSize: 24,
      evidenceFontSize: 18,
      titleColor: const Color(0xFFC9A84C),
      descriptionColor: const Color(0xFFDDD9CC),
      evidenceColor: const Color(0xFFC9A84C),
      layoutStyle: LayoutStyle.elegant,
      decorationType: DecorationType.floral,
      decorationColor: const Color(0xFFC9A84C),
    );
  }
}
