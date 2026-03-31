import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:al_quran_v3/src/core/services/ayah_of_the_day_service.dart';

/// Ayah Widget Settings Page
/// إعدادات ويدجت آية اليوم
class AyahWidgetSettingsPage extends StatefulWidget {
  const AyahWidgetSettingsPage({super.key});

  @override
  State<AyahWidgetSettingsPage> createState() => _AyahWidgetSettingsPageState();
}

class _AyahWidgetSettingsPageState extends State<AyahWidgetSettingsPage> {
  late final Box _userBox;
  
  double _fontSize = 28.0;
  String _theme = 'glass_dark';
  int _updateFrequency = 1440; // minutes (24 hours)
  int? _customSurah;
  int? _customVerse;
  String _fontFamily = 'KFGQPC-Uthmanic-HAFS-Regular';
  bool _isLoading = true;

  final List<Map<String, dynamic>> _themes = [
    {'id': 'glass_dark', 'name': 'زجاجي داكن', 'color': const Color(0xFF0A0A0A)},
    {'id': 'dark_royal', 'name': 'ملكي ذهبي', 'color': const Color(0xFF0A0806)},
    {'id': 'midnight_blue', 'name': 'أزرق داكن', 'color': const Color(0xFF0D1B2A)},
    {'id': 'emerald_gradient', 'name': 'زمردي', 'color': const Color(0xFF0A1F1A)},
    {'id': 'sunset', 'name': 'بنفسجي', 'color': const Color(0xFF1A0A2E)},
    {'id': 'glass_light', 'name': 'زجاجي فاتح', 'color': const Color(0xFFFDFAF5)},
  ];

  final List<Map<String, dynamic>> _frequencies = [
    {'value': 60, 'label': 'كل ساعة'},
    {'value': 360, 'label': 'كل 6 ساعات'},
    {'value': 720, 'label': 'كل 12 ساعة'},
    {'value': 1440, 'label': 'كل يوم'},
    {'value': 10080, 'label': 'كل أسبوع'},
  ];

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box('user');
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _fontSize = _userBox.get('widget_font_size', defaultValue: 28.0) as double;
      _theme = _userBox.get('widget_theme', defaultValue: 'glass_dark') as String;
      _updateFrequency = _userBox.get('widget_update_frequency_minutes', defaultValue: 1440) as int;
      _customSurah = _userBox.get('widget_custom_surah') as int?;
      _customVerse = _userBox.get('widget_custom_verse') as int?;
      _fontFamily = _userBox.get('widget_font_family', defaultValue: 'KFGQPC-Uthmanic-HAFS-Regular') as String;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _userBox.put('widget_font_size', _fontSize);
    await _userBox.put('widget_theme', _theme);
    await _userBox.put('widget_update_frequency_minutes', _updateFrequency);
    await _userBox.put('widget_custom_surah', _customSurah);
    await _userBox.put('widget_custom_verse', _customVerse);
    await _userBox.put('widget_font_family', _fontFamily);
    
    // Update the widget
    await AyahOfTheDayService.updateWidget(forceRefresh: true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات وتحديث الويدجت'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFDFAF5),
        appBar: AppBar(
          title: const Text('إعدادات ويدجت آية اليوم'),
          centerTitle: true,
          backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Theme Selection
                  _buildSectionTitle('نمط التصميم', Icons.palette_rounded, primary),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _themes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final theme = _themes[index];
                        final isSelected = _theme == theme['id'];
                        return GestureDetector(
                          onTap: () => setState(() => _theme = theme['id']),
                          child: Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: theme['color'] as Color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primary : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (theme['color'] as Color).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                                  color: isSelected ? primary : Colors.white54,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  theme['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Font Size
                  _buildSectionTitle('حجم الخط', Icons.text_fields_rounded, primary),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161616) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الحجم'),
                            Text('${_fontSize.toStringAsFixed(0)}px'),
                          ],
                        ),
                        Slider(
                          value: _fontSize,
                          min: 18,
                          max: 48,
                          divisions: 15,
                          onChanged: (v) => setState(() => _fontSize = v),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Update Frequency
                  _buildSectionTitle('معدل التحديث', Icons.update_rounded, primary),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161616) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _frequencies.map((freq) {
                        final isSelected = _updateFrequency == freq['value'];
                        return ChoiceChip(
                          label: Text(freq['label']),
                          selected: isSelected,
                          selectedColor: primary.withValues(alpha: 0.2),
                          onSelected: (_) => setState(() => _updateFrequency = freq['value']),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Custom Ayah
                  _buildSectionTitle('آية محددة (اختياري)', Icons.bookmark_rounded, primary),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161616) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'رقم السورة',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) => _customSurah = int.tryParse(v),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'رقم الآية',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) => _customVerse = int.tryParse(v),
                              ),
                            ),
                          ],
                        ),
                        if (_customSurah != null || _customVerse != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextButton.icon(
                              icon: const Icon(Icons.clear),
                              label: const Text('إلغاء التحديد'),
                              onPressed: () {
                                setState(() {
                                  _customSurah = null;
                                  _customVerse = null;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _saveSettings,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('حفظ وتحديث الويدجت'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Update Now Button
                  TextButton.icon(
                    onPressed: () async {
                      await AyahOfTheDayService.updateWidget(forceRefresh: true);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تحديث الويدجت'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('تحديث الويدجت الآن'),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
