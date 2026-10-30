// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  brandId: (json['brandId'] as num).toInt(),
  brandName: json['brandName'] as String,
  model: json['model'] as String,
  productionYear: (json['productionYear'] as num).toInt(),
  engineType: json['engineType'] as String,
  engineDisplacementCc: (json['engineDisplacementCc'] as num).toInt(),
  enginePowerKw: (json['enginePowerKw'] as num).toInt(),
  vin: json['vin'] as String,
  mileageKm: (json['mileageKm'] as num).toInt(),
);

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'brandId': instance.brandId,
  'brandName': instance.brandName,
  'model': instance.model,
  'productionYear': instance.productionYear,
  'engineType': instance.engineType,
  'engineDisplacementCc': instance.engineDisplacementCc,
  'enginePowerKw': instance.enginePowerKw,
  'vin': instance.vin,
  'mileageKm': instance.mileageKm,
};
