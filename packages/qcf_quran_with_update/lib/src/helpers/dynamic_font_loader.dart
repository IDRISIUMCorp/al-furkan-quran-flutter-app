import "dart:io";

import "package:archive/archive.dart";
import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import "package:qcf_quran/src/helpers/woff_to_ttf.dart";

Uint8List _extractFontFromZipIsolate(Map<String, dynamic> args) {
  final Uint8List bytes = args["bytes"] as Uint8List;
  final String fontFileName = args["fontFileName"] as String;

  final archive = ZipDecoder().decodeBytes(bytes);
  for (final file in archive) {
    if (!file.isFile) continue;
    final filename = file.name.split("/").last;
    if (filename != fontFileName) continue;

    if (filename.endsWith(".woff")) {
      final woffBytes = Uint8List.fromList(file.content as List<int>);
      return Uint8List.fromList(woffToTtf(woffBytes));
    }

    if (filename.endsWith(".ttf")) {
      return Uint8List.fromList(file.content as List<int>);
    }
  }

  throw Exception("Font $fontFileName was not found in qcf4.zip");
}

class DynamicFontLoader {
  static final Set<String> _loadedFonts = {};
  static final Map<String, Future<void>> _loadingTasks = {};
  static Future<Uint8List>? _zipBytesTask;

  static bool isTestMode = false;

  static Future<void> loadFont(int pageNumber) async {
    if (isTestMode) return;

    final fontName = "QCF_P${pageNumber.toString().padLeft(3, "0")}";
    if (_loadedFonts.contains(fontName)) return;

    final existingTask = _loadingTasks[fontName];
    if (existingTask != null) {
      return existingTask;
    }

    final task = _extractAndLoadFont(fontName);
    _loadingTasks[fontName] = task;

    try {
      await task;
      _loadedFonts.add(fontName);
    } finally {
      _loadingTasks.remove(fontName);
    }
  }

  static Future<Uint8List> _loadZipBytes() async {
    final task = _zipBytesTask;
    if (task != null) return task;

    _zipBytesTask = () async {
      final byteData = await rootBundle.load(
        "packages/qcf_quran/assets/fonts/qcf4.zip",
      );
      return byteData.buffer.asUint8List();
    }();

    return _zipBytesTask!;
  }

  static Future<void> _extractFontFromZip({
    required Directory dir,
    required String archiveFileName,
    required String outputFileName,
  }) async {
    final zipBytes = await _loadZipBytes();
    final ttfBytes = await compute(_extractFontFromZipIsolate, {
      "bytes": zipBytes,
      "fontFileName": archiveFileName,
    });
    final outFile = File("${dir.path}/$outputFileName");
    await outFile.writeAsBytes(ttfBytes, flush: true);
  }

  static Future<void> _extractAndLoadFont(String fontName) async {
    final dir = await getApplicationDocumentsDirectory();
    final pageStr = fontName.substring(5);
    final ttfFileName = "QCF4${pageStr}_X-Regular.ttf";
    final woffFileName = "QCF4${pageStr}_X-Regular.woff";
    final fontFile = File("${dir.path}/$ttfFileName");

    if (!await fontFile.exists()) {
      final staleWoffFile = File("${dir.path}/$woffFileName");
      if (await staleWoffFile.exists()) {
        await staleWoffFile.delete();
      }

      await _extractFontFromZip(
        dir: dir,
        archiveFileName: woffFileName,
        outputFileName: ttfFileName,
      );
    }

    if (!await fontFile.exists()) {
      throw Exception("Font file $ttfFileName not found after extraction");
    }

    final fontLoader = FontLoader(fontName);
    fontLoader.addFont(_readFontFile(fontFile));
    await fontLoader.load();
  }

  static Future<ByteData> _readFontFile(File file) async {
    final bytes = await file.readAsBytes();
    return ByteData.view(bytes.buffer);
  }
}
