import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/tasbeeh_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/athkar/athkar_screen.dart';
import 'screens/quran/quran_screen.dart';
import 'screens/tasbeeh/tasbeeh_screen.dart';
import 'screens/qibla/qibla_screen.dart';
import 'screens/mosques/mosques_screen.dart';
import 'screens/reminders/reminders_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(create: (_) => TasbeehProvider()),
      ],
      child: const NoorAthkarApp(),
    ),
  );
}

class NoorAthkarApp extends StatelessWidget {
  const NoorAthkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'Noor Athkar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppShell(),
    );
  }
}

/// Main navigation shell with 5-tab bottom nav.
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => AppShellState();

  /// Navigate to a specific tab by index from external screens.
  static void navigateTo(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<AppShellState>();
    state?.switchTab(index);
  }
}

class AppShellState extends State<AppShell> {
  int _index = 0;

  void switchTab(int index) {
    setState(() => _index = index);
  }

  final _screens = const [
    DashboardScreen(),
    AthkarCategoriesScreen(),
    TasbeehScreen(),
    QuranScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<SettingsProvider>().isArabic;
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: isAr ? 'الرئيسية' : 'Home'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.auto_stories_rounded),
                label: isAr ? 'الأذكار' : 'Athkar'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.touch_app_rounded),
                label: isAr ? 'المسبحة' : 'Tasbeeh'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.menu_book_rounded),
                label: isAr ? 'القرآن' : 'Quran'),
            BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                label: isAr ? 'الإعدادات' : 'Settings'),
          ],
        ),
      ),
    );
  }
}
