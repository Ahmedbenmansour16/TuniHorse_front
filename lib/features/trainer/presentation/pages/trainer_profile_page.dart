import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/presentation/pages/login_page.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tunihorse/features/trainer/presentation/pages/trainer_settings_page.dart';

class TrainerProfilePage extends StatelessWidget {
  const TrainerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellPage(
      title: 'Profil',
      subtitle: 'Compte entraîneur',
      children: [
        TuniCard(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.greenSoft,
                child: Icon(Icons.person, color: AppColors.green, size: 44),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ahmed Ben Said',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              const StatusPill('Entraîneur'),
              const SizedBox(height: 16),
              const InfoLine(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'ahmed@gmail.com',
              ),
              const InfoLine(
                icon: Icons.phone_outlined,
                label: 'Téléphone',
                value: '22 123 456',
              ),
              const InfoLine(
                icon: Icons.location_on_outlined,
                label: 'Ville',
                value: 'Sousse',
              ),
              const InfoLine(
                icon: Icons.groups_outlined,
                label: 'Équipe',
                value: 'Écurie des Bois',
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Modifier profil',
                onPressed: () =>
                    openPage(context, const EditTrainerProfilePage()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MenuActionTile(
          icon: Icons.settings_outlined,
          title: 'Paramètres',
          onTap: () => openPage(context, const TrainerSettingsPage()),
        ),
        MenuActionTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () => openPage(context, const NotificationsPage()),
        ),
        MenuActionTile(
          icon: Icons.help_outline,
          title: 'Aide & Support',
          onTap: () => openPage(context, const SupportPage()),
        ),
        MenuActionTile(
          icon: Icons.logout,
          title: 'Déconnexion',
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          ),
        ),
      ],
    );
  }
}

class EditTrainerProfilePage extends StatelessWidget {
  const EditTrainerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Modifier profil',
      showBack: true,
      children: [
        const TuniCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.greenSoft,
                child: Icon(Icons.camera_alt_outlined, color: AppColors.green),
              ),
              SizedBox(height: 8),
              Text(
                'Changer photo',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Nom complet',
            hintText: 'Ahmed Ben Said',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Téléphone',
            hintText: '22 123 456',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(labelText: 'Ville', hintText: 'Sousse'),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Spécialité',
            hintText: 'Endurance',
          ),
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Expérience',
            hintText: '8 ans',
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: 'Enregistrer',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    const questions = [
      'Comment fonctionne le suivi GPS ?',
      'Comment associer un cavalier à un cheval ?',
      'Comment consulter les rapports ?',
      'Comment gérer les rappels santé ?',
      'Comment sélectionner un cavalier pour une course ?',
    ];

    return AppPage(
      title: 'Aide & Support',
      showBack: true,
      children: [
        ...questions.map(
          (question) => MenuActionTile(
            icon: Icons.help_outline,
            title: question,
            onTap: () {},
          ),
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          label: 'Chat support',
          icon: Icons.chat_outlined,
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Envoyer email',
          icon: Icons.email_outlined,
          onPressed: () {},
        ),
      ],
    );
  }
}
