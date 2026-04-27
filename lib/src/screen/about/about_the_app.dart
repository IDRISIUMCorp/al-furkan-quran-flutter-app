import 'dart:ui' as ui;
import 'package:al_furkan/l10n/app_localizations.dart';
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/theme/controller/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  String _appVersion = "جاري التحميل...";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(
        () => _appVersion = "الإصدار ${info.version} (${info.buildNumber})",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = themeState.primary;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF9F6F0),
      body: Stack(
        children: [
          // ── Premium Animated Background ──
          if (isDark)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.15),
                ),
              ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: const Duration(seconds: 4),
                    curve: Curves.easeInOutSine,
                  ),
            ),
          if (isDark)
            Positioned(
              bottom: -150,
              left: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.08),
                ),
              ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true)).scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                    duration: const Duration(seconds: 6),
                    curve: Curves.easeInOutSine,
                  ),
            ),

          // ── Main Content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                stretch: true,
                expandedHeight: 280,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Subtly blurred backdrop for the top
                      Positioned.fill(
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Gap(40),
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                "assets/img/Quran_Logo_v3.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                curve: Curves.easeOutBack,
                                duration: const Duration(milliseconds: 700),
                              )
                              .fadeIn(),
                          const Gap(16),
                          Text(
                            l10n.appFullName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                          const Gap(6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              _appVersion,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Mission Statement Glass Card ──
                    _buildGlassCard(
                      isDark: isDark,
                      primary: primary,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite_rounded, color: primary, size: 24),
                              const Gap(8),
                              const Text(
                                "رسالة التطبيق",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          Text(
                            "هذا العمل صدقة جارية خالصة لوجه الله تعالى. التطبيق مجاني بالكامل، لا يحتوي على إعلانات، ومتاح للجميع للنفع والانتفاع بكتاب الله.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ).animate().slideY(begin: 0.2).fadeIn(duration: const Duration(milliseconds: 500)),
                    
                    const Gap(24),
                    
                    // ── GitHub Repo Button ──
                    InkWell(
                      onTap: () => launchUrl(
                        Uri.parse("https://github.com/IDRISIUMCorp/al-furkan-quran-flutter-app"),
                        mode: LaunchMode.externalApplication,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF),
                              isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF0F0F0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                              ),
                              child: Icon(SimpleIcons.github, color: isDark ? Colors.white : Colors.black, size: 30),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "الكود المصدري المفتوح",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "GitHub Repository",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.1,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: isDark ? Colors.white38 : Colors.black38,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ).animate().slideY(begin: 0.2).fadeIn(delay: const Duration(milliseconds: 100), duration: const Duration(milliseconds: 500)),

                    const Gap(32),

                    // ── Features Grid ──
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "مميزات التطبيق",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const Gap(16),
                    _buildFeatureCategory(
                      icon: Icons.menu_book_rounded,
                      title: "القراءة والتصفح",
                      items: [
                        "وضع المصحف المطابق للورقي",
                        "تفاعل آية بآية المتقدم",
                        "خطوط قرآنية (حفص، ورش، التجويد)",
                        "بحث فوري بدقة تفاعلية",
                      ],
                      primary: primary,
                      isDark: isDark,
                    ),
                    const Gap(16),
                    _buildFeatureCategory(
                      icon: Icons.headset_rounded,
                      title: "الصوتيات والتلاوة",
                      items: [
                        "أكثر من 40 قارئاً معتمداً",
                        "تلاوة للآيات أو الكلمات بتحديد ذكي",
                        "تحميل السمعيات للعمل بدون إنترنت",
                      ],
                      primary: primary,
                      isDark: isDark,
                    ),
                    const Gap(16),
                    _buildFeatureCategory(
                      icon: Icons.library_books_rounded,
                      title: "الموارد والتفاسير",
                      items: [
                        "متعدد التفاسير (الميسر، ابن كثير للمختصين)",
                        "إعراب وصرف متكامل للآيات",
                        "تراجم بأكثر من لغة حية",
                      ],
                      primary: primary,
                      isDark: isDark,
                    ),

                    const Gap(40),

                    // ── Idrisium Developer Card ──
                    _buildDeveloperCard(themeState, isDark),

                    const Gap(40),

                    // ── Footer ──
                    _buildFooter(isDark),
                    const Gap(40),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required bool isDark,
    required Color primary,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFeatureCategory({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color primary,
    required bool isDark,
  }) {
    return _buildGlassCard(
      isDark: isDark,
      primary: primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
            ],
          ),
          const Gap(16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: primary.withValues(alpha: 0.5), blurRadius: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().slideY(begin: 0.1).fadeIn(duration: const Duration(milliseconds: 500));
  }

  Widget _buildDeveloperCard(ThemeState themeState, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: themeState.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: themeState.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeState.primary.withValues(alpha: 0.15),
                ),
              ).animate(onPlay: (ctrl) => ctrl.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.15, 1.15),
                    duration: const Duration(seconds: 2),
                  ),
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeState.primary,
                    width: 2.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    "assets/dev/dev image.jpg",
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, _) => Container(
                      color: isDark ? Colors.white10 : Colors.black12,
                      child: Center(
                        child: Text(
                          "I",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: themeState.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(20),
          const Text(
            "إدريس غامد",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            textDirection: TextDirection.rtl,
          ),
          const Gap(4),
          Text(
            "IDRIS GHAMID",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black54,
              letterSpacing: 2.0,
            ),
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: themeState.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: themeState.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              "IDRISIUM Corp",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Gap(32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialIcon(
                themeState,
                isDark,
                icon: SimpleIcons.tiktok,
                url: "https://www.tiktok.com/@idris.ghamid",
              ),
              _buildSocialIcon(
                themeState,
                isDark,
                icon: SimpleIcons.instagram,
                url: "https://www.instagram.com/idris.ghamid",
              ),
              _buildSocialIcon(
                themeState,
                isDark,
                icon: SimpleIcons.telegram,
                url: "https://t.me/IDRV72",
              ),
              _buildSocialIcon(
                themeState,
                isDark,
                icon: SimpleIcons.github,
                url: "https://github.com/IDRISIUM",
              ),
              _buildSocialIcon(
                themeState,
                isDark,
                icon: Icons.email_rounded,
                url: "mailto:idris.ghamid@gmail.com",
              ),
              _buildSocialIcon(
                themeState,
                isDark,
                icon: Icons.language_rounded,
                url: "http://idrisium.linkpc.net/",
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(curve: Curves.easeOutBack, duration: const Duration(milliseconds: 600));
  }

  Widget _buildSocialIcon(
    ThemeState themeState,
    bool isDark, {
    required IconData icon,
    required String url,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          child: Icon(icon, size: 22, color: themeState.primary),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 40, height: 1, color: isDark ? Colors.white24 : Colors.black26),
            const Gap(12),
            Icon(Icons.star_rounded, size: 14, color: isDark ? Colors.white38 : Colors.black38),
            const Gap(12),
            Container(width: 40, height: 1, color: isDark ? Colors.white24 : Colors.black26),
          ],
        ),
        const Gap(16),
        Text(
          "CRAFTED WITH PRECISION BY IDRISIUM",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white38 : Colors.black38,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}
