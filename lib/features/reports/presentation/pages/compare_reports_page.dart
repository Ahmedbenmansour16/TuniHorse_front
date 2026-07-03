import 'package:flutter/material.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class CompareReportsPage extends StatelessWidget {
  const CompareReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Durée', '01:08:24', '01:02:31', '-9%'],
      ['Distance', '12,45 km', '11,02 km', '-13%'],
      ['Vitesse moy.', '10,9', '10,6', '-3%'],
      ['Allure', 'Galop', 'Trot', 'Changement'],
    ];

    return AppPage(
      title: 'Comparer séances',
      showBack: true,
      children: [
        TuniCard(
          child: Column(
            children: rows
                .map(
                  (row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            row[0],
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            row[1],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            row[2],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            row[3],
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Color(0xFF075A37),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'Exporter comparaison', onPressed: () {}),
      ],
    );
  }
}
