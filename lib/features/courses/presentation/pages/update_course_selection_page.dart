import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class UpdateCourseSelectionPage extends StatelessWidget {
  final CourseInfo course;

  const UpdateCourseSelectionPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Modifier sélection',
      showBack: true,
      children: [
        TuniCard(
          child: InfoLine(
            icon: Icons.emoji_events_outlined,
            label: 'Course',
            value: course.name,
          ),
        ),
        const SizedBox(height: 14),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Cavalier actuel',
            hintText: 'Camille Martin',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Cheval actuel',
            hintText: 'Éclipse',
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Enregistrer modification',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
