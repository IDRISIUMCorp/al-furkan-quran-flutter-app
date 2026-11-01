import 'dart:convert';
import 'package:crypto/crypto.dart';

class ServerlessLiveKitToken {
  static String base64UrlEncode(String str) {
    return base64Url.encode(utf8.encode(str)).replaceAll('=', '');
  }

  static String bytesToBase64Url(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Generates a valid LiveKit AccessToken directly on-device with HMAC-SHA256
  static String createToken({
    required String apiKey,
    required String apiSecret,
    required String roomName,
    required String participantIdentity,
    required String participantName,
  }) {
    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = {
      'exp': now + (6 * 3600), // Valid for 6 hours
      'nbf': now - 5,
      'iss': apiKey,
      'sub': participantIdentity,
      'name': participantName,
      'video': {
        'room': roomName,
        'roomJoin': true,
        'canPublish': true,
        'canSubscribe': true,
        'canPublishData': true,
      },
    };

    final headerEncoded = base64UrlEncode(jsonEncode(header));
    final payloadEncoded = base64UrlEncode(jsonEncode(payload));
    final dataToSign = '$headerEncoded.$payloadEncoded';

    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final signature = hmac.convert(utf8.encode(dataToSign));
    final signatureEncoded = bytesToBase64Url(signature.bytes);

    return '$dataToSign.$signatureEncoded';
  }
}
