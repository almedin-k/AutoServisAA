import 'package:json_annotation/json_annotation.dart';

part 'part.g.dart';

@JsonSerializable()
class Part {
  Part({
    required this.id,
    required this.name,
    this.sku,
    required this.unitPrice,
    required this.isActive,
  });

  final int id;
  final String name;
  final String? sku;
  final double unitPrice;
  final bool isActive;

  factory Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

  Map<String, dynamic> toJson() => _$PartToJson(this);
}
