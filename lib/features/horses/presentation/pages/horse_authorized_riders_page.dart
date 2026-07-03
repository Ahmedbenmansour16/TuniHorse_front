import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/horses/presentation/pages/assign_horse_to_rider_page.dart';

class HorseAuthorizedRidersPage extends StatelessWidget {
  final Horse horse;

  const HorseAuthorizedRidersPage({super.key, required this.horse});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Cavaliers autorisés',
      showBack: true,
      actions: [
        IconButton(
          onPressed: () => openPage(context, const AssignHorseToRiderPage()),
          icon: const Icon(Icons.add),
        ),
      ],
      children: [
        TuniCard(
          child: Row(
            children: [
              HorsePhoto(horse: horse),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    horse.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${horse.race} • ${horse.age}',
                    style: const TextStyle(color: Color(0xFF777B72)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...riders
            .take(3)
            .map(
              (rider) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TuniCard(
                  child: Row(
                    children: [
                      RiderAvatar(rider: rider),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rider.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Autorisé le 12/04/2025',
                              style: TextStyle(
                                color: Color(0xFF777B72),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const StatusPill('Actif'),
                    ],
                  ),
                ),
              ),
            ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Ajouter un cavalier',
          onPressed: () => openPage(context, const AssignHorseToRiderPage()),
        ),
      ],
    );
  }
}
