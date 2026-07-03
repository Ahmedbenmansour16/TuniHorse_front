import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class ProgressStatisticsPage extends StatelessWidget {
  const ProgressStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Statistiques',
      showBack: true,
      children: [
        const TuniCard(
          child: Column(
            children: [
              InfoLine(
                icon: Icons.route_outlined,
                label: 'Distance',
                value: '32.4 km',
              ),
              InfoLine(
                icon: Icons.schedule,
                label: 'Duree totale',
                value: '5h20',
              ),
              InfoLine(
                icon: Icons.timer_outlined,
                label: 'Seances',
                value: '8',
              ),
            ],
          ),
        ),
        const SectionHeader('Distance par semaine'),
        TuniCard(
          child: SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _Bar(label: 'Lun', value: 0.35),
                _Bar(label: 'Mar', value: 0.46),
                _Bar(label: 'Mer', value: 0.58),
                _Bar(label: 'Jeu', value: 0.76),
                _Bar(label: 'Ven', value: 0.88),
                _Bar(label: 'Sam', value: 0.70),
                _Bar(label: 'Dim', value: 0.92),
              ],
            ),
          ),
        ),
        const SectionHeader('Repartition des allures'),
        const TuniCard(
          child: Column(
            children: [
              _ProgressLine(label: 'Pas', value: 0.28, color: AppColors.green),
              _ProgressLine(label: 'Trot', value: 0.50, color: AppColors.gold),
              _ProgressLine(
                label: 'Galop',
                value: 0.22,
                color: AppColors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;

  const _Bar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: FractionallySizedBox(
                heightFactor: value,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ProgressLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('${(value * 100).round()}%'),
        ],
      ),
    );
  }
}
