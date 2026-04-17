import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/utils/quran_resources/get_translation.dart";
import "package:al_furkan/src/widget/ayah_by_ayah/ayah_by_ayah_card.dart";
import "package:flutter/material.dart";

class ListOfAyahsViews extends StatefulWidget {
  final List<String> ayahsKey;
  const ListOfAyahsViews({super.key, required this.ayahsKey});

  @override
  State<ListOfAyahsViews> createState() => _ListOfAyahsViewsState();
}

class _ListOfAyahsViewsState extends State<ListOfAyahsViews> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ayahCount(widget.ayahsKey.length))),
      body: ListView.builder(
        itemCount: widget.ayahsKey.length,
        itemBuilder: (context, index) {
          final translationData = getTranslationFromCache(widget.ayahsKey[index]);
          return translationData != null
              ? getAyahByAyahCard(
                  ayahKey: widget.ayahsKey[index],
                  context: context,
                  showFullKey: true,
                  translationListWithInfo: translationData,
                  wordByWord: const [],
                )
              : FutureBuilder(
                  future: getTranslation(widget.ayahsKey[index]),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(height: 250);
                    }
                    return getAyahByAyahCard(
                      ayahKey: widget.ayahsKey[index],
                      context: context,
                      showFullKey: true,
                      translationListWithInfo: asyncSnapshot.data ?? const [],
                      wordByWord: const [],
                    );
                  },
                );
        },
      ),
    );
  }
}
