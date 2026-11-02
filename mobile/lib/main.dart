import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'core/supabase_config.dart';
import 'providers/store_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoreProvider()),
      ],
      child: const LujainApp(),
    ),
  );
}

class LujainApp extends StatelessWidget {
  const LujainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متجر لجين LUJAIN',
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
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.gold,
          primary: AppColors.primary,
          secondary: AppColors.gold,
        ),
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
