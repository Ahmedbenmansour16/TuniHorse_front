import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/rider/presentation/pages/emergency_contacts_page.dart';
import 'package:tunihorse/features/rider/presentation/pages/edit_rider_profile_page.dart';
import 'package:tunihorse/features/rider/presentation/pages/rider_settings_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/rider_team_page.dart';

class RiderProfilePage extends StatelessWidget {
  const RiderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rider = riders.first;

    return ShellPage(
      title: 'Profil cavalier',
      subtitle: 'Ahmed Ben Said',
      actions: [
        IconButton(
          onPressed: () => openPage(context, const RiderSettingsPage()),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      children: [
        TuniCard(
          child: Column(
            children: [
              RiderAvatar(rider: rider, size: 92),
              const SizedBox(height: 12),
              const Text(
                'Ahmed Ben Said',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Cavalier - Galop 4',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              Row(
                children: const [
                  Expanded(
                    child: _ProfileMetric(value: '8', label: 'Seances'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _ProfileMetric(value: '32 km', label: 'Distance'),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _ProfileMetric(value: '3', label: 'Chevaux'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        MenuActionTile(
          icon: Icons.edit_outlined,
          title: 'Modifier profil',
          onTap: () => openPage(context, const EditRiderProfilePage()),
        ),
        MenuActionTile(
          icon: Icons.groups_outlined,
          title: 'Mon equipe',
          onTap: () => openPage(context, const RiderTeamPage()),
        ),
        MenuActionTile(
          icon: Icons.contact_phone_outlined,
          title: "Contacts d'urgence",
          onTap: () => openPage(context, const EmergencyContactsPage()),
        ),
        MenuActionTile(
          icon: Icons.help_outline,
          title: 'Aide & Support',
          onTap: () => openPage(context, const RiderSettingsPage()),
        ),
      ],
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
