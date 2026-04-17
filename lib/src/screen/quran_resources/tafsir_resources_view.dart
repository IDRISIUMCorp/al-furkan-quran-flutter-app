import "package:al_furkan/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_furkan/src/resources/quran_resources/tafsir_info_with_score.dart";
import "package:al_furkan/src/screen/quran_resources/widgets/managed_resources_catalog.dart";
import "package:al_furkan/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_furkan/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:al_furkan/src/utils/quran_resources/default_offline_resources.dart";
import "package:al_furkan/src/utils/quran_resources/quran_tafsir_function.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class TafsirResourcesView extends StatefulWidget {
  const TafsirResourcesView({super.key});

  @override
  State<TafsirResourcesView> createState() => _TafsirResourcesViewState();
}

class _TafsirResourcesViewState extends State<TafsirResourcesView> {
  List<TafsirBookModel> _allBooks = [];
  List<TafsirBookModel> _selectedBooks = [];
  List<TafsirBookModel> _downloadedBooks = [];
  List<String> _downloadedOrderIds = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final selected = await QuranTafsirFunction.getTafsirSelections() ?? [];
    final downloaded = QuranTafsirFunction.getDownloadedTafsirBooks();
    final orderIds = QuranTafsirFunction.getDownloadedTafsirOrderIds();

    final allBooks = <TafsirBookModel>[];
    tafsirInformationWithScore.forEach((_, books) {
      for (final book in books) {
        final model = TafsirBookModel.fromMap(book);
        if (model.name.trim() == DefaultOfflineResources.defaultTafsirSaadi.name) {
          allBooks.add(DefaultOfflineResources.defaultTafsirSaadi);
        } else {
          allBooks.add(model);
        }
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
    await QuranTafsirFunction.setDownloadedTafsirOrderIds(
      ordered.map((e) => e.id).toList(),
    );
    await _loadData();
  }

  bool _isSelected(TafsirBookModel book) {
    return _selectedBooks.any((item) => item.fullPath == book.fullPath);
  }

  bool _isDownloaded(TafsirBookModel book) {
    return _downloadedBooks.any((item) => item.fullPath == book.fullPath);
  }

  bool _isBookBusy(ResourcesProgressCubitState state, TafsirBookModel book) {
    if (state.onProcess != true) return false;
    return state.progressMap.containsKey(book.fullPath);
  }

  Future<void> _toggleSelection(TafsirBookModel book, bool selected) async {
    if (selected) {
      await QuranTafsirFunction.setTafsirSelection(book);
    } else {
      await QuranTafsirFunction.removeTafsirSelection(book);
    }
    await _loadData();
  }

  Future<void> _activateAllDownloaded() async {
    await QuranTafsirFunction.replaceTafsirSelections(_downloadedBooks);
    await _loadData();
  }

  Future<void> _clearActiveSelections() async {
    await QuranTafsirFunction.replaceTafsirSelections([]);
    await _loadData();
  }

  Future<void> _downloadBook(TafsirBookModel book) async {
    await QuranTafsirFunction.downloadResources(
      context: context,
      tafsirBook: book,
    );
    await QuranTafsirFunction.setTafsirSelection(book);
    await _loadData();
  }

  Future<void> _deleteBook(TafsirBookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف التفسير", textAlign: TextAlign.right),
        content: Text(
          "سيتم حذف تفسير ${book.name} من الجهاز.",
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
    await QuranTafsirFunction.removeFromListAlreadyDownloaded(book);
    await _loadData();
  }

  Future<void> _deleteMany(List<ManagedResourceItem> items) async {
    for (final item in items) {
      final book = _allBooks.firstWhere((entry) => entry.fullPath == item.id);
      await QuranTafsirFunction.removeFromListAlreadyDownloaded(book);
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
        subtitle: null,
        badges: const [],
        isDownloaded: downloaded,
        isActive: _isSelected(book),
        isBusy: busy,
        progress: busy ? (state.progressMap[book.fullPath] ?? 0.0).clamp(0.0, 1.0) : 0,
        orderIndex: downloaded ? orderMap[book.fullPath] : null,
        sizeBytes: downloaded
            ? QuranTafsirFunction.getDownloadedTafsirSizeBytes(book.fullPath)
            : null,
        onLoadSize: downloaded
            ? null
            : () => QuranTafsirFunction.getRemoteBookSizeBytes(book),
        transferredBytes: busy ? state.transferredBytesMap[book.fullPath] : null,
        totalBytes: busy ? state.totalBytesMap[book.fullPath] : null,
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
          title: "إدارة التفاسير",
          description:
              "فعّل أكثر من تفسير للمقارنة السريعة.",
          searchHint: "",
          emptyMessage: "لا توجد تفاسير مطابقة.",
          deleteModeLabel: "تحديد للحذف",
          activateAllLabel: "تفعيل الكل",
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
