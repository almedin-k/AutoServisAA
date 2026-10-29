import 'package:flutter/material.dart';
import '../widgets/dark_header.dart';
import '../widgets/state_views.dart';

/// Reservations tab. The reservation list and the booking wizard are added together with the appointments API.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          DarkHeader(title: 'Rezervacije'),
          Expanded(
            child: EmptyView(
              icon: Icons.calendar_today_outlined,
              message: 'Još nemate rezervacija',
              hint: 'Zakazivanje termina bit će dostupno uskoro.',
            ),
          ),
        ],
      ),
    );
  }
}