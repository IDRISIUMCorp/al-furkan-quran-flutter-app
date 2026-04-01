import "dart:async";
import "dart:developer";

import "package:al_quran_v3/main.dart";
import "package:al_quran_v3/src/core/services/ayah_of_the_day_service.dart";
import "package:al_quran_v3/src/platform_services.dart" as platform_services;
import "package:al_quran_v3/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_quran_v3/src/screen/mushaf/mushaf_screen.dart";
import "package:al_quran_v3/src/screen/onboarding/premium_onboarding_screen.dart";
import "package:al_quran_v3/src/utils/quran_resources/default_offline_resources.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_irab_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_script_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_tafsir_function.dart";
import "package:al_quran_v3/src/widget/quran_script/model/script_info.dart";
import "package:flutter/material.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

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
    if (_didRun) return;
    _didRun = true;
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    try {
      if (!Hive.isBoxOpen("user")) {
        await Hive.openBox("user");
      }
      final userBox = Hive.box("user");

      await userBox.put("quick_setup_done", true);
      await userBox.put("is_setup_complete", true);

      await userBox.put("isAyahByAyah", false);
      await userBox.put("isAyahByAyahHorizontal", false);

      if (!mounted) return;

      _startDeferredWarmup();

      // Check if Premium Onboarding V2 has been completed
      final onboardingDone =
          userBox.get("onboarding_v2_done", defaultValue: false) as bool;

      if (!onboardingDone) {
        // Show the new Premium Onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PremiumOnboardingScreen(
              onComplete: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MushafScreen()),
                );
              },
            ),
          ),
        );
      } else {
        // Go directly to MushafScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MushafScreen()),
        );
      }
    } catch (e, s) {
      log("Bootstrap failed: $e\n$s", name: "QuranBootstrap");
      if (!mounted) return;
      setState(() => _status = "Failed to prepare. Please restart.");
    }
  }

  void _startDeferredWarmup() {
    _deferredWarmupTask ??= _runDeferredWarmup();
    unawaited(
      _deferredWarmupTask!.catchError((error, stackTrace) {
        log(
          "Deferred warmup failed: $error\n$stackTrace",
          name: "QuranBootstrapWarmup",
        );
      }),
    );
  }

  Future<void> _runDeferredWarmup() async {
    await DefaultOfflineResources.ensureInstalled();
    await QuranTafsirFunction.init();
    await QuranIrabFunction.setDefaultSelected();

    final scriptOnDb = Hive.box("user").get(
      "selected_quran_script_type",
      defaultValue: QuranScriptType.values.first.name,
    );

    await QuranScriptFunction.initQuranScript(
      QuranScriptType.values.firstWhere(
        (element) => scriptOnDb == element.name,
      ),
    );

    await loadMetaSurah();

    if (platformOwn == platform_services.PlatformOwn.isAndroid ||
        platformOwn == platform_services.PlatformOwn.isIos) {
      await AyahOfTheDayService.setupBackgroundUpdates();
    }
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
