import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/core/widgets/visual_widgets.dart';
import 'package:tunihorse/features/workouts/presentation/pages/finish_workout_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/live_gait_analysis_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/sos_confirmation_page.dart';

class ActiveWorkoutPage extends StatelessWidget {
  const ActiveWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Seance en cours',
      showBack: true,
      actions: [
        IconButton(
          onPressed: () => openPage(context, const SosConfirmationPage()),
          icon: const Icon(Icons.sos, color: AppColors.danger),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        const MapPreview(height: 300),
        const SizedBox(height: 12),
        TuniCard(
          color: AppColors.green,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${horses.first.name} - Seance en cours',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(
                    child: _LiveMetric(value: '00:35:12', label: 'Duree'),
                  ),
                  Expanded(
                    child: _LiveMetric(value: '4.8', label: 'Distance'),
                  ),
                  Expanded(
                    child: _LiveMetric(value: '12.0', label: 'Vitesse'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: _LiveMetric(value: '8.5', label: 'Vitesse moy.'),
                  ),
                  Expanded(
                    child: _LiveMetric(value: 'Trot', label: 'Allure actuelle'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Analyse',
                icon: Icons.donut_large,
                onPressed: () =>
                    openPage(context, const LiveGaitAnalysisPage()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: 'Terminer',
                color: AppColors.danger,
                onPressed: () => openPage(context, const FinishWorkoutPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveMetric extends StatelessWidget {
  final String value;
  final String label;

  const _LiveMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
