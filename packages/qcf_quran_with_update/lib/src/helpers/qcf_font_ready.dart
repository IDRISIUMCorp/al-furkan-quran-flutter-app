import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:qcf_quran/src/helpers/dynamic_font_loader.dart";

class QcfFontReady extends StatefulWidget {
  final Set<int> pages;
  final WidgetBuilder builder;
  final Widget? placeholder;

  const QcfFontReady({
    super.key,
    required this.pages,
    required this.builder,
    this.placeholder,
  });

  @override
  State<QcfFontReady> createState() => _QcfFontReadyState();
}

class _QcfFontReadyState extends State<QcfFontReady> {
  late Future<void> _loadFuture;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadFonts(widget.pages);
  }

  @override
  void didUpdateWidget(covariant QcfFontReady oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(oldWidget.pages, widget.pages)) {
      _retryCount = 0;
      _loadFuture = _loadFonts(widget.pages);
    }
  }

  Future<void> _loadFonts(Set<int> pages) async {
    final sortedPages = pages.toList()..sort();
    for (final page in sortedPages) {
      if (page < 1 || page > 604) continue;
      await DynamicFontLoader.loadFont(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (_retryCount < 1) {
            _retryCount++;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _loadFuture = _loadFonts(widget.pages);
              });
            });
          }
          return widget.placeholder ?? const SizedBox.shrink();
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.placeholder ?? const SizedBox.shrink();
        }
        return widget.builder(context);
      },
    );
  }
}
