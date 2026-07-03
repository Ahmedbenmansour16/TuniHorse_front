import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/teams/presentation/pages/invite_rider_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/rider_details_page.dart';

class TeamMembersPage extends StatelessWidget {
  const TeamMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Cavaliers',
      showBack: true,
      actions: [
        IconButton(
          onPressed: () => openPage(context, const InviteRiderPage()),
          icon: const Icon(Icons.add),
        ),
      ],
      children: riders
          .map(
            (rider) => RiderListTile(
              rider: rider,
              onTap: () => openPage(context, RiderDetailsPage(rider: rider)),
            ),
          )
          .toList(),
    );
  }
}
