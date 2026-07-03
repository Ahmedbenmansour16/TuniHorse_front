import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/reports/presentation/pages/report_details_page.dart';

class FinishWorkoutPage extends StatelessWidget {
  const FinishWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Seance terminee',
      showBack: true,
      children: [
        TuniCard(
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: AppColors.green, size: 58),
              const SizedBox(height: 10),
              const Text(
                'Felicitations !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Belle seance',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  HorsePhoto(horse: horses.first),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          horses.first.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${horses.first.race} - ${horses.first.age}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const TuniCard(
          child: Column(
            children: [
              InfoLine(icon: Icons.schedule, label: 'Duree', value: '45:12'),
              InfoLine(
                icon: Icons.route_outlined,
                label: 'Distance',
                value: '6.2 km',
              ),
              InfoLine(
                icon: Icons.speed_outlined,
                label: 'Vitesse moy.',
                value: '8.4 km/h',
              ),
              InfoLine(
                icon: Icons.timeline_outlined,
                label: 'Allure dominante',
                value: 'Trot',
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Voir le rapport',
          onPressed: () =>
              openPage(context, ReportDetailsPage(session: liveSessions.first)),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: "Retour a l'accueil",
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
    );
  }
}
