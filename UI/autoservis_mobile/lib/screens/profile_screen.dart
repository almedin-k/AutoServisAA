import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/current_user.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/utils_widgets.dart';
import '../widgets/action_row.dart';
import '../widgets/dark_header.dart';
import '../widgets/error_banner.dart';
import '../widgets/photo_source_sheet.dart';
import '../widgets/profile_avatar.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'garage_screen.dart';

/// Profile tab: picture, account data, garage, password and sign out. 
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingPhoto = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProfileProvider>().load();
      context.read<VehicleProvider>().load();
    });
  }

  Future<void> _signOut() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Odjava',
      message: 'Da li ste sigurni da se želite odjaviti?',
      confirmText: 'Odjavi se',
      destructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    // The root navigator moves to the login screen as soon as the session ends.
    await context.read<AuthProvider>().logout();
  }

  Future<void> _editProfile() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const EditProfileScreen()),
    );

    if (saved == true && mounted) {
      showMessage(context, 'Profil je sačuvan.');
    }
  }

  Future<void> _changePassword() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const ChangePasswordScreen()),
    );

    if (changed == true && mounted) {
      showMessage(context, 'Lozinka je promijenjena.');
    }
  }

  Future<void> _openGarage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const GarageScreen()),
    );
  }

  Future<void> _changePhoto() async {
    if (_isUploadingPhoto) {
      return;
    }

    final profiles = context.read<ProfileProvider>();
    final action = await showPhotoSourceSheet(context, hasPhoto: profiles.imageBytes != null);
    if (action == null || !mounted) {
      return;
    }

    if (action == PhotoAction.remove) {
      await _runUpload(() => profiles.removeImage(), 'Slika profila je uklonjena.');
      return;
    }

    final picked = await _pickPhoto(action);
    if (picked == null || !mounted) {
      return;
    }

    await _runUpload(() => profiles.setImage(picked.bytes, picked.name), 'Slika profila je sačuvana.');
  }

  /// Opens the gallery or the camera. The picture is reduced to at most 1024 px, so the upload stays small.
  /// Returns null when the user cancels or the picture cannot be read.
  Future<({Uint8List bytes, String name})?> _pickPhoto(PhotoAction action) async {
    try {
      final file = await _picker.pickImage(
        source: action == PhotoAction.camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) {
        return null;
      }

      final bytes = await file.readAsBytes();
      return (bytes: bytes, name: file.name.isEmpty ? 'profile.jpg' : file.name);
    } on PlatformException {
      if (mounted) {
        showMessage(
          context,
          action == PhotoAction.camera ? 'Nije moguće otvoriti kameru.' : 'Nije moguće otvoriti galeriju.',
        );
      }
      return null;
    }
  }

  Future<void> _runUpload(Future<void> Function() action, String successMessage) async {
    setState(() => _isUploadingPhoto = true);

    try {
      await action();
      if (mounted) {
        showMessage(context, successMessage);
      }
    } on ApiClientException catch (e) {
      if (mounted) {
        showMessage(context, e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold();
    }

    final profiles = context.watch<ProfileProvider>();
    final vehicles = context.watch<VehicleProvider>();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          DarkHeader(title: 'Moj profil', overlap: 0, child: _buildIdentity(user, profiles.imageBytes)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Podaci o računu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _buildAccountCard(user, profiles),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: profiles.profile == null ? null : _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Uredi profil'),
                ),
                const SizedBox(height: 24),
                const Text('Garaža i sigurnost', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _buildShortcutsCard(vehicles),
                const SizedBox(height: 24),
                const Text('Moje rezervacije', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _buildReservationsCard(),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: AppColors.danger),
                    label: const Text('Odjava', style: TextStyle(color: AppColors.danger)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentity(CurrentUser user, Uint8List? imageBytes) {
    // The full width makes the header column centre the avatar and the name, as in the mockup.
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Semantics(
            button: true,
            label: 'Promijeni sliku profila',
            child: GestureDetector(
              onTap: _changePhoto,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ProfileAvatar(
                    radius: 42,
                    initials: user.initials,
                    imageBytes: imageBytes,
                    isBusy: _isUploadingPhoto,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.header, width: 2),
                      ),
                      child: const Icon(Icons.photo_camera, size: 16, color: AppColors.header),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            '@${user.username}',
            style: const TextStyle(color: AppColors.navMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(CurrentUser user, ProfileProvider profiles) {
    final UserProfile? profile = profiles.profile;

    Widget row(IconData icon, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.teal),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final rows = <Widget>[
      row(Icons.person_outline, 'Ime i prezime', user.fullName),
      row(Icons.alternate_email, 'Korisničko ime', user.username),
      row(Icons.mail_outline, 'E-mail', user.email),
      if (profile != null) ...[
        row(Icons.phone_outlined, 'Telefon', _orDash(profile.phoneNumber)),
        row(Icons.location_city_outlined, 'Grad', _orDash(profile.cityName)),
        row(Icons.event_outlined, 'Član od', formatDate(profile.createdAt)),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (profile == null && profiles.error != null) ...[
          ErrorBanner(message: profiles.error!),
          TextButton(
            onPressed: () => context.read<ProfileProvider>().load(force: true),
            child: const Text('Pokušaj ponovo'),
          ),
          const SizedBox(height: 4),
        ],
        Card(
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(),
                rows[i],
              ],
            ],
          ),
        ),
        if (profile == null && profiles.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(minHeight: 3),
          ),
      ],
    );
  }

  String _orDash(String? value) => (value == null || value.trim().isEmpty) ? '—' : value;

  Widget _buildShortcutsCard(VehicleProvider vehicles) {
    final String garageSubtitle;
    if (!vehicles.isLoaded) {
      garageSubtitle = 'Pregled i upravljanje vozilima';
    } else if (vehicles.vehicles.isEmpty) {
      garageSubtitle = 'Dodajte svoje prvo vozilo';
    } else {
      garageSubtitle = formatVehicleCount(vehicles.vehicles.length);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ActionRow(
            icon: Icons.directions_car_outlined,
            title: 'Moja garaža',
            subtitle: garageSubtitle,
            onTap: _openGarage,
          ),
          const Divider(),
          ActionRow(
            icon: Icons.lock_outline,
            title: 'Promijeni lozinku',
            subtitle: 'Odjavit ćemo vas sa ostalih uređaja',
            onTap: _changePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: AppColors.textMuted),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Još nemate rezervacija. Zakazivanje termina bit će dostupno uskoro.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}