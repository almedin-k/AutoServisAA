import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../models/part.dart';
import '../providers/part_provider.dart';
import '../utils/api_client_exception.dart';
import '../utils/form_errors.dart';
import '../utils/utils_widgets.dart';
import '../utils/validators.dart';
import '../widgets/error_banner.dart';

// Add or edit a part. True when something was saved.
class PartDetailsScreen extends StatefulWidget {
  const PartDetailsScreen({super.key, this.part});
  final Part? part;
  @override
  State<PartDetailsScreen> createState() => _PartDetailsScreenState();
}

class _PartDetailsScreenState extends State<PartDetailsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final PartProvider _provider;
  bool _isSaving = false;
  String? _formError;
  bool get _isEdit => widget.part != null;

  @override
  void initState() {
    super.initState();
    _provider = context.read<PartProvider>();
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }
    final values = _formKey.currentState!.value;
    final sku = (values['sku'] as String? ?? '').trim();
    final request = {
      'name': (values['name'] as String).trim(),
      'sku': sku.isEmpty ? null : sku,
      'unitPrice': Validators.parseDecimal(values['unitPrice'] as String),
      'isActive': values['isActive'] as bool? ?? true,
    };

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      if (_isEdit) {
        await _provider.update(widget.part!.id, request);
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
    final part = widget.part;
    return MasterScreen(
      title: _isEdit ? 'Uređivanje dijela' : 'Novi dio',
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
                        'name': part?.name ?? '',
                        'sku': part?.sku ?? '',
                        'unitPrice': part == null ? '' : formatDecimal(part.unitPrice),
                        'isActive': part?.isActive ?? true,
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
                              Validators.required('Unesite naziv dijela.'),
                              Validators.maxLength(100),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'sku',
                                  enabled: !_isSaving,
                                  decoration: const InputDecoration(
                                    labelText: 'SKU oznaka (nije obavezno)',
                                    helperText: 'Slova, brojevi, tačke, crtice i donje crte.',
                                  ),
                                  validator: Validators.compose([
                                    Validators.maxLength(50),
                                    (value) {
                                      final text = (value ?? '').trim();
                                      if (text.isNotEmpty && !RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(text)) {
                                        return 'SKU oznaka može sadržavati samo slova, brojeve, tačke, crtice i donje crte.';
                                      }
                                      return null;
                                    },
                                  ]),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'unitPrice',
                                  enabled: !_isSaving,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(labelText: 'Jedinična cijena (KM)'),
                                  validator: Validators.decimal(
                                    min: 0,
                                    max: 100000,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FormBuilderSwitch(
                            name: 'isActive',
                            enabled: !_isSaving,
                            title: const Text('Aktivno'),
                            subtitle: const Text('Neaktivni dijelovi ostaju u starim zapisima, ali se ne bi trebali koristiti za nove radove.'),
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
