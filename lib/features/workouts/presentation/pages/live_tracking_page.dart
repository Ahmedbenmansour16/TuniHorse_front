import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/core/widgets/visual_widgets.dart';
import 'package:tunihorse/features/reports/presentation/pages/report_details_page.dart';

class LiveTrackingPage extends StatelessWidget {
  final LiveSession session;

  const LiveTrackingPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Suivi live - ${session.horse.name}',
      showBack: true,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
      children: [
        const MapPreview(height: 270),
        const SizedBox(height: 12),
        TuniCard(
          child: Column(
            children: [
              Row(
                children: [
                  HorsePhoto(horse: session.horse),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.horse.name,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          session.rider.name,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const StatusPill('GPS live'),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _Metric(
                    label: 'Allure actuelle',
                    value: session.gait,
                    icon: Icons.directions_run,
                  ),
                  _Metric(
                    label: 'Vitesse',
                    value: session.speed,
                    icon: Icons.speed,
                  ),
                  _Metric(
                    label: 'Durée',
                    value: session.duration,
                    icon: Icons.timer,
                  ),
                  _Metric(
                    label: 'Fréquence',
                    value: session.heartRate,
                    icon: Icons.favorite,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Arrêter le suivi',
                color: AppColors.danger,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Voir détails',
                onPressed: () =>
                    openPage(context, ReportDetailsPage(session: session)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Metric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
