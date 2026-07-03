import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/workouts/presentation/pages/sos_sent_page.dart';

class SosConfirmationPage extends StatelessWidget {
  const SosConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Confirmation SOS',
      showBack: true,
      children: [
        TuniCard(
          color: AppColors.danger.withValues(alpha: 0.08),
          child: const Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 58,
              ),
              SizedBox(height: 12),
              Text(
                'Envoyer une alerte SOS ?',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8),
              Text(
                'Votre position live sera partagee avec vos contacts de securite.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Envoyer SOS',
          color: AppColors.danger,
          onPressed: () => openPage(context, const SosSentPage()),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Annuler',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
