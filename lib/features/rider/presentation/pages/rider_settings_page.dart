import 'package:flutter/material.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';
import 'package:tunihorse/features/auth/presentation/pages/login_page.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notification_preferences_page.dart';

class RiderSettingsPage extends StatelessWidget {
  const RiderSettingsPage({super.key});

  void _logout(BuildContext context) {
    AuthSessionStore.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

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
          onTap: () => openPage(context, const NotificationPreferencesPage()),
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
        SecondaryButton(
          label: 'Se deconnecter',
          icon: Icons.logout,
          onPressed: () => _logout(context),
        ),
      ],
    );
  }
}
