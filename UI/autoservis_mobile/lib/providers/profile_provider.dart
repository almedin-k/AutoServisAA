import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../utils/api_client.dart';
import '../utils/api_client_exception.dart';
import 'auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._auth);
  final AuthProvider _auth;
  UserProfile? _profile;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  String? _error;
  int _generation = 0;
  UserProfile? get profile => _profile;
  Uint8List? get imageBytes => _imageBytes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Future<void> load({bool force = false}) async {
    if (_isLoading || (_profile != null && !force)) {
      return;
    }

    final generation = _generation;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await _fetchProfile();
      final image = loaded.hasProfileImage ? await _fetchImage() : null;
      if (generation != _generation) {
        return;
      }
      _profile = loaded;
      _imageBytes = image;
    } on ApiClientException catch (e) {
      if (generation == _generation) {
        _error = e.message;
      }
    } catch (_) {
      if (generation == _generation) {
        _error = 'Došlo je do neočekivane greške. Pokušajte ponovo.';
      }
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> update({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    int? cityId,
  }) async {
    final response = await ApiClient.send(
      () => http.put(
        ApiClient.buildUri('Profile'),
        headers: ApiClient.headers(),
        body: ApiClient.encodeBody({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': (phoneNumber == null || phoneNumber.isEmpty) ? null : phoneNumber,
          'cityId': cityId,
        }),
      ),
    );
    ApiClient.ensureSuccess(response);
    final updated = UserProfile.fromJson(ApiClient.decodeBody(response) as Map<String, dynamic>);
    _profile = updated;
    _auth.applyProfile(firstName: updated.firstName, lastName: updated.lastName, email: updated.email);
    notifyListeners();
  }

  // Changes the password. The API signs the user out on all other devices.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final response = await ApiClient.send(
      () => http.put(
        ApiClient.buildUri('Profile/password'),
        headers: ApiClient.headers(),
        body: ApiClient.encodeBody({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        }),
      ),
    );
    ApiClient.ensureSuccess(response);
  }

  Future<void> setImage(Uint8List bytes, String fileName) async {
    final response = await ApiClient.sendMultipart(() {
      final request = http.MultipartRequest('PUT', ApiClient.buildUri('Profile/image'));
      request.headers.addAll(ApiClient.headers(json: false));
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
      return request;
    });
    ApiClient.ensureSuccess(response);
    _imageBytes = bytes;
    notifyListeners();
  }

  Future<void> removeImage() async {
    final response = await ApiClient.send(
      () => http.delete(ApiClient.buildUri('Profile/image'), headers: ApiClient.headers(json: false)),
    );
    ApiClient.ensureSuccess(response);
    _imageBytes = null;
    notifyListeners();
  }

  // Clears everything. Called when the user signs out.
  void clear() {
    _generation++;
    _profile = null;
    _imageBytes = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<UserProfile> _fetchProfile() async {
    final response = await ApiClient.send(
      () => http.get(ApiClient.buildUri('Profile'), headers: ApiClient.headers()),
    );
    ApiClient.ensureSuccess(response);
    return UserProfile.fromJson(ApiClient.decodeBody(response) as Map<String, dynamic>);
  }

  Future<Uint8List?> _fetchImage() async {
    final response = await ApiClient.send(
      () => http.get(ApiClient.buildUri('Profile/image'), headers: ApiClient.headers(json: false)),
    );
    if (response.statusCode == 404) {
      return null;
    }
    ApiClient.ensureSuccess(response);
    return response.bodyBytes;
  }
}