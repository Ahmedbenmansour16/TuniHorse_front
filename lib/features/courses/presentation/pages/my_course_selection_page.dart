import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_details_page.dart';

class MyCourseSelectionPage extends StatelessWidget {
  const MyCourseSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final course = courses.first;
    final horse = horses.first;

    return AppPage(
      title: 'Ma selection',
      showBack: true,
      children: [
        TuniCard(
          onTap: () => openPage(context, CourseDetailsPage(course: course)),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      course.color,
                      course.color.withValues(alpha: 0.58),
                    ],
                  ),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${course.category} - ${course.date}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusPill('Active'),
            ],
          ),
        ),
        const SectionHeader('Selection validee'),
        TuniCard(
          child: Row(
            children: [
              HorsePhoto(horse: horse),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      horse.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      'Ahmed Ben Said',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    const Text(
                      'Statut : Selectionne',
                      style: TextStyle(color: AppColors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionHeader('Infos pratiques'),
        const TuniCard(
          child: Column(
            children: [
              InfoLine(
                icon: Icons.calendar_month,
                label: 'Date',
                value: '20/06/2026',
              ),
              InfoLine(
                icon: Icons.location_on_outlined,
                label: 'Lieu',
                value: 'Club Equestre Sousse',
              ),
              InfoLine(
                icon: Icons.timer_outlined,
                label: 'Countdown',
                value: '5j 12h',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Voir les details de la course',
          onPressed: () => openPage(context, CourseDetailsPage(course: course)),
        ),
      ],
    );
  }
}
