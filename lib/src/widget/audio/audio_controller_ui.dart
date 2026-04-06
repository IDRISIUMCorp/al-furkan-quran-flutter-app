import "package:al_quran_v3/l10n/app_localizations.dart";
import "package:al_quran_v3/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_quran_v3/src/core/audio/model/audio_controller_ui.dart";
import "package:al_quran_v3/src/core/audio/model/audio_player_position_model.dart";
import "package:al_quran_v3/src/core/audio/model/ayahkey_management.dart";
import "package:al_quran_v3/src/core/audio/model/recitation_info_model.dart";
import "package:al_quran_v3/src/core/audio/services/audio_playback_service_access.dart";
import "package:al_quran_v3/src/utils/quran_ayahs_function/gen_ayahs_key.dart";
import "package:al_quran_v3/src/resources/quran_resources/quran_ayah_count.dart";
import "package:al_quran_v3/src/core/audio/player/audio_player_manager.dart";
import "package:al_quran_v3/src/utils/get_segments_supported_reciters.dart";
import "package:audio_video_progress_bar/audio_video_progress_bar.dart";
import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:just_audio/just_audio.dart" as just_audio;


import "../../core/audio/cubit/player_state_cubit.dart";

class AudioControllerUi extends StatefulWidget {
  const AudioControllerUi({super.key});

  @override
  State<AudioControllerUi> createState() => _AudioControllerUiState();
}

class _AudioControllerUiState extends State<AudioControllerUi>
    with SingleTickerProviderStateMixin {
  AudioUiCubit? _myCubitInstance;
  double _playbackSpeed = 1.0;
  int _repeatCount = 0; // 0 = no repeat, 1+ = count
  bool _isRepeatActive = false;

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

  // ─── Colors ───────────────────────────────────────────────
  Color _bg(bool isDark) =>
      isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF4EAD5);
  Color _surface(bool isDark) =>
      isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEDE5D0);
  Color _onSurface(bool isDark) =>
      isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color _muted(bool isDark) =>
      isDark ? Colors.white54 : const Color(0xFF8B7355);
  Color get _accent => const Color(0xFF6EAE7E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AudioUiCubit, AudioControllerUiState>(
      builder: (context, state) {
        if (!state.showUi || !state.isInsideQuranPlayer) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuart,
          margin: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
          decoration: BoxDecoration(
            color: _bg(isDark),
            borderRadius: BorderRadius.circular(state.isExpanded ? 20 : 40),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: state.isExpanded
              ? _buildExpandedPlayer(isDark, l10n, state)
              : _buildCollapsedPlayer(isDark, l10n, state),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  COLLAPSED PLAYER — Compact Mini Bar
  // ═══════════════════════════════════════════════════════════
  Widget _buildCollapsedPlayer(
      bool isDark, AppLocalizations l10n, AudioControllerUiState uiState) {
    return BlocBuilder<SegmentedQuranReciterCubit, ReciterInfoModel>(
      builder: (context, reciter) {
        return BlocBuilder<PlayerStateCubit, PlayerState>(
          builder: (context, playerState) {
            final isLoading =
                playerState.state == just_audio.ProcessingState.loading ||
                    playerState.state == just_audio.ProcessingState.buffering;

            return GestureDetector(
              onTap: () => context.read<AudioUiCubit>().expand(true),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // Reciter Avatar
                        _reciterAvatar(reciter, 38),
                        const Gap(10),
                        // Reciter name & status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                reciter.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _onSurface(isDark),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isLoading
                                    ? "جاري التحميل..."
                                    : (playerState.isPlaying
                                        ? "يتم التشغيل"
                                        : "متوقف"),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Prev
                        _miniControlBtn(
                          icon: Icons.skip_previous_rounded,
                          isDark: isDark,
                          onTap: uiState.isPlayList
                              ? () => audioPlaybackService.seekToPrevious()
                              : null,
                        ),
                        // Play/Pause
                        _playPauseButton(
                            isLoading, playerState.isPlaying, isDark, 32),
                        // Next
                        _miniControlBtn(
                          icon: Icons.skip_next_rounded,
                          isDark: isDark,
                          onTap: uiState.isPlayList
                              ? () => audioPlaybackService.seekToNext()
                              : null,
                        ),
                      ],
                    ),
                  ),
                  // Mini progress
                  BlocBuilder<PlayerPositionCubit, AudioPlayerPositionModel>(
                    builder: (context, pos) {
                      final total =
                          pos.totalDuration?.inMilliseconds.toDouble() ?? 1.0;
                      final current =
                          pos.currentDuration?.inMilliseconds.toDouble() ?? 0.0;
                      final fraction =
                          total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
                      return Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: _surface(isDark),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: _accent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Gap(6),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  EXPANDED PLAYER — Full-Featured
  // ═══════════════════════════════════════════════════════════
  Widget _buildExpandedPlayer(
      bool isDark, AppLocalizations l10n, AudioControllerUiState uiState) {
    return BlocBuilder<SegmentedQuranReciterCubit, ReciterInfoModel>(
      builder: (context, reciter) {
        return BlocBuilder<PlayerStateCubit, PlayerState>(
          builder: (context, playerState) {
            final isLoading =
                playerState.state == just_audio.ProcessingState.loading ||
                    playerState.state == just_audio.ProcessingState.buffering;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Top Row: Reciter Info + Collapse ───
                  Row(
                    children: [
                      // Reciter avatar
                      GestureDetector(
                        onTap: () => _openReciterPicker(isDark),
                        child: _reciterAvatar(reciter, 44),
                      ),
                      const Gap(10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openReciterPicker(isDark),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      reciter.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: _onSurface(isDark),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Gap(4),
                                  Icon(Icons.keyboard_arrow_down_rounded,
                                      size: 18, color: _accent),
                                ],
                              ),
                              if (reciter.style != null)
                                Text(
                                  reciter.style!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _muted(isDark),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Collapse
                      _iconBtn(
                        icon: Icons.keyboard_arrow_down_rounded,
                        isDark: isDark,
                        onTap: () =>
                            context.read<AudioUiCubit>().expand(false),
                        size: 22,
                      ),
                    ],
                  ),
                  const Gap(14),

                  // ─── Progress Bar ───
                  BlocBuilder<PlayerPositionCubit, AudioPlayerPositionModel>(
                    builder: (context, pos) {
                      return ProgressBar(
                        progress: pos.currentDuration ?? Duration.zero,
                        buffered: pos.bufferDuration ?? Duration.zero,
                        total: pos.totalDuration ?? Duration.zero,
                        thumbCanPaintOutsideBar: false,
                        barHeight: 5,
                        thumbRadius: 7,
                        thumbGlowRadius: 18,
                        thumbColor: _accent,
                        baseBarColor: _surface(isDark),
                        progressBarColor: _accent,
                        bufferedBarColor: _accent.withValues(alpha: 0.25),
                        timeLabelTextStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _muted(isDark),
                        ),
                        timeLabelLocation: TimeLabelLocation.below,
                        onSeek: (d) => audioPlaybackService.seek(d),
                      );
                    },
                  ),
                  const Gap(4),

                  // ─── Ayah Slider (if playlist) ───
                  BlocBuilder<AyahKeyCubit, AyahKeyManagement?>(
                    builder: (context, ayahState) {
                      if (ayahState?.current == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          ayahState!.current,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _accent,
                          ),
                        ),
                      );
                    },
                  ),

                  // ─── Main Controls ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Speed
                      _speedButton(isDark),
                      const Gap(8),
                      // Rewind 5s
                      _controlBtn(
                        icon: Icons.replay_5_rounded,
                        isDark: isDark,
                        onTap: () {
                          final d = audioPlaybackService.currentPosition;
                          int ms = d.inMilliseconds - 5000;
                          if (ms < 0) ms = 0;
                          audioPlaybackService
                              .seek(Duration(milliseconds: ms));
                        },
                      ),
                      const Gap(4),
                      // Previous
                      _controlBtn(
                        icon: Icons.skip_previous_rounded,
                        isDark: isDark,
                        onTap: () => _seekPrevious(context),
                      ),
                      const Gap(4),
                      // Play/Pause (big)
                      _playPauseButton(
                          isLoading, playerState.isPlaying, isDark, 48),
                      const Gap(4),
                      // Next
                      _controlBtn(
                        icon: Icons.skip_next_rounded,
                        isDark: isDark,
                        onTap: () => _seekNext(context),
                      ),
                      const Gap(4),
                      // Forward 5s
                      _controlBtn(
                        icon: Icons.forward_5_rounded,
                        isDark: isDark,
                        onTap: () {
                          final d = audioPlaybackService.currentPosition;
                          final max = audioPlaybackService.totalDuration;
                          int ms = d.inMilliseconds + 5000;
                          if (max != null && ms > max.inMilliseconds) {
                            ms = max.inMilliseconds;
                          }
                          audioPlaybackService
                              .seek(Duration(milliseconds: ms));
                        },
                      ),
                      const Gap(8),
                      // Repeat
                      _repeatButton(isDark),
                    ],
                  ),
                  const Gap(8),

                  // ─── Bottom Toolbar ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Playlist mode
                      _bottomAction(
                        icon: Icons.playlist_play_rounded,
                        label: "قائمة",
                        isDark: isDark,
                        isActive: uiState.isPlayList,
                        onTap: () => _togglePlaylist(context),
                      ),
                      // Repeat single ayah
                      _bottomAction(
                        icon: Icons.repeat_one_rounded,
                        label: "تكرار: $_repeatCount",
                        isDark: isDark,
                        isActive: _isRepeatActive,
                        onTap: _cycleRepeat,
                      ),
                      // Reciter
                      _bottomAction(
                        icon: Icons.record_voice_over_rounded,
                        label: "القارئ",
                        isDark: isDark,
                        onTap: () => _openReciterPicker(isDark),
                      ),
                    ],
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
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════

  Widget _reciterAvatar(ReciterInfoModel reciter, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _accent.withValues(alpha: 0.3), width: 2),
      ),
      child: ClipOval(
        child: reciter.img != null
            ? CachedNetworkImage(
                imageUrl: reciter.img!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _defaultAvatar(size),
                placeholder: (_, __) => _defaultAvatar(size),
              )
            : _defaultAvatar(size),
      ),
    );
  }

  Widget _defaultAvatar(double size) {
    return Container(
      color: _accent.withValues(alpha: 0.15),
      child: Icon(Icons.person_rounded,
          size: size * 0.55, color: _accent),
    );
  }

  Widget _playPauseButton(
      bool isLoading, bool isPlaying, bool isDark, double size) {
    return GestureDetector(
      onTap: () async {
        if (isLoading) return;

        final hasSource = audioPlaybackService.hasSource;
        final isIdle = audioPlaybackService.processingState ==
            just_audio.ProcessingState.idle;
        final noDuration = audioPlaybackService.totalDuration == null;

        if (!audioPlaybackService.isPlaying &&
            (!hasSource || isIdle || noDuration)) {
          final ayahKey = context.read<AyahKeyCubit>().state.current;
          final reciter = context.read<SegmentedQuranReciterCubit>().state;
          await audioPlaybackService.playSingleAyah(
            ayahKey: ayahKey,
            reciterInfoModel: reciter,
            instantPlay: true,
            isInsideQuran: true,
          );
          return;
        }

        if (audioPlaybackService.isPlaying) {
          await audioPlaybackService.pause();
        } else {
          await audioPlaybackService.resume();
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _accent,
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey("loading"),
                    width: size * 0.45,
                    height: size * 0.45,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(isPlaying),
                    color: Colors.white,
                    size: size * 0.55,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _miniControlBtn(
      {required IconData icon, required bool isDark, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          icon,
          size: 24,
          color: onTap != null
              ? _onSurface(isDark).withValues(alpha: 0.7)
              : _muted(isDark).withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _controlBtn(
      {required IconData icon, required bool isDark, VoidCallback? onTap}) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(padding: EdgeInsets.zero),
      icon: Icon(icon, color: _onSurface(isDark).withValues(alpha: 0.7), size: 26),
    );
  }

  Widget _iconBtn(
      {required IconData icon,
      required bool isDark,
      VoidCallback? onTap,
      double size = 20}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: size, color: _muted(isDark)),
      ),
    );
  }

  // ─── Speed ───
  Widget _speedButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        int idx = _speedOptions.indexOf(_playbackSpeed);
        idx = (idx + 1) % _speedOptions.length;
        setState(() => _playbackSpeed = _speedOptions[idx]);
        AudioPlayerManager.audioPlayer.setSpeed(_playbackSpeed);
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _playbackSpeed != 1.0
              ? _accent.withValues(alpha: 0.15)
              : _surface(isDark),
        ),
        child: Text(
          "${_playbackSpeed}x",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _playbackSpeed != 1.0 ? _accent : _muted(isDark),
          ),
        ),
      ),
    );
  }

  // ─── Repeat ───
  Widget _repeatButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        if (audioPlaybackService.loopMode == just_audio.LoopMode.one) {
          audioPlaybackService.setLoopMode(just_audio.LoopMode.all);
        } else if (audioPlaybackService.loopMode == just_audio.LoopMode.all) {
          audioPlaybackService.setLoopMode(just_audio.LoopMode.off);
        } else {
          audioPlaybackService.setLoopMode(just_audio.LoopMode.one);
        }
        setState(() {});
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: audioPlaybackService.loopMode != just_audio.LoopMode.off
              ? _accent.withValues(alpha: 0.15)
              : _surface(isDark),
        ),
        child: Icon(
          audioPlaybackService.loopMode == just_audio.LoopMode.one
              ? Icons.repeat_one_rounded
              : Icons.repeat_rounded,
          size: 20,
          color: audioPlaybackService.loopMode != just_audio.LoopMode.off
              ? _accent
              : _muted(isDark),
        ),
      ),
    );
  }

  // ─── Bottom Action ───
  Widget _bottomAction({
    required IconData icon,
    required String label,
    required bool isDark,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: isActive ? _accent : _muted(isDark)),
          const Gap(2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? _accent : _muted(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  ACTIONS
  // ═══════════════════════════════════════════════════════════

  void _seekPrevious(BuildContext context) {
    final state = context.read<AyahKeyCubit>().state;
    if (state.ayahList.length == 1) {
      int? surahNum = int.tryParse(state.current.split(":").first);
      if (surahNum == null) return;
      List ayahList = getListOfAyahKey(
        startAyahKey: "$surahNum:1",
        endAyahKey: getEndAyahKeyFromSurahNumber(surahNum),
      );
      ayahList.removeWhere((e) => e.runtimeType == int);
      int idx = ayahList.indexOf(state.current);
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
      int? surahNum = int.tryParse(state.current.split(":").first);
      if (surahNum == null) return;
      List ayahList = getListOfAyahKey(
        startAyahKey: "$surahNum:1",
        endAyahKey: getEndAyahKeyFromSurahNumber(surahNum),
      );
      ayahList.removeWhere((e) => e.runtimeType == int);
      int idx = ayahList.indexOf(state.current);
      int maxAyah = quranAyahCount[surahNum - 1];
      if (idx != -1 && idx < ayahList.length - 1 &&
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
      int surahNumber = int.parse(state.current.split(":").first);
      int currentAyah = int.parse(state.current.split(":").last);
      String endAyahKey = getEndAyahKeyFromSurahNumber(surahNumber);
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

  void _cycleRepeat() {
    setState(() {
      if (!_isRepeatActive) {
        _isRepeatActive = true;
        _repeatCount = 2;
      } else if (_repeatCount < 10) {
        _repeatCount++;
      } else {
        _isRepeatActive = false;
        _repeatCount = 0;
      }
    });
    HapticFeedback.lightImpact();
  }

  // ═══════════════════════════════════════════════════════════
  //  RECITER PICKER
  // ═══════════════════════════════════════════════════════════
  void _openReciterPicker(bool isDark) {
    HapticFeedback.mediumImpact();
    final allReciters = getSegmentsSupportedReciters();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: _bg(isDark),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "اختر القارئ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _onSurface(isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: allReciters.length,
                        separatorBuilder: (_, __) => Divider(
                          color: _surface(isDark),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final r = allReciters[index];
                          final currentReciter = this
                              .context
                              .read<SegmentedQuranReciterCubit>()
                              .state;
                          final isSelected = r.name == currentReciter.name &&
                              r.link == currentReciter.link;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            leading: _reciterAvatar(r, 44),
                            title: Text(
                              r.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isSelected
                                    ? _accent
                                    : _onSurface(isDark),
                              ),
                            ),
                            subtitle: Text(
                              r.style ?? "",
                              style: TextStyle(
                                fontSize: 12,
                                color: _muted(isDark),
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle_rounded,
                                    color: _accent, size: 22)
                                : (r.supportWordSegmentation == true
                                    ? Icon(Icons.graphic_eq_rounded,
                                        color: _muted(isDark), size: 18)
                                    : null),
                            onTap: () {
                              this
                                  .context
                                  .read<SegmentedQuranReciterCubit>()
                                  .changeReciter(this.context, r);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
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
}
