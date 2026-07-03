import 'package:flutter/material.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notification_preferences_page.dart';

class TrainerSettingsPage extends StatelessWidget {
  const TrainerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Paramètres',
      showBack: true,
      children: [
        const SectionHeader('Compte'),
        MenuActionTile(
          icon: Icons.person_outline,
          title: 'Informations personnelles',
          onTap: () {},
        ),
        MenuActionTile(
          icon: Icons.lock_outline,
          title: 'Sécurité',
          onTap: () {},
        ),
        MenuActionTile(
          icon: Icons.notifications_outlined,
          title: 'Préférences de notification',
          onTap: () => openPage(context, const NotificationPreferencesPage()),
        ),
        const SectionHeader('Préférences'),
        MenuActionTile(icon: Icons.straighten, title: 'Unités', onTap: () {}),
        MenuActionTile(icon: Icons.language, title: 'Langue', onTap: () {}),
        MenuActionTile(
          icon: Icons.palette_outlined,
          title: 'Thème',
          onTap: () {},
        ),
        const SectionHeader('Confidentialité'),
        MenuActionTile(
          icon: Icons.visibility_outlined,
          title: 'Qui peut voir mon profil',
          onTap: () {},
        ),
        MenuActionTile(
          icon: Icons.share_outlined,
          title: 'Partage de données',
          onTap: () {},
        ),
        MenuActionTile(
          icon: Icons.location_on_outlined,
          title: 'Gestion localisation',
          onTap: () {},
        ),
      ],
    );
  }
}
