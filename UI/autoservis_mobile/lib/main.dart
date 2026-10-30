import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/city_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/service_category_provider.dart';
import 'providers/service_provider.dart';
import 'providers/vehicle_brand_provider.dart';
import 'providers/vehicle_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.nav,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  if (!AppConfig.isConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => ServiceCategoryProvider()),
        ChangeNotifierProvider(create: (_) => CityProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => VehicleBrandProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider(context.read<AuthProvider>())),
        ChangeNotifierProvider(
          create: (context) => CatalogProvider(
            context.read<ServiceProvider>(),
            context.read<ServiceCategoryProvider>(),
          ),
        ),
      ],
      child: const AutoServisApp(),
    ),
  );
}

const Locale _appLocale = Locale('bs');
const List<LocalizationsDelegate<dynamic>> _localizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class AutoServisApp extends StatefulWidget {
  const AutoServisApp({super.key});
  @override
  State<AutoServisApp> createState() => _AutoServisAppState();
}

class _AutoServisAppState extends State<AutoServisApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthProvider _auth;
  bool _wasAuthenticated = false;
  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthProvider>();
    _auth.addListener(_onAuthChanged);
  }
  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final isAuthenticated = _auth.isAuthenticated;

    if (_wasAuthenticated && !isAuthenticated) {
      context.read<VehicleProvider>().clear();
      context.read<ProfileProvider>().clear();
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
    _wasAuthenticated = isAuthenticated;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoServisAA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: _appLocale,
      supportedLocales: const [_appLocale],
      localizationsDelegates: _localizationsDelegates,
      navigatorKey: _navigatorKey,
      home: const LoginScreen(),
    );
  }
}
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: SelectableText(
              'Adresa API-ja nije podešena.\n\n'
              'Pokrenite aplikaciju ovako:\n'
              'flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5126',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}