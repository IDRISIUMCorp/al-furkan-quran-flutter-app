import 'dart:ui';
import 'package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart';
import 'package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart';
import 'package:al_furkan/src/core/audio/model/recitation_info_model.dart';
import 'package:al_furkan/src/core/audio/player/audio_player_manager.dart';
import 'package:al_furkan/src/core/audio/services/audio_playback_service_access.dart';
import 'package:al_furkan/src/utils/get_segments_supported_reciters.dart';
import 'package:al_furkan/src/utils/reciter_name_translations.dart';
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gap/gap.dart';

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Reciter Picker — Quiet Luxury / Organic Minimalism
// ═══════════════════════════════════════════════════════════════════

/// Custom cache manager for reciter images — keeps files for 30 days
class ReciterImageCacheManager extends CacheManager {
  static const key = 'reciter_img_cache';

  static final ReciterImageCacheManager _instance = ReciterImageCacheManager._();
  factory ReciterImageCacheManager() => _instance;
  ReciterImageCacheManager._() : super(Config(
    key,
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 200,
    repo: JsonCacheInfoRepository(),
    fileService: HttpFileService(),
  ));
}

class ReciterPickerBottomSheet extends StatefulWidget {
  const ReciterPickerBottomSheet({super.key});

  @override
  State<ReciterPickerBottomSheet> createState() =>
      _ReciterPickerBottomSheetState();
}

class _ReciterPickerBottomSheetState extends State<ReciterPickerBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<ReciterInfoModel> _all;
  List<ReciterInfoModel> _filtered = [];
  int _categoryIdx = 0;
  late AnimationController _animCtrl;

  static const _categories = ['الكل', 'مرتل', 'مجود', 'ورش', 'معلم'];
  static const _categoryKeys = ['', 'murattal', 'mujawwad', 'warsh', 'muallim'];

  // ─── Design Tokens (Unified Beige Palette) ───
  Color _bg(bool d) => d ? AppColors.darkSurface : AppColors.ayaAudioPlayerBg;
  Color _surface(bool d) => d ? AppColors.darkCard : AppColors.ayaCard;
  Color _surfaceHigh(bool d) => d ? const Color(0xFF3A3A3C) : AppColors.ayaSurface;
  Color _text(bool d) => d ? const Color(0xFFF5F5F7) : AppColors.ayaTextMain;
  Color _sub(bool d) => d ? const Color(0xFF98989D) : AppColors.ayaTextMuted;
  Color _border(bool d) =>
      d ? Colors.white.withValues(alpha: 0.08) : AppColors.ayaBorder.withValues(alpha: 0.6);

  @override
  void initState() {
    super.initState();
    _all = getSegmentsSupportedReciters();
    _filtered = _all;
    _searchCtrl.addListener(_applyFilter);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    final locale = Localizations.localeOf(context).languageCode;
    final catKey = _categoryKeys[_categoryIdx];

    setState(() {
      _filtered = _all.where((r) {
        final arName =
            ReciterNameTranslations.getArabicName(r.name, locale).toLowerCase();
        final enName = r.name.toLowerCase();
        if (q.isNotEmpty && !arName.contains(q) && !enName.contains(q)) {
          return false;
        }
        if (catKey.isEmpty) return true;
        final style = (r.style ?? '').toLowerCase();
        if (catKey == 'muallim') {
          return style.contains('muallim') || style.contains('teacher');
        }
        return style.contains(catKey);
      }).toList();
    });
  }

  Future<void> _selectReciter(ReciterInfoModel r) async {
    final wasPlaying = audioPlaybackService.isPlaying;
    final hasSource = audioPlaybackService.hasSource;
    final ayahState = context.read<AyahKeyCubit>().state;
    final currentAyah = ayahState.current;
    final isPlayList = ayahState.ayahList.length > 1;
    final startAyah = ayahState.start;
    final endAyah = ayahState.end;
    final currentIndex = ayahState.ayahList.indexOf(currentAyah);

    final success = await context
        .read<SegmentedQuranReciterCubit>()
        .changeReciter(context, r);

    if (success && hasSource && currentAyah.isNotEmpty) {
      await AudioPlayerManager.audioPlayer.stop();
      await AudioPlayerManager.audioPlayer.clearAudioSources();

      final newReciter = context.read<SegmentedQuranReciterCubit>().state;
      final shouldPlay = wasPlaying;

      if (isPlayList && startAyah != endAyah) {
        await AudioPlayerManager.playMultipleAyahAsPlaylist(
          startAyahKey: startAyah,
          endAyahKey: endAyah,
          reciterInfoModel: newReciter,
          isInsideQuran: true,
          initialIndex: currentIndex >= 0 ? currentIndex : 0,
          instantPlay: shouldPlay,
        );
      } else {
        await AudioPlayerManager.playSingleAyah(
          ayahKey: currentAyah,
          reciterInfoModel: newReciter,
          isInsideQuran: true,
          instantPlay: shouldPlay,
        );
      }
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = context.read<ThemeCubit>().state.primary;
    final locale = Localizations.localeOf(context).languageCode;
    final currentReciter = context.watch<SegmentedQuranReciterCubit>().state;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          color: _bg(isDark).withValues(alpha: isDark ? 0.94 : 0.97),
          child: Column(
            children: [
              // ─── Handle ───
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _sub(isDark).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ─── Header ───
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.record_voice_over_rounded,
                          color: accent, size: 20),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "اختيار القارئ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _text(isDark),
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            "${_filtered.length} قارئ",
                            style: TextStyle(
                              fontSize: 12,
                              color: _sub(isDark),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(14),

              // ─── Search ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: _surfaceHigh(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border(isDark)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: _text(isDark), fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "ابحث عن قارئ...",
                      hintStyle: TextStyle(color: _sub(isDark), fontSize: 14),
                      prefixIcon: Icon(Icons.search_rounded, color: _sub(isDark), size: 20),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                _applyFilter();
                              },
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: _sub(isDark)),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),
              const Gap(12),

              // ─── Categories ───
              SizedBox(
                height: 38,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const Gap(8),
                    itemBuilder: (_, i) {
                      final selected = _categoryIdx == i;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _categoryIdx = i);
                          _applyFilter();
                          HapticFeedback.selectionClick();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? accent : _surface(isDark),
                            borderRadius: BorderRadius.circular(20),
                            border: selected ? null : Border.all(color: _border(isDark)),
                            boxShadow: selected
                                ? [BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _categories[i],
                                style: TextStyle(
                                  color: selected ? Colors.white : _text(isDark),
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13,
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
              const Gap(10),

              // ─── Divider ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Divider(height: 1, color: _border(isDark)),
              ),
              const Gap(8),

              // ─── List ───
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 40, color: _sub(isDark).withValues(alpha: 0.4)),
                              const Gap(8),
                              Text("لا يوجد نتائج",
                                  style: TextStyle(color: _sub(isDark), fontSize: 14)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final r = _filtered[index];
                            final isSelected = r.name == currentReciter.name &&
                                r.link == currentReciter.link;
                            final arName = ReciterNameTranslations.getArabicName(r.name, locale);
                            final arStyle = ReciterNameTranslations.getArabicStyle(r.style ?? "", locale);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _selectReciter(r),
                                  borderRadius: BorderRadius.circular(18),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? accent.withValues(alpha: 0.06)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(18),
                                      border: isSelected
                                          ? Border.all(
                                              color: accent.withValues(alpha: 0.3),
                                              width: 1.2)
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        // ─── Avatar ───
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _surfaceHigh(isDark),
                                            border: Border.all(
                                              color: isSelected
                                                  ? accent.withValues(alpha: 0.4)
                                                  : _border(isDark),
                                              width: isSelected ? 1.5 : 0.5,
                                            ),
                                            boxShadow: isSelected
                                                ? [BoxShadow(
                                                    color: accent.withValues(alpha: 0.15),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2))]
                                                : null,
                                          ),
                                          child: ClipOval(
                                            child: r.img != null
                                                ? CachedNetworkImage(
                                                    imageUrl: r.img!,
                                                    cacheManager: ReciterImageCacheManager(),
                                                    fit: BoxFit.cover,
                                                    errorWidget: (_, __, ___) =>
                                                        _defAvatar(accent),
                                                    placeholder: (_, __) =>
                                                        _defAvatar(accent),
                                                  )
                                                : _defAvatar(accent),
                                          ),
                                        ),
                                        const Gap(12),

                                        // ─── Info ───
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                arName,
                                                style: TextStyle(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w800
                                                      : FontWeight.w600,
                                                  fontSize: 14,
                                                  color: isSelected
                                                      ? accent
                                                      : _text(isDark),
                                                  letterSpacing: -0.2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const Gap(1),
                                              Row(
                                                children: [
                                                  if (arStyle.isNotEmpty) ...[
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: _surfaceHigh(isDark),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        arStyle,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: _sub(isDark),
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    const Gap(6),
                                                  ],
                                                  if (r.supportWordSegmentation == true)
                                                    Icon(Icons.graphic_eq_rounded,
                                                        size: 13,
                                                        color: _sub(isDark).withValues(alpha: 0.5)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ─── Trailing ───
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
                                          child: isSelected
                                              ? Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: accent.withValues(alpha: 0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.check_rounded,
                                                      color: accent, size: 16),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defAvatar(Color accent) => Container(
        color: accent.withValues(alpha: 0.08),
        child: Icon(Icons.person_rounded, size: 22, color: accent.withValues(alpha: 0.6)),
      );
}
