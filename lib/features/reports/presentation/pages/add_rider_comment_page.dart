import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class AddRiderCommentPage extends StatelessWidget {
  final LiveSession session;

  const AddRiderCommentPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Commentaire cavalier',
      showBack: true,
      children: [
        TuniCard(
          child: Row(
            children: [
              HorsePhoto(horse: session.horse),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.horse.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${session.distance} - ${session.duration}',
                      style: const TextStyle(
                        color: Color(0xFF777B72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionHeader('Mon ressenti'),
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
            labelText: 'Points positifs',
            hintText: 'Bonne energie et rythme stable.',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Difficulte ressentie',
            hintText: 'Transitions un peu rapides en fin de seance.',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          minLines: 4,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Commentaire',
            hintText: 'Ajouter mon commentaire sur cette seance.',
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Enregistrer le commentaire',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
