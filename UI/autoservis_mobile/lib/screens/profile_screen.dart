import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/current_user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/utils_widgets.dart';
import '../widgets/dark_header.dart';

/// Profile tab: the signed-in user, account data and sign out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Odjava',
      message: 'Da li ste sigurni da se želite odjaviti?',
      confirmText: 'Odjavi se',
      destructive: true,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    // The root navigator moves to the login screen as soon as the session ends.
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold();
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          DarkHeader(title: 'Moj profil', overlap: 0, child: _buildIdentity(user)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Podaci o računu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _buildAccountCard(user),
                const SizedBox(height: 24),
                const Text('Moje rezervacije', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _buildReservationsCard(),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _signOut(context),
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

  Widget _buildIdentity(CurrentUser user) {
    // The full width makes the header column centre the avatar and the name, as in the mockup.
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.teal,
            child: Text(
              user.initials,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
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

  Widget _buildAccountCard(CurrentUser user) {
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

    return Card(
      child: Column(
        children: [
          row(Icons.person_outline, 'Ime i prezime', user.fullName),
          const Divider(),
          row(Icons.alternate_email, 'Korisničko ime', user.username),
          const Divider(),
          row(Icons.mail_outline, 'E-mail', user.email),
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
