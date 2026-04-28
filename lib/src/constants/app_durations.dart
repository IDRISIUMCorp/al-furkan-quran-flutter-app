/// Al-Furkan Animation Duration Constants — Single Source of Truth
/// ZERO hardcoded durations outside this file.
class AppDurations {
  AppDurations._();

  // ── Entrance Animations ──
  static const Duration entrancePrimary = Duration(milliseconds: 500);
  static const Duration entranceSecondary = Duration(milliseconds: 400);

  // ── Exit Animations ──
  static const Duration exit = Duration(milliseconds: 250);

  // ── Micro-Interactions ──
  static const Duration microInteraction = Duration(milliseconds: 150);

  // ── Page Transitions ──
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration pageTransitionReverse = Duration(milliseconds: 250);

  // ── Stagger Delay ──
  static const Duration staggerDelay = Duration(milliseconds: 80);

  // ── IDRISIUM Signature ──
  static const Duration logoReveal = Duration(milliseconds: 800);
  static const Duration photoParallax = Duration(milliseconds: 1200);

  // ── Skeleton Shimmer ──
  static const Duration shimmerPeriod = Duration(milliseconds: 1500);
  static const Duration shimmerMinDisplay = Duration(milliseconds: 300);

  // ── Audio ──
  static const Duration audioSeekInterval = Duration(seconds: 5);
  static const Duration audioPreloadAhead = Duration(seconds: 10);

  // ── Debounce ──
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration scrollDebounce = Duration(milliseconds: 100);

  // ── Splash ──
  static const Duration splashDelay = Duration(seconds: 2);

  // ── General ──
  static const Duration tooltipWait = Duration(milliseconds: 500);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration toastDuration = Duration(seconds: 2);
}
