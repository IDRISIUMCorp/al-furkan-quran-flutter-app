import "package:al_quran_v3/src/resources/quran_resources/models/translation_book_model.dart";
import "package:al_quran_v3/src/resources/quran_resources/translation_resources.dart";
import "package:al_quran_v3/src/screen/quran_resources/widgets/managed_resources_catalog.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_translation_function.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class TranslationResourcesView extends StatefulWidget {
  const TranslationResourcesView({super.key});

  @override
  State<TranslationResourcesView> createState() =>
      _TranslationResourcesViewState();
}

class _TranslationResourcesViewState extends State<TranslationResourcesView> {
  List<TranslationBookModel> _allBooks = [];
  List<TranslationBookModel> _selectedBooks = [];
  List<TranslationBookModel> _downloadedBooks = [];
  List<String> _downloadedOrderIds = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final selected =
        await QuranTranslationFunction.getTranslationSelections() ?? [];
    final downloaded = QuranTranslationFunction.getDownloadedTranslationBooks();
    final orderIds = QuranTranslationFunction.getDownloadedTranslationOrderIds();

    final allBooks = <TranslationBookModel>[];
    translationResources.forEach((_, books) {
      for (final book in books) {
        allBooks.add(TranslationBookModel.fromMap(book));
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

  Future<void> _saveDownloadedOrder(List<ManagedResourceItem> ordered) async {
    await QuranTranslationFunction.setDownloadedTranslationOrderIds(
      ordered.map((e) => e.id).toList(),
    );
    await _loadData();
  }

  bool _isSelected(TranslationBookModel book) {
    return _selectedBooks.any((item) => item.fullPath == book.fullPath);
  }

  bool _isDownloaded(TranslationBookModel book) {
    return _downloadedBooks.any((item) => item.fullPath == book.fullPath);
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

  String _typeLabel(TranslationResourcesType type) {
    switch (type) {
      case TranslationResourcesType.simple:
        return "ترجمة بسيطة";
      case TranslationResourcesType.withFootnoteTags:
        return "مع هوامش";
      case TranslationResourcesType.wordByWord:
        return "";
    }
  }

  Future<void> _toggleSelection(
    TranslationBookModel book,
    bool selected,
  ) async {
    if (selected) {
      await QuranTranslationFunction.setTranslationSelection(book);
    } else {
      await QuranTranslationFunction.removeTranslationSelection(book);
    }
    await _loadData();
  }

  Future<void> _activateAllDownloaded() async {
    await QuranTranslationFunction.replaceTranslationSelections(
      _downloadedBooks,
    );
    await _loadData();
  }

  Future<void> _clearActiveSelections() async {
    await QuranTranslationFunction.replaceTranslationSelections([]);
    await _loadData();
  }

  Future<void> _downloadBook(TranslationBookModel book) async {
    await QuranTranslationFunction.downloadResources(
      context: context,
      translationBook: book,
    );
    await QuranTranslationFunction.setTranslationSelection(book);
    await _loadData();
  }

  Future<void> _deleteBook(TranslationBookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف الترجمة", textAlign: TextAlign.right),
        content: Text(
          "سيتم حذف ترجمة ${book.name} من الجهاز.",
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
    await QuranTranslationFunction.removeFromListAlreadyDownloaded(book);
    await _loadData();
  }

  Future<void> _deleteMany(List<ManagedResourceItem> items) async {
    for (final item in items) {
      final book = _allBooks.firstWhere((entry) => entry.fullPath == item.id);
      await QuranTranslationFunction.removeFromListAlreadyDownloaded(book);
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
        subtitle: downloaded
            ? "مفعّلة داخل التطبيق ويمكن عرض أكثر من ترجمة معًا."
            : "نزّلها لتظهر مباشرة داخل المكتبة وشاشة الآيات.",
        badges: [
          if (_typeLabel(book.type).trim().isNotEmpty) _typeLabel(book.type),
          if (book.score > 0) "درجة ${book.score.round()}",
        ],
        isDownloaded: downloaded,
        isActive: _isSelected(book),
        isBusy: busy,
        progress: busy ? (state.percentage ?? 0.0).clamp(0.0, 1.0) : 0,
        orderIndex: downloaded ? orderMap[book.fullPath] : null,
        sizeBytes: downloaded
            ? QuranTranslationFunction.getDownloadedTranslationSizeBytes(
                book.fullPath,
              )
            : null,
        onLoadSize: downloaded
            ? null
            : () => QuranTranslationFunction.getRemoteBookSizeBytes(book),
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
          title: "إدارة الترجمات",
          description:
              "اختَر ترجمة واحدة أو أكثر، فعّلها فورًا، أو احذف ما لا تحتاجه من نفس الشاشة.",
          searchHint: "ابحث عن ترجمة أو لغة...",
          emptyMessage: "لا توجد ترجمات مطابقة للبحث أو للفلاتر الحالية.",
          deleteModeLabel: "تحديد للحذف",
          activateAllLabel: "تفعيل كل المحمّل",
          clearActiveLabel: "مسح المختار",
          deleteSelectionLabel: "حذف المحدد",
          activationBehavior: ResourceActivationBehavior.multi,
          items: _buildItems(state),
          onRefresh: _loadData,
          onActivateAllDownloaded: _activateAllDownloaded,
          onClearActive: _clearActiveSelections,
          onDeleteMany: _deleteMany,
          onReorderDownloaded: _saveDownloadedOrder,
        );
      },
    );
  }
}
