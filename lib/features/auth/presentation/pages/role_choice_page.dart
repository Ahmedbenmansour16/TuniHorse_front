import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/presentation/pages/register_page.dart';

class RoleChoicePage extends StatelessWidget {
  const RoleChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Créer un compte',
      subtitle: 'Choisissez votre rôle',
      showBack: true,
      children: [
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.directions_run,
          title: 'Cavalier',
          subtitle: 'Je veux suivre mes entraînements',
          color: AppColors.green,
          onTap: () => openPage(context, const RegisterPage(role: 'Cavalier')),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.person_pin,
          title: 'Entraîneur',
          subtitle: 'Je veux gérer une équipe',
          color: AppColors.gold,
          darkText: true,
          onTap: () =>
              openPage(context, const RegisterPage(role: 'Entraîneur')),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool darkText;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.darkText = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = darkText ? AppColors.ink : Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 148,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.78)],
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 46),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(color: textColor.withValues(alpha: 0.82)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textColor),
          ],
        ),
      ),
    );
  }
}
