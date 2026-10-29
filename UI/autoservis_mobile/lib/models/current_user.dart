import 'package:json_annotation/json_annotation.dart';
import '../utils/formatters.dart';
part 'current_user.g.dart';

@JsonSerializable()
class CurrentUser {
  CurrentUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.roles = const [],
  });

  static const String clientRole = 'Client';
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;

  @JsonKey(defaultValue: <String>[])
  final List<String> roles;
  factory CurrentUser.fromJson(Map<String, dynamic> json) => _$CurrentUserFromJson(json);
  Map<String, dynamic> toJson() => _$CurrentUserToJson(this);
  String get fullName => '$firstName $lastName'.trim();
  String get initials => initialsOf(firstName, lastName);
  // Mobile app is for vehicle owners. The workshop team uses the desktop application.
  bool get isClient => roles.contains(clientRole);
}