import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/horseshoe_mark.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_selections_page.dart';
import 'package:tunihorse/features/horses/presentation/pages/team_horses_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/team_reports_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/invite_rider_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_members_page.dart';

class TeamDetailsPage extends StatelessWidget {
  const TeamDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellPage(
      title: 'Mon équipe',
      subtitle: 'Écurie des Bois',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
      ],
      children: [
        TuniCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE9DDCC)),
                    ),
                    child: const Center(
                      child: HorseshoeMark(size: 42, color: Color(0xFF075A37)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Écurie des Bois',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Sousse, Tunisie',
                          style: TextStyle(color: Color(0xFF777B72)),
                        ),
                        Text(
                          'Code équipe : EQB2025',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const MetricGrid(stats: trainerStats),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MenuActionTile(
          icon: Icons.groups_outlined,
          title: "Membres de l'équipe",
          onTap: () => openPage(context, const TeamMembersPage()),
        ),
        MenuActionTile(
          icon: Icons.hdr_strong,
          title: "Chevaux de l'équipe",
          onTap: () => openPage(context, const TeamHorsesPage()),
        ),
        MenuActionTile(
          icon: Icons.article_outlined,
          title: 'Rapports partagés',
          onTap: () => openPage(context, const TeamReportsPage()),
        ),
        MenuActionTile(
          icon: Icons.emoji_events_outlined,
          title: 'Courses & sélections',
          onTap: () => openPage(context, const CourseSelectionsPage()),
        ),
        MenuActionTile(
          icon: Icons.person_add_alt,
          title: 'Inviter un cavalier',
          onTap: () => openPage(context, const InviteRiderPage()),
        ),
      ],
    );
  }
}
