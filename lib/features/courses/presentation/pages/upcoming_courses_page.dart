import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_details_page.dart';

class UpcomingCoursesPage extends StatelessWidget {
  const UpcomingCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Courses a venir',
      showBack: true,
      children: [
        ...courses.map(
          (course) => CourseTile(
            course: course,
            onTap: () => openPage(context, CourseDetailsPage(course: course)),
          ),
        ),
      ],
    );
  }
}
