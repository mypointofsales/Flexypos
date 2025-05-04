import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'screens/welcome_screen.dart';
import 'services/database_helper.dart';
import 'widgets/theme_notifier.dart';

final themeNotifier = ThemeNotifier(ThemeMode.system); // 🌙 Global

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await DatabaseHelper.instance.initDatabase();

  // 🌙 Coba baca dark_mode dari DB (jika ada)
  try {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('general_settings', limit: 1);
    String mode =
        result.isNotEmpty
            ? result.first['dark_mode']?.toString() ?? 'system'
            : 'system';

    themeNotifier.update(mode);
  } catch (e) {
    themeNotifier.update('system'); // fallback jika error
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('id')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      startLocale: null, // default
      useOnlyLangCode: true,
      child: ChangeNotifierProvider<ThemeNotifier>.value(
        value: themeNotifier, // gunakan value
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'FlexyPOS',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blueGrey,
          ),
          themeMode: mode, // 🌙 Dynamic!
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
