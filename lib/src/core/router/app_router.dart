import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Al-Furkan Router — GoRouter configuration with type-safe routes
/// All navigation goes through this router. ZERO Navigator.push elsewhere.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      // ── Main Shell Route (Bottom Nav) ──
      ShellRoute(
        builder: (context, state, child) {
          return _ShellWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
          ),
          GoRoute(
            path: AppRoutes.script,
            name: 'script',
            builder: (context, state) => const _PlaceholderScreen(title: 'Script'),
          ),
          GoRoute(
            path: AppRoutes.search,
            name: 'search',
            builder: (context, state) => const _PlaceholderScreen(title: 'Search'),
          ),
          GoRoute(
            path: AppRoutes.prayer,
            name: 'prayer',
            builder: (context, state) => const _PlaceholderScreen(title: 'Prayer'),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
          ),
        ],
      ),
      // ── Full-Screen Routes (outside shell) ──
      GoRoute(
        path: AppRoutes.qibla,
        name: 'qibla',
        builder: (context, state) => const _PlaceholderScreen(title: 'Qibla'),
      ),
      GoRoute(
        path: AppRoutes.azkar,
        name: 'azkar',
        builder: (context, state) => const _PlaceholderScreen(title: 'Azkar'),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const _PlaceholderScreen(title: 'About'),
      ),
      GoRoute(
        path: AppRoutes.bookmarks,
        name: 'bookmarks',
        builder: (context, state) => const _PlaceholderScreen(title: 'Bookmarks'),
      ),
      GoRoute(
        path: AppRoutes.hifz,
        name: 'hifz',
        builder: (context, state) => const _PlaceholderScreen(title: 'Hifz'),
      ),
      GoRoute(
        path: AppRoutes.khatma,
        name: 'khatma',
        builder: (context, state) => const _PlaceholderScreen(title: 'Khatma'),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const _PlaceholderScreen(title: 'Onboarding'),
      ),
    ],
    errorBuilder: (context, state) => const _PlaceholderScreen(title: 'Not Found'),
  );
}

/// Shell wrapper — will be replaced with actual BottomNav shell in PHASE 4
class _ShellWrapper extends StatelessWidget {
  final Widget child;
  const _ShellWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Placeholder screen — will be replaced with actual screens in PHASE 4
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title — Coming in PHASE 4',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
