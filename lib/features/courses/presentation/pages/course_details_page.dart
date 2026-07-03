import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_countdown_page.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_selection_page.dart';

class CourseDetailsPage extends StatelessWidget {
  final CourseInfo course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Détail course',
      showBack: true,
      children: [
        TuniCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          course.category,
                          style: const TextStyle(
                            color: Color(0xFFE53E35),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StatusPill('Active'),
                ],
              ),
              const SizedBox(height: 16),
              InfoLine(
                icon: Icons.calendar_month,
                label: 'Date',
                value: course.date,
              ),
              InfoLine(
                icon: Icons.location_on_outlined,
                label: 'Lieu',
                value: course.place,
              ),
              if (course.organisation.isNotEmpty)
                InfoLine(
                  icon: Icons.business_outlined,
                  label: 'Organisation',
                  value: course.organisation,
                ),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Compétition régionale de saut d’obstacles.',
                style: TextStyle(color: Color(0xFF777B72)),
              ),
            ],
          ),
        ),
        SectionHeader(
          'Countdown',
          action: 'Voir',
          onAction: () =>
              openPage(context, CourseCountdownPage(course: course)),
        ),
        const TuniCard(
          child: Row(
            children: [
              Expanded(
                child: _CountdownUnit(value: '05', label: 'jours'),
              ),
              Expanded(
                child: _CountdownUnit(value: '12', label: 'heures'),
              ),
              Expanded(
                child: _CountdownUnit(value: '35', label: 'minutes'),
              ),
            ],
          ),
        ),
        const SectionHeader("Sélection de l'équipe"),
        TuniCard(
          child: Row(
            children: [
              RiderAvatar(rider: riders.first),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Camille Martin + Éclipse',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Sélection active',
                      style: TextStyle(color: Color(0xFF777B72), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const StatusPill('Active'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Associer cavalier + cheval',
          onPressed: () =>
              openPage(context, CourseSelectionPage(course: course)),
        ),
      ],
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final String value;
  final String label;

  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF777B72), fontSize: 11),
        ),
      ],
    );
  }
}
