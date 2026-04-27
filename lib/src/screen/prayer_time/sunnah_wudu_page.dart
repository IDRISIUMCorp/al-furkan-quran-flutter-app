import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../features/sunnah/services/sunnah_share_service.dart';
import '../../../features/sunnah/presentation/screens/image_customization_screen.dart';

// Design System Colors (Wahy + Ayah Hybrid)
const _primaryGreen = Color(0xFF4A7C59);  // من وحي - أهدأ
const _accentGold = Color(0xFFC9A84C);    // من وحي
const _darkBg = Color(0xFF1A1F26);
const _cardDark = Color(0xFF242933);
const _cardLight = Color(0xFFFFFFFF);     // أبيض نقي
const _textLight = Color(0xFFF8F9FA);
const _textDark = Color(0xFF2C2C2C);      // من وحي
const _mutedLight = Color(0xFFB8BCC2);
const _mutedDark = Color(0xFF6B6B6B);     // من وحي

class SunnahWuduPage extends StatelessWidget {
  const SunnahWuduPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? _darkBg : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'سنن الوضوء وآدابه',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? _cardDark : _cardLight,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Introduction Card
          _buildIntroCard(isDark),
          const Gap(16),
          
          // Importance Section
          _buildImportanceCard(isDark),
          const Gap(16),
          
          // Sunnah Steps
          _buildSectionHeader("خطوات الوضوء بالسنن", Icons.format_list_numbered_rounded, isDark),
          const Gap(12),
          ..._wuduSteps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildStepCard(
                context: context,
                number: entry.key + 1,
                step: entry.value,
                isDark: isDark,
              ),
            );
          }),
          
          const Gap(16),
          
          // Scholarly Statements
          _buildSectionHeader("أقوال العلماء", Icons.school_rounded, isDark),
          const Gap(12),
          ..._scholarStatements.map((statement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildScholarCard(statement, isDark),
            );
          }),
          
          const Gap(16),
          
          // Additional Benefits
          _buildSectionHeader("فوائد إضافية", Icons.lightbulb_rounded, isDark),
          const Gap(12),
          ..._additionalBenefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBenefitCard(benefit, isDark),
            );
          }),
          
          const Gap(80),
        ],
      ),
    );
  }

  Widget _buildIntroCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            _primaryGreen.withValues(alpha: 0.15),
            _primaryGreen.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  "الوضوء طهارة وعبادة",
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? _textLight : _textDark,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          Text(
            "الوضوء شرط من شروط صحة الصلاة، وهو طهارة مخصوصة بأعضاء مخصوصة. وقد حث النبي ﷺ على إسباغ الوضوء وإتقانه، وجعل الله تعالى له فضلاً عظيماً.",
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _mutedLight : _mutedDark,
              height: 1.8,
            ),
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: _primaryGreen,
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    'قال الله تعالى: "يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا قُمْتُمْ إِلَى الصَّلَاةِ فَاغْسِلُوا وُجُوهَكُمْ وَأَيْدِيَكُمْ إِلَى الْمَرَافِقِ..." [المائدة: 6]',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primaryGreen,
                      height: 1.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: _accentGold,
                  size: 24,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  "فضل الوضوء",
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? _textLight : _textDark,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          _buildHadithBox(
            'عن أبي هريرة رضي الله عنه أن رسول الله ﷺ قال: "إذا توضأ العبد المسلم أو المؤمن فغسل وجهه خرج من وجهه كل خطيئة نظر إليها بعينيه مع الماء أو مع آخر قطر الماء، فإذا غسل يديه خرج من يديه كل خطيئة كان بطشتها يداه مع الماء أو مع آخر قطر الماء، فإذا غسل رجليه خرجت كل خطيئة مشتها رجلاه مع الماء أو مع آخر قطر الماء حتى يخرج نقياً من الذنوب"',
            'رواه مسلم',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(10),
        Icon(
          icon,
          color: _primaryGreen,
          size: 24,
        ),
        const Gap(8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? _textLight : _textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required int number,
    required WuduStep step,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryGreen, _primaryGreen.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  step.title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? _textLight : _textDark,
                  ),
                ),
              ),
              if (step.isSunnah)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "سنة",
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _accentGold,
                    ),
                  ),
                ),
              const Gap(8),
              IconButton(
                onPressed: () => _shareSunnah(
                  context: context,
                  title: step.title,
                  description: step.description,
                  evidence: step.evidence,
                  type: "سنن الوضوء",
                ),
                icon: const Icon(Icons.share_rounded),
                iconSize: 20,
                color: const Color(0xFF10B981),
                tooltip: "مشاركة",
              ),
            ],
          ),
          const Gap(12),
          Text(
            step.description,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _mutedLight : _mutedDark,
              height: 1.8,
            ),
          ),
          if (step.evidence != null) ...[
            const Gap(12),
            _buildEvidenceBox(step.evidence!, isDark),
          ],
        ],
      ),
    );
  }

  // Share Sunnah Function - WORKING VERSION
  Future<void> _shareSunnah({
    required BuildContext context,
    required String title,
    required String description,
    String? evidence,
    required String type,
  }) async {
    // Show share options
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? _cardDark : _cardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 1)),
              const Gap(20),
              
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      "مشاركة السنة",
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isDark ? _textLight : _textDark,
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: -0.1),
                  ),
                ],
              ),
              const Gap(24),
              
              // Share as Text
              _shareOptionButton(
                icon: Icons.text_fields_rounded,
                label: "مشاركة كنص",
                subtitle: "نسخ النص ومشاركته",
                color: const Color(0xFF3B82F6),
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await SunnahShareService.shareAsText(
                      title: title,
                      description: description,
                      evidence: evidence,
                      type: type,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  "تم نسخ النص ومشاركته بنجاح",
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "حدث خطأ أثناء المشاركة",
                            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  }
                },
              ).animate().fadeIn(duration: 300.ms, delay: 150.ms).slideX(begin: 0.1),
              const Gap(12),
              
              // Share as Image
              _shareOptionButton(
                icon: Icons.image_rounded,
                label: "مشاركة كصورة",
                subtitle: "تخصيص وإنشاء صورة احترافية",
                color: const Color(0xFFEC4899),
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  // Open customization screen
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageCustomizationScreen(
                          title: title,
                          description: description,
                          evidence: evidence,
                          type: type,
                        ),
                      ),
                    );
                  }
                },
              ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(begin: 0.1),
            ],
          ),
        );
      },
    );
  }
  }

  Widget _shareOptionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isDark ? _textLight : _textDark,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? _mutedLight : _mutedDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceBox(String evidence, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 16,
            color: _primaryGreen,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              evidence,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _primaryGreen,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithBox(String hadith, String source, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: _accentGold,
                size: 20,
              ),
              const Gap(8),
              Text(
                "حديث شريف",
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _accentGold,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            hadith,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _textLight : _textDark,
              height: 1.9,
            ),
          ),
          const Gap(10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              source,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarCard(ScholarStatement statement, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statement.scholar,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? _textLight : _textDark,
                      ),
                    ),
                    if (statement.title != null) ...[
                      const Gap(2),
                      Text(
                        statement.title!,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? _mutedLight : _mutedDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            statement.statement,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? _mutedLight : _mutedDark,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(String benefit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 18,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              benefit,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? _mutedLight : _mutedDark,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

// Data Models
class WuduStep {
  final String title;
  final String description;
  final String? evidence;
  final bool isSunnah;

  const WuduStep({
    required this.title,
    required this.description,
    this.evidence,
    this.isSunnah = false,
  });
}

class ScholarStatement {
  final String scholar;
  final String? title;
  final String statement;

  const ScholarStatement({
    required this.scholar,
    this.title,
    required this.statement,
  });
}

// Data
final List<WuduStep> _wuduSteps = [
  const WuduStep(
    title: 'النية',
    description: 'محلها القلب، ولا يُشرع التلفظ بها. والنية شرط لصحة الوضوء.',
    evidence: 'قال النبي ﷺ: "إنما الأعمال بالنيات" - متفق عليه',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'التسمية',
    description: 'يقول: "بسم الله" في أول الوضوء. وهي سنة مؤكدة عند جمهور العلماء.',
    evidence: 'قال النبي ﷺ: "لا وضوء لمن لم يذكر اسم الله عليه" - رواه أبو داود وحسنه الألباني',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'غسل الكفين ثلاثاً',
    description: 'يغسل كفيه ثلاث مرات في بداية الوضوء قبل إدخالهما في الإناء.',
    evidence: 'كان النبي ﷺ يبدأ بغسل كفيه ثلاثاً - متفق عليه',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'المضمضة والاستنشاق',
    description: 'يتمضمض ثلاثاً ويستنشق ثلاثاً، ويبالغ فيهما إلا إذا كان صائماً.',
    evidence: 'قال النبي ﷺ: "وبالغ في الاستنشاق إلا أن تكون صائماً" - رواه الترمذي وصححه الألباني',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'غسل الوجه',
    description: 'يغسل وجهه ثلاث مرات من منابت شعر الرأس إلى أسفل الذقن، ومن الأذن إلى الأذن.',
    evidence: 'قال الله تعالى: "فَاغْسِلُوا وُجُوهَكُمْ" [المائدة: 6]',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'تخليل اللحية',
    description: 'يخلل اللحية الكثيفة بالماء ليصل إلى أصول الشعر.',
    evidence: 'كان النبي ﷺ يخلل لحيته في الوضوء - رواه الترمذي وصححه الألباني',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'غسل اليدين إلى المرفقين',
    description: 'يغسل يديه مع المرفقين ثلاث مرات، يبدأ باليمنى ثم اليسرى.',
    evidence: 'قال الله تعالى: "وَأَيْدِيَكُمْ إِلَى الْمَرَافِقِ" [المائدة: 6]',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'تخليل الأصابع',
    description: 'يخلل أصابع اليدين والرجلين ليصل الماء إلى ما بينها.',
    evidence: 'قال النبي ﷺ: "وخلل بين الأصابع" - رواه الترمذي وصححه الألباني',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'مسح الرأس',
    description: 'يمسح رأسه مرة واحدة، يبدأ من مقدم رأسه إلى قفاه ثم يرد يديه إلى المقدم.',
    evidence: 'قال الله تعالى: "وَامْسَحُوا بِرُءُوسِكُمْ" [المائدة: 6]',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'مسح الأذنين',
    description: 'يمسح أذنيه مرة واحدة، ظاهرهما وباطنهما بماء جديد.',
    evidence: 'قال النبي ﷺ: "الأذنان من الرأس" - رواه الترمذي وصححه الألباني',
    isSunnah: true,
  ),
  const WuduStep(
    title: 'غسل الرجلين إلى الكعبين',
    description: 'يغسل رجليه مع الكعبين ثلاث مرات، يبدأ باليمنى ثم اليسرى.',
    evidence: 'قال الله تعالى: "وَأَرْجُلَكُمْ إِلَى الْكَعْبَيْنِ" [المائدة: 6]',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'الترتيب والموالاة',
    description: 'يرتب أعضاء الوضوء كما ذكرها الله، ويوالي بينها فلا يؤخر غسل عضو حتى ينشف الذي قبله.',
    evidence: 'وصف الصحابة وضوء النبي ﷺ مرتباً متوالياً - متفق عليه',
    isSunnah: false,
  ),
  const WuduStep(
    title: 'الدعاء بعد الوضوء',
    description: 'يقول بعد الفراغ من الوضوء: "أشهد أن لا إله إلا الله وحده لا شريك له، وأشهد أن محمداً عبده ورسوله".',
    evidence: 'قال النبي ﷺ: "من توضأ فأحسن الوضوء ثم قال: أشهد أن لا إله إلا الله... فتحت له أبواب الجنة الثمانية يدخل من أيها شاء" - رواه مسلم',
    isSunnah: true,
  ),
];

final List<ScholarStatement> _scholarStatements = [
  const ScholarStatement(
    scholar: 'الإمام النووي',
    title: 'رحمه الله (المتوفى 676هـ)',
    statement: 'قال في المجموع: "إسباغ الوضوء من تمام الإيمان، وهو إكمال غسل الأعضاء وإيصال الماء إلى جميع ما يجب غسله، والمبالغة في ذلك من غير إسراف".',
  ),
  const ScholarStatement(
    scholar: 'ابن القيم',
    title: 'رحمه الله (المتوفى 751هـ)',
    statement: 'قال في زاد المعاد: "كان النبي ﷺ يتوضأ لكل صلاة في غالب أحيانه، وربما صلى الصلوات بوضوء واحد، وكان يتوضأ بالمد تارة وبثلثيه تارة وبأزيد منه تارة".',
  ),
  const ScholarStatement(
    scholar: 'الشيخ ابن عثيمين',
    title: 'رحمه الله (المتوفى 1421هـ)',
    statement: 'قال: "الوضوء عبادة عظيمة، وهو مفتاح الصلاة، فينبغي للمسلم أن يحرص على إتقانه وإحسانه، وأن يتعلم صفته الصحيحة كما جاءت عن النبي ﷺ".',
  ),
  const ScholarStatement(
    scholar: 'الشيخ ابن باز',
    title: 'رحمه الله (المتوفى 1420هـ)',
    statement: 'قال: "من أهم ما ينبغي للمسلم العناية به: إسباغ الوضوء وإتقانه، فإن كثيراً من الناس يتساهلون في ذلك، وقد يخل بعضهم بواجب من واجباته فيبطل وضوؤه".',
  ),
];

final List<String> _additionalBenefits = [
  'الوضوء نور للمؤمن يوم القيامة، قال النبي ﷺ: "إن أمتي يدعون يوم القيامة غراً محجلين من آثار الوضوء" - متفق عليه',
  'الوضوء يكفر الذنوب والخطايا كما جاء في الحديث الصحيح',
  'المحافظة على الوضوء من علامات الإيمان وحسن الإسلام',
  'الوضوء سبب لمحبة الله تعالى، قال تعالى: "إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ" [البقرة: 222]',
  'من نام على وضوء كان في حفظ الله ورعايته تلك الليلة',
  'الوضوء يطفئ غضب الرب ويزيل الهم والحزن',
  'استحباب تجديد الوضوء لكل صلاة وإن لم ينتقض',
  'الاقتصاد في الماء سنة، والإسراف فيه مكروه حتى لو كان على نهر جار',
];
