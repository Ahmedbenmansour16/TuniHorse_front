import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class AddTrainerCommentPage extends StatelessWidget {
  const AddTrainerCommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Ajouter commentaire',
      showBack: true,
      children: [
        TuniCard(
          child: Row(
            children: [
              HorsePhoto(horse: horses.first),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Éclipse',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '18/05/2026 - 10:21',
                    style: TextStyle(color: Color(0xFF777B72)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionHeader('Note générale'),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < 4 ? Icons.star : Icons.star_border,
              color: const Color(0xFFDFAE68),
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Points forts',
            hintText: 'Éclipse a bien géré les transitions.',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Points à améliorer',
            hintText: 'Travailler l’engagement du postérieur.',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          minLines: 4,
          maxLines: 4,
          decoration: InputDecoration(labelText: 'Commentaire'),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Enregistrer',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
