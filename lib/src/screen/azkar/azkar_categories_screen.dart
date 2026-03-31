import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_quran_v3/src/core/constants/wahy_assets.dart';
import 'package:al_quran_v3/src/theme/controller/theme_cubit.dart';
import 'package:al_quran_v3/src/screen/azkar/azkar_detail_screen.dart';
import 'package:gap/gap.dart';

class AzkarCategoriesScreen extends StatefulWidget {
  final String? initialCategory;
  const AzkarCategoriesScreen({super.key, this.initialCategory});

  @override
  State<AzkarCategoriesScreen> createState() => _AzkarCategoriesScreenState();
}

class _AzkarCategoriesScreenState extends State<AzkarCategoriesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allAzkar = [];
  List<String> _categories = [];
  bool _hasAutoOpened = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAzkarData();
  }

  Future<void> _loadAzkarData() async {
    try {
      final raw = await rootBundle.loadString(WahyAssets.jsonAzkar);
      final decoded = json.decode(raw);
      final list = List<Map<String, dynamic>>.from(decoded['data']);
      
      final Set<String> cats = {};
      for (var item in list) {
        if (item['category'] != null) {
          cats.add(item['category'].toString());
        }
      }

      if (mounted) {
        setState(() {
          _allAzkar = list;
          _categories = cats.toList();
          _isLoading = false;
          _errorMessage = _categories.isEmpty ? "┘ä┘à ┘è╪¬┘à ╪º┘ä╪╣╪½┘ê╪▒ ╪╣┘ä┘ë ╪ú╪░┘â╪º╪▒" : null;
        });

        // Auto-open logic
        if (widget.initialCategory != null && !_hasAutoOpened) {
          final target = widget.initialCategory;
          if (_categories.contains(target)) {
            _hasAutoOpened = true;
            final filteredList = _allAzkar.where((e) => e['category'] == target).toList();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AzkarDetailScreen(
                    categoryName: target!,
                    azkarList: filteredList,
                    primary: context.read<ThemeCubit>().state.primary,
                  ),
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading azkar: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "╪¡╪»╪½ ╪«╪╖╪ú ╪ú╪½┘å╪º╪í ╪¬╪¡┘à┘è┘ä ╪º┘ä╪ú╪░┘â╪º╪▒: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = themeState.primary;
    
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF7F1E6);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "╪ú╪░┘â╪º╪▒ ╪º┘ä┘à╪│┘ä┘à",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primary))
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, color: primary, size: 60),
                        const Gap(16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                        const Gap(20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _isLoading = true);
                            _loadAzkarData();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: primary),
                          child: const Text("╪Ñ╪╣╪º╪»╪⌐ ╪º┘ä┘à╪¡╪º┘ê┘ä╪⌐", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final count = _allAzkar.where((e) => e['category'] == category).length;
                    
                    return _buildCategoryCard(
                      category: category,
                      count: count,
                      primary: primary,
                      cardColor: cardColor,
                      textColor: textColor,
                      onTap: () {
                        final filteredList = _allAzkar.where((e) => e['category'] == category).toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AzkarDetailScreen(
                              categoryName: category,
                              azkarList: filteredList,
                              primary: primary,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String category,
    required int count,
    required Color primary,
    required Color cardColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    // Generate icons dynamically based on category names
    IconData iconData = Icons.book_rounded;
    if (category.contains("╪º┘ä╪╡╪¿╪º╪¡")) {
      iconData = Icons.wb_sunny_rounded;
    } else if (category.contains("╪º┘ä┘à╪│╪º╪í")) {
      iconData = Icons.nights_stay_rounded;
    } else if (category.contains("╪º┘ä┘å┘ê┘à")) {
      iconData = Icons.bedtime_rounded;
    } else if (category.contains("╪º┘ä┘à╪│╪¼╪»")) {
      iconData = Icons.mosque_rounded;
    } else if (category.contains("╪º┘ä╪º╪│╪¬┘è┘é╪º╪╕")) {
      iconData = Icons.wb_twilight_rounded;
    } else if (category.contains("╪º┘ä┘ê╪╢┘ê╪í") || category.contains("╪º┘ä╪«┘ä╪º╪í")) {
      iconData = Icons.water_drop_rounded;
    } else if (category.contains("╪º┘ä┘à┘å╪▓┘ä")) {
      iconData = Icons.home_rounded;
    } else if (category.contains("╪º┘ä╪╡┘ä╪º╪⌐")) {
      iconData = Icons.pan_tool_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconData, color: primary, size: 28),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        "$count ╪░┘â╪▒",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: textColor.withValues(alpha: 0.3),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
