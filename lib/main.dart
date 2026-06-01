import 'package:flutter/material.dart'; //this import is responsible for basic widgets like buttons, themes, navigation. everything visual comes from here
import 'package:flutter/services.dart'; //this import provides service to control device level things like orientation , haptic feedback and clipboard
import 'package:flutter_localizations/flutter_localizations.dart'; //for translating
import 'package:provider/provider.dart'; //allow sharing of data across wdiget tree



import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/tasbeeh_provider.dart';
import 'core/providers/prayer_time_provider.dart';  //core folder is for the shared infrastucture like storage or theme or global state
import 'screens/entry/splash_screen.dart'; 
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/athkar/athkar_screen.dart';
import 'screens/quran/quran_screen.dart';
import 'screens/tasbeeh/tasbeeh_screen.dart';
import 'screens/settings/settings_screen.dart'; //screens folder holds the UI pages
import 'modules/athkar_module.dart'; //for pre-loading the JSON athkar data
import 'core/services/quran_page_service.dart'; //for pre-loading the JSON Quran pages

void main() async { //this is the entry point of the app. async here means the function can use await to pause for async operations
  WidgetsFlutterBinding.ensureInitialized(); //this part is mandatory before runApp(). this makes that the framework is attached to the native window
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown, //these lines lock the app to be portrait only
  ]);
  

  await HiveService.init(); //Hive is a lightweight fast local database. this initialization is to store settings and counter data persistently
  await AthkarData.init(); //Pre-load the static supplications from the offline JSON asset file
  await QuranPageService.init(); //Pre-load all 604 Quran pages from the offline JSON asset file



  final settingsProvider = SettingsProvider();
  await settingsProvider.init();   //these lines create a provider( which is a state container) for settings and loads saved data

  final prayerTimeProvider = PrayerTimeProvider();
  prayerTimeProvider.setLanguage(isArabic: settingsProvider.isArabic); //this also provides a container but for prayer times and also sets the language based on settings

  runApp(  //takes root widget and renders it to screen
    MultiProvider( //wraps multiple providers so any widget can access them
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),  //language or theme
        ChangeNotifierProvider.value(value: prayerTimeProvider), //prayer schedules
        ChangeNotifierProvider(create: (_) => TasbeehProvider()), //created on demand for tasbeeh counter
      ],
      child: const NoorAthkarApp(),
    ),
  );

  prayerTimeProvider.init();
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
      home: const SplashScreen(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => AppShellState();

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
