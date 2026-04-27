import "package:al_furkan/src/screen/quran_resources/mutashabihat_resources_view.dart";
import "package:al_furkan/src/screen/quran_resources/tafsir_resources_view.dart";
import "package:al_furkan/src/screen/quran_resources/transliteration_resources_view.dart";
import "package:al_furkan/src/screen/quran_resources/translation_resources_view.dart";
import "package:al_furkan/src/screen/quran_resources/word_info_resources_view.dart";
import "package:al_furkan/src/theme/app_colors.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

class QuranResourcesView extends StatefulWidget {
  final int initTab;
  const QuranResourcesView({super.key, this.initTab = 0});

  @override
  State<QuranResourcesView> createState() => _QuranResourcesViewState();
}

class _QuranResourcesViewState extends State<QuranResourcesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const List<_ResourceCategory> categories = [
    _ResourceCategory(
      label: "الترجمات",
      icon: Icons.translate_rounded,
    ),
    _ResourceCategory(
      label: "التفاسير",
      icon: Icons.menu_book_rounded,
    ),
    _ResourceCategory(
      label: "بيانات الكلمات",
      icon: Icons.spellcheck_rounded,
    ),
    _ResourceCategory(
      label: "المتشابهات",
      icon: Icons.compare_arrows_rounded,
    ),
    _ResourceCategory(
      label: "النطق اللاتيني",
      icon: Icons.abc_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.initTab.clamp(0, categories.length - 1),
      length: categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.lightTextMain;
    final textSub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.h,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: bg,
              surfaceTintColor: Colors.transparent,
              title: Text(
                "المكتبة",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: textMain,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top + 12.h,
                    left: 20.w,
                    right: 20.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "اختَر الموارد اللي محتاجها وحمّلها على جهازك",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: textSub,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(52.h),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder.withValues(alpha: 0.4)
                          : AppColors.lightBorder.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    labelColor: Colors.white,
                    unselectedLabelColor: textSub,
                    indicator: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.zero,
                    dividerColor: Colors.transparent,
                    labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                    tabAlignment: TabAlignment.start,
                    tabs: categories.map((cat) {
                      return Tab(
                        height: 40.h,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.icon, size: 15.sp),
                              SizedBox(width: 5.w),
                              Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: const [
            TranslationResourcesView(),
            TafsirResourcesView(),
            WordInfoResourcesView(),
            MutashabihatResourcesView(),
            TransliterationResourcesView(),
          ],
        ),
      ),
    );
  }
}

class _ResourceCategory {
  final String label;
  final IconData icon;
  const _ResourceCategory({
    required this.label,
    required this.icon,
  });
}
