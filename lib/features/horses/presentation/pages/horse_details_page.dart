import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_selections_page.dart';
import 'package:tunihorse/features/health/presentation/pages/horse_health_page.dart';
import 'package:tunihorse/features/horses/presentation/pages/assign_horse_to_rider_page.dart';
import 'package:tunihorse/features/horses/presentation/pages/edit_horse_page.dart';
import 'package:tunihorse/features/horses/presentation/pages/horse_authorized_riders_page.dart';
import 'package:tunihorse/features/horses/presentation/pages/horse_documents_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/horse_workouts_page.dart';

class HorseDetailsPage extends StatelessWidget {
  final Horse horse;

  const HorseDetailsPage({super.key, required this.horse});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Détail cheval',
      showBack: true,
      children: [
        TuniCard(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HorsePhoto(horse: horse, size: 96),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          horse.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${horse.race} • ${horse.age}',
                          style: const TextStyle(color: Color(0xFF777B72)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Propriétaire : ${horse.owner}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Poids : 420 kg',
                          style: TextStyle(color: Color(0xFF777B72)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const InfoLine(
                icon: Icons.timer_outlined,
                label: 'Séances totales',
                value: '12',
              ),
              const InfoLine(
                icon: Icons.route_outlined,
                label: 'Distance totale',
                value: '64,8 km',
              ),
              const InfoLine(
                icon: Icons.speed_outlined,
                label: 'Allure dominante',
                value: 'Trot',
              ),
              const InfoLine(
                icon: Icons.calendar_today_outlined,
                label: 'Dernière séance',
                value: '18/05/2026',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Voir les entraînements',
          onPressed: () => openPage(context, HorseWorkoutsPage(horse: horse)),
        ),
        const SizedBox(height: 10),
        MenuActionTile(
          icon: Icons.edit_outlined,
          title: 'Modifier cheval',
          onTap: () => openPage(context, EditHorsePage(horse: horse)),
        ),
        MenuActionTile(
          icon: Icons.folder_copy_outlined,
          title: 'Documents du cheval',
          onTap: () => openPage(context, HorseDocumentsPage(horse: horse)),
        ),
        MenuActionTile(
          icon: Icons.groups_outlined,
          title: 'Cavaliers autorisés',
          onTap: () =>
              openPage(context, HorseAuthorizedRidersPage(horse: horse)),
        ),
        MenuActionTile(
          icon: Icons.favorite_outline,
          title: 'Santé',
          onTap: () => openPage(context, HorseHealthPage(horse: horse)),
        ),
        MenuActionTile(
          icon: Icons.assignment_outlined,
          title: 'Affecter cavalier',
          onTap: () => openPage(context, const AssignHorseToRiderPage()),
        ),
        MenuActionTile(
          icon: Icons.emoji_events_outlined,
          title: 'Courses sélectionnées',
          onTap: () => openPage(context, const CourseSelectionsPage()),
        ),
      ],
    );
  }
}
