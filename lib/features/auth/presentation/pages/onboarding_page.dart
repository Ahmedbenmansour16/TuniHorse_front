import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/presentation/pages/login_page.dart';
import 'package:tunihorse/features/auth/presentation/pages/role_choice_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'TuniHorse',
      showBack: true,
      children: [
        GreenHeroCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.route, color: AppColors.gold, size: 44),
              SizedBox(height: 24),
              Text(
                'Pilotez votre équipe avec précision',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Séances GPS, chevaux, cavaliers, santé et courses dans une expérience claire.',
                style: TextStyle(color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const TuniCard(
          child: Column(
            children: [
              CheckLine('Suivi live multi-chevaux'),
              CheckLine('Rapports et commentaires entraîneur'),
              CheckLine('Sélections de courses et notifications'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Créer un compte',
          onPressed: () => openPage(context, const RoleChoicePage()),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Se connecter',
          onPressed: () => openPage(context, const LoginPage()),
        ),
      ],
    );
  }
}
