import 'package:flutter/material.dart';
import 'package:aquapark/modules/welcome/welcome_page.dart';
import 'package:aquapark/core/widgets/connection_gate.dart';
import 'package:aquapark/core/di/locator.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  setupLocator();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr', 'TR'),

      useOnlyLangCode: true,

      saveLocale: false,

      child: const AquaParkApp(),
    ),
  );
}

class AquaParkApp extends StatelessWidget {
  const AquaParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => 'app_name'.tr(),
      debugShowCheckedModeBanner: false,

      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
        ),
        useMaterial3: true,
      ),

      builder: (context, child) {
        return ConnectionGate(
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const WelcomePage(),
    );
  }
}