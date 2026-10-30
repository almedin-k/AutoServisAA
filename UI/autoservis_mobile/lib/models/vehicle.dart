import 'package:json_annotation/json_annotation.dart';
import 'engine_type.dart';
part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  Vehicle({
    required this.id,
    required this.userId,
    required this.brandId,
    required this.brandName,
    required this.model,
    required this.productionYear,
    required this.engineType,
    required this.engineDisplacementCc,
    required this.enginePowerKw,
    required this.vin,
    required this.mileageKm,
  });
  final int id;
  final int userId;
  final int brandId;
  final String brandName;
  final String model;
  final int productionYear;
  final String engineType; // API sends enum
  final int engineDisplacementCc;
  final int enginePowerKw;
  final String vin;
  final int mileageKm;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);
  EngineType get engine => EngineType.fromApi(engineType);
  String get title => '$brandName $model';
}