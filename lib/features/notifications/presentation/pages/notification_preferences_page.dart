import 'package:flutter/material.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class NotificationPreferencesPage extends StatelessWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Préférences',
      subtitle: 'Notifications',
      showBack: true,
      children: const [
        _PreferenceTile(
          title: 'Alertes SOS',
          subtitle: 'Toujours actives',
          value: true,
        ),
        _PreferenceTile(
          title: 'Rappels santé',
          subtitle: 'Vaccins, ferrage, vétérinaire',
          value: true,
        ),
        _PreferenceTile(
          title: 'Séances live',
          subtitle: 'Début, pause, fin de séance',
          value: true,
        ),
        _PreferenceTile(
          title: 'Courses',
          subtitle: 'Countdown et sélections',
          value: true,
        ),
        _PreferenceTile(
          title: 'Système',
          subtitle: 'Mises à jour et sécurité',
          value: false,
        ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;

  const _PreferenceTile({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TuniCard(
        child: Row(
          children: [
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
                      color: Color(0xFF777B72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: null),
          ],
        ),
      ),
    );
  }
}
