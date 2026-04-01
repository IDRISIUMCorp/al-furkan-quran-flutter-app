import "package:al_quran_v3/src/resources/quran_resources/models/translation_book_model.dart";
import "package:al_quran_v3/src/resources/quran_resources/word_by_word_translation.dart";
import "package:al_quran_v3/src/screen/quran_resources/widgets/managed_resources_catalog.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:al_quran_v3/src/utils/quran_resources/word_by_word_function.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class WordByWordResourcesView extends StatefulWidget {
  const WordByWordResourcesView({super.key});

  @override
  State<WordByWordResourcesView> createState() =>
      _WordByWordResourcesViewState();
}

class _WordByWordResourcesViewState extends State<WordByWordResourcesView> {
  List<TranslationBookModel> _allBooks = [];
  List<TranslationBookModel> _downloadedBooks = [];
  TranslationBookModel? _selectedBook;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await WordByWordFunction.init();
    final allBooks = wordByWordTranslation.values
        .map((map) => TranslationBookModel.fromMap(map))
        .toList();
    if (!mounted) return;
    setState(() {
      _allBooks = allBooks;
      _downloadedBooks = WordByWordFunction.getDownloadedWordByWordBooks();
      _selectedBook = WordByWordFunction.getSelectedWordByWordBook();
    });
  }

  bool _isDownloaded(TranslationBookModel book) {
    return _downloadedBooks.any((item) => item.fullPath == book.fullPath);
  }

  bool _isSelected(TranslationBookModel book) {
    return _selectedBook?.fullPath == book.fullPath;
  }

  bool _isBookBusy(
    ResourcesProgressCubitState state,
    TranslationBookModel book,
  ) {
    if (state.onProcess != true) return false;
    if (state.activeResourceId != null) {
      return state.activeResourceId == book.fullPath;
    }
    final processName = state.processName ?? "";
    return processName.contains(book.name);
  }

  Future<void> _toggleSelection(TranslationBookModel book, bool value) async {
    if (value) {
      await WordByWordFunction.setSelectedWordByWordBook(book);
    } else {
      await WordByWordFunction.removeSelectedWordByWordBook();
    }
    await _loadData();
  }

  Future<void> _activateAllDownloaded() async {
    if (_downloadedBooks.isEmpty) return;
    await WordByWordFunction.setSelectedWordByWordBook(_downloadedBooks.first);
    await _loadData();
  }

  Future<void> _clearSelection() async {
    await WordByWordFunction.removeSelectedWordByWordBook();
    await _loadData();
  }

  Future<void> _downloadBook(TranslationBookModel book) async {
    await WordByWordFunction.downloadResource(context: context, book: book);
    await _loadData();
  }

  Future<void> _deleteBook(TranslationBookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف مورد كلمة بكلمة", textAlign: TextAlign.right),
        content: Text(
          "سيتم حذف ${book.name} من الجهاز.",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await WordByWordFunction.removeBookFromDownloaded(book);
    await _loadData();
  }

  Future<void> _deleteMany(List<ManagedResourceItem> items) async {
    for (final item in items) {
      final book = _allBooks.firstWhere((entry) => entry.fullPath == item.id);
      await WordByWordFunction.removeBookFromDownloaded(book);
    }
    await _loadData();
  }

  List<ManagedResourceItem> _buildItems(ResourcesProgressCubitState state) {
    return _allBooks.map((book) {
      final downloaded = _isDownloaded(book);
      final busy = _isBookBusy(state, book);
      return ManagedResourceItem(
        id: book.fullPath,
        title: book.name,
        group: book.language,
        subtitle: downloaded
            ? "هذا هو المصدر المستخدم حاليًا لترجمة الكلمة المختارة."
            : "نزّله لتفعيل ترجمة الكلمة المختارة داخل المكتبة.",
        badges: [
          "كلمة بكلمة",
          if (book.score > 0) "درجة ${book.score.round()}",
        ],
        isDownloaded: downloaded,
        isActive: _isSelected(book),
        isBusy: busy,
        progress: busy ? (state.percentage ?? 0.0).clamp(0.0, 1.0) : 0,
        onLoadSize: downloaded
            ? null
            : () => WordByWordFunction.getRemoteBookSizeBytes(book),
        transferredBytes: busy ? state.transferredBytes : null,
        totalBytes: busy ? state.totalBytes : null,
        onToggleActive: downloaded
            ? (value) => _toggleSelection(book, value)
            : null,
        onDownload: downloaded ? null : () => _downloadBook(book),
        onDelete: downloaded ? () => _deleteBook(book) : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        return ManagedResourcesCatalog(
          title: "كلمة بكلمة",
          description:
              "اختر مصدرًا واحدًا لترجمة الكلمات، مع تنزيله أو حذفه بسهولة ومن نفس الواجهة.",
          searchHint: "ابحث عن لغة أو مصدر كلمة بكلمة...",
          emptyMessage: "لا توجد نتائج مطابقة في موارد كلمة بكلمة.",
          deleteModeLabel: "تحديد للحذف",
          activateAllLabel: "تفعيل أول المحمّل",
          clearActiveLabel: "إلغاء التفعيل",
          deleteSelectionLabel: "حذف المحدد",
          activationBehavior: ResourceActivationBehavior.single,
          items: _buildItems(state),
          onRefresh: _loadData,
          onActivateAllDownloaded: _activateAllDownloaded,
          onClearActive: _clearSelection,
          onDeleteMany: _deleteMany,
        );
      },
    );
  }
}
