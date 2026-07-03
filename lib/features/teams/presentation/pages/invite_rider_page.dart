import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class InviteRiderPage extends StatelessWidget {
  const InviteRiderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Inviter un cavalier',
      showBack: true,
      children: [
        const TextField(
          decoration: InputDecoration(labelText: 'Email ou téléphone'),
        ),
        const SizedBox(height: 12),
        const TextField(
          minLines: 4,
          maxLines: 4,
          decoration: InputDecoration(labelText: 'Message optionnel'),
        ),
        const SizedBox(height: 16),
        const TuniCard(
          color: AppColors.greenSoft,
          child: InfoLine(
            icon: Icons.key,
            label: 'Code équipe',
            value: 'EQB2025',
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(label: 'Envoyer invitation', onPressed: null),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Copier code équipe',
          icon: Icons.copy,
          onPressed: null,
        ),
      ],
    );
  }
}
