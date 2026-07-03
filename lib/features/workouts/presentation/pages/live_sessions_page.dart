import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/workouts/presentation/pages/live_tracking_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/multi_horse_map_page.dart';

class LiveSessionsPage extends StatelessWidget {
  final bool inShell;

  const LiveSessionsPage({super.key, this.inShell = false});

  @override
  Widget build(BuildContext context) {
    final children = [
      ...liveSessions.map(
        (session) => LiveSessionTile(
          session: session,
          onTap: () => openPage(context, LiveTrackingPage(session: session)),
        ),
      ),
      const SizedBox(height: 6),
      PrimaryButton(
        label: 'Voir sur la carte',
        icon: Icons.map_outlined,
        onPressed: () => openPage(context, const MultiHorseMapPage()),
      ),
    ];

    if (inShell) {
      return ShellPage(
        title: 'Séances en cours',
        subtitle: '3 chevaux actifs',
        actions: [
          IconButton(
            onPressed: () => openPage(context, const MultiHorseMapPage()),
            icon: const Icon(Icons.map_outlined),
          ),
        ],
        children: children,
      );
    }

    return AppPage(
      title: 'Séances en cours',
      showBack: true,
      actions: [
        IconButton(
          onPressed: () => openPage(context, const MultiHorseMapPage()),
          icon: const Icon(Icons.map_outlined),
        ),
      ],
      children: children,
    );
  }
}
