import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/validators.dart';
import '../widgets/dark_header.dart';
import '../widgets/error_banner.dart';
import 'home_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSigningIn = false;
  bool _hidePassword = true;
  String? _error;
  late final bool _sessionExpired;
  @override
  void initState() {
    super.initState();
    _sessionExpired = context.read<AuthProvider>().consumeSessionExpired();
  }

  Future<void> _signIn() async {
    if (_isSigningIn || !(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }
    final values = _formKey.currentState!.value;
    final auth = context.read<AuthProvider>();

    setState(() {
      _isSigningIn = true;
      _error = null;
    });
    try {
      await auth.login((values['username'] as String).trim(), values['password'] as String);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeShell()),
        (route) => false,
      );
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isSigningIn = false;
      });
    }
  }
  void _openRegistration() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.header,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.directions_car_filled_outlined, color: AppColors.tealLight, size: 56),
                  const SizedBox(height: 12),
                  const Center(child: BrandTitle(fontSize: 34)),
                  const SizedBox(height: 8),
                  const Text(
                    'Rezervišite servis brzo i jednostavno, sa svog telefona.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.navMuted, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  _buildFormCard(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Nemate račun?', style: TextStyle(color: AppColors.navMuted)),
                      TextButton(
                        onPressed: _isSigningIn ? null : _openRegistration,
                        style: TextButton.styleFrom(foregroundColor: AppColors.tealLight),
                        child: const Text('Registrujte se'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Prijava', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Prijavite se svojim računom.', style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 20),
            if (_sessionExpired && _error == null) ...[
              const InfoBanner(message: 'Vaša sesija je istekla. Prijavite se ponovo.'),
              const SizedBox(height: 16),
            ],
            if (_error != null) ...[
              ErrorBanner(message: _error!),
              const SizedBox(height: 16),
            ],
            FormBuilderTextField(
              name: 'username',
              enabled: !_isSigningIn,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Korisničko ime',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: Validators.required('Unesite korisničko ime.'),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'password',
              enabled: !_isSigningIn,
              obscureText: _hidePassword,
              onSubmitted: (_) => _signIn(),
              decoration: InputDecoration(
                labelText: 'Lozinka',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? 'Prikaži lozinku' : 'Sakrij lozinku',
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              validator: Validators.required('Unesite lozinku.'),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _isSigningIn ? null : _signIn,
              child: _isSigningIn
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Prijavi se'),
            ),
          ],
        ),
      ),
    );
  }
}