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
  Map<String, List<TranslationBookModel>> _groupedBooks = {};
  List<TranslationBookModel> _selectedBooks = [];
  String? _animatingBook;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _loadData() async {
    final selections = await QuranTranslationFunction.getTranslationSelections() ?? [];
    _allBooks = [];
    translationResources.forEach((lang, books) {
      for (var bookMap in books) {
        _allBooks.add(TranslationBookModel.fromMap(bookMap));
      }
    });

    setState(() {
      _selectedBooks = selections;
      _filterBooks();
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    final filtered = _allBooks.where((book) {
      return book.name.toLowerCase().contains(query) || 
             book.language.toLowerCase().contains(query);
    }).toList();

    // Group by language
    _groupedBooks = {};
    for (var book in filtered) {
      final lang = book.language;
      if (!_groupedBooks.containsKey(lang)) {
        _groupedBooks[lang] = [];
      }
      _groupedBooks[lang]!.add(book);
    }
    
    // Sort languages: English and Arabic first, then others
    final sortedKeys = _groupedBooks.keys.toList()..sort((a, b) {
      if (a == "Arabic") return -1;
      if (b == "Arabic") return 1;
      if (a == "English") return -1;
      if (b == "English") return 1;
      return a.compareTo(b);
    });
    
    final newGrouped = <String, List<TranslationBookModel>>{};
    for (var key in sortedKeys) {
      newGrouped[key] = _groupedBooks[key]!;
    }
    
    setState(() {
      _groupedBooks = newGrouped;
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
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
            physics: const BouncingScrollPhysics(),
            children: _groupedBooks.entries.map((entry) {
              return _buildCategorySection(entry.key, entry.value, themeState, isDark);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String language, List<TranslationBookModel> books, ThemeState themeState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Text(
            language,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: themeState.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...books.map((book) => _buildBookCard(book, themeState, isDark)).toList(),
      ],
    );
  }

  Widget _buildBookCard(TranslationBookModel book, ThemeState themeState, bool isDark) {
    final isDownloaded = QuranTranslationFunction.isAlreadyDownloaded(book) == true;
    final isSelected = _selectedBooks.any((b) => b.fileName == book.fileName);
    final isAnimating = _animatingBook == book.name;

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
            color: isSelected ? themeState.primary.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.03),
            width: isSelected ? 1.5 : 1,
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
                if (isDownloaded)
                  Checkbox(
                    value: isSelected,
                    activeColor: themeState.primary,
                    onChanged: (val) async {
                      if (val == true) {
                        await QuranTranslationFunction.setTranslationSelection(book);
                      } else {
                        await QuranTranslationFunction.removeTranslationSelection(book);
                      }
                      _loadData();
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isSelected) 
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Text(
                            "مُختار للعرض",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: themeState.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isDownloaded)
                  IconButton(
                    onPressed: () => _confirmDelete(book),
                    icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                  )
                else
                  _buildDownloadButton(book, themeState, isDark),
              ],
            ),
            _buildProgressIndicator(book, isDark, themeState),
          ],
        ),
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
            setState(() => _animatingBook = book.name);
            await Future.delayed(const Duration(milliseconds: 200));
            setState(() => _animatingBook = null);
            
            context.read<ResourcesProgressCubit>().onProcess();
            await QuranTranslationFunction.downloadResources(
              context: context,
              translationBook: book,
            );
            _loadData();
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
