import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_selection_page.dart';
import 'package:tunihorse/features/horses/presentation/pages/horse_details_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/team_reports_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/horse_workouts_page.dart';

class RiderDetailsPage extends StatelessWidget {
  final Rider rider;

  const RiderDetailsPage({super.key, required this.rider});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: rider.name,
      showBack: true,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.phone_outlined)),
      ],
      children: [
        TuniCard(
          child: Column(
            children: [
              RiderAvatar(rider: rider, size: 82),
              const SizedBox(height: 12),
              Text(
                rider.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              StatusPill(rider.level),
              const SizedBox(height: 16),
              InfoLine(
                icon: Icons.phone_outlined,
                label: 'Téléphone',
                value: rider.phone,
              ),
              InfoLine(
                icon: Icons.email_outlined,
                label: 'Email',
                value: rider.email,
              ),
              const InfoLine(
                icon: Icons.location_on_outlined,
                label: 'Ville',
                value: 'Sousse',
              ),
            ],
          ),
        ),
        const SectionHeader('Chevaux autorisés'),
        HorseListTile(
          horse: horses.first,
          onTap: () => openPage(context, HorseDetailsPage(horse: horses.first)),
        ),
        HorseListTile(
          horse: horses[1],
          onTap: () => openPage(context, HorseDetailsPage(horse: horses[1])),
        ),
        const SectionHeader('Actions'),
        MenuActionTile(
          icon: Icons.timer_outlined,
          title: 'Voir ses séances',
          onTap: () => openPage(context, const HorseWorkoutsPage()),
        ),
        MenuActionTile(
          icon: Icons.article_outlined,
          title: 'Voir ses rapports',
          onTap: () => openPage(context, const TeamReportsPage()),
        ),
        MenuActionTile(
          icon: Icons.emoji_events_outlined,
          title: 'Associer à une course',
          onTap: () =>
              openPage(context, CourseSelectionPage(course: courses.first)),
        ),
      ],
    );
  }
}
