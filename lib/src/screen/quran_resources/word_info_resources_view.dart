import "package:al_quran_v3/src/screen/quran_resources/widgets/managed_resources_catalog.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart";
import "package:al_quran_v3/src/utils/quran_resources/word_info_models.dart";
import "package:al_quran_v3/src/utils/quran_resources/word_info_repository.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class WordInfoResourcesView extends StatefulWidget {
  const WordInfoResourcesView({super.key});

  @override
  State<WordInfoResourcesView> createState() => _WordInfoResourcesViewState();
}

class _WordInfoResourcesViewState extends State<WordInfoResourcesView> {
  final WordInfoRepository _wordInfoRepo = WordInfoRepository();
  final Map<WordInfoKind, int?> _sizes = {};
  List<String> _downloadedOrderIds = const [];

  @override
  void initState() {
    super.initState();
    _loadSizes();
    _loadOrder();
  }

  void _loadOrder() {
    _downloadedOrderIds = _wordInfoRepo.getDownloadedOrderIds();
  }

  Future<void> _saveDownloadedOrder(List<ManagedResourceItem> ordered) async {
    await _wordInfoRepo.setDownloadedOrderIds(
      ordered.map((e) => e.id).toList(),
    );
    if (!mounted) return;
    setState(() {
      _downloadedOrderIds = _wordInfoRepo.getDownloadedOrderIds();
    });
  }

  Future<void> _loadSizes() async {
    for (final kind in WordInfoKind.values) {
      _sizes[kind] = await _wordInfoRepo.getRemoteZipSizeBytes(kind);
    }
    if (mounted) setState(() {});
  }

  String _label(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.eerab:
        return "الإعراب";
      case WordInfoKind.tasreef:
        return "الصرف";
      case WordInfoKind.recitations:
        return "القراءات";
    }
  }

  String _subtitle(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.eerab:
        return "تحليل نحوي مباشر للكلمة داخل الآية.";
      case WordInfoKind.tasreef:
        return "بيانات صرفية وبنية الكلمة.";
      case WordInfoKind.recitations:
        return "اختلافات القراءة والمادة المرتبطة بالكلمة.";
    }
  }

  bool _isBusy(ResourcesProgressCubitState state, WordInfoKind kind) {
    if (state.onProcess != true) return false;
    if (state.activeResourceId != null) {
      return state.activeResourceId == kind.name;
    }
    final processName = state.processName ?? "";
    return processName.contains(_label(kind));
  }

  Future<void> _downloadKind(WordInfoKind kind) async {
    final cubit = context.read<ResourcesProgressCubit>();
    final totalBytes = _sizes[kind];
    cubit.onProcess();
    cubit.updateProgress(
      0.0,
      _label(kind),
      activeResourceId: kind.name,
      transferredBytes: 0,
      totalBytes: totalBytes,
    );
    try {
      await _wordInfoRepo.downloadKind(
        kind: kind,
        onProgress: (progress) {
          final percentage = progress / 100;
          final transferred = totalBytes == null
              ? null
              : (totalBytes * percentage).round();
          cubit.updateProgress(
            percentage,
            _label(kind),
            activeResourceId: kind.name,
            transferredBytes: transferred,
            totalBytes: totalBytes,
          );
        },
      );
      cubit.updateProgress(
        1.0,
        _label(kind),
        activeResourceId: kind.name,
        transferredBytes: totalBytes ?? 1,
        totalBytes: totalBytes ?? 1,
      );
      await Future<void>.delayed(const Duration(milliseconds: 220));
      cubit.success();
      if (mounted) setState(() {});
    } catch (_) {
      cubit.failure("تعذر تحميل ${_label(kind)}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تعذر تحميل ${_label(kind)} الآن، حاول مرة أخرى."),
        ),
      );
    }
  }

  Future<void> _deleteKind(WordInfoKind kind) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف المورد", textAlign: TextAlign.right),
        content: Text(
          "سيتم حذف ${_label(kind)} من الجهاز.",
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
    await _wordInfoRepo.deleteKind(kind);
    if (mounted) setState(() {});
  }

  Future<void> _deleteMany(List<ManagedResourceItem> items) async {
    for (final item in items) {
      final kind = WordInfoKind.values.firstWhere(
        (entry) => entry.name == item.id,
      );
      await _wordInfoRepo.deleteKind(kind);
    }
    if (mounted) setState(() {});
  }

  List<ManagedResourceItem> _buildItems(ResourcesProgressCubitState state) {
    final orderMap = <String, int>{
      for (int i = 0; i < _downloadedOrderIds.length; i++)
        _downloadedOrderIds[i]: i,
    };
    return WordInfoKind.values.map((kind) {
      final downloaded = _wordInfoRepo.isKindDownloaded(kind);
      final busy = _isBusy(state, kind);
      return ManagedResourceItem(
        id: kind.name,
        title: _label(kind),
        group: "الموارد اللغوية",
        subtitle: _subtitle(kind),
        badges: const [],
        isDownloaded: downloaded,
        isBusy: busy,
        progress: busy ? (state.percentage ?? 0.0) : 0,
        orderIndex: downloaded ? orderMap[kind.name] : null,
        sizeBytes: downloaded ? null : _sizes[kind],
        onLoadSize: downloaded ? () => _wordInfoRepo.getLocalKindSizeBytes(kind) : null,
        transferredBytes: busy ? state.transferredBytes : null,
        totalBytes: busy ? state.totalBytes : null,
        onDownload: downloaded ? null : () => _downloadKind(kind),
        onDelete: downloaded ? () => _deleteKind(kind) : null,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        return ManagedResourcesCatalog(
          title: "معلومات الكلمات",
          description:
              "مصادر لغوية تضيف الإعراب والصرف والقراءات للكلمة المختارة، مع تنزيل وحذف مباشر.",
          searchHint: "ابحث عن نوع المورد...",
          emptyMessage: "لا توجد نتائج مطابقة في موارد معلومات الكلمات.",
          deleteModeLabel: "تحديد للحذف",
          activateAllLabel: "",
          clearActiveLabel: "",
          deleteSelectionLabel: "حذف المحدد",
          activationBehavior: ResourceActivationBehavior.none,
          items: _buildItems(state),
          onRefresh: () async => setState(() {}),
          onDeleteMany: _deleteMany,
          onReorderDownloaded: _saveDownloadedOrder,
        );
      },
    );
  }
}
