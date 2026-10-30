import 'package:json_annotation/json_annotation.dart';
import '../utils/formatters.dart';
part 'user_profile.g.dart';

// The account data of the signed-in client, as returned by GET /Profile.
@JsonSerializable()
class UserProfile {
  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.cityId,
    this.cityName,
    this.hasProfileImage = false,
    required this.createdAt,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? phoneNumber;
  final int? cityId;
  final String? cityName;
  @JsonKey(defaultValue: false)
  final bool hasProfileImage;
  final DateTime createdAt;
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
  String get fullName => '$firstName $lastName'.trim();
  String get initials => initialsOf(firstName, lastName);
}