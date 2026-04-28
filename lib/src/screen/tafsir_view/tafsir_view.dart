import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_furkan/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:al_furkan/src/resources/quran_resources/meta/meta_data_surah.dart";
import "package:al_furkan/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_furkan/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_furkan/src/screen/quran_resources/quran_resources_view.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_state.dart";
import "package:al_furkan/src/screen/surah_list_view/model/surah_info_model.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/utils/quran_resources/quran_script_function.dart";
import "package:al_furkan/src/utils/quran_resources/quran_tafsir_function.dart";
import "package:al_furkan/src/utils/quran_resources/quran_mutashabihat_function.dart";
import "package:al_furkan/src/utils/quran_resources/word_info_models.dart";
import "package:al_furkan/src/utils/quran_resources/word_info_repository.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf;
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:flutter_html/flutter_html.dart";
import "package:gap/gap.dart";
import "package:share_plus/share_plus.dart";
import "package:al_furkan/src/resources/quran_resources/quran_ayah_count.dart";
import "package:al_furkan/src/utils/quran_resources/quran_irab_function.dart";

class TafsirView extends StatefulWidget {
  final String ayahKey;
  const TafsirView({super.key, required this.ayahKey});

  @override
  State<TafsirView> createState() => _TafsirViewState();
}

class _TafsirViewState extends State<TafsirView>
    with SingleTickerProviderStateMixin {
  late SurahInfoModel surahInfoModel;
  late AppLocalizations appLocalizations;

  late List<TafsirBookModel> tafsirBookList;
  late TabController _tabController;

  static const List<String> _tabLabels = [
    "التفسير",
    "الإعراب",
    "الصرف",
    "القراءات",
    "المتشابهات",
  ];

  final WordInfoRepository _wordInfoRepo = WordInfoRepository();

  Future<_TafsirSectionsData>? _sectionsFuture;
  _TafsirSectionsData? _cachedSectionsData;
  int _selectedTab = 0;

  /// Tabs pinned as always-visible panels above the main content.
  /// Only ayah-level tabs (0,4) can be pinned.
  final Set<int> _pinnedTabs = {};
  /// Which pinned panels are currently collapsed.
  final Set<int> _collapsedPins = {};
  /// Custom tab order (original indices). Defaults to [0,1,2,3,4].
  List<int> _tabOrder = [0, 1, 2, 3, 4];

  /// Whether a tab index is ayah-level (can be pinned).
  /// Tabs 0 (tafsir), 4 (mutashabihat) are ayah-level.
  /// Tabs 1 (irab), 2 (sarf), 3 (qiraat) are word-level.
  static bool _isAyahLevelIndex(int i) => i == 0 || i == 4;

  /// The original tab index for the currently selected position.
  int get _selectedOriginalTab => _tabOrder[_selectedTab.clamp(0, _tabOrder.length - 1)];

  @override
  void initState() {
    surahInfoModel = SurahInfoModel.fromMap(
      metaDataSurah[widget.ayahKey.split(":").first]!,
    );
    tafsirBookList = [];
    _tabController = TabController(
      length: _tabLabels.length,
      vsync: this,
      initialIndex: _selectedTab.clamp(0, _tabLabels.length - 1),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      final v = _tabController.index;
      if (v != _selectedTab) {
        setState(() {
          _selectedTab = v;
          _isLoadingBooks = true;
        });
        _updateHighlightMode();
        _initBooks();
      }
    });
    super.initState();

    _initBooks();
    // Set initial highlight mode based on default tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHighlightMode();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Whether the current tab shows ayah-level info (not word-level).
  /// Tabs 0 (tafsir), 4 (mutashabihat) are ayah-level.
  /// Tabs 1 (irab), 2 (sarf), 3 (qiraat) are word-level.
  bool get _isAyahLevelTab => _selectedOriginalTab == 0 || _selectedOriginalTab == 4;

  /// Update the highlight in the reading view based on the selected tab.
  /// Ayah-level tabs → highlight the entire ayah (clear wordKey).
  /// Word-level tabs → keep word-level highlight if available.
  void _updateHighlightMode() {
    try {
      final cubit = context.read<AudioAyahHighlightCubit>();
      final currentState = cubit.state;
      if (currentState.activeAyahKey == null) return;

      if (_isAyahLevelTab) {
        // Ayah-level tab: clear word highlight so the entire ayah is highlighted
        cubit.updateHighlight(currentState.activeAyahKey, null);
      } else {
        // Word-level tab: restore word highlight if it was previously set
        // The word key format is ayahKey:wordIndex (e.g. "1:1:3")
        final wordKey = currentState.activeWordKey ??
            "${currentState.activeAyahKey}:1";
        cubit.updateHighlight(currentState.activeAyahKey, wordKey);
      }
    } catch (_) {
      // AudioAyahHighlightCubit might not be available in all contexts
    }
  }

  bool _isLoadingBooks = true;

  Future<void> _initBooks() async {
    // Tab 0 (tafsir) uses tafsirBookList — load if selected or pinned.
    // Other tabs load data directly from WordInfoRepository or their own functions.
    List<TafsirBookModel>? selected;
    if (_tabsNeedTafsirBook()) {
      selected = await QuranTafsirFunction.getTafsirSelections();
    }

    final books = selected ?? [];

    if (!mounted) return;
    setState(() {
      tafsirBookList = books;
      _isLoadingBooks = false;
      _sectionsFuture = _loadSections(
        surahIntroAyahKey: "${widget.ayahKey.split(":").first}:1",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);

    if (_isLoadingBooks) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            appLocalizations.tafsirAppBarTitle(
              getSurahName(context, surahInfoModel.id),
              getSurahNameArabic(surahInfoModel.id),
              widget.ayahKey,
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: context.read<ThemeCubit>().state.primaryShade100,
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : const Color(0xFFF6F0E7),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _modalHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                height: 44,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      width: 3,
                      color: context.read<ThemeCubit>().state.primary,
                    ),
                  ),
                  labelColor: isDark ? Colors.white : Colors.black87,
                  unselectedLabelColor: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.45),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  tabs: List.generate(_tabOrder.length, (i) {
                    final originalIdx = _tabOrder[i];
                    final isPinned = _pinnedTabs.contains(originalIdx);
                    return Tab(
                      height: 44,
                      child: GestureDetector(
                        onLongPress: () => _togglePin(originalIdx),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isPinned) ...[
                              Icon(Icons.push_pin_rounded, size: 12, color: context.read<ThemeCubit>().state.primary),
                              const Gap(3),
                            ],
                            Text(_tabLabels[originalIdx]),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Hint bar: pin + reorder hints
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 4),
              child: Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 11, color: isDark ? Colors.white24 : Colors.black26),
                  const Gap(3),
                  Text(
                    "ضغطة مطولة = تثبيت",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: isDark ? Colors.white24 : Colors.black26),
                  ),
                  const Gap(10),
                  Icon(Icons.reorder_rounded, size: 11, color: isDark ? Colors.white24 : Colors.black26),
                  const Gap(3),
                  Text(
                    "ترتيب = سحب",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: isDark ? Colors.white24 : Colors.black26),
                  ),
                ],
              ),
            ),
            Expanded(child: _sectionsBody()),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _getPreviousAyahKey(widget.ayahKey) == null
                      ? null
                      : () {
                          final prev = _getPreviousAyahKey(widget.ayahKey);
                          if (prev == null) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TafsirView(ayahKey: prev),
                            ),
                          );
                        },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text("السابق"),
                ),
              ),
              const Gap(10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.read<ThemeCubit>().state.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _getNextAyahKey(widget.ayahKey) == null
                      ? null
                      : () {
                          final next = _getNextAyahKey(widget.ayahKey);
                          if (next == null) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TafsirView(ayahKey: next),
                            ),
                          );
                        },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text("التالي"),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _modalHeader() {
    final themeState = context.read<ThemeCubit>().state;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 12, 8),
      child: Row(
        children: [
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuranResourcesView(initTab: 1),
                ),
              );
              if (!mounted) return;
              setState(() {
                _isLoadingBooks = true;
              });
              await _initBooks();
            },
            child: Text(
              "تحرير",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: themeState.primary,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _showReorderSheet,
            icon: Icon(Icons.reorder_rounded, size: 18, color: themeState.primary),
            label: Text(
              "ترتيب",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: themeState.primary,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            "الموارد",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  /// Toggle pin state for a tab. Only ayah-level tabs can be pinned.
  void _togglePin(int tabIndex) {
    if (!_isAyahLevelIndex(tabIndex)) return; // word-level tabs can't be pinned
    setState(() {
      if (_pinnedTabs.contains(tabIndex)) {
        _pinnedTabs.remove(tabIndex);
        _collapsedPins.remove(tabIndex);
      } else {
        _pinnedTabs.add(tabIndex);
      }
    });
    // Reload sections so pinned tabs get their data
    _isLoadingBooks = true;
    _initBooks();
  }

  /// Whether any active tab (selected or pinned) needs the tafsir book.
  bool _tabsNeedTafsirBook() {
    return _selectedOriginalTab == 0 || _pinnedTabs.contains(0);
  }

  /// Show bottom sheet for reordering tabs via drag-and-drop.
  void _showReorderSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = context.read<ThemeCubit>().state;
    // Work on a copy so we can cancel
    List<int> workingOrder = List.from(_tabOrder);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(
                      "ترتيب التبويبات",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setSheetState(() => workingOrder = [0, 1, 2, 3, 4, 5, 6, 7]);
                      },
                      child: Text(
                        "إعادة تعيين",
                        style: TextStyle(color: themeState.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Gap(8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: themeState.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Track which original index was selected before reorder
                        final selectedOriginal = _tabOrder[_selectedTab];
                        setState(() {
                          _tabOrder = List.from(workingOrder);
                          // Find the new position of the previously selected tab
                          _selectedTab = _tabOrder.indexOf(selectedOriginal).clamp(0, _tabOrder.length - 1);
                        });
                        _tabController.animateTo(_selectedTab);
                        Navigator.pop(context);
                      },
                      child: const Text("تطبيق"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ReorderableListView.builder(
                  scrollController: scrollController,
                  itemCount: workingOrder.length,
                  onReorder: (oldIndex, newIndex) {
                    setSheetState(() {
                      var adjustedIndex = newIndex;
                      if (adjustedIndex > oldIndex) adjustedIndex -= 1;
                      final item = workingOrder.removeAt(oldIndex);
                      workingOrder.insert(adjustedIndex, item);
                    });
                  },
                  proxyDecorator: (child, index, animation) => AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) => Transform.scale(
                      scale: 1.03 + 0.02 * animation.value,
                      child: child,
                    ),
                    child: child,
                  ),
                  itemBuilder: (context, index) {
                    final originalIdx = workingOrder[index];
                    final label = _tabLabels[originalIdx];
                    final isAyahLevel = _isAyahLevelIndex(originalIdx);
                    final isSelected = index == _selectedTab;
                    return Container(
                      key: ValueKey('reorder_$originalIdx'),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeState.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                            : isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F0E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? themeState.primary.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.drag_handle_rounded,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                        title: Text(
                          label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? themeState.primary
                                : isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAyahLevel)
                              Icon(
                                Icons.push_pin_rounded,
                                size: 14,
                                color: _pinnedTabs.contains(originalIdx)
                                    ? themeState.primary
                                    : isDark ? Colors.white24 : Colors.black12,
                              ),
                            const Gap(4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAyahLevel
                                    ? themeState.primary.withValues(alpha: 0.12)
                                    : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAyahLevel ? "آية" : "كلمة",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: isAyahLevel ? themeState.primary : (isDark ? Colors.white38 : Colors.black38),
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
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Build pinned panels that appear above the main content.
  /// Each pinned tab shows its content as a collapsible card.
  List<Widget> _buildPinnedPanels(_TafsirSectionsData data) {
    if (_pinnedTabs.isEmpty) return const [];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = context.read<ThemeCubit>().state;

    return _pinnedTabs.map((tabIndex) {
      final isCollapsed = _collapsedPins.contains(tabIndex);
      final label = _tabLabels[tabIndex];

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: themeState.primary.withValues(alpha: 0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Panel header — tap to collapse/expand, long-press to unpin
            GestureDetector(
              onTap: () => setState(() {
                if (isCollapsed) {
                  _collapsedPins.remove(tabIndex);
                } else {
                  _collapsedPins.add(tabIndex);
                }
              }),
              onLongPress: () => _togglePin(tabIndex),
              child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: themeState.primary.withValues(alpha: isDark ? 0.10 : 0.06),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(14),
                    bottom: isCollapsed
                        ? const Radius.circular(14)
                        : Radius.zero,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCollapsed
                          ? Icons.expand_more_rounded
                          : Icons.expand_less_rounded,
                      size: 18,
                      color: themeState.primary,
                    ),
                    const Gap(6),
                    Icon(Icons.push_pin_rounded, size: 14, color: themeState.primary),
                    const Gap(6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: themeState.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isCollapsed ? "مطوي" : "مثبّت",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Panel content (only when expanded)
            if (!isCollapsed) ...[
              Padding(
                padding: const EdgeInsets.all(10),
                child: _buildPinnedTabContent(tabIndex, data, isDark),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  /// Build the content widget for a pinned tab.
  Widget _buildPinnedTabContent(int tabIndex, _TafsirSectionsData data, bool isDark) {
    switch (tabIndex) {
      case 0: // التفسير
        final html = _removeBasmala(data.ayahTafsirHtml ?? "");
        if (html.isEmpty) return _emptyResourceCard("لا يوجد تفسير لهذه الآية.");
        return _sectionCard(title: "التفسير", html: html, shareTitle: "التفسير");
      case 4: // المتشابهات
        if (data.mutashabihatEntries == null || data.mutashabihatEntries!.isEmpty) {
          return _emptyResourceCard(
            QuranMutashabihatFunction.getDownloadedMutashabihatBooks().isEmpty
              ? "حمّل كتب المتشابهات من الموارد لعرض بيانات هذه الآية."
              : "لا توجد متشابهات مسجّلة لهذه الآية في الكتب المحملة.",
          );
        }
        return Column(
          children: data.mutashabihatEntries!.map((e) => _mutashabihatCard(e)).toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _sectionsBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<_TafsirSectionsData>(
      future: _sectionsFuture,
      builder: (context, snapshot) {
        if (_sectionsFuture == null) {
          return const SizedBox.shrink();
        }

        final data = snapshot.connectionState == ConnectionState.done
            ? snapshot.data
            : _cachedSectionsData;

        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          _cachedSectionsData = snapshot.data;
        }

        if (data == null) {
          return Center(child: Text(appLocalizations.tafsirNotAvailable(widget.ayahKey)));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          children: [
            // Pinned panels (always visible above main content)
            ..._buildPinnedPanels(data),
            if (_pinnedTabs.isNotEmpty) const Gap(8),

            // Display the Ayah text
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: context.read<ThemeCubit>().state.primaryShade100),
              ),
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<QuranViewCubit, QuranViewState>(
                builder: (context, state) {
                  final surah = int.parse(widget.ayahKey.split(":").first);
                  final ayah = int.parse(widget.ayahKey.split(":").last);
                  final words = QuranScriptFunction.getWordListOfAyah(
                    state.quranScriptType,
                    surah.toString(),
                    ayah.toString(),
                  );
                  final text = words.isNotEmpty
                      ? words.join(" ")
                      : qcf.getVerse(surah, ayah, verseEndSymbol: false);

                  return Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: context.watch<QuranSettingsCubit>().state.fontFamily.flutterFontFamily,
                      fontSize: state.translationFontSize + 6,
                      color: isDark ? Colors.white : Colors.black,
                      height: 1.8,
                    ),
                  );
                },
              ),
            ),
            const Gap(12),

            if (data.surahNamingHtml != null && data.surahNamingHtml!.trim().isNotEmpty)
              _sectionCard(
                title: "التفسير (العربية)",
                html: data.surahNamingHtml!,
                shareTitle: "تسمية السورة",
              ),

            if (data.surahObjectivesHtml != null &&
                data.surahObjectivesHtml!.trim().isNotEmpty) ...[
              const Gap(12),
              _sectionCard(
                title: "التفسير (العربية)",
                html: data.surahObjectivesHtml!,
                shareTitle: "مقاصد السورة",
              ),
            ],

            const Gap(12),
            if (_selectedOriginalTab == 0)
              _sectionCard(
                title: "التفسير (العربية)",
                html: _removeBasmala(data.ayahTafsirHtml ?? ""),
                shareTitle: "التفسير",
              ),

            if (_selectedOriginalTab == 1) ...[
              // Word-level Irab from WordInfoRepository (downloadable)
              if (data.eerabWords != null && data.eerabWords!.words.isNotEmpty)
                for (final w in data.eerabWords!.words)
                  _wordInfoCard(word: w.word, content: w.content, title: "الإعراب", hasKhilaf: w.hasKhilaf),
              // Fallback to bundled Irab
              if (data.eerabWords == null || data.eerabWords!.words.isEmpty)
                if (data.ayahTafsirHtml != null && data.ayahTafsirHtml!.isNotEmpty)
                  _sectionCard(title: "إعراب القرآن (الدعاس)", html: data.ayahTafsirHtml!, shareTitle: "الإعراب"),
              if ((data.eerabWords == null || data.eerabWords!.words.isEmpty) && (data.ayahTafsirHtml == null || data.ayahTafsirHtml!.isEmpty))
                _emptyResourceCard("لا توجد بيانات إعراب لهذه الآية. حمّل الإعراب من الموارد."),
            ],

            if (_selectedOriginalTab == 2) ...[
              if (data.tasreefWords != null && data.tasreefWords!.words.isNotEmpty)
                for (final w in data.tasreefWords!.words)
                  _wordInfoCard(word: w.word, content: w.content, title: "الصرف", hasKhilaf: w.hasKhilaf),
              if (data.tasreefWords == null || data.tasreefWords!.words.isEmpty)
                _emptyResourceCard("لا توجد بيانات صرف لهذه الآية. حمّل الصرف من الموارد."),
            ],

            if (_selectedOriginalTab == 3) ...[
              if (data.qiraatWords != null && data.qiraatWords!.words.isNotEmpty)
                for (final w in data.qiraatWords!.words)
                  _wordInfoCard(word: w.word, content: w.content, title: "القراءات", hasKhilaf: w.hasKhilaf),
              if (data.qiraatWords == null || data.qiraatWords!.words.isEmpty)
                _emptyResourceCard("لا توجد بيانات قراءات لهذه الآية. حمّل القراءات من الموارد."),
            ],

            if (_selectedOriginalTab == 4) ...[
              if (data.mutashabihatEntries != null && data.mutashabihatEntries!.isNotEmpty)
                for (final entry in data.mutashabihatEntries!)
                  _mutashabihatCard(entry),
              if (data.mutashabihatEntries == null || data.mutashabihatEntries!.isEmpty)
                _emptyResourceCard(
                  QuranMutashabihatFunction.getDownloadedMutashabihatBooks().isEmpty
                    ? "حمّل كتب المتشابهات من الموارد لعرض بيانات هذه الآية."
                    : "لا توجد متشابهات مسجّلة لهذه الآية في الكتب المحملة.",
                ),
            ],

            const Gap(12),
          ],
        );
      },
    );
  }

  Future<_TafsirSectionsData> _loadSections({required String surahIntroAyahKey}) async {
    final TafsirBookModel? tafsirBook = tafsirBookList.isEmpty ? null : tafsirBookList.first;

    final String? surahIntroTafsirHtml = tafsirBook == null || !_tabsNeedTafsirBook()
        ? null
        : await QuranTafsirFunction.getResolvedTafsirTextForBook(
            tafsirBook,
            surahIntroAyahKey,
          );

    String? ayahTafsirHtml;
    QiraatAyahWords? eerabWords;
    QiraatAyahWords? tasreefWords;
    QiraatAyahWords? qiraatWords;
    List<Map<String, dynamic>>? mutashabihatEntries;

    final surahNum = int.tryParse(widget.ayahKey.split(":").first) ?? 1;
    final ayahNum = int.tryParse(widget.ayahKey.split(":").last) ?? 1;

    // Tabs that need data: the selected tab (original index) + any pinned tabs
    final tabsToLoad = {_selectedOriginalTab, ..._pinnedTabs};

    for (final tab in tabsToLoad) {
      if (tab == 0) {
        if (tafsirBook != null && ayahTafsirHtml == null) {
          ayahTafsirHtml = await QuranTafsirFunction.getResolvedTafsirTextForBook(
            tafsirBook,
            widget.ayahKey,
          );
        }
      } else if (tab == 1) {
        if (_wordInfoRepo.isKindDownloaded(WordInfoKind.eerab) && eerabWords == null) {
          eerabWords = await _wordInfoRepo.getAyahWords(
            kind: WordInfoKind.eerab, surahNumber: surahNum, ayahNumber: ayahNum,
          );
        }
        ayahTafsirHtml ??= await QuranIrabFunction.getIrabText(widget.ayahKey);
      } else if (tab == 2) {
        if (_wordInfoRepo.isKindDownloaded(WordInfoKind.tasreef) && tasreefWords == null) {
          tasreefWords = await _wordInfoRepo.getAyahWords(
            kind: WordInfoKind.tasreef, surahNumber: surahNum, ayahNumber: ayahNum,
          );
        }
      } else if (tab == 3) {
        if (_wordInfoRepo.isKindDownloaded(WordInfoKind.recitations) && qiraatWords == null) {
          qiraatWords = await _wordInfoRepo.getAyahWords(
            kind: WordInfoKind.recitations, surahNumber: surahNum, ayahNumber: ayahNum,
          );
        }
      } else if (tab == 4) {
        if (mutashabihatEntries == null) {
          var books = await QuranMutashabihatFunction.getMutashabihatSelections() ?? [];
          if (books.isEmpty) {
            books = QuranMutashabihatFunction.getDownloadedMutashabihatBooks();
          }
          for (final book in books) {
            final data = await QuranMutashabihatFunction.getMutashabihatForAyah(book, widget.ayahKey);
            if (data != null && data.isNotEmpty) {
              mutashabihatEntries ??= [];
              mutashabihatEntries.addAll(data);
            }
          }
        }
      }
    }

    return _TafsirSectionsData(
      surahNamingHtml: _extractSectionHtml(surahIntroTafsirHtml, "تسمية السورة"),
      surahObjectivesHtml: _extractSectionHtml(surahIntroTafsirHtml, "من مقاصد السورة"),
      ayahTafsirHtml: ayahTafsirHtml,
      eerabWords: eerabWords,
      tasreefWords: tasreefWords,
      qiraatWords: qiraatWords,
      mutashabihatEntries: mutashabihatEntries,
    );
  }

  String? _extractSectionHtml(String? html, String title) {
    if (html == null || html.trim().isEmpty) return null;

    // Prefer QUL-style <h3>Title</h3> sections.
    final pattern = RegExp(
      r"<h3>\s*${RegExp.escape(title)}\s*<\/h3>([\s\S]*?)(?=<h3>|$)",
      caseSensitive: false,
    );
    final match = pattern.firstMatch(html);
    if (match == null) return null;

    final content = match.group(1);
    if (content == null) return null;
    return content.trim();
  }

  Widget _sectionCard({
    required String title,
    required String html,
    required String shareTitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = context.read<ThemeCubit>().state;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: themeState.primaryShade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final buffer = StringBuffer()
                      ..writeln(shareTitle)
                      ..writeln()
                      ..writeln(_stripHtml(html));
                    await SharePlus.instance.share(
                      ShareParams(text: buffer.toString(), subject: shareTitle),
                    );
                  },
                  icon: Icon(Icons.share_rounded, color: themeState.primary),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: themeState.primary.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 16),
            child: BlocBuilder<QuranViewCubit, QuranViewState>(
              builder: (context, state) {
                final themeState = context.read<ThemeCubit>().state;
                final processedHtml = _wrapBracketsWithQuranStyle(html, themeState.primary, isDark: isDark);
                return Html(
                  data: processedHtml.isEmpty
                      ? "<div class=ar lang=ar><p>${appLocalizations.tafsirNotAvailable(widget.ayahKey)}</p></div>"
                      : processedHtml,
                  style: {
                    "*": Style(
                      padding: HtmlPaddings.zero,
                      margin: Margins.zero,
                      fontSize: FontSize(state.translationFontSize),
                      lineHeight: const LineHeight(1.8),
                      textAlign: TextAlign.justify,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    "p": Style(
                      textAlign: TextAlign.justify,
                    ),
                    ".quran-ayah": Style(
                      fontFamily: context.watch<QuranSettingsCubit>().state.fontFamily.flutterFontFamily,
                      fontSize: FontSize(state.translationFontSize + 2),
                      color: isDark ? themeState.primary : const Color(0xFF9E7C0A),
                      fontWeight: FontWeight.w500,
                    ),
                    ".bracket-accent": Style(
                      color: isDark ? const Color(0xFFCD853F) : const Color(0xFF8B5E3C),
                      fontWeight: FontWeight.w700,
                    ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Wraps text inside brackets with styled spans:
  /// - ﴿...﴾ / ﴁ...ﴂ → Uthmani font + primary color (Quran ayah)
  /// - {...} → Uthmani font + primary color (curly brackets)
  /// - [...] → primary color only (square brackets)
  String _wrapBracketsWithQuranStyle(String html, Color primaryColor, {bool isDark = false}) {
    if (html.trim().isEmpty) return html;

    // {} → golden yellow, [] → warm amber
    final curlyHex = isDark ? '#E6B422' : '#9E7C0A';
    final squareHex = isDark ? '#CD853F' : '#8B5E3C';
    final quranHex = isDark ? '#${primaryColor.toARGB32().toRadixString(16).padLeft(8, '').substring(2)}' : curlyHex;

    // Wrap ﴿...﴾ and ﴁ...ﴂ patterns (Quran ayah)
    final quranPattern = RegExp(r'[﴿ﴁ][\s\S]*?[﴾ﴂ]', unicode: true);
    var result = html.replaceAllMapped(quranPattern, (match) {
      return '<span class="quran-ayah" style="color:$quranHex">${match.group(0)}</span>';
    });

    // Wrap {...} patterns (curly brackets → Uthmani font + golden yellow)
    final curlyPattern = RegExp(r'\{[^\}]+\}');
    result = result.replaceAllMapped(curlyPattern, (match) {
      return '<span class="quran-ayah" style="color:$curlyHex">${match.group(0)}</span>';
    });

    // Wrap [...] patterns (square brackets → warm amber)
    final squarePattern = RegExp(r'\[[^\]]+\]');
    result = result.replaceAllMapped(squarePattern, (match) {
      return '<span class="bracket-accent" style="color:$squareHex;font-weight:700">${match.group(0)}</span>';
    });

    return result;
  }

  String _removeBasmala(String input) {
    return input
        .replaceAll("بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ", "")
        .replaceAll("بسم الله الرحمن الرحيم", "")
        .trim();
  }

  String? _getPreviousAyahKey(String ayahKey) {
    final parts = ayahKey.split(":");
    if (parts.length != 2) return null;
    final surah = int.tryParse(parts.first);
    final ayah = int.tryParse(parts.last);
    if (surah == null || ayah == null) return null;

    if (ayah > 1) return "$surah:${ayah - 1}";
    if (surah <= 1) return null;
    final prevSurah = surah - 1;
    final lastAyah = quranAyahCount[prevSurah - 1];
    return "$prevSurah:$lastAyah";
  }

  String? _getNextAyahKey(String ayahKey) {
    final parts = ayahKey.split(":");
    if (parts.length != 2) return null;
    final surah = int.tryParse(parts.first);
    final ayah = int.tryParse(parts.last);
    if (surah == null || ayah == null) return null;

    final maxAyah = quranAyahCount[surah - 1];
    if (ayah < maxAyah) return "$surah:${ayah + 1}";
    if (surah >= 114) return null;
    return "${surah + 1}:1";
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r"<[^>]*>"), "")
        .replaceAll("&nbsp;", " ")
        .replaceAll("&amp;", "&")
        .replaceAll("&quot;", '"')
        .replaceAll("&#39;", "'")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }

  Widget _emptyResourceCard(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = context.read<ThemeCubit>().state;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: themeState.primary.withValues(alpha: isDark ? 0.12 : 0.08),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeState.primary.withValues(alpha: isDark ? 0.08 : 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 28,
              color: themeState.primary.withValues(alpha: 0.45),
            ),
          ),
          const Gap(12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black54,
              height: 1.7,
            ),
          ),
          const Gap(14),
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranResourcesView(
                    initTab: switch (_selectedOriginalTab) {
                      0 => 1,      // tafsir → resources tab 1 (التفاسير)
                      1 || 2 || 3 => 2, // irab/sarf/qiraat → resources tab 2 (بيانات الكلمات)
                      4 => 3,      // mutashabihat → resources tab 3 (المتشابهات)
                      _ => 0,
                    },
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text("تحميل الموارد"),
            style: FilledButton.styleFrom(
              backgroundColor: themeState.primary.withValues(alpha: isDark ? 0.15 : 0.08),
              foregroundColor: themeState.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TafsirSectionsData {
  final String? surahNamingHtml;
  final String? surahObjectivesHtml;
  final String? ayahTafsirHtml;
  final QiraatAyahWords? eerabWords;
  final QiraatAyahWords? tasreefWords;
  final QiraatAyahWords? qiraatWords;
  final List<Map<String, dynamic>>? mutashabihatEntries;

  const _TafsirSectionsData({
    required this.surahNamingHtml,
    required this.surahObjectivesHtml,
    required this.ayahTafsirHtml,
    this.eerabWords,
    this.tasreefWords,
    this.qiraatWords,
    this.mutashabihatEntries,
  });
}

/// Card for word-level info (Eerab, Tasreef, Qiraat)
extension _WordInfoCard on _TafsirViewState {
  Widget _wordInfoCard({
    required String word,
    required String content,
    required String title,
    bool hasKhilaf = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = context.read<ThemeCubit>().state;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: themeState.primaryShade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    final buffer = StringBuffer()
                      ..writeln('$title: $word')
                      ..writeln()
                      ..writeln(content);
                    await SharePlus.instance.share(
                      ShareParams(text: buffer.toString(), subject: title),
                    );
                  },
                  icon: Icon(Icons.share_rounded, color: themeState.primary),
                ),
                if (hasKhilaf)
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: themeState.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'خلاف',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: themeState.primary,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  word,
                  style: TextStyle(
                    fontFamily: context.watch<QuranSettingsCubit>().state.fontFamily.flutterFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: themeState.primary.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 16),
              child: Text(
                content,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.8,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Card for displaying mutashabihat (similar ayahs) entries
extension _MutashabihatCard on _TafsirViewState {
  Widget _mutashabihatCard(Map<String, dynamic> entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = context.read<ThemeCubit>().state;
    final text = entry['text']?.toString() ?? entry['ayah_text']?.toString() ?? '';
    final surah = entry['surah']?.toString() ?? entry['surah_name']?.toString() ?? '';
    // Build display from muts (similar ayahs)
    final muts = entry['muts'];
    final mutsDisplay = <String>[];
    if (muts is List) {
      for (final m in muts) {
        if (m is Map) {
          final key = m['ayah_key']?.toString();
          if (key != null && key.isNotEmpty) mutsDisplay.add(key);
        }
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: themeState.primaryShade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await SharePlus.instance.share(
                      ShareParams(text: text.isNotEmpty ? text : surah.isNotEmpty ? surah : 'متشابهات', subject: 'متشابهات'),
                    );
                  },
                  icon: Icon(Icons.share_rounded, color: themeState.primary),
                ),
                const Spacer(),
                Text(
                  surah.isNotEmpty ? surah : 'متشابهات',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: themeState.primary.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
          if (text.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(14, 0, 14, mutsDisplay.isNotEmpty ? 8.0 : 16.0),
              child: Text(
                text,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: context.watch<QuranSettingsCubit>().state.fontFamily.flutterFontFamily,
                  fontSize: 18,
                  height: 1.9,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          if (mutsDisplay.isNotEmpty)
            Container(
              margin: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: themeState.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'متشابهات: ${mutsDisplay.join("، ")}',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
