import 'package:json_annotation/json_annotation.dart';
import 'service_part.dart';
part 'service.g.dart';

@JsonSerializable()
class Service {
  Service({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.warrantyMonths,
    required this.isActive,
    required this.hasImage,
    required this.createdAt,
    this.updatedAt,
    this.requiredParts = const [],
  });

  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final int warrantyMonths;
  final bool isActive;
  final bool hasImage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @JsonKey(defaultValue: <ServicePart>[])
  final List<ServicePart> requiredParts;
  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}