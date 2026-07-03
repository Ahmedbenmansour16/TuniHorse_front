import 'package:flutter/material.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/rider/presentation/pages/rider_root_page.dart';
import 'package:tunihorse/features/trainer/presentation/pages/trainer_root_page.dart';

class OtpPage extends StatelessWidget {
  final String role;

  const OtpPage({super.key, this.role = 'Cavalier'});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Vérification OTP',
      showBack: true,
      children: [
        const TuniCard(
          child: Text(
            'Code envoyé à votre email. Saisissez les 4 chiffres pour continuer.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: List.generate(
            4,
            (index) => const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  decoration: InputDecoration(counterText: ''),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Valider',
          onPressed: () {
            final target = role.toLowerCase().startsWith('entra')
                ? const TrainerRootPage()
                : const RiderRootPage();

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => target),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
