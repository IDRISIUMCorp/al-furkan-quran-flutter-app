import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/theme/app_colors.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/sleep_timer_cubit.dart";
import "package:al_furkan/src/widget/audio/sleep_timer_bottom_sheet.dart";
import "package:al_furkan/src/widget/audio/ayah_repeat_bottom_sheet.dart";
import "package:al_furkan/src/core/audio/model/audio_controller_ui.dart";
import "package:al_furkan/src/core/audio/model/audio_player_position_model.dart";
import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/core/audio/services/audio_playback_service_access.dart";
import "package:al_furkan/src/utils/quran_ayahs_function/gen_ayahs_key.dart";
import "package:al_furkan/src/resources/quran_resources/quran_ayah_count.dart";
import "package:al_furkan/src/core/audio/player/audio_player_manager.dart";
import "package:al_furkan/src/utils/basic_functions.dart";
import "package:al_furkan/src/resources/quran_resources/quran_pages_info.dart";
import "package:audio_video_progress_bar/audio_video_progress_bar.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:just_audio/just_audio.dart" as just_audio;
import "package:al_furkan/src/widget/audio/reciter_picker_bottom_sheet.dart";
import "package:al_furkan/src/utils/reciter_name_translations.dart";
import "../../core/audio/cubit/player_state_cubit.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Audio Controller — Quiet Luxury / Organic Minimalism
// ═══════════════════════════════════════════════════════════════════

class AudioControllerUi extends StatefulWidget {
  const AudioControllerUi({super.key});

  @override
  State<AudioControllerUi> createState() => _AudioControllerUiState();
}

class _AudioControllerUiState extends State<AudioControllerUi>
    with SingleTickerProviderStateMixin {
  AudioUiCubit? _myCubitInstance;
  double _playbackSpeed = 1.0;
  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _myCubitInstance ??= context.read<AudioUiCubit>();
  }

  @override
  void dispose() {
    _myCubitInstance = null;
    super.dispose();
  }

  // ─── Design Tokens (Unified Beige Palette) ─────────────────
  Color _bg(bool d) => d ? AppColors.darkSurface : AppColors.lightAudioPlayerBg;
  Color _card(bool d) => d ? AppColors.darkCard : AppColors.lightCard;
  Color _text(bool d) => d ? const Color(0xFFF5F5F7) : AppColors.lightTextMain;
  Color _sub(bool d) => d ? const Color(0xFF8E8E93) : AppColors.lightTextMuted;
  Color _border(bool d) =>
      d ? Colors.white.withValues(alpha: 0.06) : AppColors.lightBorder.withValues(alpha: 0.6);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return BlocBuilder<AudioUiCubit, AudioControllerUiState>(
      builder: (context, state) {
        final isVisible = state.showUi && state.isInsideQuranPlayer;
        final radius = state.isExpanded ? 24.0 : 50.0;
        final content = state.isExpanded
            ? _expandedPlayer(isDark, accent, state)
            : _collapsedPlayer(isDark, accent, state);

        final player = AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _bg(isDark),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _border(isDark), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: content,
        );

        // ── Apple-style slide + fade on show/hide ──
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          reverseDuration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: isVisible
              ? KeyedSubtree(key: const ValueKey('player_visible'), child: player)
              : const SizedBox.shrink(key: ValueKey('player_hidden')),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  COLLAPSED — Minimal Pill
  // ═══════════════════════════════════════════════════════════
  Widget _collapsedPlayer(bool isDark, Color accent, AudioControllerUiState uiState) {
    return BlocBuilder<SegmentedQuranReciterCubit, ReciterInfoModel>(
      builder: (context, reciter) {
        return BlocBuilder<PlayerStateCubit, PlayerState>(
          builder: (context, playerState) {
            final isLoading =
                playerState.state == just_audio.ProcessingState.loading ||
                    playerState.state == just_audio.ProcessingState.buffering;

            return GestureDetector(
              onTap: () => context.read<AudioUiCubit>().expand(true),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 6, 14, 0),
                    child: Row(
                      children: [
                        // Avatar
                        _avatar(reciter, 40, accent),
                        const Gap(10),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ReciterNameTranslations.getArabicName(
                                  reciter.name,
                                  Localizations.localeOf(context).languageCode,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _text(isDark),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap(1),
                              Text(
                                isLoading
                                    ? "جاري التحميل..."
                                    : playerState.isPlaying
                                        ? "يتم التشغيل"
                                        : "متوقف",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isLoading ? _sub(isDark) : accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Controls
                        _miniBtn(
                          Icons.skip_previous_rounded,
                          isDark,
                          uiState.isPlayList
                              ? () => audioPlaybackService.seekToPrevious()
                              : null,
                        ),
                        _playBtn(isLoading, playerState.isPlaying, isDark, 36, accent, tag: "mini"),
                        _miniBtn(
                          Icons.skip_next_rounded,
                          isDark,
                          uiState.isPlayList
                              ? () => audioPlaybackService.seekToNext()
                              : null,
                        ),
                      ],
                    ),
                  ),
                  // Progress line
                  BlocBuilder<PlayerPositionCubit, AudioPlayerPositionModel>(
                    builder: (context, pos) {
                      final total =
                          pos.totalDuration?.inMilliseconds.toDouble() ?? 1.0;
                      final current =
                          pos.currentDuration?.inMilliseconds.toDouble() ?? 0.0;
                      final f = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
                      return Container(
                        height: 2.5,
                        margin: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: _border(isDark),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: f,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: accent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  EXPANDED — Full Player
  // ═══════════════════════════════════════════════════════════
  Widget _expandedPlayer(bool isDark, Color accent, AudioControllerUiState uiState) {
    return BlocBuilder<SegmentedQuranReciterCubit, ReciterInfoModel>(
      builder: (context, reciter) {
        return BlocBuilder<PlayerStateCubit, PlayerState>(
          builder: (context, playerState) {
            final isLoading =
                playerState.state == just_audio.ProcessingState.loading ||
                    playerState.state == just_audio.ProcessingState.buffering;

            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Header: reciter + collapse ───
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _openReciterPicker(),
                        child: _avatar(reciter, 46, accent),
                      ),
                      const Gap(12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openReciterPicker(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      ReciterNameTranslations.getArabicName(
                                        reciter.name,
                                        Localizations.localeOf(context).languageCode,
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: _text(isDark),
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Gap(2),
                                  Icon(Icons.unfold_more_rounded,
                                      size: 16, color: _sub(isDark)),
                                ],
                              ),
                              if (reciter.style != null)
                                Text(
                                  ReciterNameTranslations.getArabicStyle(
                                    reciter.style!,
                                    Localizations.localeOf(context).languageCode,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _sub(isDark),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      _tapIcon(
                        Icons.keyboard_arrow_down_rounded,
                        isDark,
                        () => context.read<AudioUiCubit>().expand(false),
                      ),
                    ],
                  ),
                  const Gap(18),

                  // ─── Progress Bar ───
                  BlocBuilder<PlayerPositionCubit, AudioPlayerPositionModel>(
                    builder: (context, pos) {
                      return ProgressBar(
                        progress: pos.currentDuration ?? Duration.zero,
                        buffered: pos.bufferDuration ?? Duration.zero,
                        total: pos.totalDuration ?? Duration.zero,
                        thumbCanPaintOutsideBar: false,
                        barHeight: 4,
                        thumbRadius: 6,
                        thumbGlowRadius: 14,
                        thumbColor: accent,
                        baseBarColor: _border(isDark),
                        progressBarColor: accent,
                        bufferedBarColor: accent.withValues(alpha: 0.18),
                        timeLabelTextStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _sub(isDark),
                          letterSpacing: 0.2,
                        ),
                        timeLabelLocation: TimeLabelLocation.below,
                        onSeek: (d) => audioPlaybackService.seek(d),
                      );
                    },
                  ),

                  // ─── Ayah Indicator ───
                  BlocBuilder<AyahKeyCubit, AyahKeyManagement?>(
                    builder: (context, ayahState) {
                      if (ayahState?.current == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 4),
                        child: Text(
                          ayahState!.current,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      );
                    },
                  ),

                  // ─── Transport Controls ───
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _chipBtn(
                        "${_playbackSpeed}x",
                        isDark,
                        accent,
                        isActive: _playbackSpeed != 1.0,
                        onTap: _cycleSpeed,
                      ),
                      const Gap(8),
                      _ctrlIcon(Icons.replay_5_rounded, isDark, () {
                        final d = audioPlaybackService.currentPosition;
                        final int ms = (d.inMilliseconds - 5000).clamp(0, 999999999);
                        audioPlaybackService.seek(Duration(milliseconds: ms));
                      }),
                      _ctrlIcon(Icons.skip_previous_rounded, isDark,
                          () => _seekPrevious(context)),
                      const Gap(2),
                      _playBtn(isLoading, playerState.isPlaying, isDark, 52, accent, tag: "full"),
                      const Gap(2),
                      _ctrlIcon(Icons.skip_next_rounded, isDark,
                          () => _seekNext(context)),
                      _ctrlIcon(Icons.forward_5_rounded, isDark, () {
                        final d = audioPlaybackService.currentPosition;
                        final max = audioPlaybackService.totalDuration;
                        int ms = d.inMilliseconds + 5000;
                        if (max != null && ms > max.inMilliseconds) {
                          ms = max.inMilliseconds;
                        }
                        audioPlaybackService.seek(Duration(milliseconds: ms));
                      }),
                      const Gap(8),
                      _loopChip(isDark, accent),
                    ],
                  ),
                  ),
                  const Gap(10),

                  // ─── Bottom Row 1 ───
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _bottomBtn(
                          icon: Icons.skip_previous_rounded,
                          label: "السابقة",
                          isDark: isDark,
                          accent: accent,
                          onTap: () => _playPreviousSurah(context),
                        ),
                        _bottomBtn(
                          icon: Icons.playlist_play_rounded,
                          label: "قائمة",
                          isDark: isDark,
                          accent: accent,
                          isActive: uiState.isPlayList,
                          onTap: () => _togglePlaylist(context),
                        ),
                        _bottomBtn(
                          icon: Icons.record_voice_over_rounded,
                          label: "القارئ",
                          isDark: isDark,
                          accent: accent,
                          onTap: () => _openReciterPicker(),
                        ),
                        _bottomBtn(
                          icon: Icons.skip_next_rounded,
                          label: "التالية",
                          isDark: isDark,
                          accent: accent,
                          onTap: () => _playNextSurah(context),
                        ),
                      ],
                    ),
                  ),
                  const Gap(4),
                  // ─── Bottom Row 2 ───
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _bottomBtn(
                          icon: Icons.bedtime_rounded,
                          label: "مؤقت",
                          isDark: isDark,
                          accent: accent,
                          isActive: context.watch<SleepTimerCubit>().state.isActive,
                          onTap: () => _openSleepTimer(context),
                        ),
                        _bottomBtn(
                          icon: Icons.repeat_rounded,
                          label: "تكرار",
                          isDark: isDark,
                          accent: accent,
                          onTap: () => _openRepeatPicker(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SHARED COMPONENTS
  // ═══════════════════════════════════════════════════════════

  Widget _avatar(ReciterInfoModel r, double size, Color accent) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: accent.withValues(alpha: 0.25), width: 1.5),
      ),
      child: ClipOval(
        child: r.img != null
            ? CachedNetworkImage(
                imageUrl: r.img!,
                cacheManager: ReciterImageCacheManager(),
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _defAvatar(size, accent),
                placeholder: (_, _) => _defAvatar(size, accent),
              )
            : _defAvatar(size, accent),
      ),
    );
  }

  Widget _defAvatar(double s, Color accent) => Container(
        color: accent.withValues(alpha: 0.1),
        child: Icon(Icons.person_rounded, size: s * 0.5, color: accent),
      );

  Widget _playBtn(bool loading, bool playing, bool isDark, double size, Color accent, {String tag = ""}) {
    return GestureDetector(
      onTap: () => _handlePlayPause(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: loading
                ? SizedBox(
                    key: ValueKey("${tag}loading"),
                    width: size * 0.4,
                    height: size * 0.4,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey("$tag${playing ? "pause" : "play"}"),
                    color: Colors.white,
                    size: size * 0.5,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _miniBtn(IconData icon, bool isDark, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          icon,
          size: 22,
          color: onTap != null
              ? _text(isDark).withValues(alpha: 0.65)
              : _sub(isDark).withValues(alpha: 0.25),
        ),
      ),
    );
  }

  Widget _ctrlIcon(IconData icon, bool isDark, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      icon: Icon(icon, color: _text(isDark).withValues(alpha: 0.65), size: 24),
    );
  }

  Widget _tapIcon(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 22, color: _sub(isDark)),
      ),
    );
  }

  Widget _chipBtn(String label, bool isDark, Color accent,
      {bool isActive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isActive
              ? accent.withValues(alpha: 0.12)
              : _card(isDark),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? accent : _sub(isDark),
          ),
        ),
      ),
    );
  }

  Widget _loopChip(bool isDark, Color accent) {
    final mode = audioPlaybackService.loopMode;
    final active = mode != just_audio.LoopMode.off;
    return GestureDetector(
      onTap: () {
        if (mode == just_audio.LoopMode.off) {
          audioPlaybackService.setLoopMode(just_audio.LoopMode.one);
        } else if (mode == just_audio.LoopMode.one) {
          audioPlaybackService.setLoopMode(just_audio.LoopMode.all);
        } else {
          audioPlaybackService.setLoopMode(just_audio.LoopMode.off);
        }
        setState(() {});
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: active ? accent.withValues(alpha: 0.12) : _card(isDark),
        ),
        child: Icon(
          mode == just_audio.LoopMode.one
              ? Icons.repeat_one_rounded
              : Icons.repeat_rounded,
          size: 18,
          color: active ? accent : _sub(isDark),
        ),
      ),
    );
  }

  Widget _bottomBtn({
    required IconData icon,
    required String label,
    required bool isDark,
    required Color accent,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? accent.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isActive ? accent : _sub(isDark)),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? accent : _sub(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  ACTIONS
  // ═══════════════════════════════════════════════════════════

  Future<void> _handlePlayPause() async {
    final playerState = context.read<PlayerStateCubit>().state;
    final isLoading =
        playerState.state == just_audio.ProcessingState.loading ||
            playerState.state == just_audio.ProcessingState.buffering;
    if (isLoading) return;

    final hasSource = audioPlaybackService.hasSource;
    final isIdle = audioPlaybackService.processingState ==
        just_audio.ProcessingState.idle;
    final noDuration = audioPlaybackService.totalDuration == null;

    final isCompleted = audioPlaybackService.processingState ==
        just_audio.ProcessingState.completed;

    if (!audioPlaybackService.isPlaying &&
        (!hasSource || isIdle || noDuration || isCompleted)) {
      final ayahKeyState = context.read<AyahKeyCubit>().state;
      final reciter = context.read<SegmentedQuranReciterCubit>().state;

      // Get current page start ayah → play to end of surah as continuous playlist
      final currentPage = ayahKeyState.lastScrolledPageNumber ?? 1;
      final pageIdx = (currentPage - 1).clamp(0, quranPagesInfo.length - 1);
      final pageInfo = quranPagesInfo[pageIdx];
      final startKey = convertAyahNumberToKey(pageInfo["s"] ?? 1) ?? "1:1";
      // Play to end of surah (not just end of page) for continuous playback
      final surahNum = int.tryParse(startKey.split(":").first) ?? 1;
      final lastAyah = quranAyahCount[surahNum - 1];
      final endKey = "$surahNum:$lastAyah";

      await AudioPlayerManager.playMultipleAyahAsPlaylist(
        startAyahKey: startKey,
        endAyahKey: endKey,
        reciterInfoModel: reciter,
        isInsideQuran: true,
        instantPlay: true,
      );
      return;
    }

    if (audioPlaybackService.isPlaying) {
      await audioPlaybackService.pause();
    } else {
      await audioPlaybackService.resume();
    }
  }

  void _cycleSpeed() {
    int idx = _speedOptions.indexOf(_playbackSpeed);
    idx = (idx + 1) % _speedOptions.length;
    setState(() => _playbackSpeed = _speedOptions[idx]);
    AudioPlayerManager.audioPlayer.setSpeed(_playbackSpeed);
    HapticFeedback.lightImpact();
  }

  void _seekPrevious(BuildContext context) {
    final state = context.read<AyahKeyCubit>().state;
    if (state.ayahList.length == 1) {
      final int? surahNum = int.tryParse(state.current.split(":").first);
      if (surahNum == null) return;
      final List ayahList = getListOfAyahKey(
        startAyahKey: "$surahNum:1",
        endAyahKey: getEndAyahKeyFromSurahNumber(surahNum),
      );
      ayahList.removeWhere((e) => e.runtimeType == int);
      final int idx = ayahList.indexOf(state.current);
      if (idx > 0) {
        audioPlaybackService.playSingleAyah(
          ayahKey: ayahList[idx - 1],
          reciterInfoModel:
              context.read<SegmentedQuranReciterCubit>().state,
          isInsideQuran: true,
        );
      }
    } else {
      audioPlaybackService.seekToPrevious();
    }
  }

  void _seekNext(BuildContext context) {
    final state = context.read<AyahKeyCubit>().state;
    if (state.ayahList.length == 1) {
      final int? surahNum = int.tryParse(state.current.split(":").first);
      if (surahNum == null) return;
      final List ayahList = getListOfAyahKey(
        startAyahKey: "$surahNum:1",
        endAyahKey: getEndAyahKeyFromSurahNumber(surahNum),
      );
      ayahList.removeWhere((e) => e.runtimeType == int);
      final int idx = ayahList.indexOf(state.current);
      final int maxAyah = quranAyahCount[surahNum - 1];
      if (idx != -1 &&
          idx < ayahList.length - 1 &&
          int.parse(state.current.split(":").last) < maxAyah) {
        audioPlaybackService.playSingleAyah(
          ayahKey: ayahList[idx + 1],
          reciterInfoModel:
              context.read<SegmentedQuranReciterCubit>().state,
          isInsideQuran: true,
        );
      }
    } else {
      audioPlaybackService.seekToNext();
    }
  }

  void _togglePlaylist(BuildContext context) {
    final state = context.read<AyahKeyCubit>().state;
    if (state.ayahList.length <= 1) {
      final int surahNumber = int.parse(state.current.split(":").first);
      final int currentAyah = int.parse(state.current.split(":").last);
      final String endAyahKey = getEndAyahKeyFromSurahNumber(surahNumber);
      audioPlaybackService.playPlaylist(
        startAyahKey: "$surahNumber:1",
        endAyahKey: endAyahKey,
        reciterInfoModel:
            context.read<SegmentedQuranReciterCubit>().state,
        initialIndex: currentAyah - 1,
        instantPlay: audioPlaybackService.isPlaying,
        isInsideQuran: true,
      );
    }
  }

  void _playPreviousSurah(BuildContext context) async {
    final state = context.read<AyahKeyCubit>().state;
    if (state.current.isEmpty) return;
    final surahNum = int.tryParse(state.current.split(":").first) ?? 1;
    if (surahNum <= 1) return;
    final prevSurah = surahNum - 1;
    final reciter = context.read<SegmentedQuranReciterCubit>().state;
    final lastAyah = quranAyahCount[prevSurah - 1];
    await AudioPlayerManager.playMultipleAyahAsPlaylist(
      startAyahKey: "$prevSurah:1",
      endAyahKey: "$prevSurah:$lastAyah",
      reciterInfoModel: reciter,
      isInsideQuran: true,
      instantPlay: true,
    );
    if (mounted) {
      // ignore: use_build_context_synchronously
      context.read<AyahKeyCubit>().changeCurrentAyahKey("$prevSurah:1");
    }
  }

  void _playNextSurah(BuildContext context) async {
    final state = context.read<AyahKeyCubit>().state;
    if (state.current.isEmpty) return;
    final surahNum = int.tryParse(state.current.split(":").first) ?? 1;
    if (surahNum >= 114) return;
    final nextSurah = surahNum + 1;
    final reciter = context.read<SegmentedQuranReciterCubit>().state;
    final lastAyah = quranAyahCount[nextSurah - 1];
    await AudioPlayerManager.playMultipleAyahAsPlaylist(
      startAyahKey: "$nextSurah:1",
      endAyahKey: "$nextSurah:$lastAyah",
      reciterInfoModel: reciter,
      isInsideQuran: true,
      instantPlay: true,
    );
    if (mounted) {
      // ignore: use_build_context_synchronously
      context.read<AyahKeyCubit>().changeCurrentAyahKey("$nextSurah:1");
    }
  }

  void _openReciterPicker() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 1.0,
          snap: true,
          snapSizes: const [0.5, 0.85, 1.0],
          builder: (context, scrollController) {
            return const ReciterPickerBottomSheet();
          },
        );
      },
    );
  }

  void _openSleepTimer(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SleepTimerBottomSheet(),
    );
  }

  void _openRepeatPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AyahRepeatBottomSheet(),
    );
  }
}
