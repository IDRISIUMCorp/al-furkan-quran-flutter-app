import "package:al_furkan/src/resources/quran_resources/models/transliteration_book_model.dart";
import "package:al_furkan/src/resources/quran_resources/transliteration_resources.dart";
import "package:al_furkan/src/screen/quran_resources/widgets/managed_resources_catalog.dart";
import "package:al_furkan/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_furkan/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:al_furkan/src/utils/quran_resources/quran_transliteration_function.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class TransliterationResourcesView extends StatefulWidget {
  const TransliterationResourcesView({super.key});

  @override
  State<TransliterationResourcesView> createState() =>
      _TransliterationResourcesViewState();
}

class _TransliterationResourcesViewState
    extends State<TransliterationResourcesView> {
  List<TransliterationBookModel> _allBooks = [];
  List<TransliterationBookModel> _selectedBooks = [];
  List<TransliterationBookModel> _downloadedBooks = [];
  List<String> _downloadedOrderIds = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final selected =
        await QuranTransliterationFunction.getTransliterationSelections() ??
        [];
    final downloaded =
        QuranTransliterationFunction.getDownloadedTransliterationBooks();
    final orderIds =
        QuranTransliterationFunction.getDownloadedTransliterationOrderIds();

    final allBooks = <TransliterationBookModel>[];
    transliterationResources.forEach((_, books) {
      for (final book in books) {
        allBooks.add(TransliterationBookModel.fromMap(book));
      }
    });

    if (!mounted) return;
    setState(() {
      _allBooks = allBooks;
      _selectedBooks = selected;
      _downloadedBooks = downloaded;
      _downloadedOrderIds = orderIds;
    });
  }

  Future<void> _saveDownloadedOrder(
    List<ManagedResourceItem> ordered,
  ) async {
    await QuranTransliterationFunction.setDownloadedTransliterationOrderIds(
      ordered.map((e) => e.id).toList(),
    );
    await _loadData();
  }

  bool _isSelected(TransliterationBookModel book) {
    return _selectedBooks.any((item) => item.fullPath == book.fullPath);
  }

  bool _isDownloaded(TransliterationBookModel book) {
    return _downloadedBooks.any((item) => item.fullPath == book.fullPath);
  }

  bool _isBookBusy(
    ResourcesProgressCubitState state,
    TransliterationBookModel book,
  ) {
    if (state.onProcess != true) return false;
    return state.progressMap.containsKey(book.fullPath);
  }

  Future<void> _toggleSelection(
    TransliterationBookModel book,
    bool selected,
  ) async {
    if (selected) {
      await QuranTransliterationFunction.setTransliterationSelection(book);
    } else {
      await QuranTransliterationFunction.removeTransliterationSelection(book);
    }
    await _loadData();
  }

  Future<void> _activateAllDownloaded() async {
    await QuranTransliterationFunction.replaceTransliterationSelections(
      _downloadedBooks,
    );
    await _loadData();
  }

  Future<void> _clearActiveSelections() async {
    await QuranTransliterationFunction.replaceTransliterationSelections([]);
    await _loadData();
  }

  Future<void> _downloadBook(TransliterationBookModel book) async {
    await QuranTransliterationFunction.downloadResources(
      context: context,
      transliterationBook: book,
    );
    await QuranTransliterationFunction.setTransliterationSelection(book);
    await _loadData();
  }

  Future<void> _deleteBook(TransliterationBookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
        title: const Text("حذف المورد", textAlign: TextAlign.right),
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
    await QuranTransliterationFunction.removeFromListAlreadyDownloaded(book);
    await _loadData();
  }

  Future<void> _deleteMany(List<ManagedResourceItem> items) async {
    for (final item in items) {
      final book =
          _allBooks.firstWhere((entry) => entry.fullPath == item.id);
      await QuranTransliterationFunction.removeFromListAlreadyDownloaded(book);
    }
    await _loadData();
  }

  List<ManagedResourceItem> _buildItems(ResourcesProgressCubitState state) {
    final orderMap = <String, int>{
      for (int i = 0; i < _downloadedOrderIds.length; i++)
        _downloadedOrderIds[i]: i,
    };
    return _allBooks.map((book) {
      final downloaded = _isDownloaded(book);
      final busy = _isBookBusy(state, book);
      return ManagedResourceItem(
        id: book.fullPath,
        title: book.name,
        group: book.language,
        subtitle: book.description.isNotEmpty ? book.description : null,
        badges: downloaded ? [] : ["${book.totalEntries} مدخل"],
        isDownloaded: downloaded,
        isActive: _isSelected(book),
        isBusy: busy,
        progress: busy
            ? (state.progressMap[book.fullPath] ?? 0.0).clamp(0.0, 1.0)
            : 0,
        orderIndex: downloaded ? orderMap[book.fullPath] : null,
        sizeBytes: downloaded
            ? QuranTransliterationFunction
                .getDownloadedTransliterationSizeBytes(book.fullPath)
            : null,
        onLoadSize: downloaded
            ? null
            : () => QuranTransliterationFunction.getRemoteBookSizeBytes(book),
        transferredBytes:
            busy ? state.transferredBytesMap[book.fullPath] : null,
        totalBytes: busy ? state.totalBytesMap[book.fullPath] : null,
        onToggleActive:
            downloaded ? (value) => _toggleSelection(book, value) : null,
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
          title: "إدارة النطق اللاتيني",
          description:
              "نطق الآيات والكلمات بالحروف اللاتينية — مفيد لغير الناطقين بالعربية.",
          emptyMessage: "لا توجد موارد نطق.",
          activationBehavior: ResourceActivationBehavior.multi,
          items: _buildItems(state),
          onRefresh: _loadData,
          onReorderDownloaded: _saveDownloadedOrder,
        );
      },
    );
  }
}
