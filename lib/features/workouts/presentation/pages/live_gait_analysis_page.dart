import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/core/widgets/visual_widgets.dart';
import 'package:tunihorse/features/workouts/presentation/pages/sos_confirmation_page.dart';

class LiveGaitAnalysisPage extends StatelessWidget {
  const LiveGaitAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Analyse des allures',
      showBack: true,
      children: [
        const TuniCard(child: GaitDonutChart()),
        const SectionHeader('Statistiques'),
        const TuniCard(
          child: Column(
            children: [
              InfoLine(
                icon: Icons.route_outlined,
                label: 'Distance',
                value: '4.8 km',
              ),
              InfoLine(
                icon: Icons.speed_outlined,
                label: 'Vitesse moyenne',
                value: '8.5 km/h',
              ),
              InfoLine(
                icon: Icons.flash_on_outlined,
                label: 'Vitesse max',
                value: '21.3 km/h',
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
          label: 'SOS',
          color: AppColors.danger,
          icon: Icons.sos,
          onPressed: () => openPage(context, const SosConfirmationPage()),
        ),
      ],
    );
  }
}
