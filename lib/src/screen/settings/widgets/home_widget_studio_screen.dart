import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:qcf_quran/qcf_quran.dart';

import '../../../core/constants/app_fonts.dart';
import '../../../core/services/ayah_of_the_day_service.dart';
import 'premium_widget_design.dart';
import 'prayer_widget_design.dart';

class HomeWidgetStudioScreen extends StatefulWidget {
  const HomeWidgetStudioScreen({super.key});

  @override
  State<HomeWidgetStudioScreen> createState() => _HomeWidgetStudioScreenState();
}

class _HomeWidgetStudioScreenState extends State<HomeWidgetStudioScreen> with TickerProviderStateMixin {
  late final Box _userBox;
  bool _isLoading = true;

  String _contentType = "quran";
  String _themeId = PremiumWidgetDesign.availableThemes.first.id;
  String _fontFamily = "";
  double _fontSizeMultiplier = 1.0;
  String _prayerDisplayMode = "all";
  
  // Data for preview
  String _previewSurahName = "";
  String _previewAyahText = "";

  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userBox = Hive.box("user");
    _loadSettings();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    _contentType = _userBox.get("widget_content_type", defaultValue: "quran") as String;
    _themeId = _userBox.get("widget_theme", defaultValue: PremiumWidgetDesign.availableThemes.first.id) as String;
    _fontFamily = _userBox.get("widget_font_family", defaultValue: "") as String;
    _prayerDisplayMode = _userBox.get("widget_prayer_mode", defaultValue: "all") as String;
    _fontSizeMultiplier = _userBox.get("widget_font_size", defaultValue: 1.0) as double;
    
    await _generatePreviewData();
    setState(() => _isLoading = false);
  }

  Future<void> _generatePreviewData() async {
    if (_contentType == "azkar") {
      _previewAyahText = "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ العَظِيمِ";
      _previewSurahName = "ذكر مستحب";
    } else {
      _previewAyahText = AyahOfTheDayService.formatAyahTextForWidget(
        getVerse(55, 13, verseEndSymbol: false), 
      );
      _previewSurahName = AyahOfTheDayService.buildWidgetSurahName(55, 13);
    }
  }

  Future<void> _saveSettingsAndRefresh() async {
    await _userBox.put("widget_content_type", _contentType);
    await _userBox.put("widget_theme", _themeId);
    await _userBox.put("widget_font_family", _fontFamily);
    await _userBox.put("widget_prayer_mode", _prayerDisplayMode);
    await _userBox.put("widget_font_size", _fontSizeMultiplier);

    // This updates the widgets silently mapped to background isolate equivalent logic
    AyahOfTheDayService.updateWidget(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F7F7);
    final cardColor = isDark ? const Color(0xFF1C1C1C) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "تخصيص الويدجيت",
          style: TextStyle(
            fontFamily: "Cairo-Bold",
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF33B18E),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontFamily: "Cairo-Bold", fontSize: 16),
          indicatorColor: const Color(0xFF33B18E),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: "الآيات والأذكار"),
            Tab(text: "مواقيت الصلاة"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAyahTab(bgColor, cardColor, isDark),
            _buildPrayerTab(bgColor, cardColor, isDark),
          ],
        ),
      ),
    );
  }

  // --- AYAH & ZEKR TAB ---
  Widget _buildAyahTab(Color bgColor, Color cardColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildAyahLivePreview(bgColor),
        const SizedBox(height: 24),
        
        _buildSectionTitle("المحتوى الأساسي", isDark),
        _buildContentCard(cardColor, isDark),
        
        const SizedBox(height: 32),
        _buildSectionTitle("حجم الخط", isDark),
        _buildFontSizeCard(cardColor, isDark),

        const SizedBox(height: 32),
        _buildSectionTitle("الخط العربي", isDark),
        _buildFontCard(cardColor, isDark),
        
        const SizedBox(height: 32),
        _buildSectionTitle("المظهر الجمالي", isDark),
        _buildThemesGrid(),
        
        const SizedBox(height: 40),
      ],
    );
  }

  // --- PRAYER TAB ---
  Widget _buildPrayerTab(Color bgColor, Color cardColor, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildPrayerLivePreview(bgColor, isDark),
        const SizedBox(height: 24),
        
        _buildSectionTitle("طريقة العرض", isDark),
        _buildPrayerCard(cardColor, isDark),
        
        const SizedBox(height: 32),
        _buildSectionTitle("المظهر الجمالي", isDark),
        _buildThemesGrid(),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAyahLivePreview(Color bgColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      child: ClipRRect(
        key: ValueKey("ayah-$_contentType-$_themeId-$_fontFamily-$_fontSizeMultiplier"),
        borderRadius: BorderRadius.circular(24),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: PremiumWidgetDesign.canvasSize.width,
            height: PremiumWidgetDesign.canvasSize.height,
            child: PremiumWidgetDesign(
              ayahText: _previewAyahText,
              surahName: _previewSurahName,
              fontFamily: _fontFamily,
              themeId: _themeId,
              contentType: _contentType,
              fontSizeMultiplier: _fontSizeMultiplier,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerLivePreview(Color bgColor, bool isDark) {
    final mockTimes = {
      "الفجر": "٠٤:٣٠ ص",
      "الشروق": "٠٦:٠٥ ص",
      "الظهر": "١٢:٠٠ م",
      "العصر": "٠٣:٣٠ م",
      "المغرب": "٠٦:١٥ م",
      "العشاء": "٠٧:٤٠ م",
    };
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      child: ClipRRect(
        key: ValueKey("prayer-$_prayerDisplayMode-$_themeId"),
        borderRadius: BorderRadius.circular(42), // Reflect underlying design rounding
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: PrayerWidgetDesign.canvasSize.width,
            height: PrayerWidgetDesign.canvasSize.height,
            child: PrayerWidgetDesign(
              themeId: _themeId,
              prayerDisplayMode: _prayerDisplayMode,
              prayerTimes: mockTimes,
              nextPrayerName: "العصر",
              isDark: isDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "Cairo-Bold",
          fontSize: 18,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildContentCard(Color cardColor, bool isDark) {
    return Container(
      decoration: _cardDecoration(cardColor, isDark),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.menu_book_rounded,
            title: "آية من القرآن الكريم",
            isSelected: _contentType == "quran",
            onTap: () async {
              HapticFeedback.selectionClick();
              setState(() => _contentType = "quran");
              await _generatePreviewData();
              _saveSettingsAndRefresh();
            },
          ),
          _divider(isDark),
          _buildOptionTile(
            icon: Icons.auto_awesome_rounded,
            title: "ذكر مستحب / ورد يومي",
            isSelected: _contentType == "azkar",
            onTap: () async {
              HapticFeedback.selectionClick();
              setState(() => _contentType = "azkar");
              await _generatePreviewData();
              _saveSettingsAndRefresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeCard(Color cardColor, bool isDark) {
    return Container(
      decoration: _cardDecoration(cardColor, isDark),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text("A-", style: TextStyle(fontFamily: "Cairo-Bold", fontSize: 16, color: Colors.grey)),
          Expanded(
            child: Slider(
              value: _fontSizeMultiplier,
              min: 0.6,
              max: 2.0,
              activeColor: const Color(0xFF33B18E),
              inactiveColor: isDark ? Colors.white24 : Colors.black12,
              onChanged: (val) {
                setState(() => _fontSizeMultiplier = val);
              },
              onChangeEnd: (_) {
                HapticFeedback.lightImpact();
                _saveSettingsAndRefresh();
              },
            ),
          ),
          const Text("A+", style: TextStyle(fontFamily: "Cairo-Bold", fontSize: 20, color: Colors.grey)),
        ],
      ),
    );
  }
  
  Widget _buildPrayerCard(Color cardColor, bool isDark) {
    return Container(
      decoration: _cardDecoration(cardColor, isDark),
      child: Column(
        children: [
          _buildOptionTile(
            icon: Icons.access_time_rounded,
            title: "إظهار الصلاة القادمة فقط",
            isSelected: _prayerDisplayMode == "next",
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _prayerDisplayMode = "next");
              _saveSettingsAndRefresh();
            },
          ),
          _divider(isDark),
          _buildOptionTile(
            icon: Icons.view_column_rounded,
            title: "إظهار كافة مواقيت الصلاة",
            isSelected: _prayerDisplayMode == "all",
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _prayerDisplayMode = "all");
              _saveSettingsAndRefresh();
            },
          ),
          _divider(isDark),
          _buildOptionTile(
            icon: Icons.visibility_off_rounded,
            title: "تخفي",
            isSelected: _prayerDisplayMode == "none",
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _prayerDisplayMode = "none");
              _saveSettingsAndRefresh();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: PremiumWidgetDesign.availableThemes.length,
      itemBuilder: (context, index) {
        final theme = PremiumWidgetDesign.availableThemes[index];
        final isSelected = _themeId == theme.id;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _themeId = theme.id);
            _saveSettingsAndRefresh();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF33B18E) : theme.borderColor,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: const Color(0xFF33B18E).withValues(alpha: 0.2), blurRadius: 10)]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(color: theme.surahColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  theme.name,
                  style: TextStyle(fontFamily: "Cairo-Bold", fontSize: 13, color: theme.textColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFontCard(Color cardColor, bool isDark) {
    final Map<String, String> fonts = {
      "": "تلقائي (حسب المحتوى)",
      AppFonts.uthmanicHafs: "عثماني حفص المطور",
      AppFonts.qpcHafs: "مجمع الملك فهد",
      "AmiriQuran-Regular": "الخط الأميري",
      AppFonts.alQuranNeo: "خط أحمد حسني",
    };

    return Container(
      decoration: _cardDecoration(cardColor, isDark),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: fonts.entries.map((entry) {
          final isLast = entry.key == fonts.entries.last.key;
          return Column(
            children: [
              _buildOptionTile(
                icon: Icons.font_download_rounded,
                title: entry.value,
                isSelected: _fontFamily == entry.key,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _fontFamily = entry.key);
                  _saveSettingsAndRefresh();
                },
              ),
              if (!isLast) _divider(isDark),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? const Color(0xFF33B18E) : Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontFamily: isSelected ? "Cairo-Bold" : "Cairo-SemiBold",
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  child: Text(title),
                ),
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.0 : 0.8,
                child: isSelected
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF33B18E), size: 22)
                  : Icon(Icons.circle_outlined, color: isDark ? Colors.white24 : Colors.black12, size: 22),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  BoxDecoration _cardDecoration(Color cardColor, bool isDark) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
    );
  }
  
  Widget _divider(bool isDark) {
    return Divider(height: 1, indent: 56, endIndent: 16, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05));
  }
}
