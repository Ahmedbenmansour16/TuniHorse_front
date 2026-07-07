import 'package:flutter/material.dart';
import 'package:tunihorse/features/courses/presentation/pages/courses_list_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_details_page.dart';
import 'package:tunihorse/features/trainer/presentation/pages/trainer_home_page.dart';
import 'package:tunihorse/features/trainer/presentation/pages/trainer_profile_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/live_sessions_page.dart';

class TrainerRootPage extends StatefulWidget {
  const TrainerRootPage({super.key});

  @override
  State<TrainerRootPage> createState() => _TrainerRootPageState();
}

class _TrainerRootPageState extends State<TrainerRootPage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const TrainerHomePage(),
      const TeamDetailsPage(inShell: true),
      const LiveSessionsPage(inShell: true),
      const CoursesListPage(inShell: true),
      const TrainerProfilePage(),
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
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Équipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Séances',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Courses',
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
