import 'package:json_annotation/json_annotation.dart';

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

  static const String adminRole = 'Admin';
  static const String managerRole = 'Manager';
  static const String mechanicRole = 'Mechanic';

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

  // Admin and Manager can manage the catalog. Mechanics role is read-only.
  bool get isStaff => roles.contains(adminRole) || roles.contains(managerRole);

  // The desktop application is for the workshop team. Clients use the mobile application.
  bool get canUseDesktop => isStaff || roles.contains(mechanicRole);

  // Role name shown in the user interface.
  String get roleLabel => switch (primaryRole) {
        adminRole => 'Admin',
        managerRole => 'Menadžer',
        mechanicRole => 'Mehaničar',
        final other => other,
      };

  String get primaryRole {
    for (final role in [adminRole, managerRole, mechanicRole]) {
      if (roles.contains(role)) {
        return role;
      }
    }
    return roles.isEmpty ? '' : roles.first;
  }
}
