// Engine type of a vehicle.
enum EngineType {
  petrol('Petrol', 'Benzin'),
  diesel('Diesel', 'Dizel'),
  hybrid('Hybrid', 'Hibrid'),
  electric('Electric', 'Električni'),
  lpg('Lpg', 'Plin(LPG)');

  const EngineType(this.apiName, this.label);
  final String apiName;
  final String label;
  static EngineType fromApi(String? value) {
    return EngineType.values.firstWhere(
      (type) => type.apiName == value,
      orElse: () => EngineType.petrol,
    );
  }
}