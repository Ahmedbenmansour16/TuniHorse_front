import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/horseshoe_mark.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_horses_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_members_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/trainer_details_page.dart';

class RiderTeamPage extends StatefulWidget {
  const RiderTeamPage({super.key});

  @override
  State<RiderTeamPage> createState() => _RiderTeamPageState();
}

class _RiderTeamPageState extends State<RiderTeamPage> {
  final _teamsApiClient = TeamsApiClient();
  final _workoutsApiClient = WorkoutsApiClient();

  late Future<_RiderTeamData> _teamFuture;

  @override
  void initState() {
    super.initState();
    _teamFuture = _loadTeam();
  }

  @override
  void dispose() {
    _teamsApiClient.close();
    _workoutsApiClient.close();
    super.dispose();
  }

  Future<_RiderTeamData> _loadTeam() async {
    final team = await _teamsApiClient.getMyTeam();

    if (team == null) {
      return const _RiderTeamData.empty();
    }

    final trainer = await _safeTrainer(team.entraineurId);
    final riders = await _safeRiders(team.id);
    final horses = await _safeHorses(team.id);
    final stats = await _safeStats();

    return _RiderTeamData(
      team: team,
      trainer: trainer,
      riders: riders,
      horses: horses,
      stats: stats,
    );
  }

  Future<TeamUserProfileInfo?> _safeTrainer(String trainerId) async {
    try {
      return await _teamsApiClient.getUserProfile(trainerId);
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

  Future<List<Map<String, dynamic>>> _safeHorses(String teamId) async {
    try {
      return await _teamsApiClient.getTeamHorses(teamId);
    } catch (_) {
      return [];
    }
  }

  Future<RiderMonthStats> _safeStats() async {
    try {
      return await _workoutsApiClient.getMyMonthStats();
    } catch (_) {
      return const RiderMonthStats.empty();
    }
  }

  void _reload() {
    setState(() {
      _teamFuture = _loadTeam();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RiderTeamData>(
      future: _teamFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return AppPage(
          title: 'Mon equipe',
          showBack: true,
          actions: [
            IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
          ],
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const TuniCard(child: Center(child: CircularProgressIndicator()))
            else if (snapshot.hasError)
              _ErrorCard(onRetry: _reload)
            else if (data == null || data.team == null)
              const _NoTeamCard()
            else ...[
              _TeamHeader(data: data),
              const SectionHeader('Statistiques equipe'),
              _TeamStatsGrid(data: data),
              const SectionHeader('Entraineur'),
              _TrainerSummaryCard(data: data),
              const SectionHeader('Actions'),
              MenuActionTile(
                icon: Icons.groups_outlined,
                title: "Membres de l'equipe",
                onTap: () => openPage(
                  context,
                  const TeamMembersPage(canInvite: false),
                ),
              ),
              MenuActionTile(
                icon: Icons.person_pin_outlined,
                title: "Detail entraineur",
                onTap: () => openPage(
                  context,
                  TrainerDetailsPage(team: data.team, trainer: data.trainer),
                ),
              ),
              MenuActionTile(
                icon: Icons.hdr_strong,
                title: "Chevaux de l'equipe",
                onTap: () => openPage(context, const TeamHorsesPage()),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final _RiderTeamData data;

  const _TeamHeader({required this.data});

  @override
  Widget build(BuildContext context) {
    final team = data.team!;
    final trainerName = data.trainer?.nomComplet ?? 'Entraineur';

    return TuniCard(
      child: Row(
        children: [
          _TeamPhoto(photoUrl: team.photoUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entraineur : $trainerName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                Text(
                  'Ville : ${team.ville}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                StatusPill('Code ${team.codeInvitation}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamStatsGrid extends StatelessWidget {
  final _RiderTeamData data;

  const _TeamStatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      TrainerStat(
        label: 'Cavaliers',
        value: '${data.riders.length}',
        icon: Icons.groups_outlined,
      ),
      TrainerStat(
        label: 'Chevaux',
        value: '${data.horses.length}',
        icon: Icons.hdr_strong,
      ),
      TrainerStat(
        label: 'Seances',
        value: '${data.stats.seances}',
        icon: Icons.timer_outlined,
      ),
      TrainerStat(
        label: 'Distance',
        value: _distanceLabel(data.stats.distanceKm),
        icon: Icons.route,
      ),
    ];

    return MetricGrid(stats: stats);
  }
}

class _TrainerSummaryCard extends StatelessWidget {
  final _RiderTeamData data;

  const _TrainerSummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final trainer = data.trainer;
    final team = data.team!;
    final name = trainer?.nomComplet ?? 'Entraineur';

    return TuniCard(
      onTap: () => openPage(
        context,
        TrainerDetailsPage(team: team, trainer: trainer),
      ),
      child: Row(
        children: [
          _InitialsAvatar(name: name, size: 54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  team.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                Text(
                  trainer?.telephone?.isNotEmpty == true
                      ? trainer!.telephone!
                      : 'Telephone non renseigne',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _TeamPhoto extends StatelessWidget {
  final String? photoUrl;

  const _TeamPhoto({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl(photoUrl);

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        color: AppColors.gold.withValues(alpha: 0.14),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? const Center(child: HorseshoeMark(size: 40, color: AppColors.green))
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: HorseshoeMark(size: 40, color: AppColors.green),
                );
              },
            ),
    );
  }

  String? _resolvedUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '${ApiConstants.baseUrl}$value';
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

class _NoTeamCard extends StatelessWidget {
  const _NoTeamCard();

  @override
  Widget build(BuildContext context) {
    return const TuniCard(
      child: Column(
        children: [
          HorseshoeMark(size: 44, color: AppColors.green),
          SizedBox(height: 12),
          Text(
            "Vous n'etes associe a aucune equipe.",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6),
          Text(
            "Acceptez une invitation d'entraineur depuis vos notifications.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger),
          const SizedBox(height: 8),
          const Text(
            "Impossible de charger votre equipe.",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          SecondaryButton(label: 'Reessayer', onPressed: onRetry),
        ],
      ),
    );
  }
}

class _RiderTeamData {
  final TrainerTeamInfo? team;
  final TeamUserProfileInfo? trainer;
  final List<TeamRiderInfo> riders;
  final List<Map<String, dynamic>> horses;
  final RiderMonthStats stats;

  const _RiderTeamData({
    required this.team,
    required this.trainer,
    required this.riders,
    required this.horses,
    required this.stats,
  });

  const _RiderTeamData.empty()
      : team = null,
        trainer = null,
        riders = const [],
        horses = const [],
        stats = const RiderMonthStats.empty();
}

String _distanceLabel(double distanceKm) {
  final rounded = distanceKm % 1 == 0
      ? distanceKm.toStringAsFixed(0)
      : distanceKm.toStringAsFixed(1).replaceAll('.', ',');
  return '$rounded km';
}
