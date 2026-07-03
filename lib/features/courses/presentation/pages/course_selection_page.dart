import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class CourseSelectionPage extends StatelessWidget {
  final CourseInfo course;

  const CourseSelectionPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Associer course',
      showBack: true,
      children: [
        TuniCard(
          color: AppColors.greenSoft,
          child: InfoLine(
            icon: Icons.emoji_events_outlined,
            label: 'Course',
            value: course.name,
          ),
        ),
        const SizedBox(height: 14),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Cavalier',
            hintText: 'Camille Martin',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(labelText: 'Cheval', hintText: 'Éclipse'),
        ),
        const SizedBox(height: 12),
        const TextField(
          minLines: 3,
          maxLines: 3,
          decoration: InputDecoration(labelText: 'Commentaire'),
        ),
        const SectionHeader('Vérifications'),
        const TuniCard(
          child: Column(
            children: [
              CheckLine("Cavalier dans l'équipe"),
              CheckLine("Cheval dans l'équipe"),
              CheckLine('Cavalier autorisé pour ce cheval'),
              CheckLine('Cheval non sélectionné pour cette course'),
              CheckLine('Course active'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(label: 'Enregistrer sélection', onPressed: null),
      ],
    );
  }
}
