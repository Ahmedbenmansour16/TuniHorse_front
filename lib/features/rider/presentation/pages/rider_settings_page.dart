import 'package:flutter/material.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class RiderSettingsPage extends StatelessWidget {
  const RiderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Parametres',
      showBack: true,
      children: [
        MenuActionTile(
          icon: Icons.lock_outline,
          title: 'Confidentialite',
          onTap: () {},
        ),
        MenuActionTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {},
        ),
        MenuActionTile(
          icon: Icons.language_outlined,
          title: 'Langue',
          onTap: () {},
        ),
        MenuActionTile(
          icon: Icons.support_agent_outlined,
          title: 'Aide & Support',
          onTap: () {},
        ),
        MenuActionTile(
          icon: Icons.info_outline,
          title: 'A propos de TuniHorse',
          onTap: () {},
        ),
        const SizedBox(height: 10),
        SecondaryButton(label: 'Se deconnecter', onPressed: () {}),
      ],
    );
  }
}
