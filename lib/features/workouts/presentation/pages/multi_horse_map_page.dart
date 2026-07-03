import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/core/widgets/visual_widgets.dart';
import 'package:tunihorse/features/workouts/presentation/pages/live_tracking_page.dart';

class MultiHorseMapPage extends StatelessWidget {
  const MultiHorseMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Carte en direct',
      showBack: true,
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.tune))],
      children: [
        const MapPreview(height: 300, multiHorse: true),
        const SizedBox(height: 12),
        ...liveSessions.map(
          (session) => LiveSessionTile(
            session: session,
            onTap: () => openPage(context, LiveTrackingPage(session: session)),
          ),
        ),
      ],
    );
  }
}
