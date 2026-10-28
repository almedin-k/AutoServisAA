import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/part_provider.dart';
import 'providers/service_category_provider.dart';
import 'providers/service_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => PartProvider()),
      ],
      child: const AutoServisApp(),
    ),
  );
}

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

  // Signing out (or an expired session) always ends on the login screen, whichever screen was open before.
  void _onAuthChanged() {
    final isAuthenticated = _auth.isAuthenticated;
    if (_wasAuthenticated && !isAuthenticated) {
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
      navigatorKey: _navigatorKey,
      home: const LoginScreen(),
    );
  }
}

// Shown when the app was started without --dart-define=API_BASE_URL.
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
              'flutter run -d windows --dart-define=API_BASE_URL=http://localhost:5126',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}