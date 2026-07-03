import 'package:flutter/material.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/presentation/pages/otp_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Mot de passe oublié',
      showBack: true,
      children: [
        const TuniCard(
          child: Text(
            'Entrez votre email pour recevoir un lien de réinitialisation.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'coach@gmail.com',
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Envoyer le lien',
          onPressed: () => openPage(context, const OtpPage()),
        ),
      ],
    );
  }
}
