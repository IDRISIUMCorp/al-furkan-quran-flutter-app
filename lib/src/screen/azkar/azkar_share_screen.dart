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
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/screen/azkar/widgets/azkar_share_design.dart';
import 'package:al_furkan/src/core/constants/app_fonts.dart';
import 'package:al_furkan/src/screen/azkar/models/azkar_share_settings.dart';
import 'package:al_furkan/src/screen/azkar/services/azkar_share_preferences.dart';



enum CustomizationField { global, zekr, category, description, reference }

/// Tab item for TabBar
class _TabItem {
  final String label;
  final IconData icon;
  
  const _TabItem(this.label, this.icon);
}

// QUICK PRESETS

enum SharePreset {
  elegant('أنيق', 'dark_royal', 'royal', 28, true, false, true),
  minimal('مُبسّط', 'glass_light', 'minimalist', 24, false, false, false),
  viral('ستوري', 'sunset', 'insta_quote', 32, true, true, true),
  classic('كلاسيكي', 'glass_dark', 'classic', 26, true, true, true),
  nature('هادئ', 'emerald_gradient', 'zen', 24, true, false, true);

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
  
  // Granular element state
  double? _zekrFontSize;
  double? _zekrLineHeight;
  double _zekrOffsetX = 0.0; // Horizontal offset
  double _zekrOffsetY = 0.0; // Vertical offset
  
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

  String? _openColorPanelId;
  final Map<String, TextEditingController> _colorHexControllers = {};

  // UNDO/REDO SYSTEM
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  static const int _maxHistorySize = 20;

  /// Helper: encode the current customization state as JSON
  String _encodeCurrentState() {
    return jsonEncode({
      'themeId': _themeId,
      'templateType': _templateType,
      'fontSize': _fontSize,
      'isGradientBg': _isGradientBg,
      'customBgColor': _customBgColor.toARGB32(),
      'customBgColor2': _customBgColor2.toARGB32(),
      'customTextColor': _customTextColor.toARGB32(),
      'customAccentColor': _customAccentColor.toARGB32(),
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
      'zekrColor': _zekrColor?.toARGB32(),
      'categoryColor': _categoryColor?.toARGB32(),
      'descriptionColor': _descriptionColor?.toARGB32(),
      'referenceColor': _referenceColor?.toARGB32(),
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

  // THEMES

  static const Map<String, _ThemePreview> _themes = {
    'glass_dark':       _ThemePreview('زجاجي داكن', Color(0xFF0A0A0A), Colors.white, Icons.dark_mode_rounded),
    'dark_royal':       _ThemePreview('ملكي ذهبي', Color(0xFF0A0806), Color(0xFFD4A746), Icons.auto_awesome),
    'midnight_blue':    _ThemePreview('ليلي أزرق', Color(0xFF0D1B2A), Color(0xFF64B5F6), Icons.nightlight_round),
    'emerald_gradient': _ThemePreview('زمردي', Color(0xFF0A1F1A), Color(0xFF80CBC4), Icons.eco_rounded),
    'sunset':           _ThemePreview('بنفسجي', Color(0xFF1A0A2E), Color(0xFFCE93D8), Icons.gradient_rounded),
    'sand_dunes':       _ThemePreview('رملي', Color(0xFFEFEBE9), Color(0xFF8D6E63), Icons.landscape_rounded),
    'ocean_night':      _ThemePreview('محيط ليلي', Color(0xFF0A1628), Color(0xFF4DD0E1), Icons.water_rounded),
    'rose_gold':        _ThemePreview('روز جولد', Color(0xFFFBE9E7), Color(0xFFB76E79), Icons.local_florist_rounded),
    'forest_green':     _ThemePreview('غابة خضراء', Color(0xFF0B1F0E), Color(0xFF66BB6A), Icons.park_rounded),
    'glass_light':      _ThemePreview('زجاجي فاتح', Color(0xFFFDFAF5), Color(0xFF1B1B1B), Icons.light_mode_rounded),
    'custom':           _ThemePreview('مخصص', Color(0xFF141414), Color(0xFF33B18E), Icons.color_lens_rounded),
  };

  // TABS STATE
  static const List<_TabItem> _tabs = [
    _TabItem('التصميم', Icons.palette_rounded),
    _TabItem('العناصر', Icons.text_fields_rounded),
    _TabItem('التنسيق', Icons.aspect_ratio_rounded),
    _TabItem('الهوية', Icons.verified_user_rounded),
  ];

  // Custom fonts
  List<String> _customFonts = [];
  List<String> _customFontNames = [];

  Future<void> _deleteCustomFontByFamily(String family) async {
    final index = _customFontNames.indexOf(family);
    if (index < 0) return;

    _saveState();

    setState(() {
      _customFontNames.removeAt(index);
      _customFonts.removeAt(index);

      if (_fontFamily == family) {
        _fontFamily = 'IDRISIUM';
      }

      if (_zekrFont == family) _zekrFont = null;
      if (_categoryFont == family) _categoryFont = null;
      if (_descriptionFont == family) _descriptionFont = null;
      if (_referenceFont == family) _referenceFont = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('azkar_custom_fonts', _customFonts);
      await prefs.setStringList('azkar_custom_font_names', _customFontNames);

      final selectedPath = prefs.getString('azkar_selected_custom_font_path');
      if (selectedPath != null && !_customFonts.contains(selectedPath)) {
        await prefs.remove('azkar_selected_custom_font_path');
      }
    } catch (_) {}
  }

  Future<void> _loadCustomFontIfSelected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedPath = prefs.getString('azkar_selected_custom_font_path');
      if (selectedPath == null) return;
      if (!_customFonts.contains(selectedPath)) return;
      final idx = _customFonts.indexOf(selectedPath);
      if (idx < 0 || idx >= _customFontNames.length) return;
      await _loadCustomFontFromPath(selectedPath, _customFontNames[idx]);
      if (mounted) {
        setState(() {
          _fontFamily = _customFontNames[idx];
        });
      }
    } catch (_) {
      return;
    }
  }

  Future<void> _loadCustomFontFromPath(String fontPath, String familyName) async {
    final file = File(fontPath);
    if (!await file.exists()) return;
    final bytes = await file.readAsBytes();
    final loader = FontLoader(familyName);
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
  
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

  String _toHexAarrggbb(Color c) {
    final a = (c.a * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    final r = (c.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = (c.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = (c.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$a$r$g$b';
  }

  Color? _parseHexAarrggbb(String input) {
    var s = input.trim().toUpperCase();
    if (s.startsWith('0X')) s = s.substring(2);
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 6) s = 'FF$s';
    if (s.length != 8) return null;
    final v = int.tryParse(s, radix: 16);
    if (v == null) return null;
    return Color(v);
  }

  TextEditingController _hexControllerFor(String id, Color color) {
    final existing = _colorHexControllers[id];
    final hex = _toHexAarrggbb(color);
    if (existing != null) {
      if (existing.text != hex) existing.text = hex;
      return existing;
    }
    final c = TextEditingController(text: hex);
    _colorHexControllers[id] = c;
    return c;
  }
  
  /// Load saved share settings
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
  
  /// Save current share settings
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
  
  /// Load custom fonts from preferences
  Future<void> _loadCustomFonts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fonts = prefs.getStringList('azkar_custom_fonts') ?? [];
      final names = prefs.getStringList('azkar_custom_font_names') ?? [];
      setState(() {
        _customFonts = fonts;
        _customFontNames = names;
      });
      await _loadCustomFontIfSelected();
    } catch (_) {}
  }
  
  /// Import a custom font file
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

      await _loadCustomFontFromPath(newPath, fontFamilyName);
      await prefs.setString('azkar_selected_custom_font_path', newPath);

      setState(() {
        _fontFamily = fontFamilyName;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة الخط: $fontFamilyName'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إضافة الخط: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _colorHexControllers.values) {
      c.dispose();
    }
    _colorHexControllers.clear();
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
    // High quality capture: devicePixelRatio * 3
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
        await Share.shareXFiles([XFile(file.path)], text: 'مشاركة من أذكار المسلم');
      } else {
        await Gal.putImageBytes(bytes, album: 'AlFurkan');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("تم حفظ الصورة في المعرض", textDirection: TextDirection.rtl),
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
            content: Text("حصل خطأ: $e", textDirection: TextDirection.rtl),
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

  // UI HELPERS

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
      ('none', 'بدون', null),
      ('grayscale', 'أبيض وأسود', Colors.grey),
      ('sepia', 'سيبيا', const Color(0xFF8B7355)),
      ('vintage', 'فينتج', const Color(0xFFD4A574)),
      ('cool', 'بارد', Colors.cyan),
      ('warm', 'دافئ', Colors.orange),
      ('dramatic', 'درامي', Colors.purple),
      ('fade', 'باهت', Colors.grey),
      ('contrast', 'تباين', Colors.black),
      ('bright', 'ساطع', Colors.yellow),
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

  // PANEL CONTENT BUILDERS

  Widget _buildDesignContent(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("قوالب التصميم (ستوري/بوست)", Icons.dashboard_customize_rounded, primary, subtleColor),
        const Gap(12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTemplateOption('classic', 'كلاسيكي', Icons.crop_square_rounded, primary, cardColor, isDark),
              _buildTemplateOption('minimalist', 'مُبسّط', Icons.view_agenda_rounded, primary, cardColor, isDark),
            ],
          ),
        ),
        const Gap(24),
        _buildSectionTitle("الثيمات", Icons.palette_rounded, primary, subtleColor),
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
        _buildSectionTitle("خلفية صورة", Icons.image_rounded, primary, subtleColor),
        const Gap(12),
        Row(
          children: [
            _buildImageAction("اختيار صورة", Icons.add_photo_alternate_rounded, primary, () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) setState(() => _backgroundImagePath = image.path);
            }),
            if (_backgroundImagePath != null) ...[
              const Gap(12),
              _buildImageAction("تعديل", Icons.edit_attributes_rounded, primary, () => _showImageAdjuster()),
              const Gap(12),
              _buildImageAction("حذف", Icons.delete_forever_rounded, Colors.redAccent, () => setState(() => _backgroundImagePath = null)),
            ],
          ],
        ),
        if (_backgroundImagePath != null) ...[
          const Gap(16),
          _buildAdjustmentSlider("تمويه الخلفية (Blur)", _imageBlur, (v) => setState(() => _imageBlur = v), 0, 20, primary, textColor),
          const Gap(12),
          _buildAdjustmentSlider("تعتيم الطبقة (Opacity)", _imageOverlayOpacity, (v) => setState(() => _imageOverlayOpacity = v), 0, 1, primary, textColor),
          const Gap(12),
          _buildSectionTitle("فلتر الصورة", Icons.filter_alt_rounded, primary, subtleColor),
          const Gap(12),
          _buildImageFilterSelector(primary, cardColor, isDark),
        ],
        if (_themeId == 'custom') ...[
          const Gap(24),
          _buildSectionTitle("ألوان مخصصة", Icons.color_lens_rounded, primary, subtleColor),
          const Gap(16),
          _buildColorOption("لون الخلفية", _customBgColor, (c) => setState(() => _customBgColor = c), textColor),
          const Gap(12),
          _buildToggle("خلفية متدرجة", _isGradientBg, (val) => setState(() => _isGradientBg = val), primary, textColor),
          if (_isGradientBg) ...[
            const Gap(12),
            _buildColorOption("لون الخلفية 2", _customBgColor2, (c) => setState(() => _customBgColor2 = c), textColor),
          ],
          const Gap(12),
          _buildColorOption("لون النص", _customTextColor, (c) => setState(() => _customTextColor = c), textColor),
          const Gap(12),
          _buildColorOption("لون التمييز", _customAccentColor, (c) => setState(() => _customAccentColor = c), textColor),
        ],
      ],
    );
  }

  // Elements Content
  Widget _buildElementsContent(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("خط عام", Icons.font_download_rounded, primary, subtleColor),
          const Gap(12),
          _buildFontSelector(primary, cardColor, isDark),
          const Gap(8),

          // Global font
          _buildSectionTitle("تفاصيل الخط", Icons.font_download_rounded, primary, subtleColor),
          const Gap(12),
          Text(
            "اختيار الخط هنا بيأثر على النص الرئيسي (لو ماحددتش خطوط مختلفة لكل عنصر تحت).",
            style: TextStyle(fontSize: 12, color: subtleColor, height: 1.4),
          ),
          const Gap(16),
          _buildSliderRow("الحجم", "${_fontSize.toInt()}", primary, textColor),
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
          
          // Zekr
          _buildSectionTitle("نص الذكر", Icons.text_fields_rounded, primary, subtleColor),
          const Gap(12),
          _buildFullColorPicker('zekr', _zekrColor, (c) => setState(() => _zekrColor = c), primary, textColor, isDark),
          const Gap(12),
          _buildFontDropdown("خط الذكر", _zekrFont, (f) => setState(() => _zekrFont = f), primary),
          const Gap(12),
          _buildSliderRow("حجم خط الذكر", "${(_zekrFontSize ?? _fontSize + 16).toInt()}", primary, textColor),
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
          _buildSliderRow("إزاحة أفقي", "${_zekrOffsetX.toInt()}", primary, textColor),
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
                tooltip: "إعادة ضبط",
              ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("إزاحة رأسي", "${_zekrOffsetY.toInt()}", primary, textColor),
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
                tooltip: "إعادة ضبط",
              ),
            ],
          ),
          const Gap(24),
          
          // Category
          _buildSectionTitle("عنوان القسم", Icons.category_rounded, primary, subtleColor),
          const Gap(12),
          _buildFullColorPicker('category', _categoryColor, (c) => setState(() => _categoryColor = c), primary, textColor, isDark),
          const Gap(12),
          _buildFontDropdown("خط العنوان", _categoryFont, (f) => setState(() => _categoryFont = f), primary),
          const Gap(12),
          Text("ستايل العنوان:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7))),
          const Gap(8),
          Row(
            children: [
              _buildStyleChip('classic', 'كلاسيكي', _categoryStyleId == 'classic', primary),
              const Gap(8),
              _buildStyleChip('pill', 'كبسولة', _categoryStyleId == 'pill', primary),
              const Gap(8),
              _buildStyleChip('modern', 'مودرن', _categoryStyleId == 'modern', primary),
            ],
          ),
          const Gap(12),
          _buildSliderRow("حجم خط العنوان", "${(_categoryFontSize ?? _fontSize + 12).toInt()}", primary, textColor),
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
          _buildSliderRow("إزاحة أفقي", "${_categoryOffsetX.toInt()}", primary, textColor),
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
                tooltip: "إعادة ضبط",
              ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("إزاحة رأسي", "${_categoryOffsetY.toInt()}", primary, textColor),
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
                  tooltip: "إعادة ضبط",
                ),
            ],
          ),
          const Gap(24),
          
          // Reference
          _buildSectionTitle("المصدر", Icons.bookmark_rounded, primary, subtleColor),
          _buildFullColorPicker('reference', _referenceColor, (c) => setState(() => _referenceColor = c), primary, textColor, isDark),
          const Gap(12),
          _buildFontDropdown("خط المصدر", _referenceFont, (f) => setState(() => _referenceFont = f), primary),
          const Gap(12),
          _buildSliderRow("حجم خط المصدر", "${(_referenceFontSize ?? _fontSize - 4).toInt()}", primary, textColor),
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
                  tooltip: "إعادة ضبط",
                ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("إزاحة أفقي", "${_referenceOffsetX.toInt()}", primary, textColor),
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
                  tooltip: "إعادة ضبط",
                ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("إزاحة رأسي", "${_referenceOffsetY.toInt()}", primary, textColor),
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
                  tooltip: "إعادة ضبط",
                ),
            ],
          ),
          const Gap(24),
          
          // Description
          _buildSectionTitle("وصف إضافي", Icons.star_rounded, primary, subtleColor),
          const Gap(12),
          _buildFullColorPicker('description', _descriptionColor, (c) => setState(() => _descriptionColor = c), primary, textColor, isDark),
          const Gap(12),
          _buildFontDropdown("خط الوصف", _descriptionFont, (f) => setState(() => _descriptionFont = f), primary),
          const Gap(12),
          _buildSliderRow("حجم خط الوصف", "${(_descriptionFontSize ?? _fontSize + 4).toInt()}", primary, textColor),
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
                  tooltip: "إعادة ضبط",
                ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("إزاحة أفقي", "${_descriptionOffsetX.toInt()}", primary, textColor),
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
                  tooltip: "إعادة ضبط",
                ),
            ],
          ),
          const Gap(8),
          _buildSliderRow("إزاحة رأسي", "${_descriptionOffsetY.toInt()}", primary, textColor),
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
                  tooltip: "إعادة ضبط",
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFullColorPicker(
    String id,
    Color? currentColor,
    Function(Color?) onColorPicked,
    Color primary,
    Color textColor,
    bool isDark,
  ) {
    final isOpen = _openColorPanelId == id;
    final effective = currentColor ?? (isDark ? Colors.white : Colors.black);

    final hexController = _hexControllerFor(id, effective);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
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
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _openColorPanelId = isOpen ? null : id;
                  });
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
                        currentColor != null ? "مخصص" : "اختيار لون",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: currentColor != null ? FontWeight.bold : FontWeight.normal,
                          color: currentColor ?? Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: (currentColor ?? textColor).withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutQuart,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                final slide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(fade);
                return FadeTransition(
                  opacity: fade,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: isOpen
                  ? Padding(
                      key: ValueKey('panel-$id'),
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.035),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ColorPicker(
                                  color: effective,
                                  onColorChanged: (c) {
                                    _saveState();
                                    onColorPicked(c);
                                    _hexControllerFor(id, c);
                                  },
                                  width: 44,
                                  height: 44,
                                  spacing: 14,
                                  runSpacing: 14,
                                  borderRadius: 16,
                                  wheelDiameter: 280,
                                  enableOpacity: true,
                                  showColorCode: false,
                                  colorCodeHasColor: false,
                                  pickersEnabled: const <ColorPickerType, bool>{
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
                                const Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: hexController,
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                                        decoration: InputDecoration(
                                          labelText: 'HEX',
                                          labelStyle: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 12),
                                          filled: true,
                                          fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: textColor.withValues(alpha: 0.12))),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: textColor.withValues(alpha: 0.12))),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: textColor.withValues(alpha: 0.22))),
                                        ),
                                        onSubmitted: (v) {
                                          final c = _parseHexAarrggbb(v);
                                          if (c != null) {
                                            _saveState();
                                            onColorPicked(c);
                                            _hexControllerFor(id, c);
                                          }
                                        },
                                      ),
                                    ),
                                    const Gap(10),
                                    IconButton(
                                      tooltip: 'نسخ',
                                      onPressed: () => Clipboard.setData(ClipboardData(text: _toHexAarrggbb(effective))),
                                      icon: Icon(Icons.copy_rounded, color: textColor.withValues(alpha: 0.7)),
                                    ),
                                    IconButton(
                                      tooltip: 'لصق',
                                      onPressed: () async {
                                        final data = await Clipboard.getData('text/plain');
                                        final t = data?.text;
                                        if (t == null) return;
                                        final c = _parseHexAarrggbb(t);
                                        if (c != null) {
                                          _saveState();
                                          onColorPicked(c);
                                          _hexControllerFor(id, c);
                                        }
                                      },
                                      icon: Icon(Icons.content_paste_rounded, color: textColor.withValues(alpha: 0.7)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('panel-closed')),
            ),
          ),
        ),
      ],
    );
  }
  
  // Font selector chips
  Widget _buildFontDropdown(String label, String? currentFont, Function(String?) onFontChanged, Color primary) {
    final fonts = <String?>[
      null, // Default
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
      null: 'افتراضي',
      'KFGQPC-Uthmanic-HAFS-Regular': 'عثماني',
      'Amiri-Regular': 'أميري',
      'Cairo-Bold': 'Cairo Bold',
      'IDRISIUM': 'IDRISIUM',
      'AmiriQuran-Regular': 'أميري قرآن',
      'Aref Ruqaa Bold': 'عارف رقعة',
      'Cairo-Regular': 'Cairo',
      'Cairo-Light': 'Cairo Light',
      'Cairo-SemiBold': 'Cairo SemiBold',
      'Cairo-Black': 'Cairo Black',
      'al-majd': 'المجد',
      'bader-lamsat': 'بدر لمسات',
      'Afsaneh-Font': 'Afsaneh',
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
              final label = fontLabels[font] ?? 'خط';
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

  // Layout Content
  Widget _buildLayoutContent(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Output mode
        _buildSectionTitle("نمط الإخراج", Icons.aspect_ratio_rounded, primary, subtleColor),
        const Gap(12),
        Row(
          children: [
            _buildPatternOption(false, Icons.crop_square_rounded, "بوست (1:1)", primary),
            const Gap(12),
            _buildPatternOption(true, Icons.phone_android_rounded, "ستوري (9:16)", primary),
          ],
        ),
        const Gap(24),
        
        // Text alignment
        _buildSectionTitle("محاذاة النص", Icons.format_align_center_rounded, primary, subtleColor),
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
        
        // Layout tuning
        _buildSectionTitle("إعدادات التنسيق", Icons.tune_rounded, primary, subtleColor),
        const Gap(12),
        _buildSliderRow("تباعد السطور", _lineHeight.toStringAsFixed(1), primary, textColor),
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
        _buildSliderRow("المساحة الداخلية", "${_padding.toInt()}", primary, textColor),
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
        _buildSliderRow("تدوير الحواف", "${_borderRadius.toInt()}", primary, textColor),
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
        _buildSliderRow("شفافية الخلفية", _bgOpacity.toStringAsFixed(2), primary, textColor),
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

  // Identity Content
  Widget _buildIdentityContent(Color primary, Color subtleColor, Color textColor, Color cardColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("الهوية", Icons.verified_user_rounded, primary, subtleColor),
        const Gap(16),
        _buildToggle("إظهار عنوان القسم", _showCategoryHeader, (val) => setState(() => _showCategoryHeader = val), primary, textColor),
        const Gap(8),
        _buildToggle("إظهار الهوية (شعار/نص)", _showBranding, (val) => setState(() => _showBranding = val), primary, textColor),
      ],
    );
  }

  // HELPER WIDGETS

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
    // Small preset palette chip
    final presetColors = [
      Colors.white,
      Colors.black,
      const Color(0xFFD4A746), // Gold
      const Color(0xFF33B18E), // Teal
      const Color(0xFF64B5F6), // Blue
      const Color(0xFFCE93D8), // Purple
      const Color(0xFFB76E79), // Rose
      const Color(0xFF66BB6A), // Green
      const Color(0xFFFF7043), // Orange
    ];
    
    return GestureDetector(
      onTap: () {
        // Toggle: tap again to clear
        if (currentColor != null) {
          _saveState();
          onColorPicked(null);
          return;
        }
        // Otherwise open the picker (handled by parent)
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
  
  // Inline palette
  Widget _buildInlineColorPicker(Color? currentColor, Function(Color?) onColorPicked, Color primary) {
    final presetColors = [
      null, // Default
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
      'IDRISIUM': 'IDRISIUM',
      'KFGQPC-Uthmanic-HAFS-Regular': 'عثماني',
      'Amiri-Regular': 'أميري',
      'Cairo-Bold': 'Cairo Bold',
      'AmiriQuran-Regular': 'أميري قرآن',
      'Aref Ruqaa Bold': 'عارف رقعة',
      'Cairo-Regular': 'Cairo',
      'Cairo-Light': 'Cairo Light',
      'Cairo-SemiBold': 'Cairo SemiBold',
      'Cairo-Black': 'Cairo Black',
      'al-majd': 'المجد',
      'bader-lamsat': 'بدر لمسات',
      'Afsaneh-Font': 'Afsaneh',
      'Abd-ElRady-Regular': 'Abd ElRady',
      'al-hadaribold': 'Hadari',
      'a-massir-ballpoint': 'Massir',
      'b-helal': 'Helal',
      'ASane-Jaleh': 'ASane Jaleh',
      'BritishCouncil-Arabic-Black': 'British Council',
    };
    
    final customFamilyToPath = <String, String>{};
    for (int i = 0; i < _customFonts.length && i < _customFontNames.length; i++) {
      customFamilyToPath[_customFontNames[i]] = _customFonts[i];
    }

    final allFonts = [...fonts, ...customFamilyToPath.keys];
    final allLabels = <String, String>{
      ...fontLabels,
      ...Map<String, String>.fromEntries(customFamilyToPath.keys.map((k) => MapEntry(k, k))),
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: allFonts.length + 1, // +1 = add font button
            separatorBuilder: (_, __) => const Gap(6),
            itemBuilder: (context, index) {
              // Add font button
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
                          'إضافة خط',
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
              final label = allLabels[font] ?? 'خط';
              final isCustom = customFamilyToPath.containsKey(font);
              
              return GestureDetector(
                onLongPress: isCustom
                    ? () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text('حذف الخط'),
                              content: Text('هل تريد حذف الخط "$label"؟'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
                              ],
                            );
                          },
                        );
                        if (ok == true) {
                          await _deleteCustomFontByFamily(font);
                        }
                      }
                    : null,
                onTap: () {
                  _saveState();
                  if (isCustom) {
                    final path = customFamilyToPath[font];
                    if (path != null) {
                      _loadCustomFontFromPath(path, font);
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString('azkar_selected_custom_font_path', path);
                      });
                    }
                  }
                  setState(() {
                    _fontFamily = font;
                    _zekrFont = font;
                    _categoryFont = font;
                    _descriptionFont = font;
                    _referenceFont = font;
                  });
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
                          Icon(Icons.folder_open_rounded, size: 14, color: primary.withValues(alpha: 0.65)),
                          const Gap(6),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: font,
                            fontSize: 13,
                            color: isSelected ? primary : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.w700,
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

  // ORIGINAL HELPER BUILDERS

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
              "مشاركة الذكر",
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
                label: const Text("حفظ", style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
              TextButton.icon(
                onPressed: _shareImage,
                icon: const Icon(Icons.ios_share_rounded, size: 20),
                label: const Text("مشاركة", style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
            ],
          ],
        ),
        body: AbsorbPointer(
          absorbing: _isSharing,
          child: Stack(
            children: [
              Column(
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
                                    imageFilter: _imageFilter,
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
                Expanded(
                  flex: 6,
                  child: Container(
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            child: _buildTabBar(primary, isDark),
                          ),
                          Expanded(
                            child: _buildTabContent(primary, subtleColor, textColor, cardColor, isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ],
              ),
              Positioned(
                top: 280,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      _buildFloatingButton(
                        icon: Icons.undo_rounded,
                        onPressed: _undo,
                        primary: primary,
                        isDark: isDark,
                        isEnabled: _undoStack.isNotEmpty,
                      ),
                      const Gap(8),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB BAR & CONTENT BUILDERS

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
        // Tab 1: التصميم
        _buildDesignTab(primary, subtleColor, textColor, cardColor, isDark),
        
        // Tab 2: العناصر
        _buildElementsTab(primary, subtleColor, textColor, cardColor, isDark),
        
        // Tab 3: التنسيق
        _buildLayoutTab(primary, subtleColor, textColor, cardColor, isDark),
        
        // Tab 4: الهوية
        _buildIdentityTab(primary, subtleColor, textColor, cardColor, isDark),
      ],
    );
  }

  // TAB CONTENT BUILDERS

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

  // Helper Builders

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
            activeThumbColor: primary,
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
    if (val < -0.3) return "أعلى";
    if (val > 0.3) return "أسفل";
    return "منتصف";
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
      "الخطوط المقترحة": ["IDRISIUM", "KFGQPC-Uthmanic-HAFS-Regular", "Amiri-Regular", "Cairo-Bold", "Tajawal-Regular"],
    };
    for (var f in AppFonts.customFonts) {
      String prefix = f.split('-').first.split(' ').first;
      if (prefix.length < 3) prefix = f;
      if (!families.containsKey(prefix)) families[prefix] = [];
      if (!families["الخطوط المقترحة"]!.contains(f)) {
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
          _buildSubTitle("مجموعات الخطوط", primary),
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
          _buildSubTitle("أنماط الخط", primary.withValues(alpha: 0.6)),
          const Gap(12),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: families[currentFamily]!.map((fontName) {
                final isSelected = currentFont == fontName;
                const preview = "الحمد لله";

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
            _buildSubTitle("مقاس وتباعد", primary),
            const Gap(12),
            _buildAdjustmentSlider(
              "حجم الخط", 
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
              "تباعد الأسطر", 
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
                child: const Text("إعادة الضبط للوضع الافتراضي", style: TextStyle(fontSize: 12)),
              ),
            ),
            const Gap(24),
          ],

          if (field != CustomizationField.global) ...[
            // Color Selection
            _buildSubTitle("اللون", primary),
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
                  label: const Text("إلغاء اللون المخصص"),
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
            _buildSubTitle("ستايل العنصر", primary),
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
      ? {'classic': 'كلاسيكي', 'pill': 'كبسولة', 'modern': 'مودرن'}
      : {'classic': 'كلاسيكي', 'soft_pill': 'كبسولة ناعمة', 'quote': 'اقتباس', 'underline': 'خط سفلي'};

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
        builder: (ctx, setModalState) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("تعديل مكان الصورة / زوم", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  "كبر وصغر واسحب الصورة لمكان مناسب. التعديل بيتحفظ تلقائيًا بعد ما تسيب الزوم.",
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
  late final TextEditingController _hexController;
  
  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _alpha = hsv.alpha;

    _hexController = TextEditingController(text: _toHex(HSVColor.fromAHSV(_alpha, _hue, _saturation, _value).toColor()));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }
  
  Color get _selectedColor => HSVColor.fromAHSV(_alpha, _hue, _saturation, _value).toColor();

  String _toHex(Color c) {
    final a = (c.a * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    final r = (c.r * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = (c.g * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = (c.b * 255.0).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$a$r$g$b';
  }

  Color? _parseHex(String input) {
    var s = input.trim().toUpperCase();
    if (s.startsWith('0X')) s = s.substring(2);
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 6) {
      s = 'FF$s';
    }
    if (s.length != 8) return null;
    final value = int.tryParse(s, radix: 16);
    if (value == null) return null;
    return Color(value);
  }
  
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hexController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'HEX (AARRGGBB)',
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.22))),
                    ),
                    onSubmitted: (v) {
                      final c = _parseHex(v);
                      if (c == null) return;
                      final hsv = HSVColor.fromColor(c);
                      setState(() {
                        _hue = hsv.hue;
                        _saturation = hsv.saturation;
                        _value = hsv.value;
                        _alpha = hsv.alpha;
                        _hexController.text = _toHex(_selectedColor);
                      });
                    },
                  ),
                ),
                const Gap(10),
                IconButton(
                  tooltip: 'نسخ',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _toHex(_selectedColor)));
                  },
                  icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                ),
                IconButton(
                  tooltip: 'لصق',
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    final text = data?.text;
                    if (text == null) return;
                    final c = _parseHex(text);
                    if (c == null) return;
                    final hsv = HSVColor.fromColor(c);
                    setState(() {
                      _hue = hsv.hue;
                      _saturation = hsv.saturation;
                      _value = hsv.value;
                      _alpha = hsv.alpha;
                      _hexController.text = _toHex(_selectedColor);
                    });
                  },
                  icon: const Icon(Icons.content_paste_rounded, color: Colors.white70),
                ),
              ],
            ),
            const Gap(16),
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
                      onChanged: (v) => setState(() {
                        _hue = v;
                        _hexController.text = _toHex(_selectedColor);
                      }),
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
                    onChanged: (v) => setState(() {
                      _saturation = v;
                      _hexController.text = _toHex(_selectedColor);
                    }),
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
                    onChanged: (v) => setState(() {
                      _value = v;
                      _hexController.text = _toHex(_selectedColor);
                    }),
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
                    onChanged: (v) => setState(() {
                      _alpha = v;
                      _hexController.text = _toHex(_selectedColor);
                    }),
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
                  child: const Text("إلغاء", style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context, _selectedColor),
                  child: const Text("تطبيق", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
