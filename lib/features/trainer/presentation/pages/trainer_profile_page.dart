import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/data/auth_api_client.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';
import 'package:tunihorse/features/auth/presentation/pages/login_page.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_details_page.dart';
import 'package:tunihorse/features/trainer/presentation/pages/trainer_settings_page.dart';

class TrainerProfilePage extends StatefulWidget {
  const TrainerProfilePage({super.key});

  @override
  State<TrainerProfilePage> createState() => _TrainerProfilePageState();
}

class _TrainerProfilePageState extends State<TrainerProfilePage> {
  final _authApiClient = AuthApiClient();
  final _teamsApiClient = TeamsApiClient();
  final _workoutsApiClient = WorkoutsApiClient();

  late Future<_TrainerProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  @override
  void dispose() {
    _authApiClient.close();
    _teamsApiClient.close();
    _workoutsApiClient.close();
    super.dispose();
  }

  Future<_TrainerProfileData> _loadProfile() async {
    final user = await _loadCurrentUser();
    final stats = await _safeStats();
    final team = await _safeTeam();
    final riders = team == null ? <TeamRiderInfo>[] : await _safeRiders(team.id);
    final horses = team == null
        ? <Map<String, dynamic>>[]
        : await _safeTeamHorses(team.id);

    return _TrainerProfileData(
      user: user,
      stats: stats,
      team: team,
      ridersCount: riders.length,
      horsesCount: horses.length,
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

  Future<TrainerTeamInfo?> _safeTeam() async {
    try {
      return await _teamsApiClient.getMyTeam();
    } catch (_) {
      return null;
    }
  }

  Future<List<TeamRiderInfo>> _safeRiders(String teamId) async {
    try {
      return await _teamsApiClient.getTeamRiders(teamId);
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _safeTeamHorses(String teamId) async {
    try {
      return await _teamsApiClient.getTeamHorses(teamId);
    } catch (_) {
      return [];
    }
  }

  Future<void> _openEdit(Map<String, dynamic> user) async {
    final updated = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => EditTrainerProfilePage(user: user)),
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
    return FutureBuilder<_TrainerProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _TrainerProfileData.empty();
        final user = data.user;
        final name = _userValue(user, 'nomComplet', 'Entraineur');
        final teamName = data.team?.nom ?? 'Aucune equipe';

        return ShellPage(
          title: 'Profil',
          subtitle: 'Compte entraineur',
          actions: [
            IconButton(
              onPressed: () => openPage(context, const TrainerSettingsPage()),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(minHeight: 3),
            TuniCard(
              child: Column(
                children: [
                  _UserAvatar(name: name, icon: Icons.school_outlined),
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
                  const StatusPill('Entraineur'),
                  const SizedBox(height: 16),
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
                          value: '${data.ridersCount}',
                          label: 'Cavaliers',
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
            const SizedBox(height: 16),
            MenuActionTile(
              icon: Icons.groups_outlined,
              title: 'Mon equipe',
              onTap: () => openPage(context, const TeamDetailsPage()),
            ),
            MenuActionTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => openPage(context, const NotificationsPage()),
            ),
            MenuActionTile(
              icon: Icons.settings_outlined,
              title: 'Parametres',
              onTap: () => openPage(context, const TrainerSettingsPage()),
            ),
            MenuActionTile(
              icon: Icons.help_outline,
              title: 'Aide & Support',
              onTap: () => openPage(context, const SupportPage()),
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

class EditTrainerProfilePage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const EditTrainerProfilePage({super.key, this.user});

  @override
  State<EditTrainerProfilePage> createState() => _EditTrainerProfilePageState();
}

class _EditTrainerProfilePageState extends State<EditTrainerProfilePage> {
  final _authApiClient = AuthApiClient();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = widget.user ?? const <String, dynamic>{};
    _nameController = TextEditingController(
      text: _userValue(user, 'nomComplet', ''),
    );
    _phoneController = TextEditingController(
      text: _userValue(user, 'telephone', ''),
    );
    _cityController = TextEditingController(text: _userValue(user, 'ville', ''));
  }

  @override
  void dispose() {
    _authApiClient.close();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      _showError('Session expiree. Reconnectez-vous.');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      _showError('Le nom complet est obligatoire.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await _authApiClient.updateMe(
        accessToken: token,
        body: {
          'nomComplet': _nameController.text.trim(),
          'telephone': _phoneController.text.trim(),
          'ville': _cityController.text.trim(),
        },
      );

      AuthSessionStore.updateUser(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis a jour.')),
      );
      Navigator.of(context).pop(updated);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _userValue(widget.user, 'email', '-');

    return AppPage(
      title: 'Modifier profil',
      showBack: true,
      children: [
        TuniCard(
          child: Column(
            children: [
              _UserAvatar(
                name: _nameController.text.isEmpty
                    ? 'Entraineur'
                    : _nameController.text,
                icon: Icons.camera_alt_outlined,
              ),
              const SizedBox(height: 8),
              const Text(
                'Photo de profil',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'La photo sera ajoutee dans une prochaine etape.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nom complet'),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: false,
          decoration: InputDecoration(labelText: 'Email', hintText: email),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Telephone'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cityController,
          decoration: const InputDecoration(labelText: 'Ville'),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: _isSaving ? 'Enregistrement...' : 'Enregistrer',
          icon: Icons.save_outlined,
          onPressed: _isSaving ? null : _save,
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
      'Comment associer un cavalier a un cheval ?',
      'Comment consulter les rapports ?',
      'Comment gerer les rappels sante ?',
      'Comment selectionner un cavalier pour une course ?',
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

class _TrainerProfileData {
  final Map<String, dynamic> user;
  final RiderMonthStats stats;
  final TrainerTeamInfo? team;
  final int ridersCount;
  final int horsesCount;

  const _TrainerProfileData({
    required this.user,
    required this.stats,
    required this.team,
    required this.ridersCount,
    required this.horsesCount,
  });

  factory _TrainerProfileData.empty() {
    return const _TrainerProfileData(
      user: <String, dynamic>{},
      stats: RiderMonthStats.empty(),
      team: null,
      ridersCount: 0,
      horsesCount: 0,
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String name;
  final IconData icon;

  const _UserAvatar({required this.name, required this.icon});

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
      radius: 42,
      backgroundColor: AppColors.greenSoft,
      child: initials.isEmpty
          ? Icon(icon, color: AppColors.green, size: 36)
          : Text(
              initials,
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 24,
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
