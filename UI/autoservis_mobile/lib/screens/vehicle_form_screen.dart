import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import '../models/engine_type.dart';
import '../models/vehicle.dart';
import '../models/vehicle_brand.dart';
import '../providers/vehicle_brand_provider.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/form_errors.dart';
import '../utils/validators.dart';
import '../widgets/dark_header.dart';
import '../widgets/error_banner.dart';

// Adds a vehicle to the garage or changes an existing one.
class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, this.vehicle});
  final Vehicle? vehicle;
  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}
class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;
  List<String> _errors = const [];
  List<VehicleBrand>? _brands;
  bool _brandsFailed = false;
  late EngineType _engineType;
  bool get _isEditing => widget.vehicle != null;
  @override
  void initState() {
    super.initState();
    _engineType = widget.vehicle?.engine ?? EngineType.petrol;
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    final provider = context.read<VehicleBrandProvider>();
    try {
      final brands = await provider.loadAll();
      if (!mounted) return;
      setState(() {
        _brands = brands;
        _brandsFailed = false;
      });
    } on ApiClientException {
      if (!mounted) return;
      setState(() => _brandsFailed = true);
    }
  }

  // An electric vehicle has no engine displacement, so that field is switched off
  void _onEngineTypeChanged(EngineType? value) {
    if (value == null || value == _engineType) {
      return;
    }
    final displacement = _formKey.currentState?.fields['engineDisplacementCc'];
    if (value == EngineType.electric) {
      displacement?.didChange('0');
    } else if (_engineType == EngineType.electric) {
      displacement?.didChange('');
    }
    setState(() => _engineType = value);
  }

  Future<void> _submit() async {
    if (_isSubmitting || _brands == null || !(_formKey.currentState?.saveAndValidate() ?? false)) {
      return;
    }
    final values = _formKey.currentState!.value;
    final provider = context.read<VehicleProvider>();
    int number(String name) => int.parse((values[name] as String).trim());
    setState(() {
      _isSubmitting = true;
      _errors = const [];
    });
    try {
      await provider.save(
        id: widget.vehicle?.id,
        brandId: values['brandId'] as int,
        model: (values['model'] as String).trim(),
        productionYear: number('productionYear'),
        engineType: _engineType,
        engineDisplacementCc: _engineType == EngineType.electric ? 0 : number('engineDisplacementCc'),
        enginePowerKw: number('enginePowerKw'),
        vin: (values['vin'] as String).trim().toUpperCase(),
        mileageKm: number('mileageKm'),
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
            title: _isEditing ? 'Uredi vozilo' : 'Dodaj vozilo',
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
    final vehicle = widget.vehicle;
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
            _buildBrandField(),
            FormBuilderTextField(
              name: 'model',
              enabled: !_isSubmitting,
              initialValue: vehicle?.model,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Model'),
              validator: Validators.compose([
                Validators.required('Model vozila je obavezan.'),
                Validators.maxLength(50, 'Model ne može imati više od 50 znakova.'),
              ]),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'productionYear',
              enabled: !_isSubmitting,
              initialValue: vehicle?.productionYear.toString(),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
              decoration: const InputDecoration(labelText: 'Godina proizvodnje'),
              validator: Validators.integerInRange(
                min: 1950,
                max: DateTime.now().year + 1,
                requiredMessage: 'Godina proizvodnje je obavezna.',
                rangeMessage: 'Godina proizvodnje mora biti između 1950. i ${DateTime.now().year + 1}.',
              ),
            ),
            const SizedBox(height: 14),
            FormBuilderDropdown<EngineType>(
              name: 'engineType',
              enabled: !_isSubmitting,
              initialValue: _engineType,
              decoration: const InputDecoration(labelText: 'Vrsta motora'),
              onChanged: _onEngineTypeChanged,
              items: [
                for (final type in EngineType.values)
                  DropdownMenuItem<EngineType>(value: type, child: Text(type.label)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'engineDisplacementCc',
                    enabled: !_isSubmitting && _engineType != EngineType.electric,
                    initialValue: vehicle?.engineDisplacementCc.toString(),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
                    decoration: const InputDecoration(labelText: 'Zapremina(kubikaža) u cm³'),
                    validator: (value) {
                      if (_engineType == EngineType.electric) {
                        return null;
                      }
                      return Validators.integerInRange(
                        min: 1,
                        max: 10000,
                        requiredMessage: 'Zapremina(kubikaža) je obavezna.',
                        rangeMessage: 'Unesite od 1 do 10.000 cm³.',
                      )(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'enginePowerKw',
                    enabled: !_isSubmitting,
                    initialValue: vehicle?.enginePowerKw.toString(),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                    decoration: const InputDecoration(labelText: 'Snaga u kW'),
                    validator: Validators.integerInRange(
                      min: 1,
                      max: 2000,
                      requiredMessage: 'Snaga je obavezna.',
                      rangeMessage: 'Unesite od 1 do 2.000 kW.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'vin',
              enabled: !_isSubmitting,
              initialValue: vehicle?.vin,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(17),
              ],
              decoration: const InputDecoration(labelText: 'VIN (broj šasije, 17 znakova)'),
              validator: Validators.vin(),
            ),
            const SizedBox(height: 14),
            FormBuilderTextField(
              name: 'mileageKm',
              enabled: !_isSubmitting,
              initialValue: vehicle?.mileageKm.toString(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Kilometraža (km)'),
              validator: Validators.integerInRange(
                min: 0,
                max: 2000000,
                requiredMessage: 'Kilometraža je obavezna.',
                rangeMessage: 'Kilometraža mora biti između 0 i 2.000.000 km.',
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: (_isSubmitting || _brands == null) ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(_isEditing ? 'Sačuvaj izmjene' : 'Dodaj vozilo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandField() {
    final brands = _brands;
    if (brands == null) {
      if (_brandsFailed) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Brendovi vozila se trenutno ne mogu učitati.',
                  style: TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ),
              TextButton(onPressed: _loadBrands, child: const Text('Ponovo')),
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
        name: 'brandId',
        enabled: !_isSubmitting,
        initialValue: widget.vehicle?.brandId,
        decoration: const InputDecoration(labelText: 'Brend'),
        validator: (value) => value == null ? 'Odaberite brend vozila.' : null,
        items: [
          for (final brand in brands) DropdownMenuItem<int>(value: brand.id, child: Text(brand.name)),
        ],
      ),
    );
  }
}