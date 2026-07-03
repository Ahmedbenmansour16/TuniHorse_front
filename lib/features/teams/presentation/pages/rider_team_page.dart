import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/horseshoe_mark.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_horses_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_members_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/trainer_details_page.dart';

class RiderTeamPage extends StatelessWidget {
  const RiderTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Mon equipe',
      showBack: true,
      children: [
        TuniCard(
          child: Row(
            children: [
              const HorseshoeMark(size: 58, color: AppColors.green),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Ecurie des Bois',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Entraineur : Mohamed Trabelsi',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    Text(
                      'Ville : Sousse',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionHeader('Resume equipe'),
        const MetricGrid(stats: trainerStats),
        const SectionHeader('Actions'),
        MenuActionTile(
          icon: Icons.groups_outlined,
          title: "Membres de l'equipe",
          onTap: () => openPage(context, const TeamMembersPage()),
        ),
        MenuActionTile(
          icon: Icons.person_pin_outlined,
          title: "Detail entraineur",
          onTap: () => openPage(context, const TrainerDetailsPage()),
        ),
        MenuActionTile(
          icon: Icons.hdr_strong,
          title: "Chevaux de l'equipe",
          onTap: () => openPage(context, const TeamHorsesPage()),
        ),
      ],
    );
  }
}
