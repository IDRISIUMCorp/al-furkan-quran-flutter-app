import "dart:async";

import "package:al_furkan/src/theme/app_colors.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_state.dart" as theme;
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter_animate/flutter_animate.dart";

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
    this.onDelete,
    this.onDownload,
  });
}

class ManagedResourcesCatalog extends StatefulWidget {
  final String title;
  final String description;
  final String emptyMessage;
  final ResourceActivationBehavior activationBehavior;
  final List<ManagedResourceItem> items;
  final Future<void> Function()? onRefresh;
  final Future<void> Function(List<ManagedResourceItem> orderedItems)?
      onReorderDownloaded;

  const ManagedResourcesCatalog({
    super.key,
    required this.title,
    required this.description,
    required this.emptyMessage,
    required this.activationBehavior,
    required this.items,
    this.onRefresh,
    this.onReorderDownloaded,
  });

  @override
  State<ManagedResourcesCatalog> createState() =>
      _ManagedResourcesCatalogState();
}

class _ManagedResourcesCatalogState extends State<ManagedResourcesCatalog> {
  final Map<String, int?> _resolvedSizeById = <String, int?>{};
  final Set<String> _loadingSizeIds = <String>{};

  List<ManagedResourceItem> get _sortedItems {
    final items = List<ManagedResourceItem>.from(widget.items);
    items.sort((a, b) {
      final busyCompare = (b.isBusy ? 1 : 0).compareTo(a.isBusy ? 1 : 0);
      if (busyCompare != 0) return busyCompare;
      final activeCompare =
          (b.isActive ? 1 : 0).compareTo(a.isActive ? 1 : 0);
      if (activeCompare != 0) return activeCompare;
      final downloadedCompare =
          (b.isDownloaded ? 1 : 0).compareTo(a.isDownloaded ? 1 : 0);
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
    return items;
  }

  Map<String, List<ManagedResourceItem>> get _groupedItems {
    final grouped = <String, List<ManagedResourceItem>>{};
    for (final item in _sortedItems) {
      grouped.putIfAbsent(item.group, () => <ManagedResourceItem>[]).add(item);
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
      item.onLoadSize!().then((value) {
        if (!mounted) return;
        setState(() {
          _resolvedSizeById[item.id] = value;
          _loadingSizeIds.remove(item.id);
        });
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _loadingSizeIds.remove(item.id));
      }),
    );
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return "";
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

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groupedItems = _groupedItems;

    for (final item in _sortedItems.take(12)) {
      _ensureSizeLoaded(item);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await widget.onRefresh?.call();
        if (mounted) setState(() {});
      },
      color: themeState.primary,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
        children: [
          if (groupedItems.isEmpty)
            _buildEmptyState(isDark)
                .animate()
                .fadeIn(duration: 400.ms)
          else
            ...groupedItems.entries.toList().asMap().entries.map(
                  (mapEntry) => _buildGroupSection(
                    mapEntry.value.key,
                    mapEntry.value.value,
                    themeState,
                    isDark,
                  ).animate().fadeIn(
                    delay: Duration(milliseconds: 60 + (mapEntry.key * 50)),
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  ).slideY(
                    begin: 0.04,
                    end: 0,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 32.sp,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 1.6,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSection(
    String title,
    List<ManagedResourceItem> items,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10.h, right: 2.w),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark
                        ? AppColors.darkTextMain
                        : AppColors.lightTextMain,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${items.length}",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _buildItemCard(item, themeState, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    ManagedResourceItem item,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderClr = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textMain = isDark ? AppColors.darkTextMain : AppColors.lightTextMain;
    final textSub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: item.isActive
            ? Border.all(
                color: primary.withValues(alpha: 0.40),
                width: 1.2,
              )
            : Border.all(
                color: borderClr.withValues(alpha: 0.5),
                width: 0.5,
              ),
        boxShadow: item.isActive
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          _buildCardAction(item, themeState, isDark),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: textMain,
                    height: 1.4,
                  ),
                ),
                if (item.isBusy) ...[
                  SizedBox(height: 6.h),
                  _buildProgressBar(item, themeState, isDark),
                ] else if (_resolvedSizeBytes(item) != null ||
                    _loadingSizeIds.contains(item.id)) ...[
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      if (item.isDownloaded && item.isActive)
                        Container(
                          margin: EdgeInsets.only(left: 6.w),
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "مفعّل",
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: primary,
                            ),
                          ),
                        ),
                      Text(
                        _loadingSizeIds.contains(item.id)
                            ? "جاري جلب الحجم..."
                            : _formatBytes(_resolvedSizeBytes(item)),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: textSub,
                        ),
                      ),
                    ],
                  ),
                ] else if (item.isDownloaded && item.isActive) ...[
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "مفعّل",
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.isDownloaded && !item.isBusy) ...[
            SizedBox(width: 6.w),
            if (item.onDelete != null)
              GestureDetector(
                onTap: item.onDelete,
                child: Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.redAccent.withValues(alpha: 0.08)
                        : Colors.redAccent.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 16.sp,
                    color: Colors.redAccent.withValues(alpha: 0.60),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardAction(
    ManagedResourceItem item,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    if (item.isBusy) {
      return SizedBox(
        width: 40.w,
        height: 40.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2.5,
              value: item.progress > 0 ? item.progress.clamp(0.0, 1.0) : null,
              color: primary,
              backgroundColor: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.3)
                  : AppColors.lightBorder.withValues(alpha: 0.4),
            ),
            Text(
              "${(item.progress * 100).round()}",
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
          ],
        ),
      );
    }

    if (!item.isDownloaded) {
      return GestureDetector(
        onTap: item.onDownload,
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: isDark ? 0.18 : 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.download_rounded,
            size: 18.sp,
            color: primary,
          ),
        ),
      );
    }

    if (widget.activationBehavior == ResourceActivationBehavior.none ||
        item.onToggleActive == null) {
      return Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.check_rounded,
          size: 18.sp,
          color: primary,
        ),
      );
    }

    final active = item.isActive;
    return GestureDetector(
      onTap: () => item.onToggleActive!(!item.isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: active
              ? primary.withValues(alpha: isDark ? 0.22 : 0.14)
              : isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border.all(
                  color: primary.withValues(alpha: 0.40), width: 1.2)
              : Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : AppColors.lightBorder.withValues(alpha: 0.4),
                  width: 0.5,
                ),
        ),
        child: Icon(
          widget.activationBehavior == ResourceActivationBehavior.single
              ? (active
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded)
              : (active
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded),
          size: 18.sp,
          color: active
              ? primary
              : isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildProgressBar(
    ManagedResourceItem item,
    theme.ThemeState themeState,
    bool isDark,
  ) {
    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final progress = item.progress.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress > 0 ? progress : null,
            minHeight: 3.h,
            backgroundColor: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.3)
                : AppColors.lightBorder.withValues(alpha: 0.4),
            color: primary,
          ),
        ),
        if (item.totalBytes != null && item.transferredBytes != null) ...[
          SizedBox(height: 3.h),
          Text(
            "${_formatBytes(item.transferredBytes)} / ${_formatBytes(item.totalBytes)}",
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
