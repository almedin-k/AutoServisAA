import 'package:json_annotation/json_annotation.dart';
part 'service_part.g.dart';

@JsonSerializable()
class ServicePart {
  ServicePart({
    required this.partId,
    required this.partName,
    required this.unitPrice,
    required this.quantity,
  });

  final int partId;
  final String partName;
  final double unitPrice;
  final int quantity;
  factory ServicePart.fromJson(Map<String, dynamic> json) => _$ServicePartFromJson(json);
  Map<String, dynamic> toJson() => _$ServicePartToJson(this);
}