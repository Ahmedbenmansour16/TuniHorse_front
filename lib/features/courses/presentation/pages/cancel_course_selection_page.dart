import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class CancelCourseSelectionPage extends StatelessWidget {
  const CancelCourseSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Annuler sélection',
      showBack: true,
      children: [
        const TuniCard(
          child: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 42,
              ),
              SizedBox(height: 12),
              Text(
                'Voulez-vous annuler cette sélection ?',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Camille Martin + Éclipse',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Confirmer annulation',
          color: AppColors.danger,
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Retour',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
