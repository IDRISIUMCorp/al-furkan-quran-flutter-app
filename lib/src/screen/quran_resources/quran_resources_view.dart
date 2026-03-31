import "dart:ui";

import "package:al_quran_v3/src/screen/quran_resources/tafsir_resources_view.dart";
import "package:al_quran_v3/src/screen/quran_resources/translation_resources_view.dart";
import "package:al_quran_v3/src/screen/quran_resources/word_info_resources_view.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
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

  static const List<String> pagesName = ["الترجمات", "التفاسير", "معلومات الكلمات"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: widget.initTab.clamp(0, 2),
      length: pagesName.length,
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
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: isDark ? 0.75 : 0.85),
                border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
              ),
            ),
          ),
        ),
        title: Text(
          "الموارد القرآنية",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: const [
              TranslationResourcesView(),
              TafsirResourcesView(),
              WordInfoResourcesView(),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: themeState.primary,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: themeState.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
                        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                        unselectedLabelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                        tabs: pagesName.map((name) => Tab(text: name)).toList(),
                        dividerColor: Colors.transparent,
                        indicatorPadding: EdgeInsets.all(4.w),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
