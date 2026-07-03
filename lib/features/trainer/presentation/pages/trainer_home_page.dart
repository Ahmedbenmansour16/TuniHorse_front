import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_details_page.dart';
import 'package:tunihorse/features/health/presentation/pages/horse_health_page.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/team_reports_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_details_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/live_sessions_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/live_tracking_page.dart';

class TrainerHomePage extends StatelessWidget {
  const TrainerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellPage(
      title: 'Bonjour Ahmed',
      subtitle: 'Entraîneur • Écurie des Bois',
      actions: [
        IconButton(
          onPressed: () => openPage(context, const NotificationsPage()),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
      children: [
        GreenHeroCard(
          child: Row(
            children: [
              const Icon(
                Icons.play_circle_fill,
                color: AppColors.gold,
                size: 48,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Démarrer une séance',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sélectionner un cheval avant de commencer',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => openPage(context, const LiveSessionsPage()),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          ),
        ),
        const SectionHeader('Statistiques ce mois'),
        const MetricGrid(stats: trainerStats),
        SectionHeader(
          'Séances en cours',
          action: 'Voir tout',
          onAction: () => openPage(context, const LiveSessionsPage()),
        ),
        LiveSessionTile(
          session: liveSessions.first,
          onTap: () =>
              openPage(context, LiveTrackingPage(session: liveSessions.first)),
        ),
        SectionHeader(
          'Prochaine course',
          action: 'Détails',
          onAction: () =>
              openPage(context, CourseDetailsPage(course: courses.first)),
        ),
        CourseTile(
          course: courses.first,
          onTap: () =>
              openPage(context, CourseDetailsPage(course: courses.first)),
        ),
        const SectionHeader('Rappels santé urgents'),
        TuniCard(
          child: Column(
            children: healthReminders
                .take(2)
                .map((reminder) => _ReminderRow(reminder: reminder))
                .toList(),
          ),
        ),
        const SectionHeader('Accès rapides'),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.groups,
                label: 'Équipe',
                onTap: () => openPage(context, const TeamDetailsPage()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickAction(
                icon: Icons.article,
                label: 'Rapports',
                onTap: () => openPage(context, const TeamReportsPage()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickAction(
                icon: Icons.favorite,
                label: 'Santé',
                onTap: () =>
                    openPage(context, HorseHealthPage(horse: horses.first)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final HealthReminder reminder;

  const _ReminderRow({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(reminder.icon, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  'Éclipse • ${reminder.due}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
