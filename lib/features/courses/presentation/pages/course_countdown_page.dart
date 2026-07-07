import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class CourseCountdownPage extends StatelessWidget {
  final CourseInfo course;

  const CourseCountdownPage({super.key, required this.course});

  bool get _isPassed {
    final date = course.dateCourse;
    if (date == null) return course.countdown.toLowerCase().contains('passe');

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final courseDay = DateTime(date.year, date.month, date.day);
    return courseDay.isBefore(todayOnly);
  }

  String get _countdownText {
    if (_isPassed) return 'Cette course est deja passee';

    final date = course.dateCourse;
    if (date == null) return course.countdown;

    final target = DateTime(date.year, date.month, date.day, 23, 59);
    final remaining = target.difference(DateTime.now());
    if (remaining.isNegative) return 'Aujourd hui';

    final days = remaining.inDays.toString().padLeft(2, '0');
    final hours = remaining.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$days jours : $hours heures : $minutes minutes';
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Countdown course',
      subtitle: course.name,
      showBack: true,
      children: [
        TuniCard(
          child: Column(
            children: [
              Icon(
                _isPassed ? Icons.history : Icons.hourglass_top,
                color: const Color(0xFF075A37),
                size: 44,
              ),
              const SizedBox(height: 16),
              Text(
                _countdownText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isPassed ? 'Course deja passee' : 'Prochaine course',
                style: const TextStyle(color: Color(0xFF777B72)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
