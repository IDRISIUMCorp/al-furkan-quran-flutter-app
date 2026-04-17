import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:al_furkan/src/screen/mushaf/widgets/wahy_side_drawer.dart';
import '../../core/theme/sunnah_theme.dart';
import '../../services/sunnah_share_service.dart';
import '../widgets/sunnah_intro_card.dart';
import '../widgets/sunnah_importance_card.dart';
import '../widgets/sunnah_section_header.dart';
import '../widgets/sunnah_step_card.dart';
import '../widgets/sunnah_scholar_card.dart';
import '../widgets/sunnah_benefit_card.dart';
import '../widgets/sunnah_share_bottom_sheet.dart';

/// 🕌 شاشة سنن الصلاة - النسخة المحسّنة V2
/// 
/// المميزات:
/// ✅ تطبيق ديزاين Wahy+Ayah
/// ✅ Animations محسّنة وسلسة
/// ✅ Dark mode كامل
/// ✅ Accessibility features
/// ✅ Responsive design للتابلت
/// ✅ ميزة المشاركة الفعلية (نص + صورة)
/// ✅ Staggered animations للعناصر
/// ✅ Semantic labels للـ screen readers
/// ✅ Touch targets أكبر (44dp)
class SunnahPrayerScreenV2 extends StatefulWidget {
  const SunnahPrayerScreenV2({super.key});

  @override
  State<SunnahPrayerScreenV2> createState() => _SunnahPrayerScreenV2State();
}

class _SunnahPrayerScreenV2State extends State<SunnahPrayerScreenV2>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ScrollController _scrollController;
  late AnimationController _fabController;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: SunnahTheme.durationNormal),
    );
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showFab) {
      setState(() => _showFab = true);
      _fabController.forward();
    } else if (_scrollController.offset <= 200 && _showFab) {
      setState(() => _showFab = false);
      _fabController.reverse();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: SunnahTheme.durationSlow),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: SunnahTheme.getBgColor(isDark),
      drawer: WahySideDrawer(
        primary: cs.primary,
        onOpenIndex: () {},
        onOpenBookmarks: () {},
        onOpenStarred: () {},
        onOpenNotes: () {},
        onJumpToAyah: (_) {},
      ),
      appBar: _buildAppBar(isDark, cs),
      body: _buildBody(isDark, isTablet),
      floatingActionButton: _buildFab(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, ColorScheme cs) {
    return AppBar(
      title: Text(
        'سنن الصلاة وآدابها',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.w900,
          fontSize: 20.sp,
        ),
        semanticsLabel: 'سنن الصلاة وآدابها',
      ),
      centerTitle: true,
      backgroundColor: SunnahTheme.getSurfaceColor(isDark),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        tooltip: 'القائمة الرئيسية',
        iconSize: SunnahTheme.iconLarge,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: () => _shareScreen(),
          tooltip: 'مشاركة',
          iconSize: SunnahTheme.iconLarge,
        ),
        SizedBox(width: SunnahTheme.space8),
      ],
    );
  }

  Widget _buildBody(bool isDark, bool isTablet) {
    final maxWidth = isTablet ? 800.0 : double.infinity;
    
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(
            isTablet ? SunnahTheme.space32 : SunnahTheme.space16,
          ),
          children: [
            // Intro Card
            SunnahIntroCard(
              icon: Icons.book_rounded,
              title: "الصلاة عماد الدين",
              description: "الصلاة هي الركن الثاني من أركان الإسلام، وهي أول ما يحاسب عليه العبد يوم القيامة. وقد أمر الله تعالى بإقامتها وحث النبي ﷺ على إتقانها وإحسانها.",
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                )
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
            
            SizedBox(height: SunnahTheme.space16),
            
            // Importance Card
            SunnahImportanceCard(
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                  delay: Duration(milliseconds: SunnahTheme.durationStagger),
                )
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
            
            SizedBox(height: SunnahTheme.space24),
            
            // Section: أركان الصلاة وسننها
            SunnahSectionHeader(
              title: "أركان الصلاة وسننها",
              icon: Icons.format_list_numbered_rounded,
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                  delay: Duration(milliseconds: SunnahTheme.durationStagger * 2),
                )
                .slideX(begin: 0.05, end: 0),
            
            SizedBox(height: SunnahTheme.space12),
            
            // Prayer Steps
            ..._buildPrayerSteps(isDark),
            
            SizedBox(height: SunnahTheme.space24),
            
            // Section: أقوال العلماء
            SunnahSectionHeader(
              title: "أقوال العلماء",
              icon: Icons.school_rounded,
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                )
                .slideX(begin: 0.05, end: 0),
            
            SizedBox(height: SunnahTheme.space12),
            
            // Scholars
            ..._buildScholars(isDark),
            
            SizedBox(height: SunnahTheme.space24),
            
            // Section: فوائد وآداب
            SunnahSectionHeader(
              title: "فوائد وآداب",
              icon: Icons.lightbulb_rounded,
              isDark: isDark,
            )
                .animate()
                .fadeIn(
                  duration: Duration(milliseconds: SunnahTheme.durationNormal),
                )
                .slideX(begin: 0.05, end: 0),
            
            SizedBox(height: SunnahTheme.space12),
            
            // Benefits
            ..._buildBenefits(isDark),
            
            SizedBox(height: SunnahTheme.space40 * 2),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPrayerSteps(bool isDark) {
    return _prayerSteps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: SunnahTheme.space12),
        child: SunnahStepCard(
          number: index + 1,
          title: step.title,
          description: step.description,
          evidence: step.evidence,
          badgeText: step.type,
          badgeColor: step.type == 'ركن' 
              ? SunnahTheme.badgeRukn 
              : SunnahTheme.badgeSunnah,
          isDark: isDark,
          onShare: () => _shareStep(step),
        ),
      )
          .animate()
          .fadeIn(
            duration: Duration(milliseconds: SunnahTheme.durationNormal),
            delay: Duration(
              milliseconds: SunnahTheme.durationStagger * (index + 3),
            ),
          )
          .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
    }).toList();
  }

  List<Widget> _buildScholars(bool isDark) {
    return _scholarStatements.asMap().entries.map((entry) {
      final index = entry.key;
      final scholar = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: SunnahTheme.space12),
        child: SunnahScholarCard(
          scholarName: scholar.scholar,
          scholarTitle: scholar.title,
          statement: scholar.statement,
          isDark: isDark,
        ),
      )
          .animate()
          .fadeIn(
            duration: Duration(milliseconds: SunnahTheme.durationNormal),
            delay: Duration(milliseconds: SunnahTheme.durationStagger * index),
          )
          .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
    }).toList();
  }

  List<Widget> _buildBenefits(bool isDark) {
    return _additionalBenefits.asMap().entries.map((entry) {
      final index = entry.key;
      final benefit = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: SunnahTheme.space12),
        child: SunnahBenefitCard(
          benefit: benefit,
          isDark: isDark,
        ),
      )
          .animate()
          .fadeIn(
            duration: Duration(milliseconds: SunnahTheme.durationNormal),
            delay: Duration(milliseconds: SunnahTheme.durationStagger * index),
          )
          .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
    }).toList();
  }

  Widget _buildFab(bool isDark) {
    return ScaleTransition(
      scale: _fabController,
      child: FloatingActionButton(
        onPressed: _scrollToTop,
        backgroundColor: SunnahTheme.green,
        tooltip: 'العودة للأعلى',
        child: const Icon(
          Icons.arrow_upward_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  void _shareStep(PrayerStep step) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SunnahShareBottomSheet(
        title: step.title,
        description: step.description,
        evidence: step.evidence,
        type: "سنن الصلاة",
        badgeText: step.type,
        badgeColor: step.type == 'ركن' 
            ? SunnahTheme.badgeRukn 
            : SunnahTheme.badgeSunnah,
      ),
    );
  }

  void _shareScreen() {
    SunnahShareService.shareAsText(
      title: "سنن الصلاة وآدابها",
      description: "دليل شامل لأركان الصلاة وسننها وآدابها",
      type: "سنن الصلاة",
    );
  }
}

// ═══════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════

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

// ═══════════════════════════════════════════
// DATA
// ═══════════════════════════════════════════

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
    title: 'قراءة الفاتحة',
    description: 'يقرأ سورة الفاتحة في كل ركعة، وهي ركن من أركان الصلاة.',
    evidence: 'قال النبي ﷺ: "لا صلاة لمن لم يقرأ بفاتحة الكتاب" - متفق عليه',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'الركوع',
    description: 'يركع مكبراً، ويجعل رأسه حيال ظهره، ويضع يديه على ركبتيه مفرجتي الأصابع.',
    evidence: 'كان النبي ﷺ إذا ركع لم يشخص رأسه ولم يصوبه، ولكن بين ذلك - رواه مسلم',
    type: 'ركن',
  ),
  const PrayerStep(
    title: 'السجود',
    description: 'يسجد على سبعة أعظم: الجبهة مع الأنف، والكفين، والركبتين، وأطراف القدمين.',
    evidence: 'قال النبي ﷺ: "أمرت أن أسجد على سبعة أعظم" - متفق عليه',
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
];

final List<String> _additionalBenefits = [
  'الصلاة نور للمؤمن في الدنيا والآخرة، قال النبي ﷺ: "الصلاة نور" - رواه مسلم',
  'الصلاة تنهى عن الفحشاء والمنكر، قال تعالى: "إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ" [العنكبوت: 45]',
  'الصلاة كفارة للذنوب والخطايا، قال النبي ﷺ: "الصلوات الخمس، والجمعة إلى الجمعة، كفارات لما بينهن ما لم تغش الكبائر" - رواه مسلم',
  'الصلاة سبب لدخول الجنة، قال النبي ﷺ: "من صلى البردين دخل الجنة" - متفق عليه',
  'الصلاة في جماعة أفضل من صلاة الفذ بسبع وعشرين درجة - متفق عليه',
];
