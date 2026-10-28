// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Part _$PartFromJson(Map<String, dynamic> json) => Part(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  sku: json['sku'] as String?,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$PartToJson(Part instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sku': instance.sku,
  'unitPrice': instance.unitPrice,
  'isActive': instance.isActive,
};
