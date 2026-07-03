import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class NotificationDetailsPage extends StatelessWidget {
  final NotificationItem item;

  const NotificationDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Détail notification',
      showBack: true,
      children: [
        TuniCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: item.color.withValues(alpha: 0.12),
                child: Icon(item.icon, color: item.color, size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                item.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF777B72)),
              ),
              const SizedBox(height: 12),
              StatusPill(item.time, color: item.color),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Marquer comme lue',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Supprimer notification',
          icon: Icons.delete_outline,
          onPressed: () {},
        ),
      ],
    );
  }
}
