import "dart:async";
import "dart:developer";

import "package:al_quran_v3/src/core/bootstrap/app_bootstrap_coordinator.dart";
import "package:al_quran_v3/src/core/di/service_locator.dart";
import "package:al_quran_v3/src/screen/mushaf/mushaf_screen.dart";
import "package:flutter/material.dart";

class QuranBootstrapPage extends StatefulWidget {
  const QuranBootstrapPage({super.key});

  @override
  State<QuranBootstrapPage> createState() => _QuranBootstrapPageState();
}

class _QuranBootstrapPageState extends State<QuranBootstrapPage> {
  static Future<void>? _deferredWarmupTask;

  bool _didRun = false;
  String _status = "Opening...";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRun) {
      return;
    }

    _didRun = true;
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    try {
      final coordinator = getIt<AppBootstrapCoordinator>();
      await coordinator.prepareLaunch();

      if (!mounted) {
        return;
      }

      _startDeferredWarmup(coordinator);

      _openMushaf();
    } catch (error, stackTrace) {
      log("Bootstrap failed: $error\n$stackTrace", name: "QuranBootstrap");
      if (!mounted) {
        return;
      }

      setState(() => _status = "Failed to prepare. Please restart.");
    }
  }

  void _startDeferredWarmup(AppBootstrapCoordinator coordinator) {
    _deferredWarmupTask ??= coordinator.runDeferredWarmup();
    unawaited(
      _deferredWarmupTask!.catchError((error, stackTrace) {
        log(
          "Deferred warmup failed: $error\n$stackTrace",
          name: "QuranBootstrapWarmup",
        );
      }),
    );
  }

  void _openMushaf() {
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MushafScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 14),
              Text(
                _status,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
