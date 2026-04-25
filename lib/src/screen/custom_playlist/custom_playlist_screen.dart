import "package:al_furkan/src/core/audio/cubit/custom_playlist_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/player/audio_player_manager.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:flutter_animate/flutter_animate.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Custom Playlist Screen — قوائم التشغيل المخصصة
// ═══════════════════════════════════════════════════════════════════

class CustomPlaylistScreen extends StatelessWidget {
  const CustomPlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = context.read<ThemeCubit>().state.primary;
    final bg = isDark ? const Color(0xFF212529) : const Color(0xFFF7F1E6);
    final surface = isDark ? const Color(0xFF343A40) : const Color(0xFFF5EBE0);
    final text = isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);
    final sub = isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          title: Text("قوائم التشغيل", style: TextStyle(color: text, fontWeight: FontWeight.w800)),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: text), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(
              icon: Icon(Icons.add_rounded, color: accent),
              onPressed: () => _showCreatePlaylistDialog(context, accent, isDark),
            ),
          ],
        ),
        body: BlocBuilder<CustomPlaylistCubit, CustomPlaylistState>(
          builder: (context, state) {
            if (state.playlists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.playlist_add_rounded, size: 64, color: sub.withValues(alpha: 0.4)),
                    const Gap(16),
                    Text("لا توجد قوائم تشغيل", style: TextStyle(color: sub, fontWeight: FontWeight.w600, fontSize: 18)),
                    const Gap(8),
                    Text("اضغط + لإنشاء قائمة جديدة", style: TextStyle(color: sub.withValues(alpha: 0.7), fontSize: 14)),
                  ],
                ).animate().fadeIn(duration: 300.ms),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.playlists.length,
              itemBuilder: (context, index) {
                final playlist = state.playlists[index];
                return _PlaylistCard(
                  playlist: playlist,
                  surface: surface,
                  isDark: isDark,
                  accent: accent,
                  text: text,
                  sub: sub,
                  onPlay: () => _playPlaylist(context, playlist),
                  onDelete: () => _confirmDelete(context, playlist, accent),
                  onEdit: () => _showEditPlaylistDialog(context, playlist, accent, isDark),
                ).animate().fadeIn(duration: 250.ms, delay: (index * 50).ms);
              },
            );
          },
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, Color accent, bool isDark) {
    final nameCtrl = TextEditingController();
    final selectedSurahs = <int>[];
    final text = isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF343A40) : const Color(0xFFF8F9FA),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
                  const Gap(16),
                  Text("قائمة تشغيل جديدة", style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        hintText: "اسم القائمة",
                        filled: true,
                        fillColor: isDark ? const Color(0xFF495057).withValues(alpha: 0.3) : const Color(0xFFE3D5CA).withValues(alpha: 0.4),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      style: TextStyle(color: text),
                    ),
                  ),
                  const Gap(16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text("اختر السور:", style: TextStyle(color: isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057), fontWeight: FontWeight.w600)),
                  ),
                  const Gap(8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(114, (i) {
                        final surahNum = i + 1;
                        final isSelected = selectedSurahs.contains(surahNum);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                selectedSurahs.remove(surahNum);
                              } else {
                                selectedSurahs.add(surahNum);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? accent.withValues(alpha: 0.15) : isDark ? const Color(0xFF495057).withValues(alpha: 0.2) : const Color(0xFFE3D5CA).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? accent : Colors.transparent, width: 1.5),
                            ),
                            child: Text(
                              "$surahNum",
                              style: TextStyle(
                                color: isSelected ? accent : isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057),
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Gap(20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty || selectedSurahs.isEmpty) return;
                          final reciter = context.read<SegmentedQuranReciterCubit>().state;
                          context.read<CustomPlaylistCubit>().createPlaylist(
                                name: nameCtrl.text.trim(),
                                surahNumbers: selectedSurahs,
                                reciter: reciter,
                              );
                          Navigator.pop(ctx);
                        },
                        child: const Text("إنشاء", style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const Gap(20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditPlaylistDialog(BuildContext context, CustomPlaylist playlist, Color accent, bool isDark) {
    final nameCtrl = TextEditingController(text: playlist.name);
    final text = isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text("تعديل الاسم", style: TextStyle(color: text, fontWeight: FontWeight.w800)),
          content: TextField(
            controller: nameCtrl,
            style: TextStyle(color: text),
            decoration: InputDecoration(
              hintText: "اسم القائمة",
              filled: true,
              fillColor: isDark ? const Color(0xFF495057).withValues(alpha: 0.3) : const Color(0xFFE3D5CA).withValues(alpha: 0.4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: accent))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  context.read<CustomPlaylistCubit>().renamePlaylist(playlist.id, nameCtrl.text.trim());
                }
                Navigator.pop(ctx);
              },
              child: const Text("حفظ"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CustomPlaylist playlist, Color accent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text("حذف القائمة؟", style: TextStyle(color: text, fontWeight: FontWeight.w800)),
          content: Text("هل تريد حذف \"${playlist.name}\"؟", style: TextStyle(color: text)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text("إلغاء", style: TextStyle(color: accent))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                context.read<CustomPlaylistCubit>().deletePlaylist(playlist.id);
                Navigator.pop(ctx);
              },
              child: const Text("حذف"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playPlaylist(BuildContext context, CustomPlaylist playlist) async {
    if (playlist.surahNumbers.isEmpty) return;
    final firstSurah = playlist.surahNumbers.first;
    final lastAyah = _quranAyahCount[firstSurah - 1];
    await AudioPlayerManager.playMultipleAyahAsPlaylist(
      startAyahKey: "$firstSurah:1",
      endAyahKey: "$firstSurah:$lastAyah",
      reciterInfoModel: playlist.reciter,
      isInsideQuran: true,
      instantPlay: true,
    );
  }

  static const _quranAyahCount = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128, 111,
    110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73, 54, 45,
    83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60, 49, 62, 55,
    78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52, 44, 28, 28, 20,
    56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19, 26, 30, 20, 15, 21,
    30, 24, 13, 18, 7, 12, 19, 25, 36, 17, 12, 12, 30, 42, 5, 8, 8, 11, 11, 8,
    3, 9, 5, 4, 7, 3, 6, 3, 5, 4, 5, 6,
  ];
}

class _PlaylistCard extends StatelessWidget {
  final CustomPlaylist playlist;
  final Color surface;
  final bool isDark;
  final Color accent;
  final Color text;
  final Color sub;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _PlaylistCard({
    required this.playlist,
    required this.surface,
    required this.isDark,
    required this.accent,
    required this.text,
    required this.sub,
    required this.onPlay,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFFADB5BD).withValues(alpha: 0.1) : const Color(0xFFD6CCC2).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.queue_music_rounded, color: accent, size: 24),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(playlist.name, style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 16)),
                    const Gap(2),
                    Text("${playlist.surahNumbers.length} سورة • ${playlist.reciter.name}", style: TextStyle(color: sub, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(icon: Icon(Icons.play_circle_fill_rounded, color: accent, size: 32), onPressed: onPlay),
            ],
          ),
          const Gap(10),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: playlist.surahNumbers.take(12).map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text("$s", style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w600)),
            )).toList()
              ..addIf(playlist.surahNumbers.length > 12, Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text("+${playlist.surahNumbers.length - 12}", style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700)),
              )),
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: Icon(Icons.edit_rounded, size: 16, color: sub),
                label: Text("تعديل", style: TextStyle(color: sub, fontSize: 12)),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.withValues(alpha: 0.7)),
                label: Text("حذف", style: TextStyle(color: Colors.red.withValues(alpha: 0.7), fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension _WrapExtension on List<Widget> {
  void addIf(bool condition, Widget widget) {
    if (condition) add(widget);
  }
}
