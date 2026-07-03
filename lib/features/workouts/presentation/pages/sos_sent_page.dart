import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class SosSentPage extends StatelessWidget {
  const SosSentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'SOS envoye',
      showBack: true,
      children: [
        const TuniCard(
          child: Column(
            children: [
              Icon(Icons.check_circle, color: AppColors.green, size: 62),
              SizedBox(height: 12),
              Text(
                'Alerte envoyee',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 8),
              Text(
                'Le coach et les contacts d urgence ont recu votre position.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Retour a la seance',
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ],
    );
  }
}
