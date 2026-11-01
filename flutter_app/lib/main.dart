import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'core/theme/zen_theme.dart';
import 'core/alarms/escalating_alarms.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize fast local storage
  await Hive.initFlutter();
  await Hive.openBox('hifz_box');

  // Initialize strict escalating alarms
  await EscalatingAlarmsService.init();

  runApp(const AlFurkanZenApp());
}

class AlFurkanZenApp extends StatelessWidget {
  const AlFurkanZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الفرقان • Zen Hifz',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ZenTheme.light(),
      darkTheme: ZenTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
