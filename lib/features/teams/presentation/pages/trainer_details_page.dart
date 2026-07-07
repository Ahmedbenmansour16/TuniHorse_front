import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';

class TrainerDetailsPage extends StatefulWidget {
  final TrainerTeamInfo? team;
  final TeamUserProfileInfo? trainer;

  const TrainerDetailsPage({super.key, this.team, this.trainer});

  @override
  State<TrainerDetailsPage> createState() => _TrainerDetailsPageState();
}

class _TrainerDetailsPageState extends State<TrainerDetailsPage> {
  final _teamsApiClient = TeamsApiClient();

  late Future<_TrainerDetailsData> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  @override
  void dispose() {
    _teamsApiClient.close();
    super.dispose();
  }

  Future<_TrainerDetailsData> _loadDetails() async {
    var team = widget.team;
    var trainer = widget.trainer;

    team ??= await _teamsApiClient.getMyTeam();

    if (trainer == null && team != null && team.entraineurId.isNotEmpty) {
      trainer = await _teamsApiClient.getUserProfile(team.entraineurId);
    }

    return _TrainerDetailsData(team: team, trainer: trainer);
  }

  void _reload() {
    setState(() {
      _detailsFuture = _loadDetails();
    });
  }

  void _contactCoach(TeamUserProfileInfo? trainer) {
    final phone = trainer?.telephone?.trim();
    final email = trainer?.email.trim();
    final message = phone != null && phone.isNotEmpty
        ? 'Telephone coach : $phone'
        : email != null && email.isNotEmpty
        ? 'Email coach : $email'
        : 'Coordonnees coach non renseignees.';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TrainerDetailsData>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final trainer = data?.trainer;
        final team = data?.team;
        final trainerName = trainer?.nomComplet ?? 'Entraineur';
        final teamName = team?.nom ?? 'Equipe';

        return AppPage(
          title: 'Detail entraineur',
          showBack: true,
          actions: [
            IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
          ],
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const TuniCard(child: Center(child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              TuniCard(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.danger),
                    const SizedBox(height: 8),
                    const Text(
                      "Impossible de charger l'entraineur.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(label: 'Reessayer', onPressed: _reload),
                  ],
                ),
              )
            else ...[
              TuniCard(
                child: Column(
                  children: [
                    _InitialsAvatar(name: trainerName, size: 92),
                    const SizedBox(height: 12),
                    Text(
                      trainerName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Entraineur - $teamName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    const StatusPill('Coach equipe'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TuniCard(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Telephone',
                      value: _valueOrDash(trainer?.telephone),
                    ),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _valueOrDash(trainer?.email),
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Ville',
                      value: _valueOrDash(trainer?.ville ?? team?.ville),
                    ),
                    _InfoRow(
                      icon: Icons.groups_outlined,
                      label: 'Equipe',
                      value: teamName,
                    ),
                    _InfoRow(
                      icon: Icons.key_outlined,
                      label: 'Code equipe',
                      value: _valueOrDash(team?.codeInvitation),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Contacter le coach',
                icon: Icons.phone_outlined,
                onPressed: () => _contactCoach(trainer),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _InitialsAvatar({required this.name, required this.size});

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
      radius: size / 2,
      backgroundColor: AppColors.greenSoft,
      child: Text(
        initials.isEmpty ? 'E' : initials,
        style: TextStyle(
          color: AppColors.green,
          fontSize: size * 0.28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TrainerDetailsData {
  final TrainerTeamInfo? team;
  final TeamUserProfileInfo? trainer;

  const _TrainerDetailsData({required this.team, required this.trainer});
}

String _valueOrDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}
