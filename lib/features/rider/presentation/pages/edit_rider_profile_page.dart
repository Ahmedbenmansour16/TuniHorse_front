import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class EditRiderProfilePage extends StatelessWidget {
  const EditRiderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Modifier profil',
      showBack: true,
      children: [
        Center(child: RiderAvatar(rider: riders.first, size: 96)),
        const SizedBox(height: 18),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Nom complet',
            hintText: 'Ahmed Ben Said',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Telephone',
            hintText: '06 12 34 56 78',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(labelText: 'Niveau', hintText: 'Galop 4'),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Discipline',
            hintText: 'Saut',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Bio',
            hintText: 'Cavalier passionne par les parcours de saut.',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Enregistrer',
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 12),
        const Text(
          'Profil visible par votre equipe',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
