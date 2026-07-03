import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class TrainerDetailsPage extends StatelessWidget {
  const TrainerDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Detail entraineur',
      showBack: true,
      children: [
        TuniCard(
          child: Column(
            children: [
              RiderAvatar(rider: riders.first, size: 92),
              const SizedBox(height: 12),
              const Text(
                'Mohamed Trabelsi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Entraineur - Ecurie des Bois',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const TuniCard(
          child: Column(
            children: [
              InfoLine(
                icon: Icons.phone_outlined,
                label: 'Telephone',
                value: '06 12 34 56 78',
              ),
              InfoLine(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'coach@tunihorse.tn',
              ),
              InfoLine(
                icon: Icons.location_on_outlined,
                label: 'Ville',
                value: 'Sousse',
              ),
              InfoLine(
                icon: Icons.emoji_events_outlined,
                label: 'Specialite',
                value: 'Saut',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Contacter le coach', onPressed: () {}),
      ],
    );
  }
}
