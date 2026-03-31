import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart" as theme;
import "package:al_quran_v3/src/utils/quran_resources/word_info_models.dart";
import "package:al_quran_v3/src/utils/quran_resources/word_info_repository.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:percent_indicator/linear_percent_indicator.dart";

class WordInfoResourcesView extends StatefulWidget {
  const WordInfoResourcesView({super.key});

  @override
  State<WordInfoResourcesView> createState() => _WordInfoResourcesViewState();
}

class _WordInfoResourcesViewState extends State<WordInfoResourcesView> {
  final WordInfoRepository _wordInfoRepo = WordInfoRepository();
  String? _animatingKind;

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(height: 85.h),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildKindCard(WordInfoKind.eerab, "الإعراب", Icons.architecture_rounded, themeState, isDark),
              _buildKindCard(WordInfoKind.tasreef, "الصرف", Icons.auto_awesome_rounded, themeState, isDark),
              _buildKindCard(WordInfoKind.recitations, "القراءات", Icons.record_voice_over_rounded, themeState, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKindCard(WordInfoKind kind, String label, IconData icon, theme.ThemeState themeState, bool isDark) {
    final isDownloaded = _wordInfoRepo.isKindDownloaded(kind);
    final isAnimating = _animatingKind == kind.name;

    return AnimatedScale(
      scale: isAnimating ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDownloaded ? themeState.primary.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
            width: isDownloaded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: themeState.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: themeState.primary, size: 24),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isDownloaded)
                        Text(
                          "جاهز للاستخدام",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: themeState.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isDownloaded)
                  IconButton(
                    onPressed: () => _confirmDelete(kind, label),
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                  )
                else
                  _buildDownloadButton(kind, label, themeState, isDark),
              ],
            ),
            _buildProgressIndicator(kind, label, themeState, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(WordInfoKind kind, String label, theme.ThemeState themeState, bool isDark) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        final onProcess = (state.onProcess ?? false) && (state.processName == label);
        if (onProcess) return const SizedBox.shrink();

        return ElevatedButton(
          onPressed: () async {
            setState(() => _animatingKind = kind.name);
            await Future.delayed(const Duration(milliseconds: 200));
            setState(() => _animatingKind = null);

            context.read<ResourcesProgressCubit>().onProcess();
            await _wordInfoRepo.downloadKind(
              kind: kind,
              onProgress: (p) => context.read<ResourcesProgressCubit>().updateProgress(p, label),
            );
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeState.primary.withValues(alpha: 0.1),
            foregroundColor: themeState.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            minimumSize: Size(60.w, 32.h),
          ),
          child: Text("تحميل", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800)),
        );
      },
    );
  }

  Widget _buildProgressIndicator(WordInfoKind kind, String label, theme.ThemeState themeState, bool isDark) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        final onProcess = (state.onProcess ?? false) && (state.processName == label);
        if (!onProcess) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: Column(
            children: [
              LinearPercentIndicator(
                lineHeight: 6.h,
                percent: (state.percentage ?? 0.0).clamp(0.0, 1.0),
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                progressColor: themeState.primary,
                barRadius: const Radius.circular(10),
                isRTL: true,
                animateFromLastPercent: true,
                animation: true,
              ),
              SizedBox(height: 4.h),
              Text(
                "جاري التحميل... ${( (state.percentage ?? 0) * 100).toInt()}%",
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: themeState.primary),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(WordInfoKind kind, String label) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف المورد", textAlign: TextAlign.right),
        content: Text("هل أنت متأكد من حذف مورد ${label}؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _wordInfoRepo.deleteKind(kind);
              setState(() {});
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
