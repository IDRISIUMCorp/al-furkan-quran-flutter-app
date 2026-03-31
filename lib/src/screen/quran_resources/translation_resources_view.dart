import "package:al_quran_v3/src/resources/quran_resources/translation_resources.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_translation_function.dart";
import "package:al_quran_v3/src/resources/quran_resources/models/translation_book_model.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:percent_indicator/linear_percent_indicator.dart";

class TranslationResourcesView extends StatefulWidget {
  const TranslationResourcesView({super.key});

  @override
  State<TranslationResourcesView> createState() => _TranslationResourcesViewState();
}

class _TranslationResourcesViewState extends State<TranslationResourcesView> {
  final TextEditingController _searchController = TextEditingController();
  List<TranslationBookModel> _allBooks = [];
  List<TranslationBookModel> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_filterBooks);
  }

  void _loadBooks() {
    _allBooks = [];
    translationResources.forEach((lang, books) {
      for (var bookMap in books) {
        _allBooks.add(TranslationBookModel.fromMap(bookMap));
      }
    });
    // Sort: Downloaded first, then by name
    _allBooks.sort((a, b) {
      final aDownloaded = QuranTranslationFunction.isAlreadyDownloaded(a) == true;
      final bDownloaded = QuranTranslationFunction.isAlreadyDownloaded(b) == true;
      if (aDownloaded != bDownloaded) return aDownloaded ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    _filteredBooks = List.from(_allBooks);
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        return book.name.toLowerCase().contains(query) || 
               book.language.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(height: 75.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "بحث عن ترجمة...",
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
            physics: const BouncingScrollPhysics(),
            itemCount: _filteredBooks.length,
            itemBuilder: (context, index) {
              return _buildBookCard(_filteredBooks[index], themeState, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(TranslationBookModel book, ThemeState themeState, bool isDark) {
    final isDownloaded = QuranTranslationFunction.isAlreadyDownloaded(book) == true;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDownloaded ? themeState.primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      book.language,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDownloaded == true)
                IconButton(
                  onPressed: () => _confirmDelete(book),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                )
              else
                _buildDownloadButton(book, themeState, isDark),
            ],
          ),
          _buildProgressIndicator(book, isDark, themeState),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(TranslationBookModel book, ThemeState themeState, bool isDark) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        final onProcess = (state.onProcess ?? false) && (state.processName == book.name);
        if (onProcess) return const SizedBox.shrink();

        return ElevatedButton(
          onPressed: () async {
            context.read<ResourcesProgressCubit>().onProcess();
            await QuranTranslationFunction.downloadResources(
              context: context,
              translationBook: book,
            );
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeState.primary.withValues(alpha: 0.1),
            foregroundColor: themeState.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          child: const Text("تحميل"),
        );
      },
    );
  }

  Widget _buildProgressIndicator(TranslationBookModel book, bool isDark, ThemeState themeState) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        final onProcess = (state.onProcess ?? false) && (state.processName == book.name);
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

  void _confirmDelete(TranslationBookModel book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف الترجمة", textAlign: TextAlign.right),
        content: Text("هل أنت متأكد من حذف ترجمة ${book.name}؟", textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await QuranTranslationFunction.removeFromListAlreadyDownloaded(book);
              setState(() {});
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
