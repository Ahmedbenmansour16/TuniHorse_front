import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class CourseCountdownPage extends StatelessWidget {
  final CourseInfo course;

  const CourseCountdownPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Countdown course',
      subtitle: course.name,
      showBack: true,
      children: const [
        TuniCard(
          child: Column(
            children: [
              Icon(Icons.hourglass_top, color: Color(0xFF075A37), size: 44),
              SizedBox(height: 16),
              Text(
                '05 jours : 12 heures : 35 minutes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Prochaine course de l’équipe',
                style: TextStyle(color: Color(0xFF777B72)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
