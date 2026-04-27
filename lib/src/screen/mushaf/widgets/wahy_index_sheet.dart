import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/theme/app_colors.dart';
import 'package:al_furkan/src/screen/surah_list_view/model/surah_info_model.dart';
import 'package:qcf_quran/qcf_quran.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:al_furkan/src/utils/number_localization.dart';
import 'package:al_furkan/src/resources/quran_resources/meta/meta_data_surah.dart';
import 'package:al_furkan/src/utils/quran_ayahs_function/get_page_number.dart' as p;
class WahyIndexSheet extends StatefulWidget {
  final ValueChanged<int> onOpenPage;
  final ValueChanged<String>? onOpenAyah;
  const WahyIndexSheet({super.key, required this.onOpenPage, this.onOpenAyah});

  @override
  State<WahyIndexSheet> createState() => WahyIndexSheetState();
}

class WahyIndexSheetState extends State<WahyIndexSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _sheetSearchField(BuildContext context) {
    final themeState = context.read<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surfaceContainer : AppColors.ayaSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: themeState.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: "ابحث عن سورة…",
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_searchController.text.trim().isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFF8F8F8F),
              splashRadius: 18,
            ),
        ],
      ),
    );
  }

  Widget _wahySurahList(BuildContext context, List<SurahInfoModel> surahs) {
    final q = _searchController.text.trim();
    final filtered = q.isEmpty
        ? surahs
        : surahs.where((s) {
            final id = s.id;
            final arabic = getSurahNameArabic(id);
            final key =
                "$id $arabic ${s.pagesRange} ${s.versesCount} ${s.revelationPlace}"
                    .toLowerCase();
            return key.contains(q.toLowerCase());
          }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          "مفيش نتائج",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.ayaTextMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
      itemCount: filtered.length,
      separatorBuilder: (_, _) =>
          Divider(height: 10, color: Colors.black.withValues(alpha: 0.06)),
      itemBuilder: (context, index) {
        final s = filtered[index];
        final id = s.id;
        final title = getSurahNameArabic(id);
        final ayahKey = "$id:1";
        final page = p.getPageNumber(ayahKey) ?? 1;

        return InkWell(
          onTap: () {
            final cb = widget.onOpenAyah;
            if (cb != null) {
              cb(ayahKey);
              return;
            }
            widget.onOpenPage(page);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerHighest : const Color(0xFFF5EBE0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF141414) : AppColors.ayaBackground),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    localizedNumber(context, id),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.ayaTextMain),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.ayaTextMain),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "الصفحة ${localizedNumber(context, page)} · ${localizedNumber(context, s.versesCount)} آية",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ayaTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.ayaTextMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeCubit>().state;
    final surahInfoList = metaDataSurah.values
        .map((value) => SurahInfoModel.fromMap(value))
        .toList();

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "الفهرس",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.ayaTextMain),
                  ),
                ),
              ),
              Text(
                "السور والأربع",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.ayaTextMain)
                      .withValues(alpha: 0.42),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sheetSearchField(context),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainer : const Color(0xFFF5EBE0),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: themeState.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeState.primary.withValues(alpha: 0.35),
                ),
              ),
              padding: const EdgeInsets.all(4),
              labelColor: themeState.primary,
              unselectedLabelColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1B1B1B))
                  .withValues(alpha: 0.55),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(fontWeight: FontWeight.w900),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
              tabs: const [
                Tab(text: "السور"),
                Tab(text: "الأربع"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _wahySurahList(context, surahInfoList),
              RubListView(
                onOpenPage: widget.onOpenPage,
                query: _searchController.text.trim(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RubListView extends StatelessWidget {
  final ValueChanged<int> onOpenPage;
  final String query;
  const RubListView({super.key, required this.onOpenPage, required this.query});

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    return FutureBuilder<String>(
      future: rootBundle.loadString("assets/meta_data/Rub.json"),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done || !snap.hasData) {
          return const SizedBox.shrink();
        }

        final Map data = jsonDecode(snap.data!);
        final items = data.values.toList();

        bool matchesQuery({
          required int rubNumber,
          required int surah,
          required int verse,
          required int page,
        }) {
          if (q.isEmpty) return true;
          final surahName = getSurahNameArabic(surah);
          final key = "$rubNumber $surahName $surah:$verse $page".toLowerCase();
          return key.contains(q);
        }

        final filtered = <Map<String, dynamic>>[];
        for (var i = 0; i < items.length; i++) {
          final m = Map<String, dynamic>.from(items[i]);
          final String firstKey = (m["fvk"] as String?) ?? "1:1";
          final int rubNumber = (m["rn"] as int?) ?? (i + 1);
          final surah = int.tryParse(firstKey.split(":").first) ?? 1;
          final verse = int.tryParse(firstKey.split(":").last) ?? 1;
          final page = p.getPageNumber(firstKey) ?? 1;
          if (matchesQuery(
            rubNumber: rubNumber,
            surah: surah,
            verse: verse,
            page: page,
          )) {
            filtered.add({
              ...m,
              "_firstKey": firstKey,
              "_rubNumber": rubNumber,
              "_surah": surah,
              "_verse": verse,
              "_page": page,
            });
          }
        }

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "مفيش نتائج",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.ayaTextMuted,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
          itemCount: filtered.length,
          separatorBuilder: (_, _) =>
              Divider(height: 10, color: Colors.black.withValues(alpha: 0.06)),
          itemBuilder: (context, index) {
            final m = filtered[index];
            final int rubNumber = (m["_rubNumber"] as int?) ?? (index + 1);
            final surah = (m["_surah"] as int?) ?? 1;
            final verse = (m["_verse"] as int?) ?? 1;
            final page = (m["_page"] as int?) ?? 1;

            return InkWell(
              onTap: () => onOpenPage(page),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surfaceContainerHighest : AppColors.ayaCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF141414) : AppColors.ayaBackground),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        localizedNumber(context, rubNumber),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.ayaTextMain),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ربع ${localizedNumber(context, rubNumber)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.ayaTextMain),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${getSurahNameArabic(surah)}: ${localizedNumber(context, verse)} · الصفحة ${localizedNumber(context, page)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.ayaTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.ayaTextMuted,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
