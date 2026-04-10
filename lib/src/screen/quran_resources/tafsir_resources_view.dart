import "package:al_quran_v3/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_quran_v3/src/resources/quran_resources/tafsir_info_with_score.dart";
import "package:al_quran_v3/src/screen/quran_resources/widgets/managed_resources_catalog.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:al_quran_v3/src/utils/quran_resources/default_offline_resources.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_tafsir_function.dart";
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await QuranTafsirFunction.init();
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    final selected = await QuranTafsirFunction.getTafsirSelections() ?? [];
    final downloaded = QuranTafsirFunction.getDownloadedTafsirBooks();

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
    });
  }

  bool _isSelected(TafsirBookModel book) {
    return _selectedBooks.any((item) => item.fullPath == book.fullPath);
  }

  bool _isDownloaded(TafsirBookModel book) {
    return _downloadedBooks.any((item) => item.fullPath == book.fullPath);
  }

  bool _isBookBusy(ResourcesProgressCubitState state, TafsirBookModel book) {
    if (state.onProcess != true) return false;
    if (state.activeResourceId != null) {
      return state.activeResourceId == book.fullPath;
    }
    final processName = state.processName ?? "";
    return processName.contains(book.name);
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
    return _allBooks.map((book) {
      final downloaded = _isDownloaded(book);
      final busy = _isBookBusy(state, book);
      return ManagedResourceItem(
        id: book.fullPath,
        title: book.name,
        group: book.language,
        subtitle: downloaded
            ? "مفعّل داخل التطبيق ويمكن المقارنة بين أكثر من تفسير معًا."
            : "نزّله ليظهر داخل المكتبة مع التنقل بين الآيات.",
        badges: [
          "${book.hasTafsir} آية",
          if (book.score > 0) "درجة ${book.score.round()}",
        ],
        isDownloaded: downloaded,
        isActive: _isSelected(book),
        isBusy: busy,
        progress: busy ? (state.percentage ?? 0.0).clamp(0.0, 1.0) : 0,
        onLoadSize: downloaded
            ? null
            : () => QuranTafsirFunction.getRemoteBookSizeBytes(book),
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
          title: "إدارة التفاسير",
          description:
              "فعّل أكثر من تفسير للمقارنة السريعة، أو نظّف التفاسير المحمّلة بحذف فردي أو جماعي.",
          searchHint: "ابحث عن تفسير أو لغة...",
          emptyMessage: "لا توجد تفاسير مطابقة للبحث أو للفلاتر الحالية.",
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
        );
      },
    );
  }
}
