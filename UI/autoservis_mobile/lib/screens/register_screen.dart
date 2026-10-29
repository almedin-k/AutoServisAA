import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../models/city.dart';
import '../providers/auth_provider.dart';
import '../providers/city_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/form_errors.dart';
import '../utils/utils_widgets.dart';
import '../utils/validators.dart';
import '../widgets/dark_header.dart';
import '../widgets/error_banner.dart';
import 'home_shell.dart';

/// Registration of a new client. After the account is created the user is signed in automatically.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // The city control uses 0 value for "no city", so the control does not need null.
  static const int _noCity = 0;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;
  bool _hidePassword = true;
  List<String> _errors = const [];
  List<City>? _cities;
  bool _citiesFailed = false;
  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final provider = context.read<CityProvider>();
    try {
      final cities = await provider.lookup();
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _citiesFailed = false;
      });
    } on ApiClientException {
      if (!mounted) return;
      setState(() => _citiesFailed = true);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    final values = _formKey.currentState!.value;
    final auth = context.read<AuthProvider>();
    final username = (values['username'] as String).trim();
    final password = values['password'] as String;
    final cityValue = values['cityId'] as int?;
    setState(() {
      _isSubmitting = true;
      _errors = const [];
    });
    try {
      await auth.register(
        firstName: (values['firstName'] as String).trim(),
        lastName: (values['lastName'] as String).trim(),
        username: username,
        email: (values['email'] as String).trim(),
        password: password,
        confirmPassword: values['confirmPassword'] as String,
        phoneNumber: (values['phoneNumber'] as String?)?.trim(),
        cityId: (cityValue == null || cityValue == _noCity) ? null : cityValue,
      );
    } on ApiClientException catch (e) {
      if (!mounted) return;
      final leftovers = applyServerErrors(_formKey, e);
      setState(() {
        _errors = leftovers;
        _isSubmitting = false;
      });
      return;
    }

    try {
      await auth.login(username, password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeShell()),
        (route) => false,
      );
    } on ApiClientException {
      // If the account already exists, only the automatic sign in failed. The user can sign in by hand.
      if (!mounted) return;
      showMessage(context, 'Račun je kreiran. Prijavite se svojim podacima.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          DarkHeader(
            title: 'Registracija',
            overlap: 28,
            leading: IconButton(
              tooltip: 'Nazad',
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _isSubmitting ? null : () => Navigator.of(context).maybePop(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: _buildFormCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errors.isNotEmpty) ...[
              ErrorBanner(message: _errors.join('\n')),
              const SizedBox(height: 16),
            ],
            FormBuilderTextField(
              name: 'firstName',
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Ime'),
              validator: Validators.compose([
                Validators.required('Ime je obavezno.'),
                Validators.maxLength(50, 'Ime ne može imati više od 50 znakova.'),
              ]),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'lastName',
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Prezime'),
              validator: Validators.compose([
                Validators.required('Prezime je obavezno.'),
                Validators.maxLength(50, 'Prezime ne može imati više od 50 znakova.'),
              ]),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'username',
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Korisničko ime'),
              validator: Validators.username(),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'email',
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: Validators.email(),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'phoneNumber',
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Broj telefona (nije obavezno)'),
              validator: Validators.optionalPhone(),
            ),
            const SizedBox(height: 14),
            _buildCityField(),
            FormBuilderTextField(
              name: 'password',
              enabled: !_isSubmitting,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Lozinka',
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? 'Prikaži lozinku' : 'Sakrij lozinku',
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              validator: Validators.password(),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'confirmPassword',
              enabled: !_isSubmitting,
              obscureText: _hidePassword,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Potvrda lozinke'),
              validator: Validators.sameAs(
                () => _formKey.currentState?.fields['password']?.value as String?,
                'Potvrda lozinke se ne podudara s lozinkom.',
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Registruj se'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityField() {
    final cities = _cities;
    if (cities == null) {
      if (_citiesFailed) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Gradovi se trenutno ne mogu učitati. Možete nastaviti i bez grada, pa kasnije urediti.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              TextButton(onPressed: _loadCities, child: const Text('Ponovo')),
            ],
          ),
        );
      }

      return const Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: LinearProgressIndicator(minHeight: 3),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FormBuilderDropdown<int>(
        name: 'cityId',
        enabled: !_isSubmitting,
        initialValue: _noCity,
        decoration: const InputDecoration(labelText: 'Grad (nije obavezno)'),
        items: [
          const DropdownMenuItem<int>(value: _noCity, child: Text('Bez grada')),
          for (final city in cities) DropdownMenuItem<int>(value: city.id, child: Text(city.name)),
        ],
      ),
    );
  }
}