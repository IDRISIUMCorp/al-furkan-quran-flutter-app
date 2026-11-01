import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/zen_theme.dart';
import '../core/audio/audio_player_service.dart';

enum MaskingMode { visible, blurred, hidden }

/// ZenHifzScreen (also exported as ZenHifzView)
/// Distraction-free active memorization screen powered by AudioPlayerService with just_audio.
class ZenHifzScreen extends StatefulWidget {
  final Function(bool isFocusMode) onFocusModeChanged;

  const ZenHifzScreen({super.key, required this.onFocusModeChanged});

  @override
  State<ZenHifzScreen> createState() => _ZenHifzScreenState();
}

/// Backward compatibility alias
typedef ZenHifzView = ZenHifzScreen;

class _ZenHifzScreenState extends State<ZenHifzScreen> {
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  StreamSubscription<HifzSessionState>? _sessionSub;

  MaskingMode _maskingMode = MaskingMode.visible;
  double _fontSize = 28.0;
  bool _isFocusMode = false;
  final Set<int> _peekedAyahs = {};

  // Current session config
  int _surah = 1;
  int _startAyah = 1;
  int _endAyah = 7;
  int _singleRepeat = 10;
  int _linkGroupRepeat = 3;
  int _pauseDelaySeconds = 4;
  String _selectedReciterName = 'الحصري (المعلم)';
  String _reciterPattern =
      'https://everyayah.com/data/Husary_Muallim_128kbps/{surah:03d}{ayah:03d}.mp3';

  // State from AudioPlayerService
  HifzSessionState _sessionState = const HifzSessionState();

  // Surah Al-Fatihah verses data
  final List<Map<String, dynamic>> _sampleAyahs = [
    {'num': 1, 'text': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ'},
    {'num': 2, 'text': 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ'},
    {'num': 3, 'text': 'ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ'},
    {'num': 4, 'text': 'مَـٰلِكِ يَوْمِ ٱلدِّينِ'},
    {'num': 5, 'text': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ'},
    {'num': 6, 'text': 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ'},
    {'num': 7, 'text': 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ'},
  ];

  @override
  void initState() {
    super.initState();
    // Subscribe to AudioPlayerService events to track loop counting and delay
    _sessionSub = _audioPlayer.sessionStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _sessionState = state;
        if (state.status == HifzPlaybackStatus.completed) {
          _isFocusMode = false;
          widget.onFocusModeChanged(false);
          _showCompletionSnackbar();
        }
      });
    });
  }

  final Map<int, Timer> _peekTimers = {};

  @override
  void dispose() {
    for (final timer in _peekTimers.values) {
      timer.cancel();
    }
    _peekTimers.clear();
    _sessionSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showCompletionSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ما شاء الله! اكتملت جلسة التكرار والحفظ بنجاح',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: ZenTheme.lightSage,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _toggleMaskingMode() {
    setState(() {
      for (final timer in _peekTimers.values) {
        timer.cancel();
      }
      _peekTimers.clear();
      _peekedAyahs.clear();

      if (_maskingMode == MaskingMode.visible) {
        _maskingMode = MaskingMode.blurred;
      } else if (_maskingMode == MaskingMode.blurred) {
        _maskingMode = MaskingMode.hidden;
      } else {
        _maskingMode = MaskingMode.visible;
      }
    });
  }

  void _peekAyah(int ayahNum) {
    if (_maskingMode == MaskingMode.visible) return;

    _peekTimers[ayahNum]?.cancel();

    setState(() {
      _peekedAyahs.add(ayahNum);
    });

    _peekTimers[ayahNum] = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _peekedAyahs.remove(ayahNum);
          _peekTimers.remove(ayahNum);
        });
      }
    });
  }

  void _startSession() {
    setState(() {
      _isFocusMode = true;
    });
    widget.onFocusModeChanged(true);

    _audioPlayer.prepareAndPlay(
      HifzVerseConfig(
        surah: _surah,
        startAyah: _startAyah,
        endAyah: _endAyah,
        singleRepeatCount: _singleRepeat,
        linkGroupRepeat: _linkGroupRepeat,
        pauseDelaySeconds: _pauseDelaySeconds,
        reciterCdnPattern: _reciterPattern,
      ),
    );
  }

  void _pauseSession() {
    _audioPlayer.pause();
  }

  void _resumeSession() {
    _audioPlayer.resume();
  }

  void _stopSession() {
    setState(() {
      _isFocusMode = false;
    });
    widget.onFocusModeChanged(false);
    _audioPlayer.stop();
  }

  void _openSetupModalSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ZenTheme.darkAmberText : ZenTheme.lightText;
    final sageColor = isDark ? ZenTheme.darkSage : ZenTheme.lightSage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? ZenTheme.darkSurface : ZenTheme.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إعدادات جلسة التكرار',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reciter Selector
                  Text(
                    'القارئ والرواية',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedReciterName,
                    dropdownColor: isDark ? ZenTheme.darkSurface : ZenTheme.lightSurface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'الحصري (المعلم)',
                        child: Text('الحصري (المعلم) - حفص'),
                      ),
                      DropdownMenuItem(
                        value: 'مشاري العفاسي',
                        child: Text('مشاري راشد العفاسي - حفص'),
                      ),
                      DropdownMenuItem(
                        value: 'محمد صديق المنشاوي',
                        child: Text('محمد صديق المنشاوي (معلم)'),
                      ),
                      DropdownMenuItem(
                        value: 'علي الحذيفي (قالون)',
                        child: Text('علي الحذيفي - رواية قالون'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => _selectedReciterName = val);
                        setState(() {
                          _selectedReciterName = val;
                          if (val == 'الحصري (المعلم)') {
                            _reciterPattern =
                                'https://everyayah.com/data/Husary_Muallim_128kbps/{surah:03d}{ayah:03d}.mp3';
                          } else if (val == 'مشاري العفاسي') {
                            _reciterPattern =
                                'https://everyayah.com/data/Alafasy_128kbps/{surah:03d}{ayah:03d}.mp3';
                          } else if (val == 'محمد صديق المنشاوي') {
                            _reciterPattern =
                                'https://everyayah.com/data/Minshawy_Teacher_128kbps/{surah:03d}{ayah:03d}.mp3';
                          } else if (val == 'علي الحذيفي (قالون)') {
                            _reciterPattern =
                                'https://everyayah.com/data/Hudhaify_128kbps/{surah:03d}{ayah:03d}.mp3';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Single Repeat Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تكرار الآية الواحدة (N مرات)',
                        style: TextStyle(fontSize: 13, color: textColor),
                      ),
                      Text(
                        '$_singleRepeat مرات',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: sageColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _singleRepeat.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    activeColor: sageColor,
                    onChanged: (v) {
                      setSheetState(() => _singleRepeat = v.round());
                      setState(() => _singleRepeat = v.round());
                    },
                  ),

                  // Link Verses Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ربط المجموعة متسلسلة (M مرات)',
                        style: TextStyle(fontSize: 13, color: textColor),
                      ),
                      Text(
                        '$_linkGroupRepeat مرات',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: sageColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _linkGroupRepeat.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: sageColor,
                    onChanged: (v) {
                      setSheetState(() => _linkGroupRepeat = v.round());
                      setState(() => _linkGroupRepeat = v.round());
                    },
                  ),

                  // Pause Delay Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مهلة الصمت للترديد من الذاكرة (X ث)',
                        style: TextStyle(fontSize: 13, color: textColor),
                      ),
                      Text(
                        '$_pauseDelaySeconds ثوانٍ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: sageColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _pauseDelaySeconds.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    activeColor: sageColor,
                    onChanged: (v) {
                      setSheetState(() => _pauseDelaySeconds = v.round());
                      setState(() => _pauseDelaySeconds = v.round());
                    },
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startSession();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sageColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'حفظ الإعدادات وبدء التكرار',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? ZenTheme.darkAmberText : ZenTheme.lightText;
    final sageColor = isDark ? ZenTheme.darkSage : ZenTheme.lightSage;

    final isPlaying = _sessionState.isPlaying;
    final isPaused = _sessionState.isPaused;
    final isDelaying = _sessionState.isDelaying;
    final currentAyah = _sessionState.currentAyah;
    final currentLoop = _sessionState.currentLoop;
    final totalLoops = _sessionState.totalLoops;

    return Scaffold(
      body: Stack(
        children: [
          // Main Verses Scroll Area
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                if (!_isFocusMode) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سورة الفاتحة',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الآيات $_startAyah - $_endAyah • $_selectedReciterName',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.tune, color: sageColor),
                        tooltip: 'إعدادات الجلسة',
                        onPressed: _openSetupModalSheet,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Verses list
                ..._sampleAyahs.map((ayah) {
                  final ayahNum = ayah['num'] as int;
                  final isCurrent = (isPlaying || isPaused) && currentAyah == ayahNum;
                  final isPeeked = _peekedAyahs.contains(ayahNum);

                  Widget verseContent;
                  if (_maskingMode == MaskingMode.hidden && !isPeeked && !isCurrent) {
                    verseContent = const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '••••••••••••••••••••••••••••••••',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 4,
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  } else if (_maskingMode == MaskingMode.blurred && !isCurrent && !isPeeked) {
                    verseContent = ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                      child: Text(
                        ayah['text'] as String,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: 2.1,
                          color: textColor,
                        ),
                      ),
                    );
                  } else {
                    verseContent = Text(
                      ayah['text'] as String,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 2.1,
                        color: isCurrent
                            ? sageColor
                            : (isPeeked ? (isDark ? ZenTheme.darkSage : ZenTheme.lightSage) : textColor),
                        fontWeight: (isCurrent || isPeeked) ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () => _peekAyah(ayahNum),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? sageColor.withValues(alpha: 0.12)
                            : (isPeeked
                                ? sageColor.withValues(alpha: 0.15)
                                : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02))),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCurrent
                              ? sageColor
                              : (isPeeked ? sageColor : Colors.transparent),
                          width: (isCurrent || isPeeked) ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: isCurrent
                                    ? sageColor
                                    : (isPeeked ? sageColor : (isDark ? Colors.white12 : Colors.black12)),
                                child: Text(
                                  '$ayahNum',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: (isCurrent || isPeeked) ? Colors.white : textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isCurrent && isDelaying)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: sageColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'مهلة الترديد: ${_sessionState.delayRemainingSeconds}ث',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: sageColor,
                                    ),
                                  ),
                                )
                              else if (_maskingMode != MaskingMode.visible)
                                Text(
                                  isPeeked ? 'كشف مؤقت (2.5ث)' : 'انقر للكشف',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isPeeked ? sageColor : Colors.grey,
                                    fontWeight: isPeeked ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          verseContent,
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 120), // Spacing for floating control pill
              ],
            ),
          ),

          // Floating Translucent Bottom Control Pill
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? ZenTheme.darkSurface : ZenTheme.lightSurface)
                        .withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: sageColor.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Status and Loop Counter
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isPlaying || isPaused
                                  ? (_sessionState.isGroupPhase
                                      ? 'المجموعة المترابطة • تكرار ${_sessionState.groupLoop}/${_sessionState.totalGroupLoops}'
                                      : 'آية $_surah:$currentAyah • تكرار $currentLoop/$totalLoops')
                                  : 'الفاتحة ($_startAyah - $_endAyah)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (isDelaying)
                              Text(
                                'ردد بصوتك الآن...',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: sageColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Masking Eye Toggle
                      IconButton(
                        icon: Icon(
                          _maskingMode == MaskingMode.visible
                              ? Icons.visibility
                              : (_maskingMode == MaskingMode.blurred
                                  ? Icons.blur_on
                                  : Icons.visibility_off),
                          color: sageColor,
                        ),
                        onPressed: _toggleMaskingMode,
                        tooltip: 'تبديل وضع الإخفاء',
                      ),

                      // Audio Controls
                      if (isPlaying) ...[
                        IconButton(
                          icon: const Icon(Icons.pause, color: Colors.amber),
                          onPressed: _pauseSession,
                          tooltip: 'إيقاف مؤقت',
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop, color: Colors.redAccent),
                          onPressed: _stopSession,
                          tooltip: 'إنهاء الجلسة',
                        ),
                      ] else if (isPaused) ...[
                        IconButton(
                          icon: Icon(Icons.play_arrow, color: sageColor),
                          onPressed: _resumeSession,
                          tooltip: 'متابعة التكرار',
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop, color: Colors.redAccent),
                          onPressed: _stopSession,
                          tooltip: 'إنهاء الجلسة',
                        ),
                      ] else
                        ElevatedButton.icon(
                          onPressed: _startSession,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('بدء التكرار'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: sageColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
