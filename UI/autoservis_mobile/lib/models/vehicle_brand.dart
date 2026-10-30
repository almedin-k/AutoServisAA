import 'package:json_annotation/json_annotation.dart';
part 'vehicle_brand.g.dart';

@JsonSerializable()
class VehicleBrand {
  VehicleBrand({required this.id, required this.name});
  final int id;
  final String name;
  factory VehicleBrand.fromJson(Map<String, dynamic> json) => _$VehicleBrandFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleBrandToJson(this);
}