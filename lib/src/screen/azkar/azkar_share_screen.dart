import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_quran_v3/src/theme/controller/theme_cubit.dart';
import 'package:al_quran_v3/src/screen/azkar/widgets/azkar_share_design.dart';
import 'package:al_quran_v3/src/core/constants/app_fonts.dart';
import 'package:al_quran_v3/src/screen/azkar/models/azkar_share_settings.dart';
import 'package:al_quran_v3/src/screen/azkar/services/azkar_share_preferences.dart';



enum CustomizationField { global, zekr, category, description, reference }

/// Tab Item ┘ä┘ä┘Ç TabBar
class _TabItem {
  final String label;
  final IconData icon;
  
  const _TabItem(this.label, this.icon);
}

// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
// QUICK PRESETS - ╪¬╪╡┘à┘è┘à╪º╪¬ ╪¼╪º┘ç╪▓╪⌐ ╪│╪▒┘è╪╣╪⌐
// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

enum SharePreset {
  elegant('╪ú┘å┘è┘é', 'dark_royal', 'royal', 28, true, false, true),
  minimal('╪¿╪│┘è╪╖', 'glass_light', 'minimalist', 24, false, false, false),
  viral('┘ü┘è╪▒┘ê╪º┘ä', 'sunset', 'insta_quote', 32, true, true, true),
  classic('┘â┘ä╪º╪│┘è┘â┘è', 'glass_dark', 'classic', 26, true, true, true),
  nature('╪╖╪¿┘è╪╣┘è', 'emerald_gradient', 'zen', 24, true, false, true);

  final String label;
  final String themeId;
  final String templateType;
  final double fontSize;
  final bool showBranding;
  final bool showCategory;
  final bool isDark;

  const SharePreset(this.label, this.themeId, this.templateType, this.fontSize, this.showBranding, this.showCategory, this.isDark);
}

class AzkarShareScreen extends StatefulWidget {
  final Map<String, dynamic> zekr;
  final String categoryName;

  const AzkarShareScreen({
    super.key,
    required this.zekr,
    required this.categoryName,
  });

  @override
  State<AzkarShareScreen> createState() => _AzkarShareScreenState();
}

class _AzkarShareScreenState extends State<AzkarShareScreen> with TickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ScrollController _scrollController = ScrollController();
  final TransformationController _transformationController = TransformationController();
  
  // Tab Controller
  late TabController _tabController;
  
  String _themeId = 'glass_dark';
  String _templateType = 'classic';
  double _fontSize = 24.0;
  bool _isGradientBg = false;
  Color _customBgColor = const Color(0xFF141414);
  Color _customBgColor2 = const Color(0xFF1E1E1E);
  Color _customTextColor = Colors.white;
  Color _customAccentColor = const Color(0xFF33B18E);
  String _fontFamily = "IDRISIUM";
  bool _showBranding = true;
  bool _showCategoryHeader = true;
  double _padding = 60.0;
  bool _isStoryMode = false;
  double _borderRadius = 32.0;
  double _bgOpacity = 0.98;
  TextAlign _textAlign = TextAlign.center;
  double _lineHeight = 1.7;
  double _verticalAlignment = 0.0;
  
  // Granular Element State
  double? _zekrFontSize;
  double? _zekrLineHeight;
  double _zekrOffsetX = 0.0; // ┘è┘à┘è┘å/╪┤┘à╪º┘ä
  double _zekrOffsetY = 0.0; // ┘ü┘ê┘é/╪¬╪¡╪¬
  
  double? _categoryFontSize;
  double? _categoryLineHeight;
  double _categoryOffsetX = 0.0;
  double _categoryOffsetY = 0.0;
  
  double? _descriptionFontSize;
  double? _descriptionLineHeight;
  double _descriptionOffsetX = 0.0;
  double _descriptionOffsetY = 0.0;
  
  double? _referenceFontSize;
  double? _referenceLineHeight;
  double _referenceOffsetX = 0.0;
  double _referenceOffsetY = 0.0;
  
  Color? _zekrColor;
  String? _zekrFont;

  Color? _categoryColor;
  String? _categoryFont;
  String _categoryStyleId = 'classic';

  Color? _descriptionColor;
  String? _descriptionFont;
  String _descriptionStyleId = 'classic';

  Color? _referenceColor;
  String? _referenceFont;

  // Image Background State
  String? _backgroundImagePath;
  Offset _imageOffset = Offset.zero;
  double _imageScale = 1.0;
  double _imageBlur = 0.0;
  double _imageOverlayOpacity = 0.0;
  String _imageFilter = 'none'; // Image filter type

  bool _isSharing = false;

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // UNDO/REDO SYSTEM
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  static const int _maxHistorySize = 20;

  /// Helper: ╪¬╪¡┘ê┘è┘ä ╪º┘ä╪¡╪º┘ä╪⌐ ╪º┘ä╪¡╪º┘ä┘è╪⌐ ┘ä┘Ç JSON
  String _encodeCurrentState() {
    return jsonEncode({
      'themeId': _themeId,
      'templateType': _templateType,
      'fontSize': _fontSize,
      'isGradientBg': _isGradientBg,
      'customBgColor': _customBgColor.value,
      'customBgColor2': _customBgColor2.value,
      'customTextColor': _customTextColor.value,
      'customAccentColor': _customAccentColor.value,
      'fontFamily': _fontFamily,
      'showBranding': _showBranding,
      'showCategoryHeader': _showCategoryHeader,
      'padding': _padding,
      'isStoryMode': _isStoryMode,
      'borderRadius': _borderRadius,
      'bgOpacity': _bgOpacity,
      'textAlign': _textAlign.index,
      'lineHeight': _lineHeight,
      'verticalAlignment': _verticalAlignment,
      // Element Colors
      'zekrColor': _zekrColor?.value,
      'categoryColor': _categoryColor?.value,
      'descriptionColor': _descriptionColor?.value,
      'referenceColor': _referenceColor?.value,
      // Element Fonts
      'zekrFont': _zekrFont,
      'categoryFont': _categoryFont,
      'descriptionFont': _descriptionFont,
      'referenceFont': _referenceFont,
      // Element Font Sizes
      'zekrFontSize': _zekrFontSize,
      'categoryFontSize': _categoryFontSize,
      'descriptionFontSize': _descriptionFontSize,
      'referenceFontSize': _referenceFontSize,
      // Element Offsets
      'zekrOffsetX': _zekrOffsetX,
      'zekrOffsetY': _zekrOffsetY,
      'categoryOffsetX': _categoryOffsetX,
      'categoryOffsetY': _categoryOffsetY,
      'descriptionOffsetX': _descriptionOffsetX,
      'descriptionOffsetY': _descriptionOffsetY,
      'referenceOffsetX': _referenceOffsetX,
      'referenceOffsetY': _referenceOffsetY,
      // Category Style
      'categoryStyleId': _categoryStyleId,
    });
  }

  void _saveState() {
    _undoStack.add(_encodeCurrentState());
    if (_undoStack.length > _maxHistorySize) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    final current = _encodeCurrentState();
    final previous = _undoStack.removeLast();
    _redoStack.add(current);
    _restoreState(previous);
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    final current = _encodeCurrentState();
    final next = _redoStack.removeLast();
    _undoStack.add(current);
    _restoreState(next);
  }

  void _restoreState(String state) {
    final data = jsonDecode(state);
    setState(() {
      _themeId = data['themeId'];
      _templateType = data['templateType'];
      _fontSize = data['fontSize'];
      _isGradientBg = data['isGradientBg'];
      _customBgColor = Color(data['customBgColor']);
      _customBgColor2 = Color(data['customBgColor2']);
      _customTextColor = Color(data['customTextColor']);
      _customAccentColor = Color(data['customAccentColor']);
      _fontFamily = data['fontFamily'];
      _showBranding = data['showBranding'];
      _showCategoryHeader = data['showCategoryHeader'];
      _padding = data['padding'];
      _isStoryMode = data['isStoryMode'];
      _borderRadius = data['borderRadius'];
      _bgOpacity = data['bgOpacity'];
      _textAlign = TextAlign.values[data['textAlign']];
      _lineHeight = data['lineHeight'];
      _verticalAlignment = data['verticalAlignment'];
      // Element Colors
      _zekrColor = data['zekrColor'] != null ? Color(data['zekrColor']) : null;
      _categoryColor = data['categoryColor'] != null ? Color(data['categoryColor']) : null;
      _descriptionColor = data['descriptionColor'] != null ? Color(data['descriptionColor']) : null;
      _referenceColor = data['referenceColor'] != null ? Color(data['referenceColor']) : null;
      // Element Fonts
      _zekrFont = data['zekrFont'];
      _categoryFont = data['categoryFont'];
      _descriptionFont = data['descriptionFont'];
      _referenceFont = data['referenceFont'];
      // Element Font Sizes
      _zekrFontSize = data['zekrFontSize'];
      _categoryFontSize = data['categoryFontSize'];
      _descriptionFontSize = data['descriptionFontSize'];
      _referenceFontSize = data['referenceFontSize'];
      // Element Offsets
      _zekrOffsetX = data['zekrOffsetX'] ?? 0.0;
      _zekrOffsetY = data['zekrOffsetY'] ?? 0.0;
      _categoryOffsetX = data['categoryOffsetX'] ?? 0.0;
      _categoryOffsetY = data['categoryOffsetY'] ?? 0.0;
      _descriptionOffsetX = data['descriptionOffsetX'] ?? 0.0;
      _descriptionOffsetY = data['descriptionOffsetY'] ?? 0.0;
      _referenceOffsetX = data['referenceOffsetX'] ?? 0.0;
      _referenceOffsetY = data['referenceOffsetY'] ?? 0.0;
      // Category Style
      _categoryStyleId = data['categoryStyleId'] ?? 'classic';
    });
  }

  void _applyPreset(SharePreset preset) {
    _saveState();
    setState(() {
      _themeId = preset.themeId;
      _templateType = preset.templateType;
      _fontSize = preset.fontSize;
      _showBranding = preset.showBranding;
      _showCategoryHeader = preset.showCategory;
    });
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // THEMES
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  static const Map<String, _ThemePreview> _themes = {
    'glass_dark':       _ThemePreview('╪▓╪¼╪º╪¼┘è ╪»╪º┘â┘å', Color(0xFF0A0A0A), Colors.white, Icons.dark_mode_rounded),
    'dark_royal':       _ThemePreview('┘à┘ä┘â┘è ╪░┘ç╪¿┘è', Color(0xFF0A0806), Color(0xFFD4A746), Icons.auto_awesome),
    'midnight_blue':    _ThemePreview('╪ú╪▓╪▒┘é ╪»╪º┘â┘å', Color(0xFF0D1B2A), Color(0xFF64B5F6), Icons.nightlight_round),
    'emerald_gradient': _ThemePreview('╪▓┘à╪▒╪»┘è', Color(0xFF0A1F1A), Color(0xFF80CBC4), Icons.eco_rounded),
    'sunset':           _ThemePreview('╪¿┘å┘ü╪│╪¼', Color(0xFF1A0A2E), Color(0xFFCE93D8), Icons.gradient_rounded),
    'sand_dunes':       _ThemePreview('┘â╪½╪¿╪º┘å ╪▒┘à┘ä┘è╪⌐', Color(0xFFEFEBE9), Color(0xFF8D6E63), Icons.landscape_rounded),
    'ocean_night':      _ThemePreview('┘à╪¡┘è╪╖ ┘ä┘è┘ä┘è', Color(0xFF0A1628), Color(0xFF4DD0E1), Icons.water_rounded),
    'rose_gold':        _ThemePreview('┘ê╪▒╪»┘è ╪░┘ç╪¿┘è', Color(0xFFFBE9E7), Color(0xFFB76E79), Icons.local_florist_rounded),
    'forest_green':     _ThemePreview('╪║╪º╪¿╪⌐ ╪«╪╢╪▒╪º╪í', Color(0xFF0B1F0E), Color(0xFF66BB6A), Icons.park_rounded),
    'glass_light':      _ThemePreview('╪▓╪¼╪º╪¼┘è ┘ü╪º╪¬╪¡', Color(0xFFFDFAF5), Color(0xFF1B1B1B), Icons.light_mode_rounded),
    'custom':           _ThemePreview('┘à╪«╪╡╪╡', Color(0xFF141414), Color(0xFF33B18E), Icons.color_lens_rounded),
  };

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // TABS STATE
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  static const List<_TabItem> _tabs = [
    _TabItem('╪º┘ä╪¬╪╡┘à┘è┘à', Icons.palette_rounded),
    _TabItem('╪º┘ä╪╣┘å╪º╪╡╪▒', Icons.text_fields_rounded),
    _TabItem('╪º┘ä╪¬╪«╪╖┘è╪╖', Icons.aspect_ratio_rounded),
    _TabItem('╪º┘ä┘ç┘ê┘è╪⌐', Icons.verified_user_rounded),
  ];

  // Custom Fonts ╪º┘ä┘à╪│╪¬┘ê╪▒╪»╪⌐
  List<String> _customFonts = [];
  List<String> _customFontNames = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
    _loadSavedSettings();
    _loadCustomFonts();
  }
  
  /// ╪¬╪¡┘à┘è┘ä ╪º┘ä╪Ñ╪╣╪»╪º╪»╪º╪¬ ╪º┘ä┘à╪¡┘ü┘ê╪╕╪⌐
  Future<void> _loadSavedSettings() async {
    final settings = await AzkarSharePreferences.loadSettings();
    if (settings != null && mounted) {
      setState(() {
        _themeId = settings.themeId;
        _templateType = settings.templateType;
        _fontSize = settings.fontSize;
        _isGradientBg = settings.isGradientBg;
        _customBgColor = settings.customBgColor;
        _customBgColor2 = settings.customBgColor2;
        _customTextColor = settings.customTextColor;
        _customAccentColor = settings.customAccentColor;
        _fontFamily = settings.fontFamily;
        _showBranding = settings.showBranding;
        _showCategoryHeader = settings.showCategoryHeader;
        _padding = settings.padding;
        _isStoryMode = settings.isStoryMode;
        _borderRadius = settings.borderRadius;
        _bgOpacity = settings.bgOpacity;
        _textAlign = settings.textAlign;
        _lineHeight = settings.lineHeight;
        _verticalAlignment = settings.verticalAlignment;
        // Element styles
        _zekrColor = settings.zekrStyle.color;
        _zekrFont = settings.zekrStyle.font;
        _zekrFontSize = settings.zekrStyle.fontSize;
        _categoryColor = settings.categoryStyle.color;
        _categoryFont = settings.categoryStyle.font;
        _categoryFontSize = settings.categoryStyle.fontSize;
        _descriptionColor = settings.descriptionStyle.color;
        _descriptionFont = settings.descriptionStyle.font;
        _descriptionFontSize = settings.descriptionStyle.fontSize;
        _referenceColor = settings.referenceStyle.color;
        _referenceFont = settings.referenceStyle.font;
        _referenceFontSize = settings.referenceStyle.fontSize;
      });
    }
  }
  
  /// ╪¡┘ü╪╕ ╪º┘ä╪Ñ╪╣╪»╪º╪»╪º╪¬ ╪º┘ä╪¡╪º┘ä┘è╪⌐
  Future<void> _saveCurrentSettings() async {
    final settings = AzkarShareSettings(
      themeId: _themeId,
      templateType: _templateType,
      fontSize: _fontSize,
      isGradientBg: _isGradientBg,
      customBgColor: _customBgColor,
      customBgColor2: _customBgColor2,
      customTextColor: _customTextColor,
      customAccentColor: _customAccentColor,
      fontFamily: _fontFamily,
      showBranding: _showBranding,
      showCategoryHeader: _showCategoryHeader,
      padding: _padding,
      isStoryMode: _isStoryMode,
      borderRadius: _borderRadius,
      bgOpacity: _bgOpacity,
      textAlign: _textAlign,
      lineHeight: _lineHeight,
      verticalAlignment: _verticalAlignment,
      zekrStyle: ElementStyle(color: _zekrColor, font: _zekrFont, fontSize: _zekrFontSize),
      categoryStyle: ElementStyle(color: _categoryColor, font: _categoryFont, fontSize: _categoryFontSize, styleId: _categoryStyleId),
      descriptionStyle: ElementStyle(color: _descriptionColor, font: _descriptionFont, fontSize: _descriptionFontSize, styleId: _descriptionStyleId),
      referenceStyle: ElementStyle(color: _referenceColor, font: _referenceFont, fontSize: _referenceFontSize),
    );
    await AzkarSharePreferences.saveSettings(settings);
  }
  
  /// ╪¬╪¡┘à┘è┘ä ╪º┘ä╪«╪╖┘ê╪╖ ╪º┘ä┘à╪│╪¬┘ê╪▒╪»╪⌐
  Future<void> _loadCustomFonts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fonts = prefs.getStringList('azkar_custom_fonts') ?? [];
      final names = prefs.getStringList('azkar_custom_font_names') ?? [];
      setState(() {
        _customFonts = fonts;
        _customFontNames = names;
      });
    } catch (_) {}
  }
  
  /// ╪º╪│╪¬┘è╪▒╪º╪» ╪«╪╖ ╪¼╪»┘è╪»
  Future<void> _importCustomFont() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) return;
      
      final file = result.files.first;
      if (file.path == null) return;
      
      // Copy to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fontName = file.name;
      final newPath = '${appDir.path}/fonts/$fontName';
      
      // Create fonts directory if not exists
      final fontDir = Directory('${appDir.path}/fonts');
      if (!await fontDir.exists()) {
        await fontDir.create();
      }
      
      await File(file.path!).copy(newPath);
      
      // Extract font family name from filename
      final fontFamilyName = fontName.replaceAll('.ttf', '').replaceAll('.otf', '');
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      _customFonts.add(newPath);
      _customFontNames.add(fontFamilyName);
      await prefs.setStringList('azkar_custom_fonts', _customFonts);
      await prefs.setStringList('azkar_custom_font_names', _customFontNames);
      
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('╪¬┘à ╪º╪│╪¬┘è╪▒╪º╪» ╪º┘ä╪«╪╖: $fontFamilyName'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('╪«╪╖╪ú ┘ü┘è ╪º╪│╪¬┘è╪▒╪º╪» ╪º┘ä╪«╪╖: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _transformationController.dispose();
    super.dispose();
  }


  Future<void> _cleanupOldTempShareImages({Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final entries = tempDir.listSync();
      final now = DateTime.now();
      for (final e in entries) {
        if (e is! File) continue;
        final name = e.uri.pathSegments.isNotEmpty ? e.uri.pathSegments.last : '';
        if (!name.startsWith('zekr_share_') || !name.endsWith('.png')) continue;
        final stat = e.statSync();
        if (now.difference(stat.modified) > maxAge) {
          await e.delete();
        }
      }
    } catch (_) {
      return;
    }
  }

  Future<Uint8List> _capturePngBytes() async {
    // ╪ú╪╣┘ä┘ë ╪¼┘ê╪»╪⌐ ┘à┘à┘â┘å╪⌐: devicePixelRatio ├ù 3
    final deviceRatio = View.of(context).devicePixelRatio;
    final maxRatio = deviceRatio * 3;
    final image = await _screenshotController.capture(
      delay: const Duration(milliseconds: 300),
      pixelRatio: maxRatio,
    );
    if (image == null) {
      throw Exception("Capture failed");
    }
    return image;
  }

  Future<File> _writeTempPng(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/zekr_share_${DateTime.now().millisecondsSinceEpoch}.png').create();
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _export({required bool share}) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      await _cleanupOldTempShareImages();
      final bytes = await _capturePngBytes();
      if (share) {
        final file = await _writeTempPng(bytes);
        await Share.shareXFiles([XFile(file.path)], text: '┘à╪┤╪º╪▒┘â╪⌐ ┘à┘å ╪¬╪╖╪¿┘è┘é ╪º┘ä┘ü┘Å╪▒┘é╪º┘å');
      } else {
        await Gal.putImageBytes(bytes, album: 'AlFurkan');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("╪¬┘à ╪¡┘ü╪╕ ╪º┘ä╪╡┘ê╪▒╪⌐ ┘ü┘è ╪º┘ä┘à╪╣╪▒╪╢", textDirection: TextDirection.rtl),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("╪¡╪»╪½ ╪«╪╖╪ú: $e", textDirection: TextDirection.rtl),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _shareImage() async {
    await _saveCurrentSettings();
    await _export(share: true);
  }

  Future<void> _saveImage() async {
    await _saveCurrentSettings();
    await _export(share: false);
  }

  void _scrollToField(CustomizationField field) {
    // Scroll to the appropriate panel - only if attached
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        field.index * 300.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // UI HELPERS
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color primary,
  }) {
    final isEnabled = onPressed != null;
    return Material(
      color: isEnabled 
          ? primary.withValues(alpha: 0.08)
          : Colors.grey.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isEnabled
            ? () {
                HapticFeedback.lightImpact();
                onPressed();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 42,
          height: 42,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: isEnabled 
                ? primary 
                : Colors.grey.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(SharePreset preset, Color primary, Color cardColor, bool isDark) {
    final theme = _themes[preset.themeId];
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _applyPreset(preset);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme?.bg ?? const Color(0xFF0A0A0A),
              (theme?.bg ?? const Color(0xFF0A0A0A)).withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (theme?.accent ?? primary).withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (theme?.accent ?? primary).withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              theme?.icon ?? Icons.palette_rounded,
              size: 14,
              color: theme?.accent ?? primary,
            ),
            const Gap(6),
            Text(
              preset.label,
              style: TextStyle(
                color: theme?.accent ?? primary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFilterSelector(Color primary, Color cardColor, bool isDark) {
    final filters = [
      ('none', '╪╣╪º╪»┘è', null),
      ('grayscale', '╪▒┘à╪º╪»┘è', Colors.grey),
      ('sepia', '╪¿┘å┘è', const Color(0xFF8B7355)),
      ('vintage', '┘é╪»┘è┘à', const Color(0xFFD4A574)),
      ('cool', '╪¿╪º╪▒╪»', Colors.cyan),
      ('warm', '╪»╪º┘ü╪ª', Colors.orange),
      ('dramatic', '╪»╪▒╪º┘à┘è', Colors.purple),
      ('fade', '╪¿╪º┘ç╪¬', Colors.grey),
      ('contrast', '╪¬╪¿╪º┘è┘å', Colors.black),
      ('bright', '┘à╪┤╪▒┘é', Colors.yellow),
    ];
    
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (ctx, i) {
          final (id, label, color) = filters[i];
          final isSelected = _imageFilter == id;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _imageFilter = id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? primary.withValues(alpha: 0.12)
                    : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (color != null) ...[
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                      ),
                    ),
                    const Gap(8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? primary : (isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6)),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
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

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // PANEL CONTENT BUILDERS
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  Widget _buildDesignContent(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("╪╖╪▒┘è┘é╪⌐ ╪º┘ä╪╣╪▒╪╢ (╪│╪¬╪º┘è┘ä╪º╪¬ ╪º╪¡╪¬╪▒╪º┘ü┘è╪⌐)", Icons.dashboard_customize_rounded, primary, subtleColor),
        const Gap(12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTemplateOption('classic', '┘â┘ä╪º╪│┘è┘â┘è', Icons.crop_square_rounded, primary, cardColor, isDark),
              _buildTemplateOption('minimalist', '╪¿╪│┘è╪╖', Icons.view_agenda_rounded, primary, cardColor, isDark),
              _buildTemplateOption('elegant', '╪ú┘å┘è┘é', Icons.auto_awesome_rounded, primary, cardColor, isDark),
              _buildTemplateOption('modern', '╪╣╪╡╪▒┘è', Icons.filter_vintage_rounded, primary, cardColor, isDark),
            ],
          ),
        ),
        const Gap(24),
        _buildSectionTitle("╪º┘ä╪½┘è┘à╪º╪¬", Icons.palette_rounded, primary, subtleColor),
        const Gap(12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _themes.length,
            itemBuilder: (ctx, index) {
              final entry = _themes.entries.elementAt(index);
              final id = entry.key;
              final theme = entry.value;
              final isSelected = _themeId == id;

              return GestureDetector(
                onTap: () {
                  _saveState();
                  setState(() => _themeId = id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 90,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: theme.bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primary : Colors.grey.withValues(alpha: 0.1),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: primary.withValues(alpha: 0.2), blurRadius: 8)] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(theme.icon, color: theme.accent, size: 24),
                      const Gap(8),
                      Text(
                        theme.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.accent, 
                          fontSize: 11, 
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Gap(24),
        _buildSectionTitle("╪╡┘ê╪▒╪⌐ ╪«┘ä┘ü┘è╪⌐ ┘à╪«╪╡╪╡╪⌐", Icons.image_rounded, primary, subtleColor),
        const Gap(12),
        Row(
          children: [
            _buildImageAction("╪º╪«╪¬┘è╪º╪▒ ╪╡┘ê╪▒╪⌐", Icons.add_photo_alternate_rounded, primary, () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) setState(() => _backgroundImagePath = image.path);
            }),
            if (_backgroundImagePath != null) ...[
              const Gap(12),
              _buildImageAction("╪¬╪╣╪»┘è┘ä", Icons.edit_attributes_rounded, primary, () => _showImageAdjuster()),
              const Gap(12),
              _buildImageAction("╪¡╪░┘ü", Icons.delete_forever_rounded, Colors.redAccent, () => setState(() => _backgroundImagePath = null)),
            ],
          ],
        ),
        if (_backgroundImagePath != null) ...[
          const Gap(16),
          _buildAdjustmentSlider("╪º┘ä╪¬╪║╪¿┘è╪┤ (Blur)", _imageBlur, (v) => setState(() => _imageBlur = v), 0, 20, primary, textColor),
          const Gap(12),
          _buildAdjustmentSlider("╪¬╪╣╪¬┘è┘à (Opacity)", _imageOverlayOpacity, (v) => setState(() => _imageOverlayOpacity = v), 0, 1, primary, textColor),
        ],
        if (_themeId == 'custom') ...[
          const Gap(24),
          _buildSectionTitle("╪º┘ä╪ú┘ä┘ê╪º┘å ╪º┘ä┘à╪«╪╡╪╡╪⌐", Icons.color_lens_rounded, primary, subtleColor),
          const Gap(16),
          _buildColorOption("┘ä┘ê┘å ╪º┘ä╪«┘ä┘ü┘è╪⌐", _customBgColor, (c) => setState(() => _customBgColor = c), textColor),
          const Gap(12),
          _buildToggle("╪«┘ä┘ü┘è╪⌐ ┘à╪¬╪»╪▒╪¼╪⌐", _isGradientBg, (val) => setState(() => _isGradientBg = val), primary, textColor),
          if (_isGradientBg) ...[
            const Gap(12),
            _buildColorOption("╪º┘ä╪«┘ä┘ü┘è╪⌐ 2", _customBgColor2, (c) => setState(() => _customBgColor2 = c), textColor),
          ],
          const Gap(12),
          _buildColorOption("┘ä┘ê┘å ╪º┘ä┘å╪╡", _customTextColor, (c) => setState(() => _customTextColor = c), textColor),
          const Gap(12),
          _buildColorOption("┘ä┘ê┘å ╪º┘ä╪¬┘à┘è┘è╪▓", _customAccentColor, (c) => setState(() => _customAccentColor = c), textColor),
        ],
      ],
    );
  }

  // Elements Content - ┘à╪¡╪¬┘ê┘ë ╪º┘ä╪╣┘å╪º╪╡╪▒
  Widget _buildElementsContent(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ╪º┘ä╪«╪╖ ╪º┘ä╪╣╪º┘à
          _buildSectionTitle("╪º┘ä╪«╪╖ ╪º┘ä╪╣╪º┘à", Icons.font_download_rounded, primary, subtleColor),
          const Gap(12),
          _buildFontSelector(primary, cardColor, isDark),
          const Gap(16),
          _buildSliderRow("╪¡╪¼┘à ╪º┘ä╪«╪╖", "${_fontSize.toInt()}", primary, textColor),
          Slider(
            value: _fontSize,
            min: 16,
            max: 60,
            activeColor: primary,
            inactiveColor: primary.withValues(alpha: 0.1),
            onChanged: (val) {
              _saveState();
              setState(() => _fontSize = val);
            },
          ),
          const Gap(24),
          
          // ┘å╪╡ ╪º┘ä╪░┘â╪▒
          _buildSectionTitle("┘å╪╡ ╪º┘ä╪░┘â╪▒", Icons.text_fields_rounded, primary, subtleColor),
          const Gap(12),
          _buildFullColorPicker(_zekrColor, (c) => setState(() => _zekrColor = c), primary),
          const Gap(12),
          _buildFontDropdown("╪«╪╖ ╪º┘ä╪░┘â╪▒", _zekrFont, (f) => setState(() => _zekrFont = f), primary),
          const Gap(12),
          _buildSliderRow("╪¡╪¼┘à ╪«╪╖ ╪º┘ä╪░┘â╪▒", "${(_zekrFontSize ?? _fontSize + 16).toInt()}", primary, textColor),
          Slider(
            value: _zekrFontSize ?? _fontSize + 16,
            min: 20,
            max: 80,
            activeColor: primary,
            inactiveColor: primary.withValues(alpha: 0.1),
            onChanged: (val) {
              _saveState();
              setState(() => _zekrFontSize = val);
            },
          ),
          const Gap(8),
          _buildSliderRow("┘à┘ê╪╢╪╣ ╪ú┘ü┘é┘è (┘è┘à┘è┘å/╪┤┘à╪º┘ä)", "${_zekrOffsetX.toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _zekrOffsetX,
                  min: -300,
                  max: 300,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _zekrOffsetX = val);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                onPressed: () {
                  _saveState();
                  setState(() => _zekrOffsetX = 0.0);
                },
                tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
              ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("┘à┘ê╪╢╪╣ ╪╣┘à┘ê╪»┘è (┘ü┘ê┘é/╪¬╪¡╪¬)", "${_zekrOffsetY.toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _zekrOffsetY,
                  min: -300,
                  max: 300,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _zekrOffsetY = val);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                onPressed: () {
                  _saveState();
                  setState(() => _zekrOffsetY = 0.0);
                },
                tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
              ),
            ],
          ),
          const Gap(24),
          
          // ╪º╪│┘à ╪º┘ä┘é╪│┘à
          _buildSectionTitle("╪º╪│┘à ╪º┘ä┘é╪│┘à", Icons.category_rounded, primary, subtleColor),
          const Gap(12),
          _buildFullColorPicker(_categoryColor, (c) => setState(() => _categoryColor = c), primary),
          const Gap(12),
          _buildFontDropdown("╪«╪╖ ╪º┘ä┘é╪│┘à", _categoryFont, (f) => setState(() => _categoryFont = f), primary),
          const Gap(12),
          Text("╪│╪¬╪º┘è┘ä ╪º┘ä┘é╪│┘à:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7))),
          const Gap(8),
          Row(
            children: [
              _buildStyleChip('classic', '┘â┘ä╪º╪│┘è┘â┘è', _categoryStyleId == 'classic', primary),
              const Gap(8),
              _buildStyleChip('pill', 'Pill', _categoryStyleId == 'pill', primary),
              const Gap(8),
              _buildStyleChip('modern', '┘à┘ê╪»╪▒┘å', _categoryStyleId == 'modern', primary),
            ],
          ),
          const Gap(12),
          _buildSliderRow("╪¡╪¼┘à ╪«╪╖ ╪º┘ä┘é╪│┘à", "${(_categoryFontSize ?? _fontSize + 12).toInt()}", primary, textColor),
          Slider(
            value: _categoryFontSize ?? _fontSize + 12,
            min: 14,
            max: 50,
            activeColor: primary,
            inactiveColor: primary.withValues(alpha: 0.1),
            onChanged: (val) {
              _saveState();
              setState(() => _categoryFontSize = val);
            },
          ),
          const Gap(8),
          _buildSliderRow("┘à┘ê╪╢╪╣ ╪ú┘ü┘é┘è", "${_categoryOffsetX.toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _categoryOffsetX,
                  min: -300,
                  max: 300,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _categoryOffsetX = val);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                onPressed: () {
                  _saveState();
                  setState(() => _categoryOffsetX = 0.0);
                },
                tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
              ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("┘à┘ê╪╢╪╣ ╪╣┘à┘ê╪»┘è", "${_categoryOffsetY.toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _categoryOffsetY,
                  min: -300,
                  max: 300,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _categoryOffsetY = val);
                  },
                ),
              ),
              if (_categoryOffsetY != 0.0)
                IconButton(
                  icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                  onPressed: () {
                    _saveState();
                    setState(() => _categoryOffsetY = 0.0);
                  },
                  tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
                ),
            ],
          ),
          const Gap(24),
          
          // ╪º┘ä╪»┘ä┘è┘ä (Reference)
          _buildSectionTitle("╪º┘ä╪»┘ä┘è┘ä", Icons.bookmark_rounded, primary, subtleColor),
          const Gap(12),
          _buildFullColorPicker(_referenceColor, (c) => setState(() => _referenceColor = c), primary),
          const Gap(12),
          _buildFontDropdown("╪«╪╖ ╪º┘ä╪»┘ä┘è┘ä", _referenceFont, (f) => setState(() => _referenceFont = f), primary),
          const Gap(12),
          _buildSliderRow("╪¡╪¼┘à ╪«╪╖ ╪º┘ä╪»┘ä┘è┘ä", "${(_referenceFontSize ?? _fontSize - 4).toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _referenceFontSize ?? _fontSize - 4,
                  min: 10,
                  max: 40,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _referenceFontSize = val);
                  },
                ),
              ),
              if (_referenceFontSize != null)
                IconButton(
                  icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                  onPressed: () {
                    _saveState();
                    setState(() => _referenceFontSize = null);
                  },
                  tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
                ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("┘à┘ê╪╢╪╣ ╪ú┘ü┘é┘è", "${_referenceOffsetX.toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _referenceOffsetX,
                  min: -300,
                  max: 300,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _referenceOffsetX = val);
                  },
                ),
              ),
              if (_referenceOffsetX != 0.0)
                IconButton(
                  icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                  onPressed: () {
                    _saveState();
                    setState(() => _referenceOffsetX = 0.0);
                  },
                  tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
                ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("┘à┘ê╪╢╪╣ ╪╣┘à┘ê╪»┘è", "${_referenceOffsetY.toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _referenceOffsetY,
                  min: -300,
                  max: 300,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _referenceOffsetY = val);
                  },
                ),
              ),
              if (_referenceOffsetY != 0.0)
                IconButton(
                  icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                  onPressed: () {
                    _saveState();
                    setState(() => _referenceOffsetY = 0.0);
                  },
                  tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
                ),
            ],
          ),
          const Gap(24),
          
          // ╪º┘ä┘ü╪╢┘ä (Description)
          _buildSectionTitle("╪º┘ä┘ü╪╢┘ä", Icons.star_rounded, primary, subtleColor),
          const Gap(12),
          _buildFullColorPicker(_descriptionColor, (c) => setState(() => _descriptionColor = c), primary),
          const Gap(12),
          _buildFontDropdown("╪«╪╖ ╪º┘ä┘ü╪╢┘ä", _descriptionFont, (f) => setState(() => _descriptionFont = f), primary),
          const Gap(12),
          _buildSliderRow("╪¡╪¼┘à ╪«╪╖ ╪º┘ä┘ü╪╢┘ä", "${(_descriptionFontSize ?? _fontSize + 4).toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _descriptionFontSize ?? _fontSize + 4,
                  min: 12,
                  max: 50,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _descriptionFontSize = val);
                  },
                ),
              ),
              if (_descriptionFontSize != null)
                IconButton(
                  icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                  onPressed: () {
                    _saveState();
                    setState(() => _descriptionFontSize = null);
                  },
                  tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
                ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("┘à┘ê╪╢╪╣ ╪ú┘ü┘é┘è", "${_descriptionOffsetX.toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _descriptionOffsetX,
                  min: -300,
                  max: 300,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _descriptionOffsetX = val);
                  },
                ),
              ),
              if (_descriptionOffsetX != 0.0)
                IconButton(
                  icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                  onPressed: () {
                    _saveState();
                    setState(() => _descriptionOffsetX = 0.0);
                  },
                  tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
                ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("┘à┘ê╪╢╪╣ ╪╣┘à┘ê╪»┘è", "${_descriptionOffsetY.toInt()}", primary, textColor),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _descriptionOffsetY,
                  min: -300,
                  max: 300,
                  activeColor: primary,
                  inactiveColor: primary.withValues(alpha: 0.1),
                  onChanged: (val) {
                    _saveState();
                    setState(() => _descriptionOffsetY = val);
                  },
                ),
              ),
              if (_descriptionOffsetY != 0.0)
                IconButton(
                  icon: Icon(Icons.refresh, size: 18, color: primary.withValues(alpha: 0.7)),
                  onPressed: () {
                    _saveState();
                    setState(() => _descriptionOffsetY = 0.0);
                  },
                  tooltip: "╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å",
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Full Spectrum Color Picker
  Widget _buildFullColorPicker(Color? currentColor, Function(Color?) onColorPicked, Color primary) {
    return Column(
      children: [
        Row(
          children: [
            // ╪▓╪▒ ╪Ñ╪╣╪º╪»╪⌐ ╪¬╪╣┘è┘è┘å
            GestureDetector(
              onTap: () {
                _saveState();
                onColorPicked(null);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentColor == null ? primary : Colors.grey.withValues(alpha: 0.3),
                    width: currentColor == null ? 2 : 1,
                  ),
                ),
                child: Icon(Icons.refresh, size: 16, color: primary),
              ),
            ),
            const Gap(12),
            // Color picker button
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (ctx) => _ColorPickerDialog(initialColor: currentColor ?? primary),
                  );
                  if (color != null) {
                    _saveState();
                    onColorPicked(color);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: currentColor?.withValues(alpha: 0.15) ?? Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentColor ?? Colors.grey.withValues(alpha: 0.3),
                      width: currentColor != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: currentColor ?? primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: currentColor != null ? [BoxShadow(color: currentColor.withValues(alpha: 0.4), blurRadius: 6)] : null,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        currentColor != null ? "┘à╪«╪╡╪╡" : "╪º╪«╪¬╪▒ ┘ä┘ê┘å",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: currentColor != null ? FontWeight.bold : FontWeight.normal,
                          color: currentColor ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Font Selector Horizontal - ┘à╪╣╪º┘è┘å╪⌐ ╪¿╪º┘ä╪«╪╖ ┘å┘ü╪│┘ç
  Widget _buildFontDropdown(String label, String? currentFont, Function(String?) onFontChanged, Color primary) {
    final fonts = <String?>[
      null, // ╪º┘ü╪¬╪▒╪º╪╢┘è
      'KFGQPC-Uthmanic-HAFS-Regular',
      'Amiri-Regular',
      'Cairo-Bold',
      'IDRISIUM',
      'AmiriQuran-Regular',
      'Aref Ruqaa Bold',
      'Cairo-Regular',
      'Cairo-Light',
      'Cairo-SemiBold',
      'Cairo-Black',
      'al-majd',
      'bader-lamsat',
      'Afsaneh-Font',
    ];
    
    final fontLabels = {
      null: '╪º┘ü╪¬╪▒╪º╪╢┘è',
      'KFGQPC-Uthmanic-HAFS-Regular': '╪╣╪½┘à╪º┘å┘è',
      'Amiri-Regular': '╪ú┘à┘è╪▒┘è',
      'Cairo-Bold': '┘é╪º┘ç╪▒╪⌐ ╪½┘é┘è┘ä',
      'IDRISIUM': '╪Ñ╪»╪▒┘è╪│┘è┘ê┘à',
      'AmiriQuran-Regular': '╪ú┘à┘è╪▒┘è ┘é╪▒╪ó┘å',
      'Aref Ruqaa Bold': '╪▒┘é╪╣╪⌐ ╪½┘é┘è┘ä',
      'Cairo-Regular': '┘é╪º┘ç╪▒╪⌐',
      'Cairo-Light': '┘é╪º┘ç╪▒╪⌐ ╪«┘ü┘è┘ü',
      'Cairo-SemiBold': '┘é╪º┘ç╪▒╪⌐ ┘à╪¬┘ê╪│╪╖',
      'Cairo-Black': '┘é╪º┘ç╪▒╪⌐ ╪ú╪│┘ê╪»',
      'al-majd': '╪º┘ä┘à╪¼╪»',
      'bader-lamsat': '╪¿╪»╪▒',
      'Afsaneh-Font': '╪ú┘ü╪│╪º┘å┘ç',
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primary.withValues(alpha: 0.7))),
        const Gap(8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fonts.length,
            separatorBuilder: (_, __) => const Gap(6),
            itemBuilder: (context, index) {
              final font = fonts[index];
              final isSelected = currentFont == font;
              final label = fontLabels[font] ?? '╪«╪╖';
              return GestureDetector(
                onTap: () {
                  _saveState();
                  onFontChanged(font);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? primary : Colors.grey.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: font,
                        fontSize: 14,
                        color: isSelected ? primary : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Layout Content - ┘à╪¡╪¬┘ê┘ë ╪º┘ä╪¬╪«╪╖┘è╪╖
  Widget _buildLayoutContent(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ┘å┘à╪╖ ╪º┘ä╪╣╪▒╪╢
        _buildSectionTitle("┘å┘à╪╖ ╪º┘ä╪╣╪▒╪╢", Icons.aspect_ratio_rounded, primary, subtleColor),
        const Gap(12),
        Row(
          children: [
            _buildPatternOption(false, Icons.crop_square_rounded, "┘à╪▒╪¿╪╣ (1:1)", primary),
            const Gap(12),
            _buildPatternOption(true, Icons.phone_android_rounded, "╪│╪¬┘ê╪▒┘è (9:16)", primary),
          ],
        ),
        const Gap(24),
        
        // ╪º┘ä┘à╪¡╪º╪░╪º╪⌐
        _buildSectionTitle("╪º┘ä┘à╪¡╪º╪░╪º╪⌐", Icons.format_align_center_rounded, primary, subtleColor),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAlignmentOption(TextAlign.right, Icons.format_align_right_rounded, primary),
            _buildAlignmentOption(TextAlign.center, Icons.format_align_center_rounded, primary),
            _buildAlignmentOption(TextAlign.left, Icons.format_align_left_rounded, primary),
          ],
        ),
        const Gap(24),
        
        // ╪º┘ä╪ú╪¿╪╣╪º╪»
        _buildSectionTitle("╪º┘ä╪ú╪¿╪╣╪º╪»", Icons.tune_rounded, primary, subtleColor),
        const Gap(12),
        _buildSliderRow("╪º╪▒╪¬┘ü╪º╪╣ ╪º┘ä╪│╪╖╪▒", _lineHeight.toStringAsFixed(1), primary, textColor),
        Slider(
          value: _lineHeight,
          min: 1.0,
          max: 3.0,
          activeColor: primary,
          inactiveColor: primary.withValues(alpha: 0.08),
          onChanged: (val) {
            _saveState();
            HapticFeedback.selectionClick();
            setState(() => _lineHeight = val);
          },
        ),
        _buildSliderRow("╪º┘ä┘ç┘ê╪º┘à╪┤", "${_padding.toInt()}", primary, textColor),
        Slider(
          value: _padding,
          min: 20,
          max: 180,
          activeColor: primary,
          inactiveColor: primary.withValues(alpha: 0.08),
          onChanged: (val) {
            _saveState();
            HapticFeedback.selectionClick();
            setState(() => _padding = val);
          },
        ),
        _buildSliderRow("╪º┘ä╪▓┘ê╪º┘è╪º", "${_borderRadius.toInt()}", primary, textColor),
        Slider(
          value: _borderRadius,
          min: 0,
          max: 150,
          activeColor: primary,
          inactiveColor: primary.withValues(alpha: 0.08),
          onChanged: (val) {
            _saveState();
            HapticFeedback.selectionClick();
            setState(() => _borderRadius = val);
          },
        ),
        _buildSliderRow("╪º┘ä╪╣╪¬╪º┘à╪⌐", _bgOpacity.toStringAsFixed(2), primary, textColor),
        Slider(
          value: _bgOpacity,
          min: 0.0,
          max: 1.0,
          activeColor: primary,
          inactiveColor: primary.withValues(alpha: 0.08),
          onChanged: (val) {
            _saveState();
            HapticFeedback.selectionClick();
            setState(() => _bgOpacity = val);
          },
        ),
      ],
    );
  }

  // Identity Content - ┘à╪¡╪¬┘ê┘ë ╪º┘ä┘ç┘ê┘è╪⌐
  Widget _buildIdentityContent(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("╪Ñ╪╣╪»╪º╪»╪º╪¬ ╪º┘ä┘ç┘ê┘è╪⌐", Icons.verified_user_rounded, primary, subtleColor),
        const Gap(16),
        _buildToggle("╪Ñ╪╕┘ç╪º╪▒ ╪º╪│┘à ╪º┘ä┘é╪│┘à", _showCategoryHeader, (val) => setState(() => _showCategoryHeader = val), primary, textColor),
        const Gap(8),
        _buildToggle("┘ä┘ê╪¼┘ê ┘ê╪¡┘é┘ê┘é ╪º┘ä╪¬╪╖╪¿┘è┘é", _showBranding, (val) => setState(() => _showBranding = val), primary, textColor),
        const Gap(24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: primary, size: 20),
              const Gap(12),
              Expanded(
                child: Text(
                  "╪¬╪¡┘â┘à ┘ü┘è ╪╕┘ç┘ê╪▒ ╪º┘ä╪╣┘ä╪º┘à╪⌐ ╪º┘ä┘à╪º╪ª┘è╪⌐ ┘ê╪º╪│┘à ╪º┘ä┘é╪│┘à ╪╣┘ä┘ë ╪º┘ä╪╡┘ê╪▒╪⌐ ╪º┘ä┘à╪┤╪º╪▒┘â╪⌐.",
                  style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // HELPER WIDGETS
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  Widget _buildColorChip(String label, Color? color, bool isSelected, Color primary) {
    return GestureDetector(
      onTap: () => setState(() => _zekrColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? primary : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildColorPickerChip(String label, Color? currentColor, Function(Color?) onColorPicked, Color primary) {
    // ╪ú┘ä┘ê╪º┘å ╪¼╪º┘ç╪▓╪⌐ ┘ä┘ä╪º╪«╪¬┘è╪º╪▒ ╪º┘ä╪│╪▒┘è╪╣
    final presetColors = [
      Colors.white,
      Colors.black,
      const Color(0xFFD4A746), // ╪░┘ç╪¿┘è
      const Color(0xFF33B18E), // ╪ú╪«╪╢╪▒
      const Color(0xFF64B5F6), // ╪ú╪▓╪▒┘é
      const Color(0xFFCE93D8), // ╪¿┘å┘ü╪│╪¼┘è
      const Color(0xFFB76E79), // ┘ê╪▒╪»┘è
      const Color(0xFF66BB6A), // ╪ú╪«╪╢╪▒ ┘ü╪º╪¬╪¡
      const Color(0xFFFF7043), // ╪¿╪▒╪¬┘é╪º┘ä┘è
    ];
    
    return GestureDetector(
      onTap: () {
        // Toggle: ┘ä┘ê ╪º┘ä┘à╪«╪╡╪╡ ┘à╪«╪¬╪º╪▒╪î ┘å┘ä╪║┘è┘ç ┘ê┘å╪▒╪¼╪╣ ╪º┘ü╪¬╪▒╪º╪╢┘è
        if (currentColor != null) {
          _saveState();
          onColorPicked(null);
          return;
        }
        // ┘ä┘ê ╪º┘ü╪¬╪▒╪º╪╢┘è╪î ┘å┘ü╪¬╪¡ ┘é╪º╪ª┘à╪⌐ ╪º┘ä╪ú┘ä┘ê╪º┘å
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: currentColor != null ? currentColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: currentColor ?? Colors.grey.withValues(alpha: 0.3),
            width: currentColor != null ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: currentColor ?? primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: currentColor != null ? [BoxShadow(color: currentColor.withValues(alpha: 0.4), blurRadius: 6)] : null,
              ),
            ),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: currentColor != null ? FontWeight.bold : FontWeight.normal,
                color: currentColor ?? Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // ┘é╪º╪ª┘à╪⌐ ╪ú┘ä┘ê╪º┘å inline ┘ä┘ä╪╣╪▒╪╢ ╪¬╪¡╪¬ ╪º┘ä╪╣┘å╪╡╪▒
  Widget _buildInlineColorPicker(Color? currentColor, Function(Color?) onColorPicked, Color primary) {
    final presetColors = [
      null, // ╪º┘ü╪¬╪▒╪º╪╢┘è
      Colors.white,
      Colors.black,
      const Color(0xFFD4A746),
      const Color(0xFF33B18E),
      const Color(0xFF64B5F6),
      const Color(0xFFCE93D8),
      const Color(0xFFB76E79),
      const Color(0xFF66BB6A),
      const Color(0xFFFF7043),
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetColors.map((color) {
        final isSelected = currentColor == color;
        return GestureDetector(
          onTap: () {
            _saveState();
            onColorPicked(color);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color ?? primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primary : Colors.grey.withValues(alpha: 0.3),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected ? [BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 8)] : null,
            ),
            child: color == null 
              ? Icon(Icons.refresh, size: 16, color: primary)
              : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontSelector(Color primary, Color cardColor, bool isDark) {
    final fonts = [
      'IDRISIUM',
      'KFGQPC-Uthmanic-HAFS-Regular',
      'Amiri-Regular',
      'Cairo-Bold',
      'AmiriQuran-Regular',
      'Aref Ruqaa Bold',
      'Cairo-Regular',
      'Cairo-Light',
      'Cairo-SemiBold',
      'Cairo-Black',
      'al-majd',
      'bader-lamsat',
      'Afsaneh-Font',
      'Abd-ElRady-Regular',
      'al-hadaribold',
      'a-massir-ballpoint',
      'b-helal',
      'ASane-Jaleh',
      'BritishCouncil-Arabic-Black',
    ];
    
    final fontLabels = {
      'IDRISIUM': '╪Ñ╪»╪▒┘è╪│┘è┘ê┘à',
      'KFGQPC-Uthmanic-HAFS-Regular': '╪╣╪½┘à╪º┘å┘è',
      'Amiri-Regular': '╪ú┘à┘è╪▒┘è',
      'Cairo-Bold': '┘é╪º┘ç╪▒╪⌐ ╪½┘é┘è┘ä',
      'AmiriQuran-Regular': '╪ú┘à┘è╪▒┘è ┘é╪▒╪ó┘å',
      'Aref Ruqaa Bold': '╪▒┘é╪╣╪⌐ ╪½┘é┘è┘ä',
      'Cairo-Regular': '┘é╪º┘ç╪▒╪⌐',
      'Cairo-Light': '┘é╪º┘ç╪▒╪⌐ ╪«┘ü┘è┘ü',
      'Cairo-SemiBold': '┘é╪º┘ç╪▒╪⌐ ┘à╪¬┘ê╪│╪╖',
      'Cairo-Black': '┘é╪º┘ç╪▒╪⌐ ╪ú╪│┘ê╪»',
      'al-majd': '╪º┘ä┘à╪¼╪»',
      'bader-lamsat': '╪¿╪»╪▒',
      'Afsaneh-Font': '╪ú┘ü╪│╪º┘å┘ç',
      'Abd-ElRady-Regular': '╪╣╪¿╪» ╪º┘ä╪▒╪º╪╢┘è',
      'al-hadaribold': '┘ç╪»╪º╪▒┘è',
      'a-massir-ballpoint': '┘à╪│┘è╪▒',
      'b-helal': '┘ç┘ä╪º┘ä',
      'ASane-Jaleh': '╪¼╪º┘ä┘ç',
      'BritishCouncil-Arabic-Black': '╪¿╪▒┘è╪╖╪º┘å┘è',
    };
    
    // ╪»┘à╪¼ ╪º┘ä╪«╪╖┘ê╪╖ ╪º┘ä┘à╪»┘à╪¼╪⌐ ┘à╪╣ ╪º┘ä╪«╪╖┘ê╪╖ ╪º┘ä┘à╪│╪¬┘ê╪▒╪»╪⌐
    final allFonts = [...fonts, ..._customFonts];
    final allLabels = {...fontLabels};
    for (int i = 0; i < _customFonts.length; i++) {
      allLabels[_customFonts[i]] = _customFontNames[i];
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allFonts.length + 1, // +1 ┘ä╪▓╪▒ ╪º┘ä╪º╪│╪¬┘è╪▒╪º╪»
            separatorBuilder: (_, __) => const Gap(6),
            itemBuilder: (context, index) {
              // ╪▓╪▒ ╪º╪│╪¬┘è╪▒╪º╪» ╪«╪╖ ╪¼╪»┘è╪»
              if (index == allFonts.length) {
                return GestureDetector(
                  onTap: _importCustomFont,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: primary),
                        const Gap(4),
                        Text(
                          '╪Ñ╪╢╪º┘ü╪⌐ ╪«╪╖',
                          style: TextStyle(
                            fontSize: 12,
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final font = allFonts[index];
              final isSelected = _fontFamily == font;
              final label = allLabels[font] ?? '╪«╪╖';
              final isCustom = _customFonts.contains(font);
              
              return GestureDetector(
                onTap: () {
                  _saveState();
                  setState(() => _fontFamily = font);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? primary : Colors.grey.withValues(alpha: 0.15),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCustom) ...[
                          Icon(Icons.folder_open_rounded, size: 12, color: primary.withValues(alpha: 0.6)),
                          const Gap(4),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: isCustom ? null : font,
                            fontSize: 14,
                            color: isSelected ? primary : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStyleChip(String id, String label, bool isSelected, Color primary) {
    return GestureDetector(
      onTap: () => setState(() => _categoryStyleId = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primary : primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : primary,
          ),
        ),
      ),
    );
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // ORIGINAL HELPER BUILDERS
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = themeState.primary;
    
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F1E6);
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final subtleColor = isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.4);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "┘à╪┤╪º╪▒┘â╪⌐ ╪º┘ä╪░┘â╪▒",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          centerTitle: true,
          actions: [
            if (_isSharing)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else ...[
              TextButton.icon(
                onPressed: _saveImage,
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text("╪¡┘ü╪╕", style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
              TextButton.icon(
                onPressed: _shareImage,
                icon: const Icon(Icons.ios_share_rounded, size: 20),
                label: const Text("┘à╪┤╪º╪▒┘â╪⌐", style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
            ],
          ],
        ),
        body: AbsorbPointer(
          absorbing: _isSharing,
          child: Column(
            children: [
            Expanded(
              flex: 5,
              child: Container(
                color: bg,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _isStoryMode ? 9 / 16 : 1,
                    child: Stack(
                      children: [
                        Screenshot(
                          controller: _screenshotController,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: AzkarShareDesign(
                              zekr: widget.zekr['zekr'] ?? "",
                              description: widget.zekr['description'],
                              reference: widget.zekr['reference'],
                              categoryName: widget.categoryName,
                              primaryColor: primary,
                              themeId: _themeId,
                              templateType: _templateType,
                              fontSize: _fontSize,
                              isGradientBg: _isGradientBg,
                              customBgColor: _customBgColor,
                              customBgColor2: _customBgColor2,
                              customTextColor: _customTextColor,
                              customAccentColor: _customAccentColor,
                              fontFamily: _fontFamily,
                              showBranding: _showBranding,
                              showCategoryHeader: _showCategoryHeader,
                              padding: _padding,
                              isStoryMode: _isStoryMode,
                              borderRadius: _borderRadius,
                              bgOpacity: _bgOpacity,
                              textAlign: _textAlign,
                              lineHeight: _lineHeight,
                              verticalAlignment: _verticalAlignment,
                              zekrColor: _zekrColor,
                              zekrFont: _zekrFont,
                              categoryColor: _categoryColor,
                              categoryFont: _categoryFont,
                              categoryStyleId: _categoryStyleId,
                              descriptionColor: _descriptionColor,
                              descriptionFont: _descriptionFont,
                              descriptionStyleId: _descriptionStyleId,
                              referenceColor: _referenceColor,
                              backgroundImagePath: _backgroundImagePath,
                              imageOffset: _imageOffset,
                              imageScale: _imageScale,
                              imageBlur: _imageBlur,
                              imageOverlayOpacity: _imageOverlayOpacity,
                              zekrFontSize: _zekrFontSize,
                              zekrLineHeight: _zekrLineHeight,
                              zekrOffsetX: _zekrOffsetX,
                              zekrOffsetY: _zekrOffsetY,
                              categoryFontSize: _categoryFontSize,
                              categoryLineHeight: _categoryLineHeight,
                              categoryOffsetX: _categoryOffsetX,
                              categoryOffsetY: _categoryOffsetY,
                              descriptionFontSize: _descriptionFontSize,
                              descriptionLineHeight: _descriptionLineHeight,
                              descriptionOffsetX: _descriptionOffsetX,
                              descriptionOffsetY: _descriptionOffsetY,
                              referenceFontSize: _referenceFontSize,
                              referenceLineHeight: _referenceLineHeight,
                              referenceOffsetX: _referenceOffsetX,
                              referenceOffsetY: _referenceOffsetY,
                            ),
                          ),
                        ),
                        
                        // Floating Undo/Redo ┘ü┘ê┘é ╪º┘ä┘Ç Preview - ╪¬┘à ┘å┘é┘ä┘ç ┘ü┘ê┘é ╪º┘ä╪¬╪¿┘ê┘è╪¿╪º╪¬
                        
                        Positioned.fill(
                          child: Column(
                            children: [
                              if (_showCategoryHeader)
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => _scrollToField(CustomizationField.category),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                              Expanded(
                                flex: 5,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () => _scrollToField(CustomizationField.zekr),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                              if (widget.zekr['description'] != null)
                                Expanded(
                                  flex: 3,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () => _scrollToField(CustomizationField.description),
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
            // TABS + CONTENT (┘à╪»┘à╪¼┘è┘å)
            // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
            Expanded(
              flex: 6,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      child: Column(
                        children: [
                          // ╪º┘ä╪¬╪¿┘ê┘è╪¿╪º╪¬
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: _buildTabBar(primary, isDark),
                          ),
                          // ╪º┘ä┘à╪¡╪¬┘ê┘ë
                          Expanded(
                            child: _buildTabContent(primary, subtleColor, textColor, cardColor, isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Undo/Redo ╪╣╪º╪ª┘à╪⌐ ┘ü┘ê┘é ┘â┘ä ╪¡╪º╪¼╪⌐
                  Positioned(
                    top: -23,
                    right: 16,
                    child: Row(
                      children: [
                        _buildFloatingButton(
                          icon: Icons.undo_rounded,
                          onPressed: _undo,
                          primary: primary,
                          isDark: isDark,
                          isEnabled: _undoStack.isNotEmpty,
                        ),
                        const Gap(6),
                        _buildFloatingButton(
                          icon: Icons.redo_rounded,
                          onPressed: _redo,
                          primary: primary,
                          isDark: isDark,
                          isEnabled: _redoStack.isNotEmpty,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // TAB BAR & CONTENT BUILDERS
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color primary,
    required bool isDark,
    bool isEnabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled 
                  ? primary 
                  : (isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(Color primary, bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: isDark ? Colors.white : primary,
        unselectedLabelColor: isDark 
            ? Colors.white.withValues(alpha: 0.45)
            : Colors.black.withValues(alpha: 0.5),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12.5,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: _tabs.map((tab) => Tab(
          height: 36,
          child: Text(tab.label),
        )).toList(),
      ),
    );
  }

  Widget _buildTabContent(
    Color primary,
    Color subtleColor,
    Color textColor,
    Color cardColor,
    bool isDark,
  ) {
    return TabBarView(
      controller: _tabController,
      physics: const BouncingScrollPhysics(),
      children: [
        // Tab 1: ╪º┘ä╪¬╪╡┘à┘è┘à
        _buildDesignTab(primary, subtleColor, textColor, cardColor, isDark),
        
        // Tab 2: ╪º┘ä╪╣┘å╪º╪╡╪▒
        _buildElementsTab(primary, subtleColor, textColor, cardColor, isDark),
        
        // Tab 3: ╪º┘ä╪¬╪«╪╖┘è╪╖
        _buildLayoutTab(primary, subtleColor, textColor, cardColor, isDark),
        
        // Tab 4: ╪º┘ä┘ç┘ê┘è╪⌐
        _buildIdentityTab(primary, subtleColor, textColor, cardColor, isDark),
      ],
    );
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // TAB CONTENT BUILDERS
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  Widget _buildDesignTab(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: _buildDesignContent(primary, subtleColor, textColor, cardColor, isDark),
    );
  }

  Widget _buildElementsTab(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: _buildElementsContent(primary, subtleColor, textColor, cardColor, isDark),
    );
  }

  Widget _buildLayoutTab(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: _buildLayoutContent(primary, subtleColor, textColor, cardColor, isDark),
    );
  }

  Widget _buildIdentityTab(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: _buildIdentityContent(primary, subtleColor, textColor, cardColor, isDark),
    );
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // Helper Builders
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  Widget _buildSectionTitle(String title, IconData icon, Color primary, Color subtleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 18),
          const Gap(10),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: subtleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, String val, Color primary, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(val, style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateOption(String id, String label, IconData icon, Color primary, Color cardColor, bool isDark) {
    final isSelected = _templateType == id;
    final subtleColor = isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.4);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _saveState();
        setState(() => _templateType = id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? primary.withValues(alpha: 0.08)
              : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? primary.withValues(alpha: 0.5)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? primary : subtleColor, size: 16),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primary : subtleColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlignmentOption(TextAlign align, IconData icon, Color primary) {
    final isSelected = _textAlign == align;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _textAlign = align);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected 
              ? primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected 
                ? primary.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(icon, color: isSelected ? primary : Colors.grey.shade400, size: 18),
      ),
    );
  }

  Widget _buildPatternOption(bool isStory, IconData icon, String label, Color primary) {
    final isSelected = _isStoryMode == isStory;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _isStoryMode = isStory);
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected 
                  ? primary.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primary : Colors.grey.shade400, size: 20),
              const Gap(6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primary : Colors.grey.shade500,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged, Color primary, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.75),
              fontSize: 13.5,
            ),
          ),
          const Spacer(),
          Switch.adaptive(
            value: value,
            activeColor: primary,
            activeTrackColor: primary.withValues(alpha: 0.3),
            onChanged: (val) {
              HapticFeedback.lightImpact();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String label, Color current, Function(Color) onSelect, Color textColor) {
    return InkWell(
      onTap: () async {
        HapticFeedback.lightImpact();
        final newColor = await showColorPickerDialog(context, current);
        onSelect(newColor);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.75),
                fontSize: 13.5,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: current,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: current.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAlignmentLabel(double val) {
    if (val < -0.3) return "╪ú╪╣┘ä┘ë";
    if (val > 0.3) return "╪ú╪│┘ü┘ä";
    return "┘à┘å╪¬╪╡┘ü";
  }

  Widget _buildElementCustomizer(CustomizationField field, Color primary, Color cardColor, bool isDark) {
    String? currentFont;
    Color? currentColor;
    double? currentSize;
    double? currentHeight;
    
    switch (field) {
      case CustomizationField.global: 
        currentFont = _fontFamily; 
        currentColor = _customTextColor;
        break;
      case CustomizationField.zekr: 
        currentFont = _zekrFont; 
        currentColor = _zekrColor;
        currentSize = _zekrFontSize;
        currentHeight = _zekrLineHeight;
        break;
      case CustomizationField.category: 
        currentFont = _categoryFont; 
        currentColor = _categoryColor;
        currentSize = _categoryFontSize;
        currentHeight = _categoryLineHeight;
        break;
      case CustomizationField.description: 
        currentFont = _descriptionFont; 
        currentColor = _descriptionColor;
        currentSize = _descriptionFontSize;
        currentHeight = _descriptionLineHeight;
        break;
      case CustomizationField.reference: 
        currentFont = _referenceFont; 
        currentColor = _referenceColor;
        currentSize = _referenceFontSize;
        currentHeight = _referenceLineHeight;
        break;
    }

    final Map<String, List<String>> families = {
      "╪º┘ä╪«╪╖┘ê╪╖ ╪º┘ä╪ú╪│╪º╪│┘è╪⌐": ["IDRISIUM", "KFGQPC-Uthmanic-HAFS-Regular", "Amiri-Regular", "Cairo-Bold", "Tajawal-Regular"],
    };
    for (var f in AppFonts.customFonts) {
      String prefix = f.split('-').first.split(' ').first;
      if (prefix.length < 3) prefix = f;
      if (!families.containsKey(prefix)) families[prefix] = [];
      if (!families["╪º┘ä╪«╪╖┘ê╪╖ ╪º┘ä╪ú╪│╪º╪│┘è╪⌐"]!.contains(f)) {
        families[prefix]!.add(f);
      }
    }

    String? currentFamily;
    for (var entry in families.entries) {
      if (entry.value.contains(currentFont)) { currentFamily = entry.key; break; }
    }
    currentFamily ??= families.keys.first;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Font Families
          _buildSubTitle("╪╣╪º╪ª┘ä╪º╪¬ ╪º┘ä╪«╪╖┘ê╪╖", primary),
          const Gap(12),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: families.keys.map((fam) {
                final isSelected = currentFamily == fam;
                return GestureDetector(
                  onTap: () => setState(() {
                    final defaultFont = families[fam]!.first;
                    if (field == CustomizationField.global) { _fontFamily = defaultFont; }
                    else if (field == CustomizationField.zekr) { _zekrFont = defaultFont; }
                    else if (field == CustomizationField.category) { _categoryFont = defaultFont; }
                    else if (field == CustomizationField.description) { _descriptionFont = defaultFont; }
                    else if (field == CustomizationField.reference) { _referenceFont = defaultFont; }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? primary : Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(
                        fam, 
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const Gap(16),
          // Font Variants (Weights/Styles)
          _buildSubTitle("╪º┘ä╪ú╪┤┘â╪º┘ä ╪º┘ä┘à╪¬╪º╪¡╪⌐", primary.withValues(alpha: 0.6)),
          const Gap(12),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: families[currentFamily]!.map((fontName) {
                final isSelected = currentFont == fontName;
                const preview = "╪º┘ä┘ü┘Å╪▒┘é╪º┘å";

                return GestureDetector(
                  onTap: () => setState(() {
                    if (field == CustomizationField.global) { _fontFamily = fontName; }
                    else if (field == CustomizationField.zekr) { _zekrFont = fontName; }
                    else if (field == CustomizationField.category) { _categoryFont = fontName; }
                    else if (field == CustomizationField.description) { _descriptionFont = fontName; }
                    else if (field == CustomizationField.reference) { _referenceFont = fontName; }
                  }),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? primary.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? primary : Colors.grey.withValues(alpha: 0.1), width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              preview,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: fontName, fontSize: 18, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? primary.withValues(alpha: 0.2) : (isDark ? Colors.white10 : Colors.black12),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                          ),
                          child: Text(
                            fontName.split('-').last.replaceAll('_', ' '),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 8, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Gap(24),

          // Size and Height Adjustment
          if (field != CustomizationField.global) ...[
            _buildSubTitle("╪¬╪¡╪¼┘è┘à ╪º┘ä╪╣┘å╪╡╪▒", primary),
            const Gap(12),
            _buildAdjustmentSlider(
              "╪¡╪¼┘à ╪º┘ä╪«╪╖", 
              currentSize ?? (field == CustomizationField.zekr ? 32 : (field == CustomizationField.category ? 24 : 18)),
              (val) => setState(() {
                if (field == CustomizationField.zekr) _zekrFontSize = val;
                if (field == CustomizationField.category) _categoryFontSize = val;
                if (field == CustomizationField.description) _descriptionFontSize = val;
                if (field == CustomizationField.reference) _referenceFontSize = val;
              }), 
              10, 80, primary, cardColor
            ),
            const Gap(8),
            _buildAdjustmentSlider(
              "╪º╪▒╪¬┘ü╪º╪╣ ╪º┘ä╪│╪╖╪▒", 
              currentHeight ?? (field == CustomizationField.zekr ? 1.7 : 1.4), 
              (val) => setState(() {
                if (field == CustomizationField.zekr) _zekrLineHeight = val;
                if (field == CustomizationField.category) _categoryLineHeight = val;
                if (field == CustomizationField.description) _descriptionLineHeight = val;
                if (field == CustomizationField.reference) _referenceLineHeight = val;
              }), 
              0.5, 4.0, primary, cardColor
            ),
            const Gap(8),
            Center(
              child: TextButton(
                onPressed: () => setState(() {
                  if (field == CustomizationField.zekr) { _zekrFontSize = null; _zekrLineHeight = null; }
                  if (field == CustomizationField.category) { _categoryFontSize = null; _categoryLineHeight = null; }
                  if (field == CustomizationField.description) { _descriptionFontSize = null; _descriptionLineHeight = null; }
                  if (field == CustomizationField.reference) { _referenceFontSize = null; _referenceLineHeight = null; }
                }),
                child: const Text("╪º╪│╪¬╪╣╪º╪»╪⌐ ╪º┘ä╪¡╪¼┘à ╪º┘ä╪º┘ü╪¬╪▒╪º╪╢┘è", style: TextStyle(fontSize: 12)),
              ),
            ),
            const Gap(24),
          ],

          if (field != CustomizationField.global) ...[
            // Color Selection
            _buildSubTitle("╪º┘ä┘ä┘ê┘å", primary),
            const Gap(12),
            SizedBox(
              height: 350,
              child: ColorPicker(
                color: currentColor ?? (isDark ? Colors.white : Colors.black),
                onColorChanged: (Color color) => setState(() {
                    if (field == CustomizationField.zekr) _zekrColor = color;
                    if (field == CustomizationField.category) _categoryColor = color;
                    if (field == CustomizationField.description) _descriptionColor = color;
                    if (field == CustomizationField.reference) _referenceColor = color;
                }),
                width: 36,
                height: 36,
                spacing: 8,
                runSpacing: 8,
                borderRadius: 12,
                wheelDiameter: 180,
                enableOpacity: true,
                showColorCode: true,
                colorCodeHasColor: true,
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.both: false,
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: false,
                  ColorPickerType.wheel: true,
                },
                actionButtons: const ColorPickerActionButtons(
                  okButton: false,
                  closeButton: false,
                  dialogActionButtons: false,
                ),
              ),
            ),
            if (currentColor != null)
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("╪º╪│╪¬╪▒╪¼╪º╪╣ ╪º┘ä┘ä┘ê┘å ╪º┘ä╪º┘ü╪¬╪▒╪º╪╢┘è"),
                  onPressed: () => setState(() {
                      if (field == CustomizationField.zekr) _zekrColor = null;
                      if (field == CustomizationField.category) _categoryColor = null;
                      if (field == CustomizationField.description) _descriptionColor = null;
                      if (field == CustomizationField.reference) _referenceColor = null;
                  }),
                ),
              ),
          ],
          const Gap(24),

          // Style Selection (Only for Category and Description)
          if (field == CustomizationField.category || field == CustomizationField.description) ...[
            _buildSubTitle("╪º┘ä╪│╪¬╪º┘è┘ä ╪º┘ä┘à╪▒╪ª┘è", primary),
            const Gap(12),
            _buildStyleSelector(field, primary, isDark),
            const Gap(24),
          ],
        ],
      ),
    );
  }

  Widget _buildSubTitle(String title, Color primary) {
    return Text(title, style: TextStyle(color: primary.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2));
  }


  Widget _buildStyleSelector(CustomizationField field, Color primary, bool isDark) {
    final styles = field == CustomizationField.category 
      ? {'classic': '┘â┘ä╪º╪│┘è┘â┘è', 'pill': '╪¿┘è╪╢╪º┘ê┘è', 'modern': '┘à┘ê╪»╪▒┘å'}
      : {'classic': '┘â┘ä╪º╪│┘è┘â┘è', 'soft_pill': '╪«┘ä┘ü┘è╪⌐ ┘å╪º╪╣┘à╪⌐', 'quote': '╪º┘é╪¬╪¿╪º╪│', 'underline': '╪«╪╖ ╪│┘ü┘ä┘è'};

    String currentId = field == CustomizationField.category ? _categoryStyleId : _descriptionStyleId;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: styles.entries.map((e) {
        bool isSelected = currentId == e.key;
        return InkWell(
          onTap: () => setState(() {
            if (field == CustomizationField.category) _categoryStyleId = e.key;
            if (field == CustomizationField.description) _descriptionStyleId = e.key;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary : (isDark ? Colors.white10 : Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(e.value, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const Gap(4),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustmentSlider(String label, double value, ValueChanged<double> onChanged, double min, double max, Color primary, Color textColor) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600)),
            Text(value.toStringAsFixed(2), style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: primary,
            inactiveColor: primary.withValues(alpha: 0.1),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showImageAdjuster() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("╪¬╪╣╪»┘è┘ä ┘à┘â╪º┘å ╪º┘ä╪╡┘ê╪▒╪⌐ / ╪▓┘ê┘à", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 30), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      boundaryMargin: const EdgeInsets.all(300),
                      minScale: 0.1,
                      maxScale: 10.0,
                      onInteractionEnd: (details) {
                        final matrix = _transformationController.value;
                        setState(() {
                           _imageScale = matrix.getMaxScaleOnAxis();
                           _imageOffset = Offset(matrix.storage[12], matrix.storage[13]);
                        });
                      },
                      child: Image.file(
                        File(_backgroundImagePath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  "╪º╪│╪¡╪¿ ╪º┘ä╪╡┘ê╪▒╪⌐ ┘ä╪¬╪¡╪▒┘è┘â┘ç╪º ┘ê╪º╪│╪¬╪«╪»┘à ╪Ñ╪╡╪¿╪╣┘è┘å ┘ä┘ä╪¬┘â╪¿┘è╪▒ ┘ê╪º┘ä╪¬╪╡╪║┘è╪▒",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}


class _ThemePreview {
  final String label;
  final Color bg;
  final Color accent;
  final IconData icon;
  const _ThemePreview(this.label, this.bg, this.accent, this.icon);
}

// Full Spectrum Color Picker Dialog
class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  const _ColorPickerDialog({required this.initialColor});
  
  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late double _hue;
  late double _saturation;
  late double _value;
  late double _alpha;
  
  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _alpha = hsv.alpha;
  }
  
  Color get _selectedColor => HSVColor.fromAHSV(_alpha, _hue, _saturation, _value).toColor();
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color Preview
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
            const Gap(20),
            // Hue Slider
            Row(
              children: [
                const Text("H", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Gap(8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(trackHeight: 12),
                    child: Slider(
                      value: _hue,
                      min: 0,
                      max: 360,
                      activeColor: HSVColor.fromAHSV(1, _hue, 1, 1).toColor(),
                      onChanged: (v) => setState(() => _hue = v),
                    ),
                  ),
                ),
              ],
            ),
            // Saturation Slider
            Row(
              children: [
                const Text("S", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Gap(8),
                Expanded(
                  child: Slider(
                    value: _saturation,
                    min: 0,
                    max: 1,
                    activeColor: _selectedColor,
                    onChanged: (v) => setState(() => _saturation = v),
                  ),
                ),
              ],
            ),
            // Value Slider
            Row(
              children: [
                const Text("V", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Gap(8),
                Expanded(
                  child: Slider(
                    value: _value,
                    min: 0,
                    max: 1,
                    activeColor: _selectedColor,
                    onChanged: (v) => setState(() => _value = v),
                  ),
                ),
              ],
            ),
            // Alpha Slider
            Row(
              children: [
                const Text("A", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const Gap(8),
                Expanded(
                  child: Slider(
                    value: _alpha,
                    min: 0,
                    max: 1,
                    activeColor: _selectedColor.withValues(alpha: _alpha),
                    onChanged: (v) => setState(() => _alpha = v),
                  ),
                ),
              ],
            ),
            const Gap(20),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("╪Ñ┘ä╪║╪º╪í", style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context, _selectedColor),
                  child: const Text("╪º╪«╪¬┘è╪º╪▒", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
