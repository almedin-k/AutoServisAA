import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../models/service_category.dart';
import '../providers/service_category_provider.dart';
import '../utils/api_client_exception.dart';
import '../utils/form_errors.dart';
import '../utils/validators.dart';
import '../widgets/error_banner.dart';

// Add or edit a service category. True when something was saved.
class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({super.key, this.category});
  final ServiceCategory? category;
  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final ServiceCategoryProvider _provider;

  bool _isSaving = false;
  String? _formError;
  bool get _isEdit => widget.category != null;
  @override
  void initState() {
    super.initState();
    _provider = context.read<ServiceCategoryProvider>();
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    final values = _formKey.currentState!.value;
    final description = (values['description'] as String? ?? '').trim();
    final request = {
      'name': (values['name'] as String).trim(),
      'description': description.isEmpty ? null : description,
      'isActive': values['isActive'] as bool? ?? true,
    };

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      if (_isEdit) {
        await _provider.update(widget.category!.id, request);
      } else {
        await _provider.insert(request);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiClientException catch (e) {
      if (!mounted) return;
      final leftovers = applyServerErrors(_formKey, e);
      setState(() {
        _isSaving = false;
        _formError = leftovers.isEmpty ? null : leftovers.join('\n');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    return MasterScreen(
      title: _isEdit ? 'Uređivanje kategorije' : 'Nova kategorija',
      section: AppSection.serviceManagement,
      showBackButton: true,
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FormBuilder(
                      key: _formKey,
                      initialValue: {
                        'name': category?.name ?? '',
                        'description': category?.description ?? '',
                        'isActive': category?.isActive ?? true,
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_formError != null) ...[
                            ErrorBanner(message: _formError!),
                            const SizedBox(height: 16),
                          ],
                          FormBuilderTextField(
                            name: 'name',
                            enabled: !_isSaving,
                            decoration: const InputDecoration(labelText: 'Naziv'),
                            validator: Validators.compose([
                              Validators.required('Unesite naziv kategorije.'),
                              Validators.maxLength(100),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          FormBuilderTextField(
                            name: 'description',
                            enabled: !_isSaving,
                            maxLines: 4,
                            decoration: const InputDecoration(labelText: 'Opis (nije obavezno)'),
                            validator: Validators.maxLength(500),
                          ),
                          const SizedBox(height: 8),
                          FormBuilderSwitch(
                            name: 'isActive',
                            enabled: !_isSaving,
                            title: const Text('Aktivno'),
                            subtitle: const Text('Klijenti vide samo aktivne kategorije.'),
                            decoration: const InputDecoration(border: InputBorder.none, filled: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).maybePop(),
                      child: const Text('Odustani'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Spremi'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
