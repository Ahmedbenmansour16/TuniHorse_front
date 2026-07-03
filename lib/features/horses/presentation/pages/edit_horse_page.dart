import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class EditHorsePage extends StatelessWidget {
  final Horse horse;

  const EditHorsePage({super.key, required this.horse});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Modifier cheval',
      subtitle: horse.name,
      showBack: true,
      children: [
        Center(child: HorsePhoto(horse: horse, size: 118)),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: 'Nom du cheval',
            hintText: horse.name,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(labelText: 'Race', hintText: horse.race),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Age',
                  hintText: horse.age,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Sexe',
                  hintText: 'Male',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(labelText: 'Robe', hintText: 'Marron'),
        ),
        const SizedBox(height: 12),
        const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Poids (kg)', hintText: '420'),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Enregistrer',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
