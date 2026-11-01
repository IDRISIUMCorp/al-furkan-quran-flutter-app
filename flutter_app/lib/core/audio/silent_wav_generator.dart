import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class SilentWavGenerator {
  /// Generates a valid PCM 16-bit 44.1kHz mono silent WAV file in cache
  static Future<File> createSilentWav({required int durationSeconds}) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/silent_${durationSeconds}s.wav');

    if (await file.exists()) {
      return file;
    }

    const int sampleRate = 44100;
    const int channels = 1;
    const int bitsPerSample = 16;
    final int byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
    final int blockAlign = channels * (bitsPerSample ~/ 8);
    final int dataSize = byteRate * durationSeconds;
    final int totalSize = 36 + dataSize;

    final bytes = BytesBuilder();

    // 1. RIFF Header
    bytes.add('RIFF'.codeUnits);
    bytes.add(_int32ToBytes(totalSize));
    bytes.add('WAVE'.codeUnits);

    // 2. fmt Sub-chunk
    bytes.add('fmt '.codeUnits);
    bytes.add(_int32ToBytes(16)); // SubChunk1Size (16 for PCM)
    bytes.add(_int16ToBytes(1));  // AudioFormat (1 for PCM)
    bytes.add(_int16ToBytes(channels));
    bytes.add(_int32ToBytes(sampleRate));
    bytes.add(_int32ToBytes(byteRate));
    bytes.add(_int16ToBytes(blockAlign));
    bytes.add(_int16ToBytes(bitsPerSample));

    // 3. data Sub-chunk
    bytes.add('data'.codeUnits);
    bytes.add(_int32ToBytes(dataSize));

    // 4. Zero byte PCM silent samples
    bytes.add(Uint8List(dataSize));

    await file.writeAsBytes(bytes.toBytes(), flush: true);
    return file;
  }

  static Uint8List _int16ToBytes(int value) {
    return Uint8List(2)..buffer.asByteData().setInt16(0, value, Endian.little);
  }

  static Uint8List _int32ToBytes(int value) {
    return Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.little);
  }
}
