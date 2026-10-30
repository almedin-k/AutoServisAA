import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../models/city.dart';
import '../providers/city_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/form_errors.dart';
import '../utils/validators.dart';
import '../widgets/dark_header.dart';
import '../widgets/error_banner.dart';

// Changes the profile data of the signed-in client. The screen closes with the result true when saved.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int _noCity = 0;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;
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
    final provider = context.read<ProfileProvider>();
    final cityValue = values['cityId'] as int?;
    setState(() {
      _isSubmitting = true;
      _errors = const [];
    });
    try {
      await provider.update(
        firstName: (values['firstName'] as String).trim(),
        lastName: (values['lastName'] as String).trim(),
        email: (values['email'] as String).trim(),
        phoneNumber: (values['phoneNumber'] as String?)?.trim(),
        cityId: _cities == null
            ? provider.profile?.cityId
            : (cityValue == null || cityValue == _noCity ? null : cityValue),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } 
    on ApiClientException catch (e) {
      if (!mounted) return;
      final leftovers = applyServerErrors(_formKey, e);
      setState(() {
        _errors = leftovers;
        _isSubmitting = false;
      });
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
            title: 'Uredi profil',
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
    final profile = context.read<ProfileProvider>().profile;
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
              initialValue: profile?.firstName,
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
              initialValue: profile?.lastName,
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
              name: 'email',
              enabled: !_isSubmitting,
              initialValue: profile?.email,
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
              initialValue: profile?.phoneNumber,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Broj telefona (nije obavezno)'),
              validator: Validators.optionalPhone(),
            ),
            const SizedBox(height: 14),
            _buildCityField(profile?.cityId),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Sačuvaj izmjene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityField(int? currentCityId) {
    final cities = _cities;
    if (cities == null) {
      if (_citiesFailed) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Gradovi se trenutno ne mogu učitati. Grad ostaje nepromijenjen.',
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
    final hasCurrentCity = currentCityId != null && cities.any((city) => city.id == currentCityId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FormBuilderDropdown<int>(
        name: 'cityId',
        enabled: !_isSubmitting,
        initialValue: hasCurrentCity ? currentCityId : _noCity,
        decoration: const InputDecoration(labelText: 'Grad (nije obavezno)'),
        items: [
          const DropdownMenuItem<int>(value: _noCity, child: Text('Bez grada')),
          for (final city in cities) DropdownMenuItem<int>(value: city.id, child: Text(city.name)),
        ],
      ),
    );
  }
}