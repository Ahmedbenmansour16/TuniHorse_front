import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notification_details_page.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notification_preferences_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Notifications',
      showBack: true,
      actions: [
        IconButton(
          onPressed: () =>
              openPage(context, const NotificationPreferencesPage()),
          icon: const Icon(Icons.tune),
        ),
      ],
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            StatusPill('Toutes'),
            StatusPill('Alertes', color: Color(0xFFE53E35)),
            StatusPill('Santé'),
            StatusPill('Courses', color: Color(0xFFDFAE68)),
          ],
        ),
        const SizedBox(height: 16),
        ...notifications.map(
          (item) => _NotificationTile(
            item: item,
            onTap: () => openPage(context, NotificationDetailsPage(item: item)),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TuniCard(
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: item.color.withValues(alpha: 0.12),
              child: Icon(item.icon, color: item.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Color(0xFF777B72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              item.time,
              style: const TextStyle(color: Color(0xFF777B72), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
