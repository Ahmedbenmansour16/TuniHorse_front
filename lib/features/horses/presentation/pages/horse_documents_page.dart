import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class HorseDocumentsPage extends StatelessWidget {
  final Horse horse;

  const HorseDocumentsPage({super.key, required this.horse});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Documents',
      subtitle: horse.name,
      showBack: true,
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
      children: [
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
                    Text(
                      '${horse.race} - ${horse.age}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusPill('Actif'),
            ],
          ),
        ),
        const SectionHeader('Documents du cheval'),
        const _DocumentTile(
          icon: Icons.badge_outlined,
          title: 'Passeport equin',
          subtitle: 'Ajoute le 10/06/2026',
        ),
        const _DocumentTile(
          icon: Icons.vaccines_outlined,
          title: 'Carnet de vaccination',
          subtitle: 'Mis a jour le 18/06/2026',
        ),
        const _DocumentTile(
          icon: Icons.description_outlined,
          title: 'Certificat veterinaire',
          subtitle: 'Valide jusqu au 20/09/2026',
        ),
        const SizedBox(height: 12),
        PrimaryButton(label: 'Ajouter un document', onPressed: () {}),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DocumentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TuniCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.greenSoft,
              child: Icon(icon, color: AppColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
