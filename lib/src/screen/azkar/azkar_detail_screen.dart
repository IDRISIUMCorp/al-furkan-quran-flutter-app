import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:al_quran_v3/src/screen/azkar/azkar_share_screen.dart';

class AzkarDetailScreen extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> azkarList;
  final Color primary;

  const AzkarDetailScreen({
    super.key,
    required this.categoryName,
    required this.azkarList,
    required this.primary,
  });

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  late List<int> _counts;
  late PageController _pageController;
  int _currentIndex = 0;
  double _fontSize = 26.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fontSize = Hive.box("user").get("azkar_detail_font_size", defaultValue: 26.0) as double;
    _counts = widget.azkarList.map((e) {
      final String rawCount = e['count'].toString();
      return int.tryParse(rawCount) ?? 1;
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCountTap() {
    if (_counts[_currentIndex] > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _counts[_currentIndex]--;
      });
      
      if (_counts[_currentIndex] == 0) {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (_currentIndex < widget.azkarList.length - 1 && mounted) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            );
          } else if (_currentIndex == widget.azkarList.length - 1 && mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(
                   "تم الانتهاء من ${widget.categoryName}",
                   style: const TextStyle(fontWeight: FontWeight.bold),
                 ),
                 backgroundColor: widget.primary,
               )
             );
             Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            icon: Icon(Icons.arrow_back_ios_rounded, color: widget.primary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.categoryName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.text_fields_rounded, color: widget.primary),
              onPressed: _showFontSizeSheet,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.azkarList.length,
              backgroundColor: widget.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(widget.primary),
            ),
          ),
        ),
        body: Column(
          children: [
            const Gap(12),
            Text(
              "الذكر ${_currentIndex + 1} من ${widget.azkarList.length}",
              style: TextStyle(
                color: widget.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const Gap(12),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: widget.azkarList.length,
                itemBuilder: (context, index) {
                  final zekr = widget.azkarList[index];
                  final originalCount = int.tryParse(zekr['count'].toString()) ?? 1;
                  final currentCount = _counts[index];
                  final isDone = currentCount == 0;

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Stack(
                            children: [
                              if (isDark)
                                Positioned(
                                  top: -50,
                                  right: -50,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: widget.primary.withValues(alpha: 0.15),
                                    ),
                                  ),
                                ),
                              
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          children: [
                                            AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 200),
                                              style: TextStyle(
                                                fontSize: _fontSize,
                                                height: 1.8,
                                                color: textColor,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: "KFGQPC-Uthmanic-HAFS-Regular",
                                              ),
                                              child: Text(
                                                zekr['zekr'].toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            if (zekr['description'] != null && zekr['description'].toString().isNotEmpty) ...[
                                              const Gap(20),
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: widget.primary.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  zekr['description'].toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: widget.primary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (zekr['reference'] != null && zekr['reference'].toString().isNotEmpty) ...[
                                              const Gap(16),
                                              Text(
                                                zekr['reference'].toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: textColor.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Gap(20),
                                    GestureDetector(
                                      onTap: _onCountTap,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: isDone ? 100 : 120,
                                        height: isDone ? 100 : 120,
                                        decoration: BoxDecoration(
                                          color: isDone ? Colors.green : widget.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isDone ? Colors.green : widget.primary).withValues(alpha: 0.4),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            transitionBuilder: (Widget child, Animation<double> animation) {
                                              return ScaleTransition(scale: animation, child: child);
                                            },
                                            child: isDone
                                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 50, key: ValueKey('done'))
                                                : Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    key: const ValueKey('counting'),
                                                    children: [
                                                      Text(
                                                        currentCount.toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 38,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),
                                                      if (originalCount > 1)
                                                        Text(
                                                          "┘à┘å $originalCount",
                                                          style: TextStyle(
                                                            color: Colors.white.withValues(alpha: 0.7),
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                          ),
                                        ),
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
                  );
                },
              ),
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _buildActionButton(
                    icon: Icons.image_rounded,
                    label: "صورة",
                    color: widget.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AzkarShareScreen(
                            zekr: widget.azkarList[_currentIndex],
                            categoryName: widget.categoryName,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.share_rounded,
                    label: "مشاركة",
                    color: widget.primary,
                    onTap: () {
                      final zekr = widget.azkarList[_currentIndex];
                      final text = zekr['zekr'].toString();
                      final ref = zekr['reference']?.toString() ?? '';
                      final shareText = "$text\n\n${ref.isNotEmpty ? 'المصدر: $ref\n' : ''}— أذكار المسلم";
                      Share.share(shareText);
                    },
                  ),
                ],
              ),
            ),
            const Gap(30),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Gap(24),
                  Text(
                    "حجم الخط",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      const Text("A", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 20,
                          max: 60,
                          activeColor: widget.primary,
                          onChanged: (val) {
                            setState(() => _fontSize = val);
                            setSheetState(() {});
                          },
                          onChangeEnd: (val) {
                            Hive.box("user").put("azkar_detail_font_size", val);
                          },
                        ),
                      ),
                      const Text("A", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                  const Gap(24),
                  const Text(
                    "اسحب الشريط لتكبير أو تصغير الخط. سيتم حفظ الإعداد تلقائياً.",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
