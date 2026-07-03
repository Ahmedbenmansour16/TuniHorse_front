import 'package:flutter/material.dart';
import 'package:tunihorse/features/horses/presentation/pages/rider_horses_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/rider_history_page.dart';
import 'package:tunihorse/features/rider/presentation/pages/rider_home_page.dart';
import 'package:tunihorse/features/rider/presentation/pages/rider_profile_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/start_workout_page.dart';

class RiderRootPage extends StatefulWidget {
  const RiderRootPage({super.key});

  @override
  State<RiderRootPage> createState() => _RiderRootPageState();
}

class _RiderRootPageState extends State<RiderRootPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const RiderHomePage(),
      const RiderHorsesPage(inShell: true),
      const StartWorkoutPage(inShell: true),
      const RiderHistoryPage(inShell: true),
      const RiderProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hdr_strong),
            activeIcon: Icon(Icons.hdr_strong),
            label: 'Chevaux',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.power_settings_new_outlined),
            activeIcon: Icon(Icons.power_settings_new),
            label: 'Seance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
