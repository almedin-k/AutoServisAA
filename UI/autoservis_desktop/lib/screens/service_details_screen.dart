import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../models/part.dart';
import '../models/service.dart';
import '../models/service_category.dart';
import '../providers/part_provider.dart';
import '../providers/service_category_provider.dart';
import '../providers/service_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/form_errors.dart';
import '../utils/utils_widgets.dart';
import '../utils/validators.dart';
import '../widgets/error_banner.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/state_views.dart';

class _SelectedPart {
  _SelectedPart({required this.partId, required this.name, required this.unitPrice, required this.quantity});
  final int partId;
  final String name;
  final double unitPrice;
  final int quantity;
}

// Add or edit a service, including its required parts and its image. True when something was saved.
class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key, this.serviceId});
  final int? serviceId;
  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  static const int _maxImageBytes = 2 * 1024 * 1024;
  static const int _maxParts = 30;
  final _formKey = GlobalKey<FormBuilderState>();
  late final ServiceProvider _serviceProvider;
  late final ServiceCategoryProvider _categoryProvider;
  late final PartProvider _partProvider;
  int? _serviceId;
  Service? _service;
  List<ServiceCategory> _categories = [];
  List<Part> _parts = [];
  final List<_SelectedPart> _selectedParts = [];
  bool _isLoading = true;
  String? _loadError;
  bool _isSaving = false;
  String? _formError;
  // "Add part" row.
  int? _addPartId;
  final TextEditingController _addQuantityController = TextEditingController(text: '1');
  String? _addPartError;

  Uint8List? _pickedImage;
  String? _pickedImageName;
  bool _removeImage = false;
  String? _imageError;

  bool get _isEdit => _serviceId != null;

  @override
  void initState() {
    super.initState();
    _serviceId = widget.serviceId;
    _serviceProvider = context.read<ServiceProvider>();
    _categoryProvider = context.read<ServiceCategoryProvider>();
    _partProvider = context.read<PartProvider>();
    _load();
  }

  @override
  void dispose() {
    _addQuantityController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final categories = await _categoryProvider.get(filter: {'pageSize': 100});
      final parts = await _partProvider.get(filter: {'pageSize': 100});
      final service = _serviceId == null ? null : await _serviceProvider.getById(_serviceId!);
      if (!mounted) return;
      setState(() {
        _categories = categories.items;
        _parts = parts.items;
        _service = service;
        _selectedParts
          ..clear()
          ..addAll(
            (service?.requiredParts ?? []).map(
              (p) => _SelectedPart(partId: p.partId, name: p.partName, unitPrice: p.unitPrice, quantity: p.quantity),
            ),
          );
        _isLoading = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _isLoading = false;
      });
    }
  }

  List<Part> get _availableParts =>
      _parts.where((p) => p.isActive && _selectedParts.every((s) => s.partId != p.id)).toList();

  void _addPart() {
    final partId = _addPartId;
    if (partId == null) {
      setState(() => _addPartError = 'Prvo odaberite dio.');
      return;
    }

    final quantity = int.tryParse(_addQuantityController.text.trim());
    if (quantity == null || quantity < 1 || quantity > 100) {
      setState(() => _addPartError = 'Količina mora biti cijeli broj između 1 i 100.');
      return;
    }

    if (_selectedParts.length >= _maxParts) {
      setState(() => _addPartError = 'Usluga može imati najviše $_maxParts potrebnih dijelova.');
      return;
    }

    final part = _parts.firstWhere((p) => p.id == partId);
    setState(() {
      _selectedParts.add(
        _SelectedPart(partId: part.id, name: part.name, unitPrice: part.unitPrice, quantity: quantity),
      );
      _addPartId = null;
      _addQuantityController.text = '1';
      _addPartError = null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = await file.xFile.readAsBytes();

      if (!mounted) return;
      if (bytes.length > _maxImageBytes) {
        setState(() => _imageError = 'Slika je prevelika. Maksimalna veličina je 2 MB.');
        return;
      }

      setState(() {
        _pickedImage = bytes;
        _pickedImageName = file.name;
        _removeImage = false;
        _imageError = null;
      });
    } on Exception {
      if (!mounted) return;
      setState(() => _imageError = 'Slika se ne može pročitati. Odaberite drugu datoteku u podržanom formatu.');
    }
  }

  bool get _hasSavedImage => _service?.hasImage ?? false;
  bool get _canRemoveImage => _pickedImage != null || (_hasSavedImage && !_removeImage);

  void _removeImageClicked() {
    setState(() {
      if (_pickedImage != null) {
        _pickedImage = null;
        _pickedImageName = null;
      } else {
        _removeImage = true;
      }
      _imageError = null;
    });
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }

    final values = _formKey.currentState!.value;
    final request = {
      'categoryId': values['categoryId'] as int,
      'name': (values['name'] as String).trim(),
      'description': (values['description'] as String).trim(),
      'price': Validators.parseDecimal(values['price'] as String),
      'durationMinutes': int.parse((values['durationMinutes'] as String).trim()),
      'warrantyMonths': int.parse((values['warrantyMonths'] as String).trim()),
      'isActive': values['isActive'] as bool? ?? true,
      'requiredParts': [
        for (final part in _selectedParts) {'partId': part.partId, 'quantity': part.quantity},
      ],
    };

    setState(() {
      _isSaving = true;
      _formError = null;
    });

    try {
      // After the first successful insert the screen switches to edit mode, so a retry never creates a duplicate.
      final saved = _isEdit
          ? await _serviceProvider.update(_serviceId!, request)
          : await _serviceProvider.insert(request);
      _serviceId = saved.id;
      _service = saved;
    } on ApiClientException catch (e) {
      if (!mounted) return;
      final leftovers = applyServerErrors(_formKey, e);
      setState(() {
        _isSaving = false;
        _formError = leftovers.isEmpty ? null : leftovers.join('\n');
      });
      return;
    }

    try {
      if (_pickedImage != null) {
        await _serviceProvider.uploadImage(_serviceId!, _pickedImage!, _pickedImageName ?? 'image.jpg');
      } else if (_removeImage && _hasSavedImage) {
        await _serviceProvider.deleteImage(_serviceId!);
      }
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _formError = 'Usluga je spremljena, ali slika nije mogla biti ažurirana: ${e.message}';
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _isEdit ? 'Uređivanje usluge' : 'Nova usluga',
      section: AppSection.serviceManagement,
      showBackButton: true,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView();
    }
    if (_loadError != null) {
      return ErrorView(message: _loadError!, onRetry: _load);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_formError != null) ...[
            ErrorBanner(message: _formError!),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final main = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFormCard(),
                  const SizedBox(height: 20),
                  _buildPartsCard(),
                ],
              );

              if (constraints.maxWidth < 1000) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [main, const SizedBox(height: 20), _buildImageCard()],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: main),
                  const SizedBox(width: 20),
                  SizedBox(width: 320, child: _buildImageCard()),
                ],
              );
            },
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    final service = _service;
    final categoryItems = _categories
        .where((c) => c.isActive || c.id == service?.categoryId)
        .map(
          (c) => DropdownMenuItem<int>(
            value: c.id,
            child: Text(c.isActive ? c.name : '${c.name} (neaktivna)'),
          ),
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'categoryId': service?.categoryId,
            'name': service?.name ?? '',
            'description': service?.description ?? '',
            'price': service == null ? '' : formatDecimal(service.price),
            'durationMinutes': service?.durationMinutes.toString() ?? '',
            'warrantyMonths': service?.warrantyMonths.toString() ?? '0',
            'isActive': service?.isActive ?? true,
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Podaci o usluzi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: FormBuilderTextField(
                      name: 'name',
                      enabled: !_isSaving,
                      decoration: const InputDecoration(labelText: 'Naziv'),
                      validator: Validators.compose([
                        Validators.required('Unesite naziv usluge.'),
                        Validators.maxLength(100),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FormBuilderDropdown<int>(
                      name: 'categoryId',
                      enabled: !_isSaving,
                      decoration: const InputDecoration(labelText: 'Kategorija'),
                      items: categoryItems,
                      validator: (value) => value == null ? 'Odaberite kategoriju.' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                enabled: !_isSaving,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Opis'),
                validator: Validators.compose([
                  Validators.required('Unesite opis usluge.'),
                  Validators.maxLength(1000),
                ]),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'price',
                      enabled: !_isSaving,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cijena (KM)',
                        helperText: 'Samo rad. Dijelovi se naplaćuju posebno.',
                        helperMaxLines: 2,
                      ),
                      validator: Validators.decimal(
                        min: 0,
                        minInclusive: false,
                        max: 100000,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'durationMinutes',
                      enabled: !_isSaving,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Trajanje (min)',
                        helperText: 'U koracima od 5 minuta. Trajanje mora biti djelivo sa 5.',
                      ),
                      validator: Validators.integer(min: 5, max: 720, multipleOf: 5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'warrantyMonths',
                      enabled: !_isSaving,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Garancija (mjeseci)',
                        helperText: '0 znači bez garancije.',
                      ),
                      validator: Validators.integer(min: 0, max: 60),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FormBuilderSwitch(
                name: 'isActive',
                enabled: !_isSaving,
                title: const Text('Aktivno'),
                subtitle: const Text('Klijenti vide samo aktivne usluge.'),
                decoration: const InputDecoration(border: InputBorder.none, filled: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartsCard() {
    final available = _availableParts;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Potrebni dijelovi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              'Dijelovi koji su obično potrebni za ovu uslugu. Klijent ih vidi samo za orijentaciju.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            if (_selectedParts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nijedan dio nije dodan.', style: TextStyle(color: AppColors.textMuted)),
              )
            else
              for (final part in _selectedParts) _buildPartRow(part),
            const Divider(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FilterDropdown<int?>(
                    value: _addPartId,
                    width: null,
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(
                          available.isEmpty ? 'Nema više dijelova za dodavanje' : 'Odaberite dio...',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                      for (final part in available)
                        DropdownMenuItem<int?>(
                          value: part.id,
                          child: Text('${part.name} (${formatMoney(part.unitPrice)})', overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _addPartId = value;
                      _addPartError = null;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _addQuantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Kol.'),
                    onChanged: (_) => setState(() => _addPartError = null),
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: _addPartId == null ? 'Prvo odaberite dio.' : 'Dodaj dio ovoj usluzi',
                  child: ElevatedButton.icon(
                    style: AppTheme.accentButton(),
                    onPressed: _addPartId == null ? null : _addPart,
                    icon: const Icon(Icons.add),
                    label: const Text('Dodaj'),
                  ),
                ),
              ],
            ),
            if (_addPartError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_addPartError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartRow(_SelectedPart part) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(part.name, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Količina: ${part.quantity}')),
          Expanded(flex: 2, child: Text(formatMoney(part.unitPrice), style: const TextStyle(color: AppColors.textMuted))),
          IconButton(
            tooltip: 'Ukloni dio',
            onPressed: _isSaving ? null : () => setState(() => _selectedParts.remove(part)),
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    final Widget preview;
    if (_pickedImage != null) {
      preview = Image.memory(_pickedImage!, fit: BoxFit.cover);
    } else if (_hasSavedImage && !_removeImage) {
      final version = _service?.updatedAt?.millisecondsSinceEpoch ?? 0;
      preview = Image.network(
        _serviceProvider.imageUrl(_serviceId!, version: version),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder('Slika se ne može učitati.'),
      );
    } else {
      preview = _imagePlaceholder('Nema slike');
    }

    String? note;
    if (_pickedImage != null) {
      note = 'Nova slika: $_pickedImageName će biti spremljena kada spremite uslugu.';
    } else if (_removeImage) {
      note = 'Slika će biti uklonjena kada spremite uslugu.';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Slika', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: preview),
            ),
            const SizedBox(height: 8),
            const Text(
              'JPEG, PNG ili WebP, do 2 MB.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            if (note != null) ...[
              const SizedBox(height: 6),
              Text(note, style: const TextStyle(fontSize: 12)),
            ],
            if (_imageError != null) ...[
              const SizedBox(height: 6),
              Text(_imageError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _pickImage,
                    icon: const Icon(Icons.upload_file_outlined, size: 18),
                    label: const Text('Odaberi'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: _canRemoveImage ? 'Ukloni sliku' : 'Ova usluga nema sliku za uklanjanje.',
                    child: OutlinedButton.icon(
                      onPressed: (_isSaving || !_canRemoveImage) ? null : _removeImageClicked,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Ukloni'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(String text) => Container(
        color: AppColors.field,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
}
