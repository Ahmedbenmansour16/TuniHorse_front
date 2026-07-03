import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/workouts/presentation/pages/active_workout_page.dart';

class StartWorkoutPage extends StatelessWidget {
  final bool inShell;

  const StartWorkoutPage({super.key, this.inShell = false});

  @override
  Widget build(BuildContext context) {
    final children = [
      const SectionHeader('Choisir un cheval'),
      TuniCard(
        child: Row(
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
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
      const SectionHeader('Partager la position avec'),
      const TuniCard(
        child: Column(
          children: [
            _ShareLine(label: 'Entraineur', checked: true),
            _ShareLine(label: 'Equipe', checked: true),
            _ShareLine(label: 'Contact de securite', checked: false),
          ],
        ),
      ),
      const SizedBox(height: 14),
      TuniCard(
        color: AppColors.gold.withValues(alpha: 0.16),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'GPS requis avec une bonne reception en exterieur.',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      PrimaryButton(
        label: 'Demarrer la seance',
        icon: Icons.play_arrow,
        onPressed: () => openPage(context, const ActiveWorkoutPage()),
      ),
    ];

    if (inShell) {
      return ShellPage(
        title: 'Seance GPS',
        subtitle: 'Preparation du suivi live',
        children: children,
      );
    }

    return AppPage(
      title: 'Demarrer seance',
      showBack: true,
      children: children,
    );
  }
}

class _ShareLine extends StatelessWidget {
  final String label;
  final bool checked;

  const _ShareLine({required this.label, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            color: checked ? AppColors.green : AppColors.muted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
