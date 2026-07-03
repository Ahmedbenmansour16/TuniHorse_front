import 'package:flutter/material.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class AssignHorseToRiderPage extends StatelessWidget {
  const AssignHorseToRiderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Affecter cheval',
      subtitle: 'Cheval à cavalier',
      showBack: true,
      children: [
        const TextField(
          decoration: InputDecoration(labelText: 'Cheval', hintText: 'Éclipse'),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Cavalier',
            hintText: 'Sélectionner un cavalier',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Remarque',
            hintText: 'Autorisé pour entraînements',
          ),
        ),
        const SectionHeader('Statut'),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(label: 'Actif', onPressed: () {}),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SecondaryButton(label: 'Inactif', onPressed: () {}),
            ),
          ],
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Enregistrer',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
