import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/form_errors.dart';
import '../utils/validators.dart';
import '../widgets/dark_header.dart';
import '../widgets/error_banner.dart';

// Changes the password. The screen closes with the result true when the password was changed.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;
  bool _hidePasswords = true;
  List<String> _errors = const [];
  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }
    final values = _formKey.currentState!.value;
    final provider = context.read<ProfileProvider>();
    setState(() {
      _isSubmitting = true;
      _errors = const [];
    });

    try {
      await provider.changePassword(
        currentPassword: values['currentPassword'] as String,
        newPassword: values['newPassword'] as String,
        confirmNewPassword: values['confirmNewPassword'] as String,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiClientException catch (e) {
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
            title: 'Promjena lozinke',
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
    final toggle = IconButton(
      tooltip: _hidePasswords ? 'Prikaži lozinke' : 'Sakrij lozinke',
      onPressed: () => setState(() => _hidePasswords = !_hidePasswords),
      icon: Icon(_hidePasswords ? Icons.visibility_outlined : Icons.visibility_off_outlined),
    );
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
            const InfoBanner(
              message: 'Nakon promjene lozinke bit ćete odjavljeni sa svih ostalih uređaja.',
            ),
            const SizedBox(height: 16),
            if (_errors.isNotEmpty) ...[
              ErrorBanner(message: _errors.join('\n')),
              const SizedBox(height: 16),
            ],
            FormBuilderTextField(
              name: 'currentPassword',
              enabled: !_isSubmitting,
              obscureText: _hidePasswords,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'Trenutna lozinka', suffixIcon: toggle),
              validator: Validators.required('Unesite trenutnu lozinku.'),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'newPassword',
              enabled: !_isSubmitting,
              obscureText: _hidePasswords,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nova lozinka'),
              validator: Validators.compose([
                Validators.password(),
                Validators.differentFrom(
                  () => _formKey.currentState?.fields['currentPassword']?.value as String?,
                  'Nova lozinka mora biti različita od trenutne.',
                ),
              ]),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'confirmNewPassword',
              enabled: !_isSubmitting,
              obscureText: _hidePasswords,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Potvrda nove lozinke'),
              validator: Validators.sameAs(
                () => _formKey.currentState?.fields['newPassword']?.value as String?,
                'Potvrđena lozinka se ne podudara s novom lozinkom.',
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
                    ): const Text('Promijeni lozinku'),
            ),
          ],
        ),
      ),
    );
  }
}