import "package:al_quran_v3/src/core/navigation/wahy_page_route.dart";
import "package:al_quran_v3/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_quran_v3/src/resources/quran_resources/meta/meta_data_surah.dart";
import "package:al_quran_v3/src/screen/collections/collection_page.dart";
import "package:al_quran_v3/src/screen/mushaf/wahy_library_store.dart";
import "package:al_quran_v3/src/screen/smart_khatma/smart_khatma_page.dart";
import "package:al_quran_v3/src/screen/surah_list_view/model/surah_info_model.dart";
import "package:al_quran_v3/src/utils/number_localization.dart";
import "package:al_quran_v3/src/utils/quran_ayahs_function/get_page_number.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_script_function.dart";
import "package:al_quran_v3/src/widget/quran_script/model/script_info.dart";
import "package:flutter/material.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

class AyaIndexPage extends StatefulWidget {
  final int initialTabIndex;
  final bool isEmbedded;
  final void Function(int page, String ayahKey)? onOpenLocation;

  const AyaIndexPage({
    super.key,
    this.initialTabIndex = 4,
    this.isEmbedded = false,
    this.onOpenLocation,
  });

  @override
  State<AyaIndexPage> createState() => _AyaIndexPageState();
}

class _AyaIndexPageState extends State<AyaIndexPage> {
  static const List<_AyaIndexTabConfig> _tabs = <_AyaIndexTabConfig>[
    _AyaIndexTabConfig(
      label: "ملاحظات",
      title: "ملاحظات الآيات",
      subtitle: "أحدث الملاحظات مع وصول سريع لمجموعاتك",
      icon: Icons.sticky_note_2_rounded,
      emptyTitle: "لا توجد ملاحظات بعد",
      emptyMessage: "عندما تضيف ملاحظة من المصحف ستظهر هنا مباشرة.",
      searchHint: "ابحث في الملاحظات",
    ),
    _AyaIndexTabConfig(
      label: "المميزة",
      title: "الآيات المميزة",
      subtitle: "كل الآيات التي علمتها بنجمة في مكان واحد",
      icon: Icons.star_rounded,
      emptyTitle: "لا توجد آيات مميزة",
      emptyMessage: "استخدم النجمة داخل المصحف لحفظ الآيات المهمة بسرعة.",
      searchHint: "ابحث في المميزة",
    ),
    _AyaIndexTabConfig(
      label: "الفواصل",
      title: "الفواصل المحفوظة",
      subtitle: "فواصلك الملونة ومواقع العودة إلى القراءة",
      icon: Icons.bookmark_rounded,
      emptyTitle: "لا توجد فواصل محفوظة",
      emptyMessage: "احفظ مواضع الوقوف من المصحف لتعود لها لاحقًا.",
      searchHint: "ابحث في الفواصل",
    ),
    _AyaIndexTabConfig(
      label: "الختمة",
      title: "الختمة",
      subtitle: "وردك اليومي وتقدمك الحالي في متابعة القراءة",
      icon: Icons.auto_awesome_rounded,
      emptyTitle: "",
      emptyMessage: "",
      searchHint: "",
      searchable: false,
    ),
    _AyaIndexTabConfig(
      label: "السور",
      title: "فهرس السور",
      subtitle: "تنقل مباشر بين السور والصفحات بنظرة أوضح",
      icon: Icons.format_list_bulleted_rounded,
      emptyTitle: "تعذر تحميل السور",
      emptyMessage: "أعد فتح الصفحة أو حاول مرة أخرى.",
      searchHint: "ابحث باسم السورة أو رقمها",
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  final Map<String, _AyahSnapshot> _ayahCache = <String, _AyahSnapshot>{};
  final Map<int, String> _searchDrafts = <int, String>{};

  int _selectedIndex = 0;
  bool _metaLoaded = surahNameLocalization.isNotEmpty;
  bool _syncingSearchText = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex.clamp(0, _tabs.length - 1);
    _searchController.addListener(_handleSearchChanged);
    if (!_metaLoaded) {
      loadMetaSurah().then((_) {
        if (!mounted) return;
        setState(() => _metaLoaded = true);
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    if (_syncingSearchText) return;
    setState(() {});
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    _searchDrafts[_selectedIndex] = _searchController.text;
    _selectedIndex = index;
    _setSearchText(_searchDrafts[index] ?? "");
    setState(() {});
  }

  void _setSearchText(String value) {
    _syncingSearchText = true;
    _searchController
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
    _syncingSearchText = false;
  }

  String get _searchQuery => _searchController.text.trim();

  _AyahSnapshot _resolveAyahSnapshot(String ayahKey) {
    return _ayahCache.putIfAbsent(ayahKey, () {
      final parts = ayahKey.split(":");
      final surahNumber = int.tryParse(parts.isNotEmpty ? parts[0] : "") ?? 1;
      final verseNumber = int.tryParse(parts.length > 1 ? parts[1] : "") ?? 1;
      return _AyahSnapshot(
        ayahKey: ayahKey,
        surahNumber: surahNumber,
        verseNumber: verseNumber,
        surahName: getSurahNameArabic(surahNumber),
        pageNumber: getPageNumber(ayahKey) ?? 1,
        preview: _buildAyahPreview(ayahKey),
      );
    });
  }

  String _buildAyahPreview(String ayahKey) {
    final parts = ayahKey.split(":");
    if (parts.length != 2) return "";
    try {
      final words = QuranScriptFunction.getWordListOfAyah(
        QuranScriptType.tajweed,
        parts[0],
        parts[1],
      );
      return words
          .map(
            (word) => word
                .replaceAll(RegExp(r"<[^>]+>"), "")
                .replaceAll("\uFD3E", "")
                .replaceAll("\uFD3F", "")
                .replaceAll(RegExp(r"[0-9\u0660-\u0669]+"), "")
                .trim(),
          )
          .where((word) => word.isNotEmpty)
          .join(" ");
    } catch (_) {
      return "";
    }
  }

  Future<void> _openAyah(String ayahKey) async {
    final snapshot = _resolveAyahSnapshot(ayahKey);
    final onOpenLocation = widget.onOpenLocation;
    if (onOpenLocation != null) {
      onOpenLocation(snapshot.pageNumber, ayahKey);
      return;
    }
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, <String, dynamic>{
        "page": snapshot.pageNumber,
        "ayahKey": ayahKey,
      });
    }
  }

  String _normalizeForSearch(String value) {
    const diacritics =
        "\u0610\u0611\u0612\u0613\u0614\u0615\u0616\u0617\u0618\u0619\u061A"
        "\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0653\u0654\u0655"
        "\u0656\u0657\u0658\u0659\u065A\u065B\u065C\u065D\u065E\u065F\u0670"
        "\u06D6\u06D7\u06D8\u06D9\u06DA\u06DB\u06DC\u06DF\u06E0\u06E1\u06E2"
        "\u06E3\u06E4\u06E7\u06E8\u06EA\u06EB\u06EC\u06ED";
    return value
        .toLowerCase()
        .replaceAll(RegExp("[$diacritics]"), "")
        .replaceAll("أ", "ا")
        .replaceAll("إ", "ا")
        .replaceAll("آ", "ا")
        .replaceAll("ٱ", "ا")
        .replaceAll("ى", "ي")
        .replaceAll("ؤ", "و")
        .replaceAll("ئ", "ي")
        .replaceAll("ة", "ه")
        .replaceAll("ـ", "")
        .replaceAll(RegExp(r"[^\p{L}\p{N}\s]+", unicode: true), " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }

  bool _matchesQuery(Iterable<String> values, String query) {
    if (query.isEmpty) return true;
    final normalizedQuery = _normalizeForSearch(query);
    return values.any(
      (value) => _normalizeForSearch(value).contains(normalizedQuery),
    );
  }

  Future<void> _openNotesCollections() async {
    await Navigator.of(context).push(
      WahyPageRoute(
        page: CollectionPage(
          collectionType: CollectionType.notes,
          onOpenLocation: widget.onOpenLocation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userBox = Hive.box("user");
    final currentTab = _tabs[_selectedIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ValueListenableBuilder<Box<dynamic>>(
        valueListenable: userBox.listenable(
          keys: const <String>[
            WahyLibraryStore.notesKey,
            WahyLibraryStore.starredKey,
            WahyLibraryStore.bookmarksKey,
          ],
        ),
        builder: (context, box, _) {
          final notes = WahyLibraryStore.loadNotes();
          final starred = WahyLibraryStore.loadStarred();
          final bookmarks = WahyLibraryStore.loadBookmarks();

          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: SafeArea(
              top: true,
              bottom: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      colorScheme.surface,
                      colorScheme.surfaceContainerLowest,
                    ],
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    _buildHeader(
                      colorScheme: colorScheme,
                      currentTab: currentTab,
                      notesCount: notes.length,
                      starredCount: starred.length,
                      bookmarksCount: bookmarks.length,
                    ),
                    if (currentTab.searchable)
                      _buildSearchField(colorScheme, currentTab.searchHint),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: KeyedSubtree(
                          key: ValueKey<int>(_selectedIndex),
                          child: _buildCurrentTab(
                            colorScheme: colorScheme,
                            notes: notes,
                            starred: starred,
                            bookmarks: bookmarks,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomTabs(colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildHeader({
    required ColorScheme colorScheme,
    required _AyaIndexTabConfig currentTab,
    required int notesCount,
    required int starredCount,
    required int bookmarksCount,
  }) {
    final primary = colorScheme.primary;
    final onSurface = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                tooltip: widget.isEmbedded ? "إغلاق" : "رجوع",
                icon: Icon(
                  widget.isEmbedded
                      ? Icons.close_rounded
                      : Icons.arrow_back_ios_new_rounded,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      currentTab.title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTab.subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: onSurface.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: primary.withValues(alpha: 0.12)),
            ),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _MetricChip(
                  label: "الملاحظات",
                  value: notesCount.toString(),
                  icon: Icons.sticky_note_2_rounded,
                  color: primary,
                ),
                _MetricChip(
                  label: "المميزة",
                  value: starredCount.toString(),
                  icon: Icons.star_rounded,
                  color: const Color(0xFFCE8B00),
                ),
                _MetricChip(
                  label: "الفواصل",
                  value: bookmarksCount.toString(),
                  icon: Icons.bookmark_rounded,
                  color: const Color(0xFF2962FF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme, String hintText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: "مسح",
                    onPressed: () => _setSearchText(""),
                    icon: const Icon(Icons.close_rounded),
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab({
    required ColorScheme colorScheme,
    required List<Map<String, dynamic>> notes,
    required List<String> starred,
    required List<Map<String, dynamic>> bookmarks,
  }) {
    switch (_selectedIndex) {
      case 0:
        return _buildNotesTab(colorScheme, notes);
      case 1:
        return _buildStarredTab(colorScheme, starred);
      case 2:
        return _buildBookmarksTab(colorScheme, bookmarks);
      case 3:
        return _buildKhatmaTab();
      case 4:
        return _buildSurahsTab();
    }
    return const SizedBox.shrink();
  }

  Widget _buildNotesTab(
    ColorScheme colorScheme,
    List<Map<String, dynamic>> notes,
  ) {
    final query = _searchQuery;
    final indexedNotes = notes
        .asMap()
        .entries
        .map((entry) {
          final note = entry.value;
          final ayahKey = note["ayahKey"] as String? ?? "";
          return _NoteListItem(
            originalIndex: entry.key,
            text: note["text"] as String? ?? "",
            createdAt: note["createdAt"] as String?,
            snapshot: _resolveAyahSnapshot(ayahKey),
          );
        })
        .where(
          (item) => _matchesQuery(<String>[
            item.text,
            item.snapshot.surahName,
            item.snapshot.preview,
            item.snapshot.ayahKey,
          ], query),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
      children: <Widget>[
        _NotesCollectionsCard(onTap: _openNotesCollections),
        const SizedBox(height: 12),
        if (indexedNotes.isEmpty)
          _EmptyStateCard(
            icon: Icons.sticky_note_2_rounded,
            title: _tabs[0].emptyTitle,
            message: query.isEmpty
                ? _tabs[0].emptyMessage
                : "لا توجد نتيجة تطابق بحثك داخل الملاحظات الحالية.",
          )
        else
          ...indexedNotes.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AyahLibraryCard(
                key: ValueKey<String>(
                  "note-${item.snapshot.ayahKey}-${item.originalIndex}",
                ),
                title:
                    "${item.snapshot.surahName} • الآية ${localizedNumber(context, item.snapshot.verseNumber)}",
                subtitle: item.text,
                preview: item.snapshot.preview,
                metaLabel:
                    "الصفحة ${localizedNumber(context, item.snapshot.pageNumber)}${_formatCreatedAt(item.createdAt) == null ? "" : " • ${_formatCreatedAt(item.createdAt)!}"}",
                icon: Icons.sticky_note_2_rounded,
                iconColor: colorScheme.primary,
                accentColor: colorScheme.primary.withValues(alpha: 0.14),
                onTap: () => _openAyah(item.snapshot.ayahKey),
                trailing: IconButton(
                  tooltip: "حذف",
                  onPressed: () =>
                      WahyLibraryStore.removeNoteAt(item.originalIndex),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStarredTab(ColorScheme colorScheme, List<String> starred) {
    final items = starred
        .map(_resolveAyahSnapshot)
        .where(
          (item) => _matchesQuery(<String>[
            item.surahName,
            item.preview,
            item.ayahKey,
            item.verseNumber.toString(),
          ], _searchQuery),
        )
        .toList();

    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
        children: <Widget>[
          _EmptyStateCard(
            icon: Icons.star_rounded,
            title: _tabs[1].emptyTitle,
            message: _searchQuery.isEmpty
                ? _tabs[1].emptyMessage
                : "لا توجد نتيجة تطابق بحثك داخل الآيات المميزة.",
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _AyahLibraryCard(
          title:
              "${item.surahName} • الآية ${localizedNumber(context, item.verseNumber)}",
          subtitle: "مميزة للوصول السريع",
          preview: item.preview,
          metaLabel: "الصفحة ${localizedNumber(context, item.pageNumber)}",
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFCE8B00),
          accentColor: const Color(0xFFFFF3D4),
          onTap: () => _openAyah(item.ayahKey),
          trailing: IconButton(
            tooltip: "إلغاء التمييز",
            onPressed: () => WahyLibraryStore.toggleStar(item.ayahKey),
            icon: const Icon(Icons.star_rounded),
          ),
        );
      },
    );
  }

  Widget _buildBookmarksTab(
    ColorScheme colorScheme,
    List<Map<String, dynamic>> bookmarks,
  ) {
    final items = bookmarks
        .map((bookmark) {
          final ayahKey = bookmark["ayahKey"] as String? ?? "";
          return _BookmarkListItem(
            colorId: bookmark["color"] as String? ?? "green",
            updatedAt: bookmark["updatedAt"] as String?,
            snapshot: _resolveAyahSnapshot(ayahKey),
          );
        })
        .where(
          (item) => _matchesQuery(<String>[
            item.snapshot.surahName,
            item.snapshot.preview,
            item.snapshot.ayahKey,
            item.colorId,
          ], _searchQuery),
        )
        .toList();

    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
        children: <Widget>[
          _EmptyStateCard(
            icon: Icons.bookmark_rounded,
            title: _tabs[2].emptyTitle,
            message: _searchQuery.isEmpty
                ? _tabs[2].emptyMessage
                : "لا توجد نتيجة تطابق بحثك داخل الفواصل الحالية.",
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final color = _bookmarkColor(item.colorId, colorScheme.primary);
        return _AyahLibraryCard(
          title:
              "${item.snapshot.surahName} • الآية ${localizedNumber(context, item.snapshot.verseNumber)}",
          subtitle: _bookmarkLabel(item.colorId),
          preview: item.snapshot.preview,
          metaLabel:
              "الصفحة ${localizedNumber(context, item.snapshot.pageNumber)}${_formatCreatedAt(item.updatedAt) == null ? "" : " • ${_formatCreatedAt(item.updatedAt)!}"}",
          icon: Icons.bookmark_rounded,
          iconColor: color,
          accentColor: color.withValues(alpha: 0.12),
          onTap: () => _openAyah(item.snapshot.ayahKey),
          trailing: IconButton(
            tooltip: "حذف",
            onPressed: () =>
                WahyLibraryStore.removeBookmark(item.snapshot.ayahKey),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        );
      },
    );
  }

  Widget _buildKhatmaTab() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 92),
      child: SmartKhatmaPage(),
    );
  }

  Widget _buildSurahsTab() {
    if (!_metaLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final surahList = _searchQuery.isEmpty
        ? metaDataSurah.values.map(SurahInfoModel.fromMap).toList()
        : metaDataSurah.values
              .map(SurahInfoModel.fromMap)
              .where(
                (surah) => _matchesQuery(<String>[
                  surah.id.toString(),
                  getSurahName(context, surah.id),
                  getSurahNameArabic(surah.id),
                  getSurahMeaning(context, surah.id),
                ], _searchQuery),
              )
              .toList();

    if (surahList.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
        children: const <Widget>[
          _EmptyStateCard(
            icon: Icons.format_list_bulleted_rounded,
            title: "لا توجد سورة مطابقة",
            message: "غيّر صيغة البحث أو ابحث باسم السورة أو رقمها.",
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
      itemCount: surahList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final surah = surahList[index];
        return _SurahCard(
          surah: surah,
          title: getSurahName(context, surah.id),
          arabicTitle: getSurahNameArabic(surah.id),
          meaning: getSurahMeaning(context, surah.id),
          onTap: () => _openAyah("${surah.id}:1"),
        );
      },
    );
  }

  Widget _buildBottomTabs(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: List<Widget>.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              return Expanded(
                child: _BottomTabItem(
                  label: tab.label,
                  icon: tab.icon,
                  selected: index == _selectedIndex,
                  color: colorScheme.primary,
                  onTap: () => _selectTab(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _bookmarkLabel(String colorId) {
    switch (colorId) {
      case "red":
        return "فاصل أحمر";
      case "yellow":
        return "فاصل أصفر";
      case "blue":
        return "فاصل أزرق";
      case "green":
      default:
        return "فاصل أخضر";
    }
  }

  Color _bookmarkColor(String colorId, Color primary) {
    switch (colorId) {
      case "red":
        return const Color(0xFFB3261E);
      case "yellow":
        return const Color(0xFFB68A00);
      case "blue":
        return const Color(0xFF2962FF);
      case "green":
      default:
        return primary;
    }
  }

  String? _formatCreatedAt(String? iso) {
    final dateTime = DateTime.tryParse(iso ?? "")?.toLocal();
    if (dateTime == null) return null;
    return "${localizedNumber(context, dateTime.day)}/${localizedNumber(context, dateTime.month)}";
  }
}

class _AyaIndexTabConfig {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final String emptyTitle;
  final String emptyMessage;
  final String searchHint;
  final bool searchable;

  const _AyaIndexTabConfig({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.searchHint,
    this.searchable = true,
  });
}

class _AyahSnapshot {
  final String ayahKey;
  final int surahNumber;
  final int verseNumber;
  final String surahName;
  final int pageNumber;
  final String preview;

  const _AyahSnapshot({
    required this.ayahKey,
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
    required this.pageNumber,
    required this.preview,
  });
}

class _NoteListItem {
  final int originalIndex;
  final String text;
  final String? createdAt;
  final _AyahSnapshot snapshot;

  const _NoteListItem({
    required this.originalIndex,
    required this.text,
    required this.createdAt,
    required this.snapshot,
  });
}

class _BookmarkListItem {
  final String colorId;
  final String? updatedAt;
  final _AyahSnapshot snapshot;

  const _BookmarkListItem({
    required this.colorId,
    required this.updatedAt,
    required this.snapshot,
  });
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w900, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NotesCollectionsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _NotesCollectionsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: Hive.box(CollectionType.notes.name).listenable(),
      builder: (context, box, _) {
        final count = box.length;
        final label = count == 0 ? "ابدأ أول مجموعة" : "$count مجموعات جاهزة";
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.folder_copy_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        const Text(
                          "مجموعات الملاحظات",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.65,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AyahLibraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String preview;
  final String metaLabel;
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const _AyahLibraryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.preview,
    required this.metaLabel,
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (trailing != null) ...<Widget>[
                trailing!,
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                title,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  height: 1.45,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.76,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: iconColor),
                        ),
                      ],
                    ),
                    if (preview.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        preview,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1.7,
                          fontFamily: "Uthmanic",
                          fontSize: 15,
                          color: colorScheme.onSurface.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        metaLabel,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.55,
              color: colorScheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final SurahInfoModel surah;
  final String title;
  final String arabicTitle;
  final String meaning;
  final VoidCallback onTap;

  const _SurahCard({
    required this.surah,
    required this.title,
    required this.arabicTitle,
    required this.meaning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final revelationLabel = surah.revelationPlace == "makkah"
        ? "مكية"
        : "مدنية";
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.chevron_left_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                title,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                meaning,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            localizedNumber(context, surah.id),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _MetaBadge(text: arabicTitle),
                        _MetaBadge(text: revelationLabel),
                        _MetaBadge(
                          text:
                              "${localizedNumber(context, surah.versesCount)} آيات",
                        ),
                        _MetaBadge(text: "ص ${surah.pagesRange}"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String text;

  const _MetaBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _BottomTabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _BottomTabItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = selected
        ? color
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 20, color: baseColor),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  color: baseColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
