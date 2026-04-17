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
const _bgLight = Color(0xFFF8F6ED);       // من وحي - دافئ
const _textLight = Color(0xFFF8F9FA);
const _textDark = Color(0xFF2C2C2C);      // من وحي
const _mutedLight = Color(0xFFB8BCC2);
const _mutedDark = Color(0xFF6B6B6B);     // من وحي
const _border = Color(0xFFDDD9CC);        // من آية - أوضح
const _borderDark = Color(0xFF3A3F4D);

// Dimensions (من آية - أكثر سخاءً)
const _space4 = 4.0;
const _space8 = 8.0;
const _space12 = 12.0;
const _space16 = 16.0;
const _space20 = 20.0;
const _space24 = 24.0;
const _radiusSmall = 10.0;
const _radiusMedium = 14.0;
const _radiusLarge = 18.0;
const _radiusXLarge = 24.0;
const _borderWidth = 1.5;                 // من آية
const _touchTarget = 44.0;                // من آية

class SunnahPrayerPage extends StatelessWidget {
  const SunnahPrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? _darkBg : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'سنن الصلاة وآدابها',
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
          _buildIntroCard(isDark),
          const Gap(16),
          _buildImportanceCard(isDark),
          const Gap(16),
          _buildSectionHeader("أركان الصلاة وسننها", Icons.format_list_numbered_rounded, isDark),
          const Gap(12),
          _buildPrayerStepsSection(context, isDark),
          const Gap(16),
          _buildSectionHeader("أقوال العلماء", Icons.school_rounded, isDark),
          const Gap(12),
          _buildScholarsSection(isDark),
          const Gap(16),
          _buildSectionHeader("فوائد وآداب", Icons.lightbulb_rounded, isDark),
          const Gap(12),
          _buildBenefitsSection(isDark),
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
            _primaryGreen.withOpacity(0.15),
            _primaryGreen.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _primaryGreen.withOpacity(0.3),
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
                  Icons.book_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  "الصلاة عماد الدين",
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
            "الصلاة هي الركن الثاني من أركان الإسلام، وهي أول ما يحاسب عليه العبد يوم القيامة. وقد أمر الله تعالى بإقامتها وحث النبي ﷺ على إتقانها وإحسانها.",
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

  Widget _buildImportanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
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
                  color: _accentGold.withOpacity(0.15),
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
                  "فضل الصلاة",
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
            'عن أبي هريرة رضي الله عنه قال: سمعت رسول الله ﷺ يقول: "أرأيتم لو أن نهراً بباب أحدكم يغتسل منه كل يوم خمس مرات، هل يبقى من درنه شيء؟" قالوا: لا يبقى من درنه شيء. قال: "فذلك مثل الصلوات الخمس، يمحو الله بهن الخطايا"',
            'متفق عليه',
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

  Widget _buildPrayerStepsSection(BuildContext context, bool isDark) {
    return Column(
      children: _prayerSteps.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStepCard(
            context: context,
            number: entry.key + 1,
            step: entry.value,
            isDark: isDark,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required int number,
    required PrayerStep step,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
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
                    colors: [_primaryGreen, _primaryGreen.withOpacity(0.7)],
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
              if (step.type != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: step.type == 'ركن' 
                        ? const Color(0xFFDC2626).withOpacity(0.15)
                        : _accentGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    step.type!,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: step.type == 'ركن' 
                          ? const Color(0xFFDC2626)
                          : _accentGold,
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
                  type: "سنن الصلاة",
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
                color: Colors.black.withOpacity(0.2),
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
                        colors: [const Color(0xFF10B981), const Color(0xFF10B981).withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
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
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
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
                        color: color.withOpacity(0.3),
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
        color: _primaryGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _primaryGreen.withOpacity(0.2),
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
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _accentGold.withOpacity(0.3),
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
              color: _accentGold.withOpacity(0.15),
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

  Widget _buildScholarsSection(bool isDark) {
    return Column(
      children: _scholarStatements.map((statement) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildScholarCard(statement, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildScholarCard(ScholarStatement statement, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
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
                  color: const Color(0xFF8B5CF6).withOpacity(0.15),
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

  Widget _buildBenefitsSection(bool isDark) {
    return Column(
      children: _additionalBenefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildBenefitCard(benefit, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildBenefitCard(String benefit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
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
}

class PrayerStep {
  final String title;
  final String description;
  final String? evidence;
  final String? type;

  const PrayerStep({
    required this.title,
    required this.description,
    this.evidence,
    this.type,
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


// Prayer Steps Data
final List<PrayerStep> _prayerSteps = [
  const PrayerStep(
    title: 'القيام مع القدرة',
    description: 'القيام في الصلاة المفروضة ركن من أركانها لمن قدر عليه، فإن لم يستطع صلى قاعداً، فإن لم يستطع فعلى جنب.',
    evidence: 'قال النبي ﷺ لعمران بن حصين: "صل قائماً، فإن لم تستطع فقاعداً، فإن لم تستطع فعلى جنب" - رواه البخاري',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'تكبيرة الإحرام',
    description: 'يقول: "الله أكبر" وهي ركن من أركان الصلاة، ولا تنعقد الصلاة بدونها.',
    evidence: 'قال النبي ﷺ: "مفتاح الصلاة الطهور، وتحريمها التكبير، وتحليلها التسليم" - رواه أبو داود وصححه الألباني',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'رفع اليدين عند التكبير',
    description: 'يرفع يديه حذو منكبيه أو إلى فروع أذنيه عند تكبيرة الإحرام، وعند الركوع، وعند الرفع منه، وعند القيام من التشهد الأول.',
    evidence: 'كان النبي ﷺ يرفع يديه في هذه المواضع - متفق عليه',
    type: 'سنة',
  ),
  const PrayerStep(
    title: 'وضع اليمنى على اليسرى',
    description: 'يضع يده اليمنى على اليسرى على صدره بعد تكبيرة الإحرام.',
    evidence: 'كان النبي ﷺ إذا قام في الصلاة وضع يده اليمنى على اليسرى - رواه البخاري',
    type: 'سنة',
  ),
  const PrayerStep(
    title: 'دعاء الاستفتاح',
    description: 'يقول بعد تكبيرة الإحرام: "سبحانك اللهم وبحمدك، وتبارك اسمك، وتعالى جدك، ولا إله غيرك".',
    evidence: 'كان النبي ﷺ يستفتح الصلاة بهذا الدعاء - رواه مسلم',
    type: 'سنة',
  ),
  const PrayerStep(
    title: 'الاستعاذة والبسملة',
    description: 'يستعيذ بالله من الشيطان الرجيم، ثم يبسمل سراً في الصلاة الجهرية والسرية.',
    evidence: 'قال الله تعالى: "فَإِذَا قَرَأْتَ الْقُرْآنَ فَاسْتَعِذْ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ" [النحل: 98]',
    type: 'سنة',
  ),
  const PrayerStep(
    title: 'قراءة الفاتحة',
    description: 'يقرأ سورة الفاتحة في كل ركعة، وهي ركن من أركان الصلاة.',
    evidence: 'قال النبي ﷺ: "لا صلاة لمن لم يقرأ بفاتحة الكتاب" - متفق عليه',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'قول آمين',
    description: 'يقول "آمين" بعد الفاتحة، يجهر بها في الصلاة الجهرية ويسر بها في السرية.',
    evidence: 'قال النبي ﷺ: "إذا أمّن الإمام فأمّنوا، فإنه من وافق تأمينه تأمين الملائكة غفر له ما تقدم من ذنبه" - متفق عليه',
    type: 'سنة',
  ),
  const PrayerStep(
    title: 'قراءة سورة بعد الفاتحة',
    description: 'يقرأ سورة أو آيات من القرآن بعد الفاتحة في الركعتين الأوليين من كل صلاة.',
    evidence: 'كان النبي ﷺ يقرأ في الركعتين الأوليين بفاتحة الكتاب وسورة - متفق عليه',
    type: 'سنة',
  ),
  const PrayerStep(
    title: 'الركوع',
    description: 'يركع مكبراً، ويجعل رأسه حيال ظهره، ويضع يديه على ركبتيه مفرجتي الأصابع.',
    evidence: 'كان النبي ﷺ إذا ركع لم يشخص رأسه ولم يصوبه، ولكن بين ذلك - رواه مسلم',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'التسبيح في الركوع',
    description: 'يقول في ركوعه: "سبحان ربي العظيم" ثلاث مرات أو أكثر.',
    evidence: 'قال النبي ﷺ: "أما الركوع فعظموا فيه الرب" - رواه مسلم',
    type: 'سنة',
  ),
  const PrayerStep(
    title: 'الرفع من الركوع',
    description: 'يرفع من الركوع قائلاً: "سمع الله لمن حمده"، ثم يقول بعد اعتداله: "ربنا ولك الحمد".',
    evidence: 'كان النبي ﷺ إذا رفع رأسه من الركوع قال: "سمع الله لمن حمده، ربنا ولك الحمد" - متفق عليه',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'السجود',
    description: 'يسجد على سبعة أعظم: الجبهة مع الأنف، والكفين، والركبتين، وأطراف القدمين.',
    evidence: 'قال النبي ﷺ: "أمرت أن أسجد على سبعة أعظم" - متفق عليه',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'التسبيح في السجود',
    description: 'يقول في سجوده: "سبحان ربي الأعلى" ثلاث مرات أو أكثر.',
    evidence: 'قال النبي ﷺ: "وأما السجود فاجتهدوا في الدعاء، فقمن أن يستجاب لكم" - رواه مسلم',
    type: 'سنة',
  ),
  const PrayerStep(
    title: 'الجلسة بين السجدتين',
    description: 'يجلس بين السجدتين مفترشاً رجله اليسرى وناصباً اليمنى، ويقول: "رب اغفر لي".',
    evidence: 'كان النبي ﷺ يقول بين السجدتين: "رب اغفر لي، رب اغفر لي" - رواه أبو داود وصححه الألباني',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'التشهد الأول',
    description: 'يجلس للتشهد الأول بعد الركعة الثانية، ويقرأ التحيات.',
    evidence: 'كان النبي ﷺ إذا جلس في الركعتين قال: "التحيات لله والصلوات والطيبات..." - متفق عليه',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'التشهد الأخير',
    description: 'يجلس للتشهد الأخير ويقرأ التحيات والصلاة الإبراهيمية.',
    evidence: 'قال النبي ﷺ: "إذا تشهد أحدكم فليستعذ بالله من أربع..." - رواه مسلم',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'التسليم',
    description: 'يسلم عن يمينه وشماله قائلاً: "السلام عليكم ورحمة الله".',
    evidence: 'كان النبي ﷺ يسلم عن يمينه وعن شماله - رواه مسلم',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'الطمأنينة في جميع الأركان',
    description: 'الطمأنينة واجبة في جميع أركان الصلاة، وهي السكون وعدم العجلة.',
    evidence: 'قال النبي ﷺ للمسيء في صلاته: "ارجع فصل فإنك لم تصل" - متفق عليه',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'الخشوع في الصلاة',
    description: 'الخشوع هو حضور القلب وخضوعه لله تعالى، وهو روح الصلاة ولبها.',
    evidence: 'قال الله تعالى: "قَدْ أَفْلَحَ الْمُؤْمِنُونَ * الَّذِينَ هُمْ فِي صَلَاتِهِمْ خَاشِعُونَ" [المؤمنون: 1-2]',
    type: 'سنة',
  ),
];

final List<ScholarStatement> _scholarStatements = [
  const ScholarStatement(
    scholar: 'الإمام ابن القيم',
    title: 'رحمه الله (المتوفى 751هـ)',
    statement: 'قال في كتاب الصلاة: "الصلاة قرة عيون المحبين، وسرور أرواح الموحدين، ولذة نفوس العارفين، وبستان العابدين، ولذة نفوس الخاشعين، وهي محك أحوال الصادقين".',
  ),
  const ScholarStatement(
    scholar: 'الإمام النووي',
    title: 'رحمه الله (المتوفى 676هـ)',
    statement: 'قال في المجموع: "ينبغي للمصلي أن يحضر قلبه في جميع أقوال الصلاة وأفعالها، ويتدبر ما يقوله ويفعله، فإن ذلك روح الصلاة ولبها".',
  ),
  const ScholarStatement(
    scholar: 'الشيخ ابن عثيمين',
    title: 'رحمه الله (المتوفى 1421هـ)',
    statement: 'قال: "الصلاة عمود الإسلام، وهي الصلة بين العبد وربه، فينبغي للمسلم أن يعتني بها غاية العناية، وأن يؤديها على الوجه الذي شرعه الله تعالى".',
  ),
  const ScholarStatement(
    scholar: 'الشيخ ابن باز',
    title: 'رحمه الله (المتوفى 1420هـ)',
    statement: 'قال: "الصلاة هي أعظم أركان الإسلام بعد الشهادتين، وهي عمود الدين، فمن أقامها فقد أقام الدين، ومن هدمها فقد هدم الدين".',
  ),
  const ScholarStatement(
    scholar: 'الإمام أحمد بن حنبل',
    title: 'رحمه الله (المتوفى 241هـ)',
    statement: 'قال: "الصلاة أفضل الأعمال بعد الشهادتين، وهي أول ما يحاسب عليه العبد يوم القيامة، فإن صلحت صلح سائر عمله، وإن فسدت فسد سائر عمله".',
  ),
];

final List<String> _additionalBenefits = [
  'الصلاة نور للمؤمن في الدنيا والآخرة، قال النبي ﷺ: "الصلاة نور" - رواه مسلم',
  'الصلاة تنهى عن الفحشاء والمنكر، قال تعالى: "إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ" [العنكبوت: 45]',
  'الصلاة كفارة للذنوب والخطايا، قال النبي ﷺ: "الصلوات الخمس، والجمعة إلى الجمعة، كفارات لما بينهن ما لم تغش الكبائر" - رواه مسلم',
  'الصلاة سبب لدخول الجنة، قال النبي ﷺ: "من صلى البردين دخل الجنة" - متفق عليه',
  'الصلاة في جماعة أفضل من صلاة الفذ بسبع وعشرين درجة - متفق عليه',
  'المحافظة على الصلوات الخمس من علامات الإيمان وحسن الإسلام',
  'الصلاة راحة للقلب وطمأنينة للنفس، قال النبي ﷺ: "أرحنا بها يا بلال" - رواه أبو داود',
  'السجود أقرب ما يكون العبد من ربه، قال النبي ﷺ: "أقرب ما يكون العبد من ربه وهو ساجد" - رواه مسلم',
  'الدعاء في السجود مستجاب، فينبغي الإكثار من الدعاء فيه',
  'صلاة الليل شرف المؤمن، قال النبي ﷺ: "عليكم بقيام الليل فإنه دأب الصالحين قبلكم" - رواه الترمذي',
];
