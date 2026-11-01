import 'package:flutter/material.dart';
import '../core/theme/zen_theme.dart';

class HalaqaScreen extends StatefulWidget {
  const HalaqaScreen({super.key});

  @override
  State<HalaqaScreen> createState() => _HalaqaScreenState();
}

class _HalaqaScreenState extends State<HalaqaScreen> {
  bool _isConnected = false;
  bool _isMuted = false;
  final String _roomCode = 'HIFZ-777';

  final List<Map<String, dynamic>> _participants = [
    {'name': 'أنت (الحافظ)', 'isSpeaking': false, 'isTurn': true},
    {'name': 'عبد الرحمن', 'isSpeaking': true, 'isTurn': false},
    {'name': 'طارق الزيتوني', 'isSpeaking': false, 'isTurn': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ZenTheme.darkAmberText : ZenTheme.lightText;
    final sageColor = isDark ? ZenTheme.darkSage : ZenTheme.lightSage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حلقة الأصدقاء الصوتية', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isConnected
            ? Column(
                children: [
                  // Room Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? ZenTheme.darkSurface : ZenTheme.lightSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sageColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الغرفة: $_roomCode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sageColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _isConnected = false);
                          },
                          child: const Text('مغادرة', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Active Verses
                  Text(
                    'المقطع الموحد: سورة الفاتحة (1 - 7)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Participant list with speaking pulse
                  Expanded(
                    child: ListView.builder(
                      itemCount: _participants.length,
                      itemBuilder: (context, index) {
                        final p = _participants[index];
                        final isSpeaking = p['isSpeaking'] as bool;
                        final isTurn = p['isTurn'] as bool;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isTurn
                                ? sageColor.withValues(alpha: 0.15)
                                : (isDark ? ZenTheme.darkSurface : ZenTheme.lightSurface),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isTurn ? sageColor : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isSpeaking ? Colors.green : sageColor,
                                child: Text(
                                  (p['name'] as String).substring(0, 1),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['name'] as String,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                    ),
                                    Text(
                                      isTurn ? 'دوره في التسميع' : (isSpeaking ? 'يتحدث الآن...' : 'مستمع'),
                                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSpeaking)
                                const Icon(Icons.graphic_eq, color: Colors.green)
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Mic control
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                    },
                    icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                    label: Text(_isMuted ? 'إلغاء كتم الميكروفون' : 'كتم الميكروفون'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMuted ? Colors.redAccent : sageColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.radio, size: 64, color: sageColor),
                    const SizedBox(height: 16),
                    Text(
                      'غرفة التسميع المباشر مع الأصدقاء',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    const Text('تسميع مباشر بالصوت فقط وبدون خادم خارجي'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _isConnected = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sageColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('دخول الغرفة الصوتية الآن'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
