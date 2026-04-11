import "dart:async";

import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart" as theme;
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

enum ResourceLibraryFilter { all, active, downloaded, available }

enum ResourceActivationBehavior { multi, single, none }

class ManagedResourceItem {
  final String id;
  final String title;
  final String group;
  final String? subtitle;
  final List<String> badges;
  final bool isDownloaded;
  final bool isActive;
  final bool isBusy;
  final double progress;
  final int? orderIndex;
  final int? sizeBytes;
  final Future<int?> Function()? onLoadSize;
  final int? transferredBytes;
  final int? totalBytes;
  final Future<void> Function(bool value)? onToggleActive;
  final Future<void> Function()? onDownload;
  final Future<void> Function()? onDelete;

  const ManagedResourceItem({
    required this.id,
    required this.title,
    required this.group,
    this.subtitle,
    this.badges = const [],
    this.isDownloaded = false,
    this.isActive = false,
    this.isBusy = false,
    this.progress = 0,
    this.orderIndex,
    this.sizeBytes,
    this.onLoadSize,
    this.transferredBytes,
    this.totalBytes,
    this.onToggleActive,
    this.onDownload,
    this.onDelete,
  });
}

class ManagedResourcesCatalog extends StatefulWidget {
  final String title;
  final String description;
  final String searchHint;
  final String emptyMessage;
  final String deleteModeLabel;
  final String activateAllLabel;
  final String clearActiveLabel;
  final String deleteSelectionLabel;
  final ResourceActivationBehavior activationBehavior;
  final List<ManagedResourceItem> items;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onActivateAllDownloaded;
  final Future<void> Function()? onClearActive;
  final Future<void> Function(List<ManagedResourceItem> items)? onDeleteMany;
  final Future<void> Function(List<ManagedResourceItem> orderedItems)?
  onReorderDownloaded;

  const ManagedResourcesCatalog({
    super.key,
    required this.title,
    required this.description,
    required this.searchHint,
    required this.emptyMessage,
    required this.deleteModeLabel,
    required this.activateAllLabel,
    required this.clearActiveLabel,
    required this.deleteSelectionLabel,
    required this.activationBehavior,
    required this.items,
    this.onRefresh,
    this.onActivateAllDownloaded,
    this.onClearActive,
    this.onDeleteMany,
    this.onReorderDownloaded,
  });

  @override
  State<ManagedResourcesCatalog> createState() =>
      _ManagedResourcesCatalogState();
}

class _ManagedResourcesCatalogState extends State<ManagedResourcesCatalog> {
  final TextEditingController _searchController = TextEditingController();

  ResourceLibraryFilter _filter = ResourceLibraryFilter.all;
  bool _deleteMode = false;
  final Set<String> _markedForDeletion = <String>{};
  final Map<String, int?> _resolvedSizeById = <String, int?>{};
  final Set<String> _loadingSizeIds = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _reorderEnabled {
    if (widget.onReorderDownloaded == null) return false;
    if (_deleteMode) return false;
    if (_filter != ResourceLibraryFilter.downloaded) return false;
    final query = _searchController.text.trim();
    if (query.isNotEmpty) return false;
    if (_visibleItems.any((item) => item.isBusy)) return false;
    return true;
  }

  List<ManagedResourceItem> get _downloadedFlatList {
    final items = _visibleItems.where((item) => item.isDownloaded).toList();
    items.sort((a, b) {
      final ai = a.orderIndex;
      final bi = b.orderIndex;
      if (ai != null && bi != null) return ai.compareTo(bi);
      if (ai != null && bi == null) return -1;
      if (ai == null && bi != null) return 1;
      return a.title.compareTo(b.title);
    });
    return items;
  }

  List<ManagedResourceItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    return widget.items.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.group.toLowerCase().contains(query) ||
          (item.subtitle?.toLowerCase().contains(query) ?? false) ||
          item.badges.any((badge) => badge.toLowerCase().contains(query));
      if (!matchesQuery) return false;

      switch (_filter) {
        case ResourceLibraryFilter.all:
          return true;
        case ResourceLibraryFilter.active:
          return item.isActive;
        case ResourceLibraryFilter.downloaded:
          return item.isDownloaded;
        case ResourceLibraryFilter.available:
          return !item.isDownloaded;
      }
    }).toList();
  }

  Map<String, List<ManagedResourceItem>> get _groupedVisibleItems {
    final grouped = <String, List<ManagedResourceItem>>{};
    for (final item in _visibleItems) {
      grouped.putIfAbsent(item.group, () => <ManagedResourceItem>[]).add(item);
    }
    for (final items in grouped.values) {
      items.sort((a, b) {
        final busyCompare = (b.isBusy ? 1 : 0).compareTo(a.isBusy ? 1 : 0);
        if (busyCompare != 0) return busyCompare;
        final activeCompare = (b.isActive ? 1 : 0).compareTo(
          a.isActive ? 1 : 0,
        );
        if (activeCompare != 0) return activeCompare;
        final downloadedCompare = (b.isDownloaded ? 1 : 0).compareTo(
          a.isDownloaded ? 1 : 0,
        );
        if (downloadedCompare != 0) return downloadedCompare;
        if (a.isDownloaded && b.isDownloaded) {
          final ai = a.orderIndex;
          final bi = b.orderIndex;
          if (ai != null && bi != null) return ai.compareTo(bi);
          if (ai != null && bi == null) return -1;
          if (ai == null && bi != null) return 1;
        }
        return a.title.compareTo(b.title);
      });
    }
    final keys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == "Arabic") return -1;
        if (b == "Arabic") return 1;
        if (a == "English") return -1;
        if (b == "English") return 1;
        return a.compareTo(b);
      });
    return {for (final key in keys) key: grouped[key]!};
  }

  int get _downloadedCount =>
      widget.items.where((item) => item.isDownloaded).length;
  int get _activeCount => widget.items.where((item) => item.isActive).length;
  int get _availableCount =>
      widget.items.where((item) => !item.isDownloaded).length;

  int? _resolvedSizeBytes(ManagedResourceItem item) =>
      item.sizeBytes ?? _resolvedSizeById[item.id];

  void _ensureSizeLoaded(ManagedResourceItem item) {
    if (item.onLoadSize == null ||
        _loadingSizeIds.contains(item.id) ||
        _resolvedSizeById.containsKey(item.id)) {
      return;
    }

    _loadingSizeIds.add(item.id);
    unawaited(
      item.onLoadSize!()
          .then((value) {
            if (!mounted) return;
            setState(() {
              _resolvedSizeById[item.id] = value;
              _loadingSizeIds.remove(item.id);
            });
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() {
              _loadingSizeIds.remove(item.id);
            });
          }),
    );
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return "غير معروف";
    if (bytes == 0) return "0 B";
    const units = ["B", "KB", "MB", "GB"];
    double size = bytes.toDouble();
    int unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final fixed = unitIndex == 0 ? 0 : (size >= 10 ? 1 : 2);
    return "${size.toStringAsFixed(fixed)} ${units[unitIndex]}";
  }

  void _toggleDeleteMode() {
    setState(() {
      _deleteMode = !_deleteMode;
      _markedForDeletion.clear();
    });
  }

  void _toggleMarkedItem(String id) {
    setState(() {
      if (_markedForDeletion.contains(id)) {
        _markedForDeletion.remove(id);
      } else {
        _markedForDeletion.add(id);
      }
    });
  }

  Future<void> _deleteMarkedItems() async {
    if (widget.onDeleteMany == null || _markedForDeletion.isEmpty) return;

    final itemsToDelete = widget.items
        .where((item) => _markedForDeletion.contains(item.id))
        .toList();
    if (itemsToDelete.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف الموارد", textAlign: TextAlign.right),
        content: Text(
          "سيتم حذف ${itemsToDelete.length} مورد من الجهاز. هل تريد المتابعة؟",
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

    await widget.onDeleteMany!(itemsToDelete);
    if (!mounted) return;
    setState(() {
      _markedForDeletion.clear();
      _deleteMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedItems = _groupedVisibleItems;
    final hasDownloadedItems = _downloadedCount > 0;
    for (final item in _visibleItems.take(12)) {
      _ensureSizeLoaded(item);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh?.call();
        if (mounted) setState(() {});
      },
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 26.h, 16.w, 100.h),
        children: [
          _buildSearchField(isDark),
          SizedBox(height: 12.h),
          _buildFilters(themeState, isDark),
          SizedBox(height: 12.h),
          _buildQuickActions(themeState, isDark, hasDownloadedItems),
          if (_deleteMode && _markedForDeletion.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _buildDeleteBanner(themeState, isDark),
          ],
          SizedBox(height: 14.h),
          if (groupedItems.isEmpty)
            _buildEmptyState(isDark)
          else if (_reorderEnabled)
            _buildReorderList(themeState, isDark)
          else
            ...groupedItems.entries.map(
              (entry) => _buildGroupSection(
                entry.key,
                entry.value,
                themeState,
                isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReorderList(theme.ThemeState themeState, bool isDark) {
    final items = _downloadedFlatList;
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) async {
        final current = List<ManagedResourceItem>.from(items);
        if (newIndex > oldIndex) newIndex -= 1;
        final moved = current.removeAt(oldIndex);
        current.insert(newIndex, moved);
        await widget.onReorderDownloaded?.call(current);
        if (mounted) setState(() {});
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          key: ValueKey<String>("reorder-${item.id}"),
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildItemCard(item, themeState, isDark),
        );
      },
    );
  }

  Widget _buildHeroCard(theme.ThemeState themeState, bool isDark) {
    final cardColor = isDark ? const Color(0xFF171717) : Colors.white;
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : themeState.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.18)
                : themeState.primary.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            widget.description,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.7,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildCounterPill(
                label: "الكل",
                value: widget.items.length,
                themeState: themeState,
                isDark: isDark,
              ),
              _buildCounterPill(
                label: "المفعّل",
                value: _activeCount,
                themeState: themeState,
                isDark: isDark,
              ),
              _buildCounterPill(
                label: "المحمّل",
                value: _downloadedCount,
                themeState: themeState,
                isDark: isDark,
              ),
              _buildCounterPill(
                label: "المتاح",
                value: _availableCount,
                themeState: themeState,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterPill({
    required String label,
    required int value,
    required theme.ThemeState themeState,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: themeState.primary.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: themeState.primary,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: widget.searchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilters(theme.ThemeState themeState, bool isDark) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: ResourceLibraryFilter.values.map((filter) {
        final selected = _filter == filter;
        final label = switch (filter) {
          ResourceLibraryFilter.all => "الكل",
          ResourceLibraryFilter.active => "المفعّل",
          ResourceLibraryFilter.downloaded => "المحمّل",
          ResourceLibraryFilter.available => "غير المحمّل",
        };
        return ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(() => _filter = filter),
          selectedColor: themeState.primary.withValues(alpha: 0.16),
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white,
          labelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? themeState.primary : null,
          ),
          side: BorderSide(
            color: selected
                ? themeState.primary.withValues(alpha: 0.25)
                : (isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.06)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions(
    theme.ThemeState themeState,
    bool isDark,
    bool hasDownloadedItems,
  ) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.start,
      children: [
        if (widget.activationBehavior != ResourceActivationBehavior.none &&
            widget.onActivateAllDownloaded != null)
          _buildActionChip(
            label: widget.activateAllLabel,
            icon: Icons.done_all_rounded,
            themeState: themeState,
            isDark: isDark,
            onTap: () {
              widget.onActivateAllDownloaded!.call();
            },
          ),
        if (widget.activationBehavior != ResourceActivationBehavior.none &&
            widget.onClearActive != null)
          _buildActionChip(
            label: widget.clearActiveLabel,
            icon: Icons.layers_clear_rounded,
            themeState: themeState,
            isDark: isDark,
            onTap: () {
              widget.onClearActive!.call();
            },
          ),
        if (hasDownloadedItems && widget.onDeleteMany != null)
          _buildActionChip(
            label: _deleteMode ? "إلغاء الحذف" : widget.deleteModeLabel,
            icon: _deleteMode
                ? Icons.close_rounded
                : Icons.delete_outline_rounded,
            themeState: themeState,
            isDark: isDark,
            onTap: _toggleDeleteMode,
            destructive: _deleteMode,
          ),
      ],
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required theme.ThemeState themeState,
    required bool isDark,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? Colors.redAccent : themeState.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.14 : 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteBanner(theme.ThemeState themeState, bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "تم تحديد ${_markedForDeletion.length} مورد للحذف",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.red.shade900,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _deleteMarkedItems,
            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
            label: Text(
              widget.deleteSelectionLabel,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(
    String title,
    List<ManagedResourceItem> items,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h, top: 6.h),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: themeState.primary,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "${items.length}",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildItemCard(item, themeState, isDark)),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildItemCard(
    ManagedResourceItem item,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF171717) : Colors.white;
    final marked = _markedForDeletion.contains(item.id);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: InkWell(
        key: ValueKey<String>("card-${item.id}-${item.isDownloaded}-${item.isBusy}-${item.isActive}"),
        onTap: _deleteMode && item.isDownloaded
            ? () => _toggleMarkedItem(item.id)
            : null,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: marked
                ? Colors.redAccent.withValues(alpha: 0.45)
                : item.isActive
                ? themeState.primary.withValues(alpha: 0.25)
                : (isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05)),
            width: marked || item.isActive ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_deleteMode && item.isDownloaded)
                  Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 2.h),
                    child: Icon(
                      marked
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: marked ? Colors.redAccent : Colors.grey,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (!_deleteMode &&
                          (_resolvedSizeBytes(item) != null ||
                              _loadingSizeIds.contains(item.id))) ...[
                        SizedBox(height: 8.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _loadingSizeIds.contains(item.id)
                              ? Text(
                                  "جاري جلب حجم الملف...",
                                  key: ValueKey<String>("loading-${item.id}"),
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black45,
                                  ),
                                )
                              : Text(
                                  item.isDownloaded
                                      ? "الحجم على الجهاز: ${_formatBytes(_resolvedSizeBytes(item))}"
                                      : "الحجم التقريبي: ${_formatBytes(_resolvedSizeBytes(item))}",
                                  key: ValueKey<String>("size-${item.id}"),
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: themeState.primary,
                                  ),
                                ),
                        ),
                      ],
                      if ((item.subtitle ?? "").trim().isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          item.subtitle!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.5,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!_deleteMode)
                  _buildTrailingAction(item, themeState, isDark),
              ],
            ),
            if (item.badges.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: item.badges
                    .map(
                      (badge) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: themeState.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: themeState.primary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (!_deleteMode) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildStatusPill(item, themeState, isDark),
                  const Spacer(),
                  if (item.isDownloaded && item.onDelete != null)
                    IconButton(
                      onPressed: item.onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildTrailingAction(
    ManagedResourceItem item,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    if (item.isBusy) {
      return SizedBox(
        width: 60.w,
        child: Column(
          children: [
            SizedBox(
              width: 26.w,
              height: 26.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                value: item.progress > 0 ? item.progress.clamp(0.0, 1.0) : null,
                color: themeState.primary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "${(item.progress * 100).round()}%",
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: themeState.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (!item.isDownloaded) {
      return ElevatedButton(
        onPressed: item.onDownload,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: themeState.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          "تحميل",
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
        ),
      );
    }

    if (widget.activationBehavior == ResourceActivationBehavior.none ||
        item.onToggleActive == null) {
      return Icon(
        Icons.check_circle_rounded,
        color: themeState.primary,
        size: 22.sp,
      );
    }

    final activeColor = item.isActive ? themeState.primary : Colors.grey;
    return InkWell(
      onTap: () => item.onToggleActive!(!item.isActive),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.activationBehavior == ResourceActivationBehavior.single
                  ? (item.isActive
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded)
                  : (item.isActive
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded),
              size: 18.sp,
              color: activeColor,
            ),
            SizedBox(width: 6.w),
            Text(
              item.isActive ? "مفعل" : "تفعيل",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(
    ManagedResourceItem item,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    late final Color color;
    late final IconData icon;
    late final String label;

    if (item.isBusy) {
      color = themeState.primary;
      icon = Icons.downloading_rounded;
      label = "جاري التحميل";
    } else if (item.isDownloaded && item.isActive) {
      color = themeState.primary;
      icon = Icons.visibility_rounded;
      label = "مفعّل للعرض";
    } else if (item.isDownloaded) {
      color = isDark ? Colors.white70 : Colors.black54;
      icon = Icons.download_done_rounded;
      label = "محمّل";
    } else {
      color = isDark ? Colors.white54 : Colors.black45;
      icon = Icons.cloud_download_outlined;
      label = "";
    }

    return label.trim().isEmpty
        ? const SizedBox.shrink()
        : Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPanel(
    ManagedResourceItem item,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    final total = item.totalBytes;
    final transferred = item.transferredBytes;
    final remaining = total != null && transferred != null
        ? (total - transferred).clamp(0, total)
        : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: themeState.primary.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "جارٍ التحميل ${((item.progress).clamp(0.0, 1.0) * 100).round()}%",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (total != null && transferred != null) ...[
            SizedBox(height: 4.h),
            Text(
              "تم تحميل ${_formatBytes(transferred)} من ${_formatBytes(total)}",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            if (remaining != null)
              Text(
                "المتبقي ${_formatBytes(remaining)}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: themeState.primary,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(top: 28.h),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 30.sp,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          SizedBox(height: 10.h),
          Text(
            widget.emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.7,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
