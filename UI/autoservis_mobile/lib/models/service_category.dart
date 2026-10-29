import 'package:json_annotation/json_annotation.dart';
part 'service_category.g.dart';

@JsonSerializable()
class ServiceCategory {
  ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  final int id;
  final String name;
  final String? description;
  final bool isActive;
  factory ServiceCategory.fromJson(Map<String, dynamic> json) => _$ServiceCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceCategoryToJson(this);
}