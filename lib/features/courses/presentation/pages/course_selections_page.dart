import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/cancel_course_selection_page.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_details_page.dart';
import 'package:tunihorse/features/courses/presentation/pages/update_course_selection_page.dart';

class CourseSelectionsPage extends StatelessWidget {
  const CourseSelectionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Sélections course',
      showBack: true,
      children: [
        CourseTile(
          course: courses.first,
          onTap: () =>
              openPage(context, CourseDetailsPage(course: courses.first)),
        ),
        const SectionHeader('Cavaliers + chevaux'),
        _SelectionTile(
          riderName: riders.first.name,
          horseName: horses.first.name,
        ),
        _SelectionTile(riderName: riders[1].name, horseName: horses[1].name),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Modifier sélection',
          onPressed: () => openPage(
            context,
            UpdateCourseSelectionPage(course: courses.first),
          ),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Annuler sélection',
          onPressed: () => openPage(context, const CancelCourseSelectionPage()),
        ),
      ],
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String riderName;
  final String horseName;

  const _SelectionTile({required this.riderName, required this.horseName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TuniCard(
        child: Row(
          children: [
            RiderAvatar(rider: riders.first),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$riderName + $horseName',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const StatusPill('Active'),
          ],
        ),
      ),
    );
  }
}
