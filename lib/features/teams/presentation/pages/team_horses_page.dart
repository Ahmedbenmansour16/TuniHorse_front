import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/horses/presentation/pages/horse_details_page.dart';

class TeamHorsesPage extends StatelessWidget {
  const TeamHorsesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: "Chevaux de l'equipe",
      showBack: true,
      children: horses
          .map(
            (horse) => HorseListTile(
              horse: horse,
              onTap: () => openPage(context, HorseDetailsPage(horse: horse)),
            ),
          )
          .toList(),
    );
  }
}
