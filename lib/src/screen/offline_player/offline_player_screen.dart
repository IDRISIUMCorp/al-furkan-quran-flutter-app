import "package:al_furkan/src/core/audio/cubit/offline_download_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/core/audio/player/audio_player_manager.dart";
import "package:al_furkan/src/core/audio/services/offline_audio_service.dart";
import "package:al_furkan/src/resources/quran_resources/quran_ayah_count.dart";
import "package:al_furkan/src/utils/reciter_name_translations.dart";
import "package:al_furkan/src/widget/audio/reciter_picker_bottom_sheet.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf;

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Offline Player Screen — Full Music Player Experience
// ═══════════════════════════════════════════════════════════════════

class OfflinePlayerScreen extends StatefulWidget {
  const OfflinePlayerScreen({super.key});

  @override
  State<OfflinePlayerScreen> createState() => _OfflinePlayerScreenState();
}

class _OfflinePlayerScreenState extends State<OfflinePlayerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ─── Design Tokens ────────────────────────────────────────
  Color _bg(bool d) => d ? const Color(0xFF1C1C1E) : const Color(0xFFFAF6EF);
  Color _card(bool d) => d ? const Color(0xFF2C2C2E) : Colors.white;
  Color _text(bool d) => d ? const Color(0xFFF5F5F7) : const Color(0xFF1C1C1E);
  Color _sub(bool d) => d ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
  Color _border(bool d) =>
      d ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfflineDownloadCubit>().refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = context.watch<ThemeCubit>().state.primary;

    return Scaffold(
      backgroundColor: _bg(isDark),
      appBar: AppBar(
        backgroundColor: _bg(isDark),
        centerTitle: true,
        title: Text(
          "المشغّل",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: _text(isDark),
            letterSpacing: -0.4,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: accent,
          unselectedLabelColor: _sub(isDark),
          indicatorColor: accent,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: "المحمّل"),
            Tab(text: "حمّل سورة"),
            Tab(text: "إدارة المساحة"),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: _sub(isDark), size: 22),
            onPressed: () => _showInfoDialog(isDark, accent),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDownloadedTab(isDark, accent),
          _buildDownloadTab(isDark, accent),
          _buildStorageTab(isDark, accent),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TAB 1 — Downloaded Content (Music Player View)
  // ═══════════════════════════════════════════════════════════
  Widget _buildDownloadedTab(bool isDark, Color accent) {
    return BlocBuilder<OfflineDownloadCubit, OfflineDownloadState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator(color: accent, strokeWidth: 2));
        }

        if (state.downloadedSurahs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_download_outlined, size: 64, color: _sub(isDark).withValues(alpha: 0.3)),
                const Gap(16),
                Text(
                  "لا توجد تلاوات محمّلة",
                  style: TextStyle(color: _sub(isDark), fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Gap(8),
                Text(
                  "حمّل سور من تاب \"حمّل سورة\" للاستماع أوفلاين",
                  style: TextStyle(color: _sub(isDark).withValues(alpha: 0.7), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                GestureDetector(
                  onTap: () => _tabController.animateTo(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      "حمّل الآن",
                      style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final byReciter = state.byReciter;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: byReciter.length,
            itemBuilder: (context, index) {
              final reciterKey = byReciter.keys.elementAt(index);
              final surahs = byReciter[reciterKey]!;
              final reciter = surahs.first.reciter;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Reciter Header ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                    child: Row(
                      children: [
                        _reciterAvatar(reciter, 36, accent),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reciterKey,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: _text(isDark),
                                ),
                              ),
                              Text(
                                "${surahs.length} سورة · ${OfflineAudioService.formatBytes(surahs.fold(0, (sum, s) => sum + s.sizeBytes))}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _sub(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Delete all for this reciter
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                          onPressed: () => _confirmDeleteReciter(reciter, isDark),
                        ),
                      ],
                    ),
                  ),
                  // ─── Surah Cards ───
                  ...surahs.map((info) => _surahCard(info, isDark, accent)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _surahCard(DownloadedSurahInfo info, bool isDark, Color accent) {
    final surahName = qcf.getSurahNameArabic(info.surahNumber);
    final ayahCount = quranAyahCount[info.surahNumber - 1];
    final isFullyDownloaded = info.ayahCount >= ayahCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: isFullyDownloaded ? () => _playSurahOffline(info) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border(isDark)),
          ),
          child: Row(
            children: [
              // Play icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFullyDownloaded
                      ? accent.withValues(alpha: 0.12)
                      : _sub(isDark).withValues(alpha: 0.08),
                ),
                child: Icon(
                  isFullyDownloaded ? Icons.play_arrow_rounded : Icons.cloud_off_rounded,
                  color: isFullyDownloaded ? accent : _sub(isDark),
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _text(isDark),
                      ),
                    ),
                    const Gap(2),
                    Text(
                      isFullyDownloaded
                          ? "${info.ayahCount} آية · ${OfflineAudioService.formatBytes(info.sizeBytes)}"
                          : "غير مكتمل (${info.ayahCount}/$ayahCount)",
                      style: TextStyle(
                        fontSize: 11,
                        color: isFullyDownloaded ? _sub(isDark) : Colors.orange.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete
              IconButton(
                icon: Icon(Icons.close_rounded, color: _sub(isDark).withValues(alpha: 0.5), size: 18),
                onPressed: () => _confirmDeleteSurah(info, isDark),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TAB 2 — Download New Surahs
  // ═══════════════════════════════════════════════════════════
  Widget _buildDownloadTab(bool isDark, Color accent) {
    final currentReciter = context.watch<SegmentedQuranReciterCubit>().state;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocBuilder<OfflineDownloadCubit, OfflineDownloadState>(
      builder: (context, state) {
        return Column(
          children: [
            // ─── Reciter Selector ───
            GestureDetector(
              onTap: () => _openReciterPicker(),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    _reciterAvatar(currentReciter, 42, accent),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "القارئ الحالي",
                            style: TextStyle(fontSize: 11, color: _sub(isDark), fontWeight: FontWeight.w500),
                          ),
                          const Gap(2),
                          Text(
                            ReciterNameTranslations.getArabicName(currentReciter.name, locale),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: _text(isDark),
                            ),
                          ),
                          if (currentReciter.style != null)
                            Text(
                              ReciterNameTranslations.getArabicStyle(currentReciter.style!, locale),
                              style: TextStyle(fontSize: 12, color: _sub(isDark)),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.swap_horiz_rounded, color: accent, size: 22),
                  ],
                ),
              ),
            ),
            const Gap(8),

            // ─── Download All Button ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => _downloadAllSurahs(currentReciter),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accent.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_for_offline_rounded, color: accent, size: 20),
                      const Gap(8),
                      Text(
                        "حمّل كل السور",
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Gap(8),

            // ─── Surah Grid ───
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 114,
                  itemBuilder: (context, index) {
                    final surahNum = index + 1;
                    final surahName = qcf.getSurahNameArabic(surahNum);
                    final isDownloaded = state.isSurahDownloaded(currentReciter, surahNum);
                    final progress = state.getProgress(currentReciter, surahNum);
                    final isDownloading = progress?.isDownloading ?? false;

                    return GestureDetector(
                      onTap: isDownloading
                          ? null
                          : () => _toggleDownload(currentReciter, surahNum, isDownloaded),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDownloaded
                              ? accent.withValues(alpha: 0.08)
                              : _card(isDark),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDownloaded
                                ? accent.withValues(alpha: 0.3)
                                : _border(isDark),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Content
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    surahNum.toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _sub(isDark),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Gap(4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      surahName,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: _text(isDark),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Gap(6),
                                  Icon(
                                    isDownloaded
                                        ? Icons.check_circle_rounded
                                        : isDownloading
                                            ? Icons.downloading_rounded
                                            : Icons.download_rounded,
                                    size: 20,
                                    color: isDownloaded
                                        ? accent
                                        : isDownloading
                                            ? Colors.orange.shade400
                                            : _sub(isDark).withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                            ),
                            // Progress overlay
                            if (isDownloading && progress != null)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: accent.withValues(alpha: 0.06),
                                  ),
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                    child: Text(
                                      "${(progress.progress * 100).toInt()}%",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TAB 3 — Storage Management
  // ═══════════════════════════════════════════════════════════
  Widget _buildStorageTab(bool isDark, Color accent) {
    return BlocBuilder<OfflineDownloadCubit, OfflineDownloadState>(
      builder: (context, state) {
        final totalSize = state.totalSizeFormatted;
        final surahCount = state.downloadedSurahs.length;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              // ─── Storage Overview Card ───
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _card(isDark),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border(isDark)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.storage_rounded, size: 40, color: accent.withValues(alpha: 0.7)),
                    const Gap(12),
                    Text(
                      totalSize,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        color: _text(isDark),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      "إجمالي المساحة المستخدمة",
                      style: TextStyle(fontSize: 13, color: _sub(isDark)),
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem("سور محمّلة", "$surahCount", isDark),
                        Container(width: 1, height: 30, color: _border(isDark)),
                        _statItem(
                          "قراء",
                          "${state.byReciter.length}",
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(20),

              // ─── Per-Reciter Breakdown ───
              if (state.byReciter.isNotEmpty) ...[
                Text(
                  "تفاصيل القراء",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _text(isDark),
                  ),
                ),
                const Gap(10),
                ...state.byReciter.entries.map((entry) {
                  final reciter = entry.value.first.reciter;
                  final totalBytes = entry.value.fold(0, (sum, s) => sum + s.sizeBytes);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _card(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border(isDark)),
                    ),
                    child: Row(
                      children: [
                        _reciterAvatar(reciter, 36, accent),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _text(isDark)),
                              ),
                              Text(
                                "${entry.value.length} سورة · ${OfflineAudioService.formatBytes(totalBytes)}",
                                style: TextStyle(fontSize: 11, color: _sub(isDark)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_forever_rounded, color: Colors.red.shade400, size: 20),
                          onPressed: () => _confirmDeleteReciter(reciter, isDark),
                        ),
                      ],
                    ),
                  );
                }),
                const Gap(20),
              ],

              // ─── Danger Zone ───
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: isDark ? 0.08 : 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 20),
                        const Gap(8),
                        Text(
                          "منطقة الخطر",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.delete_forever_rounded, size: 18, color: Colors.red.shade400),
                        label: Text(
                          "حذف جميع التلاوات المحمّلة",
                          style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _confirmDeleteAll(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Shared Components ──────────────────────────────────────

  Widget _reciterAvatar(ReciterInfoModel r, double size, Color accent) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.2), width: 1.5),
      ),
      child: ClipOval(
        child: r.img != null
            ? CachedNetworkImage(
                imageUrl: r.img!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _defAvatar(size, accent),
                placeholder: (_, __) => _defAvatar(size, accent),
              )
            : _defAvatar(size, accent),
      ),
    );
  }

  Widget _defAvatar(double s, Color accent) => Container(
        color: accent.withValues(alpha: 0.1),
        child: Icon(Icons.person_rounded, size: s * 0.5, color: accent),
      );

  Widget _statItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: _text(isDark)),
        ),
        const Gap(2),
        Text(label, style: TextStyle(fontSize: 11, color: _sub(isDark))),
      ],
    );
  }

  // ─── Actions ────────────────────────────────────────────────

  void _toggleDownload(ReciterInfoModel reciter, int surahNum, bool isDownloaded) {
    if (isDownloaded) {
      _confirmDeleteSurahByNum(reciter, surahNum);
    } else {
      HapticFeedback.lightImpact();
      context.read<OfflineDownloadCubit>().downloadSurah(
            reciter: reciter,
            surahNumber: surahNum,
          );
    }
  }

  void _downloadAllSurahs(ReciterInfoModel reciter) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        
        title: Text("تحميل كل السور؟", style: TextStyle(color: _text(isDark), fontWeight: FontWeight.w800)),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            "سيتم تحميل 114 سورة للقارئ ${reciter.name}. قد يستغرق ذلك وقتاً ومساحة كبيرة.",
            style: TextStyle(color: _sub(isDark)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: _sub(isDark)))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final surahNumbers = List.generate(114, (i) => i + 1);
              context.read<OfflineDownloadCubit>().downloadSurahs(
                    reciter: reciter,
                    surahNumbers: surahNumbers,
                  );
            },
            child: Text("حمّل الكل", style: TextStyle(color: context.read<ThemeCubit>().state.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _playSurahOffline(DownloadedSurahInfo info) async {
    HapticFeedback.lightImpact();
    final surahNum = info.surahNumber;
    final totalAyahs = quranAyahCount[surahNum - 1];
    final startKey = "$surahNum:1";
    final endKey = "$surahNum:$totalAyahs";
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = context.read<ThemeCubit>().state.primary;

    // Ask user: navigate to surah or play from current page
    final shouldNavigate = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text("تشغيل السورة", style: TextStyle(color: _text(isDark), fontWeight: FontWeight.w800)),
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Text("عايز تروح للسورة وتشغلها من أولها، ولا تشغلها من مكانك الحالي؟", style: TextStyle(color: _sub(isDark))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("شغّل هنا", style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("روح للسورة", style: TextStyle(color: _text(isDark))),
          ),
        ],
      ),
    );

    if (shouldNavigate == null) return;

    // Switch to this reciter first
    await context.read<SegmentedQuranReciterCubit>().changeReciter(
          context,
          info.reciter,
        );

    // Play the full surah — AudioPlayerManager auto-detects local files
    await AudioPlayerManager.playMultipleAyahAsPlaylist(
      startAyahKey: startKey,
      endAyahKey: endKey,
      reciterInfoModel: info.reciter,
      isInsideQuran: true,
      instantPlay: true,
    );

    // Update ayah key cubit
    if (mounted) {
      context.read<AyahKeyCubit>().changeCurrentAyahKey(startKey);
      if (shouldNavigate) {
        // Navigate back to mushaf to see highlighting
        Navigator.pop(context);
      }
    }
  }

  void _openReciterPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InlineReciterPicker(),
    );
  }

  void _confirmDeleteSurah(DownloadedSurahInfo info, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        
        title: Text("حذف السورة؟", style: TextStyle(color: _text(isDark))),
        content: Text(
          "سيتم حذف سورة ${qcf.getSurahNameArabic(info.surahNumber)} للقارئ ${info.reciterLabel} من التخزين",
          style: TextStyle(color: _sub(isDark)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: _sub(isDark)))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OfflineDownloadCubit>().deleteSurah(
                    reciter: info.reciter,
                    surahNumber: info.surahNumber,
                  );
            },
            child: Text("حذف", style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSurahByNum(ReciterInfoModel reciter, int surahNum) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        
        title: Text("حذف السورة؟", style: TextStyle(color: _text(isDark))),
        content: Text(
          "سيتم حذف سورة ${qcf.getSurahNameArabic(surahNum)} من التخزين",
          style: TextStyle(color: _sub(isDark)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: _sub(isDark)))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OfflineDownloadCubit>().deleteSurah(
                    reciter: reciter,
                    surahNumber: surahNum,
                  );
            },
            child: Text("حذف", style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReciter(ReciterInfoModel reciter, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        
        title: Text("حذف جميع سور القارئ؟", style: TextStyle(color: _text(isDark))),
        content: Text(
          "سيتم حذف جميع السور المحمّلة للقارئ ${reciter.name}",
          style: TextStyle(color: _sub(isDark)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: _sub(isDark)))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OfflineDownloadCubit>().deleteReciter(reciter);
            },
            child: Text("حذف الكل", style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        
        title: Text("حذف جميع التلاوات؟", style: TextStyle(color: _text(isDark), fontWeight: FontWeight.w800)),
        content: Text(
          "سيتم حذف جميع التلاوات المحمّلة من التخزين. لا يمكن التراجع عن هذا الإجراء.",
          style: TextStyle(color: _sub(isDark)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: _sub(isDark)))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OfflineDownloadCubit>().deleteAll();
            },
            child: Text("حذف الكل", style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(bool isDark, Color accent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: accent),
            const Gap(8),
            Text("المشغّل الأوفلاين", style: TextStyle(color: _text(isDark), fontWeight: FontWeight.w800)),
          ],
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.download_rounded, "حمّل سور أي قارئ للاستماع بدون إنترنت", isDark),
              const Gap(8),
              _infoRow(Icons.play_circle_rounded, "شغّل السور المحمّلة مباشرة من التخزين", isDark),
              const Gap(8),
              _infoRow(Icons.delete_outline_rounded, "تحكّم في المساحة واحذف اللي مش محتاجه", isDark),
              const Gap(8),
              _infoRow(Icons.graphic_eq_rounded, "التظليل كلمة بكلمة يعمل أوتوماتك لو متاح", isDark),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("فهمت", style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _sub(isDark)),
        const Gap(8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13, color: _text(isDark), fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Inline Reciter Picker (compact version for download tab)
// ═══════════════════════════════════════════════════════════════════
class _InlineReciterPicker extends StatelessWidget {
  const _InlineReciterPicker();

  @override
  Widget build(BuildContext context) {
    return const ReciterPickerBottomSheet();
  }
}
