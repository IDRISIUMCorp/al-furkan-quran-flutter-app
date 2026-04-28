import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:al_furkan/src/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
class WahyFeedbackDialog extends StatefulWidget {
  final Color primary;
  const WahyFeedbackDialog({super.key, required this.primary});

  @override
  State<WahyFeedbackDialog> createState() => WahyFeedbackDialogState();
}

class WahyFeedbackDialogState extends State<WahyFeedbackDialog> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _message = TextEditingController();
  bool _isSending = false;

  static const String _telegramBotToken = String.fromEnvironment(
    "TELEGRAM_BOT_TOKEN",
    defaultValue: "",
  );
  static const String _telegramChatId = String.fromEnvironment(
    "TELEGRAM_CHAT_ID",
    defaultValue: "",
  );

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<bool> _sendToTelegram(String text) async {
    try {
      final url = Uri.parse(
        "https://api.telegram.org/bot$_telegramBotToken/sendMessage",
      );
      final res = await http.post(
        url,
        body: {
          "chat_id": _telegramChatId,
          "text": text,
          "disable_web_page_preview": "true",
        },
      );
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF1B1B1F)
        : AppColors.lightSurface;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppColors.lightBorder;
    final inputBg = isDark
        ? const Color(0xFF252529)
        : Colors.white.withValues(alpha: 0.5);

    return Animate(
      effects: [
        FadeEffect(duration: 400.ms, curve: Curves.easeOut),
        ScaleEffect(
          begin: const Offset(0.98, 0.98),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        ),
      ],
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Minimalist Header
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_rounded,
                          color: widget.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "إرسال ملاحظة",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "شارك في تطوير التطبيق تؤجر بإذن الله",
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white54 : Colors.black45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Fields
                    _buildField(
                      controller: _name,
                      label: "الاسم",
                      hint: "اسمك الكريم",
                      icon: Icons.person_outline_rounded,
                      bg: inputBg,
                      border: borderColor,
                    ),
                    const SizedBox(height: 18),
                    _buildField(
                      controller: _contact,
                      label: "التواصل",
                      hint: "رقم أو إيميل (اختياري)",
                      icon: Icons.alternate_email_rounded,
                      bg: inputBg,
                      border: borderColor,
                    ),
                    const SizedBox(height: 18),
                    _buildField(
                      controller: _message,
                      label: "الرسالة",
                      hint: "اكتب ملاحظتك أو اقتراحك هنا...",
                      icon: Icons.edit_note_rounded,
                      minLines: 4,
                      maxLines: 6,
                      bg: inputBg,
                      border: borderColor,
                    ),
                    const SizedBox(height: 36),
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isSending
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              "إلغاء",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey[500],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isSending ? null : _handleSubmit,
                            child: _isSending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "إرسال",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int minLines = 1,
    int maxLines = 1,
    required Color bg,
    required Color border,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            prefixIcon: Icon(icon, color: widget.primary, size: 20),
            filled: true,
            fillColor: bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: widget.primary.withValues(alpha: 0.3),
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final msg = _message.text.trim();
    if (msg.isEmpty) return;

    final name = _name.text.trim();
    final contact = _contact.text.trim();

    final payload = StringBuffer()
      ..writeln("💎 [IDRISIUM App Feedback]")
      ..writeln("━━━━━━━━━━━━━━━")
      ..writeln("📱 Platform: ${defaultTargetPlatform.name}")
      ..writeln("👤 Name: ${name.isEmpty ? '-' : name}")
      ..writeln("🔗 Contact: ${contact.isEmpty ? '-' : contact}")
      ..writeln("━━━━━━━━━━━━━━━")
      ..writeln("📝 Message:")
      ..writeln(msg);

    setState(() => _isSending = true);
    try {
      final canSend =
          _telegramBotToken.isNotEmpty && _telegramChatId.isNotEmpty;
      if (!canSend) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("إرسال تيليجرام غير مُفعّل حالياً")),
          );
        }
        return;
      }

      final ok = await _sendToTelegram(payload.toString());
      if (ok && context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("تم إرسال رسالتك بنجاح، شكراً لك! 💎"),
          ),
        );
        return;
      }

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("فشل إرسال الرسالة، يرجى المحاولة لاحقاً"),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
