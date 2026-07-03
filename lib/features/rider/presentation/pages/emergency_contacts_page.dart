import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class EmergencyContactsPage extends StatelessWidget {
  const EmergencyContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: "Contacts d'urgence",
      showBack: true,
      children: [
        const TuniCard(
          child: Column(
            children: [
              InfoLine(
                icon: Icons.person_outline,
                label: 'Contact principal',
                value: 'Sami Ben Said',
              ),
              InfoLine(
                icon: Icons.phone_outlined,
                label: 'Telephone',
                value: '06 22 45 78 90',
              ),
              InfoLine(
                icon: Icons.groups_outlined,
                label: 'Relation',
                value: 'Famille',
              ),
            ],
          ),
        ),
        const SectionHeader('Ajouter un contact'),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Nom complet',
            hintText: 'Sami Ben Said',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Telephone',
            hintText: '06 22 45 78 90',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Relation',
            hintText: 'Famille',
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Enregistrer',
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 10),
        const Text(
          'Ces contacts seront prevenus en cas de SOS.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
