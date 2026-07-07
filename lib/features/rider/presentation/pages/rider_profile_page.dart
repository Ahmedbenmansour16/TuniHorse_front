import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/data/auth_api_client.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';
import 'package:tunihorse/features/auth/presentation/pages/login_page.dart';
import 'package:tunihorse/features/horses/data/horses_api_client.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/rider/presentation/pages/edit_rider_profile_page.dart';
import 'package:tunihorse/features/rider/presentation/pages/emergency_contacts_page.dart';
import 'package:tunihorse/features/rider/presentation/pages/rider_settings_page.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';
import 'package:tunihorse/features/teams/presentation/pages/rider_team_page.dart';

class RiderProfilePage extends StatefulWidget {
  const RiderProfilePage({super.key});

  @override
  State<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends State<RiderProfilePage> {
  final _authApiClient = AuthApiClient();
  final _horsesApiClient = HorsesApiClient();
  final _teamsApiClient = TeamsApiClient();
  final _workoutsApiClient = WorkoutsApiClient();

  late Future<_RiderProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  @override
  void dispose() {
    _authApiClient.close();
    _horsesApiClient.close();
    _teamsApiClient.close();
    _workoutsApiClient.close();
    super.dispose();
  }

  Future<_RiderProfileData> _loadProfile() async {
    final user = await _loadCurrentUser();
    final stats = await _safeStats();
    final horses = await _safeHorses();
    final team = await _safeTeam();

    return _RiderProfileData(
      user: user,
      stats: stats,
      horsesCount: horses.length,
      team: team,
    );
  }

  Future<Map<String, dynamic>> _loadCurrentUser() async {
    final fallback = Map<String, dynamic>.from(
      AuthSessionStore.session?.user ?? const <String, dynamic>{},
    );
    final token = AuthSessionStore.accessToken;

    if (token == null || token.isEmpty) return fallback;

    try {
      final user = await _authApiClient.getMe(token);
      AuthSessionStore.updateUser(user);
      return user;
    } catch (_) {
      return fallback;
    }
  }

  Future<RiderMonthStats> _safeStats() async {
    try {
      return await _workoutsApiClient.getMyMonthStats();
    } catch (_) {
      return const RiderMonthStats.empty();
    }
  }

  Future<List<Map<String, dynamic>>> _safeHorses() async {
    try {
      return await _horsesApiClient.getMyHorses();
    } catch (_) {
      return [];
    }
  }

  Future<TrainerTeamInfo?> _safeTeam() async {
    try {
      return await _teamsApiClient.getMyTeam();
    } catch (_) {
      return null;
    }
  }

  Future<void> _openEdit(Map<String, dynamic> user) async {
    final updated = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => EditRiderProfilePage(user: user)),
    );

    if (!mounted || updated == null) return;

    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Voulez-vous quitter votre compte ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deconnecter'),
          ),
        ],
      ),
    );

    if (!mounted || shouldLogout != true) return;

    AuthSessionStore.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RiderProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _RiderProfileData.empty();
        final user = data.user;
        final name = _userValue(user, 'nomComplet', 'Cavalier');
        final teamName = data.team?.nom ?? 'Aucune equipe';

        return ShellPage(
          title: 'Profil cavalier',
          subtitle: name,
          actions: [
            IconButton(
              onPressed: () => openPage(context, const RiderSettingsPage()),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(minHeight: 3),
            TuniCard(
              child: Column(
                children: [
                  _UserAvatar(name: name),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const StatusPill('Cavalier'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileMetric(
                          value: '${data.stats.seances}',
                          label: 'Seances',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ProfileMetric(
                          value: _distanceLabel(data.stats.distanceKm),
                          label: 'Distance',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ProfileMetric(
                          value: _durationLabel(data.stats.durationSeconds),
                          label: 'Duree',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ProfileMetric(
                          value: '${data.horsesCount}',
                          label: 'Chevaux',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileInfoLine(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _userValue(user, 'email', '-'),
                  ),
                  _ProfileInfoLine(
                    icon: Icons.phone_outlined,
                    label: 'Telephone',
                    value: _userValue(user, 'telephone', '-'),
                  ),
                  _ProfileInfoLine(
                    icon: Icons.location_on_outlined,
                    label: 'Ville',
                    value: _userValue(user, 'ville', '-'),
                  ),
                  _ProfileInfoLine(
                    icon: Icons.groups_outlined,
                    label: 'Equipe',
                    value: teamName,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Modifier profil',
                    icon: Icons.edit_outlined,
                    onPressed: () => _openEdit(user),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            MenuActionTile(
              icon: Icons.groups_outlined,
              title: 'Mon equipe',
              onTap: () => openPage(context, const RiderTeamPage()),
            ),
            MenuActionTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => openPage(context, const NotificationsPage()),
            ),
            MenuActionTile(
              icon: Icons.contact_phone_outlined,
              title: "Contacts d'urgence",
              onTap: () => openPage(context, const EmergencyContactsPage()),
            ),
            MenuActionTile(
              icon: Icons.settings_outlined,
              title: 'Parametres',
              onTap: () => openPage(context, const RiderSettingsPage()),
            ),
            MenuActionTile(
              icon: Icons.help_outline,
              title: 'Aide & Support',
              onTap: () => openPage(context, const RiderSupportPage()),
            ),
            MenuActionTile(
              icon: Icons.logout,
              title: 'Deconnexion',
              onTap: _logout,
            ),
          ],
        );
      },
    );
  }
}

class RiderSupportPage extends StatelessWidget {
  const RiderSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    const questions = [
      'Comment demarrer une seance GPS ?',
      'Comment ajouter un cheval ?',
      'Comment consulter un rapport ?',
      'Comment gerer les rappels sante ?',
      'Comment contacter mon entraineur ?',
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
          label: 'Contacter support',
          icon: Icons.support_agent_outlined,
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Envoyer un feedback',
          icon: Icons.rate_review_outlined,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _RiderProfileData {
  final Map<String, dynamic> user;
  final RiderMonthStats stats;
  final int horsesCount;
  final TrainerTeamInfo? team;

  const _RiderProfileData({
    required this.user,
    required this.stats,
    required this.horsesCount,
    required this.team,
  });

  factory _RiderProfileData.empty() {
    return const _RiderProfileData(
      user: <String, dynamic>{},
      stats: RiderMonthStats.empty(),
      horsesCount: 0,
      team: null,
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String name;

  const _UserAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim()[0])
        .take(2)
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: 46,
      backgroundColor: AppColors.greenSoft,
      child: initials.isEmpty
          ? const Icon(Icons.person, color: AppColors.green, size: 40)
          : Text(
              initials,
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: AppColors.green, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

String _userValue(Map<String, dynamic>? user, String key, String fallback) {
  final value = user?[key]?.toString().trim();
  return value == null || value.isEmpty ? fallback : value;
}

String _distanceLabel(double distanceKm) {
  final rounded = distanceKm % 1 == 0
      ? distanceKm.toStringAsFixed(0)
      : distanceKm.toStringAsFixed(1).replaceAll('.', ',');
  return '$rounded km';
}

String _durationLabel(int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);

  if (hours == 0) return '${minutes}m';
  return '${hours}h${minutes.toString().padLeft(2, '0')}';
}
