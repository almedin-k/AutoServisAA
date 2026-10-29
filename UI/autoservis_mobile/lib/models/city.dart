import 'package:json_annotation/json_annotation.dart';
part 'city.g.dart';

@JsonSerializable()
class City {
  City({
    required this.id,
    required this.name,
    this.postalCode,
  });

  final int id;
  final String name;
  final String? postalCode;
  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);
}