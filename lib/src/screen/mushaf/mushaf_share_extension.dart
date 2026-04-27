part of 'mushaf_screen.dart';

extension _MushafShareExtension on _MushafViewState {
  String _toArabicDigits(String number) {
    const arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buffer = StringBuffer();
    for (final ch in number.split('')) {
      final digit = int.tryParse(ch);
      if (digit == null) {
        buffer.write(ch);
      } else {
        buffer.write(arabics[digit]);
      }
    }
    return buffer.toString();
  }
}
