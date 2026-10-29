// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_part.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServicePart _$ServicePartFromJson(Map<String, dynamic> json) => ServicePart(
  partId: (json['partId'] as num).toInt(),
  partName: json['partName'] as String,
  unitPrice: (json['unitPrice'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$ServicePartToJson(ServicePart instance) =>
    <String, dynamic>{
      'partId': instance.partId,
      'partName': instance.partName,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
    };
