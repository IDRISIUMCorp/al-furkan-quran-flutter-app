import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sunnah_theme.dart';
import '../../services/sunnah_share_service.dart';

/// 📤 Bottom Sheet للمشاركة
/// 
/// يعرض خيارات المشاركة:
/// - مشاركة كنص
/// - مشاركة كصورة
/// - مشاركة مباشرة
class SunnahShareBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final String? evidence;
  final String type;
  final String? badgeText;
  final Color? badgeColor;

  const SunnahShareBottomSheet({
    super.key,
    required this.title,
    required this.description,
    this.evidence,
    required this.type,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: SunnahTheme.getSurfaceColor(isDark),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SunnahTheme.radiusXLarge),
        ),
      ),
      padding: EdgeInsets.all(SunnahTheme.space24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: SunnahTheme.getBorderColor(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 1)),
            
            SizedBox(height: SunnahTheme.space20),
            
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(SunnahTheme.space12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SunnahTheme.success,
                        SunnahTheme.success.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                  ),
                  child: Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: SunnahTheme.iconLarge,
                  ),
                )
                    .animate()
                    .scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                
                SizedBox(width: SunnahTheme.space12),
                
                Expanded(
                  child: Text(
                    "مشاركة السنة",
                    style: GoogleFonts.cairo(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: SunnahTheme.getTextPrimaryColor(isDark),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideX(begin: -0.1),
                ),
              ],
            ),
            
            SizedBox(height: SunnahTheme.space24),
            
            // Share Options
            _ShareOptionButton(
              icon: Icons.text_fields_rounded,
              label: "مشاركة كنص",
              color: SunnahTheme.info,
              isDark: isDark,
              onTap: () => _shareAsText(context),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 150.ms)
                .slideX(begin: 0.1),
            
            SizedBox(height: SunnahTheme.space12),
            
            _ShareOptionButton(
              icon: Icons.image_rounded,
              label: "مشاركة كصورة",
              color: const Color(0xFFEC4899),
              isDark: isDark,
              onTap: () => _shareAsImage(context),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideX(begin: 0.1),
            
            SizedBox(height: SunnahTheme.space12),
            
            _ShareOptionButton(
              icon: Icons.send_rounded,
              label: "مشاركة مباشرة",
              color: SunnahTheme.success,
              isDark: isDark,
              onTap: () => _shareDirect(context),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 250.ms)
                .slideX(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAsText(BuildContext context) async {
    try {
      await SunnahShareService.copyToClipboard(
        title: title,
        description: description,
        evidence: evidence,
        type: type,
      );
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "تم نسخ النص بنجاح ✓",
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SunnahTheme.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ أثناء النسخ",
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SunnahTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _shareAsImage(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(SunnahTheme.space24),
          decoration: BoxDecoration(
            color: SunnahTheme.getSurfaceColor(
              Theme.of(context).brightness == Brightness.dark,
            ),
            borderRadius: BorderRadius.circular(SunnahTheme.radiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(SunnahTheme.green),
              ),
              SizedBox(height: SunnahTheme.space16),
              Text(
                "جاري إنشاء الصورة...",
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    try {
      await SunnahShareService.shareAsImage(
        context: context,
        title: title,
        description: description,
        evidence: evidence,
        type: type,
        badgeText: badgeText,
        badgeColor: badgeColor,
      );
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "تم إنشاء الصورة بنجاح ✓",
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SunnahTheme.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "حدث خطأ أثناء إنشاء الصورة",
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SunnahTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _shareDirect(BuildContext context) async {
    try {
      await SunnahShareService.shareAsText(
        title: title,
        description: description,
        evidence: evidence,
        type: type,
      );
      
      if (context.mounted) {
        Navigator.pop(context);
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
            backgroundColor: SunnahTheme.error,
          ),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════
// SHARE OPTION BUTTON
// ═══════════════════════════════════════════

class _ShareOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ShareOptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
        child: Container(
          padding: EdgeInsets.all(SunnahTheme.space20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: SunnahTheme.borderStandard,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(SunnahTheme.space12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(SunnahTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: SunnahTheme.iconLarge,
                ),
              ),
              SizedBox(width: SunnahTheme.space16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: SunnahTheme.getTextPrimaryColor(isDark),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: SunnahTheme.iconMedium,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

