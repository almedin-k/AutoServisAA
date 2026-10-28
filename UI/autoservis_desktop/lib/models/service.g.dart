// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
  id: (json['id'] as num).toInt(),
  categoryId: (json['categoryId'] as num).toInt(),
  categoryName: json['categoryName'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  warrantyMonths: (json['warrantyMonths'] as num).toInt(),
  isActive: json['isActive'] as bool,
  hasImage: json['hasImage'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  requiredParts:
      (json['requiredParts'] as List<dynamic>?)
          ?.map((e) => ServicePart.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
  'id': instance.id,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'durationMinutes': instance.durationMinutes,
  'warrantyMonths': instance.warrantyMonths,
  'isActive': instance.isActive,
  'hasImage': instance.hasImage,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'requiredParts': instance.requiredParts,
};
