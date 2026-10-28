import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/validators.dart';
import '../widgets/error_banner.dart';
import 'dashboard_screen.dart';

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
        MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(flex: 5, child: _buildBrandPanel()),
          Expanded(flex: 4, child: _buildFormPanel(context)),
        ],
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      color: AppColors.sidebar,
      padding: const EdgeInsets.all(48),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.directions_car_filled_outlined, color: AppColors.primary, size: 64),
          SizedBox(height: 24),
          Text(
            'AutoServisAA',
            style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'Upravljanje servisom: rezervacije, usluge i izvještaji na jednom mjestu.',
            style: TextStyle(color: AppColors.sidebarText, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Prijava',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text('Prijavite se sa svojom ulogom.', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 24),
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
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Korisničko ime',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.required('Unesite korisničko ime.'),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSigningIn ? null : _signIn,
                  child: _isSigningIn
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Prijavi se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
