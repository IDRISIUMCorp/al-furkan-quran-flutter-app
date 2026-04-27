import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sunnah_theme.dart';

/// 📦 مجموعة ويدجتس السنن
/// 
/// تحتوي على جميع الويدجتس المستخدمة في شاشات السنن

// ═══════════════════════════════════════════
// INTRO CARD
// ═══════════════════════════════════════════

class SunnahIntroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const SunnahIntroCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $description',
      child: Container(
        padding: EdgeInsets.all(SunnahTheme.space20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              SunnahTheme.green.withValues(alpha: 0.15),
              SunnahTheme.green.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(SunnahTheme.radiusXLarge),
          border: Border.all(
            color: SunnahTheme.green.withValues(alpha: 0.3),
            width: SunnahTheme.borderStandard,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(SunnahTheme.space12),
                  decoration: BoxDecoration(
                    color: SunnahTheme.green,
                    borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: SunnahTheme.iconXLarge,
                  ),
                ),
                SizedBox(width: SunnahTheme.space12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: SunnahTheme.getTextPrimaryColor(isDark),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SunnahTheme.space16),
            Text(
              description,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: SunnahTheme.getTextSecondaryColor(isDark),
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// IMPORTANCE CARD
// ═══════════════════════════════════════════

class SunnahImportanceCard extends StatelessWidget {
  final bool isDark;

  const SunnahImportanceCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'فضل الصلاة',
      child: Container(
        padding: EdgeInsets.all(SunnahTheme.space20),
        decoration: BoxDecoration(
          color: SunnahTheme.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(SunnahTheme.radiusXLarge),
          border: Border.all(
            color: SunnahTheme.getBorderColor(isDark),
            width: SunnahTheme.borderStandard,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(SunnahTheme.space12),
                  decoration: BoxDecoration(
                    color: SunnahTheme.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: SunnahTheme.gold,
                    size: SunnahTheme.iconLarge,
                  ),
                ),
                SizedBox(width: SunnahTheme.space12),
                Expanded(
                  child: Text(
                    'فضل الصلاة',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: SunnahTheme.getTextPrimaryColor(isDark),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SunnahTheme.space16),
            _buildHadithBox(
              'عن أبي هريرة رضي الله عنه قال: سمعت رسول الله ﷺ يقول: "أرأيتم لو أن نهراً بباب أحدكم يغتسل منه كل يوم خمس مرات، هل يبقى من درنه شيء؟" قالوا: لا يبقى من درنه شيء. قال: "فذلك مثل الصلوات الخمس، يمحو الله بهن الخطايا"',
              'متفق عليه',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithBox(String hadith, String source, bool isDark) {
    return Container(
      padding: EdgeInsets.all(SunnahTheme.space16),
      decoration: BoxDecoration(
        color: SunnahTheme.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
        border: Border.all(
          color: SunnahTheme.gold.withValues(alpha: 0.3),
          width: SunnahTheme.borderStandard,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: SunnahTheme.gold,
                size: SunnahTheme.iconMedium,
              ),
              SizedBox(width: SunnahTheme.space8),
              Text(
                "حديث شريف",
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: SunnahTheme.gold,
                ),
              ),
            ],
          ),
          SizedBox(height: SunnahTheme.space12),
          Text(
            hadith,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: SunnahTheme.getTextPrimaryColor(isDark),
              height: 1.9,
            ),
          ),
          SizedBox(height: SunnahTheme.space12),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SunnahTheme.space12,
              vertical: SunnahTheme.space8,
            ),
            decoration: BoxDecoration(
              color: SunnahTheme.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(SunnahTheme.radiusSmall),
            ),
            child: Text(
              source,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: SunnahTheme.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════

class SunnahSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;

  const SunnahSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: title,
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: SunnahTheme.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: SunnahTheme.space12),
          Icon(
            icon,
            color: SunnahTheme.green,
            size: SunnahTheme.iconLarge,
          ),
          SizedBox(width: SunnahTheme.space8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: SunnahTheme.getTextPrimaryColor(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// STEP CARD
// ═══════════════════════════════════════════

class SunnahStepCard extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String? evidence;
  final String? badgeText;
  final Color? badgeColor;
  final bool isDark;
  final VoidCallback onShare;

  const SunnahStepCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    this.evidence,
    this.badgeText,
    this.badgeColor,
    required this.isDark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $description',
      child: Container(
        padding: EdgeInsets.all(SunnahTheme.space20),
        decoration: BoxDecoration(
          color: SunnahTheme.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(SunnahTheme.radiusLarge),
          border: Border.all(
            color: SunnahTheme.getBorderColor(isDark),
            width: SunnahTheme.borderStandard,
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
                // Number Badge
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SunnahTheme.green,
                        SunnahTheme.green.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SunnahTheme.space12),
                
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: SunnahTheme.getTextPrimaryColor(isDark),
                    ),
                  ),
                ),
                
                // Badge (ركن/سنة)
                if (badgeText != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SunnahTheme.space12,
                      vertical: SunnahTheme.space4,
                    ),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? SunnahTheme.gold).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(SunnahTheme.radiusSmall),
                    ),
                    child: Text(
                      badgeText!,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: badgeColor ?? SunnahTheme.gold,
                      ),
                    ),
                  ),
                  SizedBox(width: SunnahTheme.space8),
                ],
                
                // Share Button
                Semantics(
                  button: true,
                  label: 'مشاركة $title',
                  child: IconButton(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded),
                    iconSize: SunnahTheme.iconMedium,
                    color: SunnahTheme.success,
                    tooltip: "مشاركة",
                    constraints: BoxConstraints(
                      minWidth: SunnahTheme.touchTarget,
                      minHeight: SunnahTheme.touchTarget,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: SunnahTheme.space12),
            
            // Description
            Text(
              description,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: SunnahTheme.getTextSecondaryColor(isDark),
                height: 1.8,
              ),
            ),
            
            // Evidence
            if (evidence != null) ...[
              SizedBox(height: SunnahTheme.space12),
              _buildEvidenceBox(evidence!, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceBox(String evidence, bool isDark) {
    return Container(
      padding: EdgeInsets.all(SunnahTheme.space12),
      decoration: BoxDecoration(
        color: SunnahTheme.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
        border: Border.all(
          color: SunnahTheme.green.withValues(alpha: 0.2),
          width: SunnahTheme.borderStandard,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_rounded,
            size: SunnahTheme.iconSmall,
            color: SunnahTheme.green,
          ),
          SizedBox(width: SunnahTheme.space8),
          Expanded(
            child: Text(
              evidence,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: SunnahTheme.green,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SCHOLAR CARD
// ═══════════════════════════════════════════

class SunnahScholarCard extends StatelessWidget {
  final String scholarName;
  final String? scholarTitle;
  final String statement;
  final bool isDark;

  const SunnahScholarCard({
    super.key,
    required this.scholarName,
    this.scholarTitle,
    required this.statement,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$scholarName. $statement',
      child: Container(
        padding: EdgeInsets.all(SunnahTheme.space20),
        decoration: BoxDecoration(
          color: SunnahTheme.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(SunnahTheme.radiusLarge),
          border: Border.all(
            color: SunnahTheme.getBorderColor(isDark),
            width: SunnahTheme.borderStandard,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(SunnahTheme.space12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                SizedBox(width: SunnahTheme.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scholarName,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: SunnahTheme.getTextPrimaryColor(isDark),
                        ),
                      ),
                      if (scholarTitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          scholarTitle!,
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: SunnahTheme.getTextSecondaryColor(isDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: SunnahTheme.space12),
            Text(
              statement,
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: SunnahTheme.getTextSecondaryColor(isDark),
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// BENEFIT CARD
// ═══════════════════════════════════════════

class SunnahBenefitCard extends StatelessWidget {
  final String benefit;
  final bool isDark;

  const SunnahBenefitCard({
    super.key,
    required this.benefit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: benefit,
      child: Container(
        padding: EdgeInsets.all(SunnahTheme.space16),
        decoration: BoxDecoration(
          color: SunnahTheme.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
          border: Border.all(
            color: SunnahTheme.getBorderColor(isDark),
            width: SunnahTheme.borderStandard,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(SunnahTheme.space8),
              decoration: BoxDecoration(
                color: SunnahTheme.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(SunnahTheme.radiusSmall),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: SunnahTheme.success,
                size: SunnahTheme.iconMedium,
              ),
            ),
            SizedBox(width: SunnahTheme.space12),
            Expanded(
              child: Text(
                benefit,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: SunnahTheme.getTextSecondaryColor(isDark),
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
