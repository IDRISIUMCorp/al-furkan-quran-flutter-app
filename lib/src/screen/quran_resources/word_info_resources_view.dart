import 'package:al_quran_v3/src/theme/controller/theme_cubit.dart';
import 'package:al_quran_v3/src/theme/controller/theme_state.dart' as theme;
import 'package:al_quran_v3/src/utils/quran_resources/word_info_models.dart';
import 'package:al_quran_v3/src/utils/quran_resources/word_info_repository.dart';
import 'package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart';
import 'package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class WordInfoResourcesView extends StatefulWidget {
  const WordInfoResourcesView({super.key});

  @override
  State<WordInfoResourcesView> createState() => _WordInfoResourcesViewState();
}

class _WordInfoResourcesViewState extends State<WordInfoResourcesView> {
  final WordInfoRepository _repository = WordInfoRepository();

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 80.h, 16.w, 20.h),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKindCard(WordInfoKind.eerab, "الإعراب", "بيانات إعراب كلمات القرآن الكريم بالكامل.", themeState, isDark),
          SizedBox(height: 16.h),
          _buildKindCard(WordInfoKind.tasreef, "الصرف", "بيانات الصرف والاشتقاق لكل كلمة في القرآن.", themeState, isDark),
          SizedBox(height: 16.h),
          _buildKindCard(WordInfoKind.recitations, "القراءات", "بيانات اختلاف القراءات والتوجيه لكل كلمة.", themeState, isDark),
        ],
      ),
    );
  }

  Widget _buildKindCard(WordInfoKind kind, String title, String desc, theme.ThemeState themeState, bool isDark) {
    final isDownloaded = _repository.isKindDownloaded(kind);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDownloaded 
              ? themeState.primary.withValues(alpha: 0.3) 
              : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: themeState.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  kind == WordInfoKind.eerab ? Icons.account_tree_rounded : 
                  kind == WordInfoKind.tasreef ? Icons.merge_type_rounded : Icons.record_voice_over_rounded,
                  color: themeState.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      isDownloaded ? "جاهز للاستخدام" : "متاح للتحميل",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDownloaded ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDownloaded)
                IconButton(
                  onPressed: () => _confirmDelete(kind),
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: Colors.redAccent,
                )
              else
                _buildDownloadButton(kind, title, themeState, isDark),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          _buildProgressIndicator(kind, title, isDark, themeState),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(WordInfoKind kind, String title, theme.ThemeState themeState, bool isDark) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        final isOnProcess = state.onProcess ?? false;
        if (isOnProcess && (state.processName?.contains(title) ?? false)) {
          return const SizedBox.shrink();
        }

        return ElevatedButton(
          onPressed: () async {
            context.read<ResourcesProgressCubit>().onProcess();
            await _repository.downloadKind(
              kind: kind,
              onProgress: (p) {
                context.read<ResourcesProgressCubit>().updateProgress(p / 100, "تحميل $title");
              },
            );
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeState.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          child: const Text("تحميل"),
        );
      },
    );
  }

  Widget _buildProgressIndicator(WordInfoKind kind, String title, bool isDark, theme.ThemeState themeState) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        final onProcess = (state.onProcess ?? false) && (state.processName?.contains(title) ?? false);
        if (!onProcess) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: Column(
            children: [
              LinearPercentIndicator(
                lineHeight: 8.h,
                percent: (state.percentage ?? 0.0).clamp(0.0, 1.0),
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                progressColor: themeState.primary,
                barRadius: const Radius.circular(10),
                isRTL: true,
                animateFromLastPercent: true,
                animation: true,
              ),
              SizedBox(height: 8.h),
              Text(
                "جاري التحميل... ${( (state.percentage ?? 0) * 100).toInt()}%",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: themeState.primary),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(WordInfoKind kind) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف المورد", textAlign: TextAlign.right),
        content: const Text("هل أنت متأكد من حذف هذا المورد؟ ستحتاج لتحميله مرة أخرى لاستخدامه.", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _repository.deleteKind(kind);
              setState(() {});
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
