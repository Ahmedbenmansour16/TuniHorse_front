import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';
import 'package:tunihorse/features/teams/presentation/pages/invite_rider_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/rider_details_page.dart';

class TeamMembersPage extends StatefulWidget {
  final bool canInvite;

  const TeamMembersPage({super.key, this.canInvite = true});

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  final _teamsApiClient = TeamsApiClient();

  TrainerTeamInfo? _team;
  List<TeamRiderInfo> _riders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _teamsApiClient.close();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final team = await _teamsApiClient.getMyTeam();
      final riders = team == null
          ? <TeamRiderInfo>[]
          : await _teamsApiClient.getTeamRiders(team.id);
      if (!mounted) return;
      setState(() {
        _team = team;
        _riders = riders;
      });
    } on TeamsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les cavaliers.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openInvitePage() async {
    final sent = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const InviteRiderPage()),
    );

    if (sent == true) {
      _loadMembers();
    }
  }

  Rider _toRider(TeamRiderInfo rider) {
    return Rider(
      name: rider.nomComplet.isEmpty ? 'Cavalier' : rider.nomComplet,
      level: rider.ville == null || rider.ville!.isEmpty
          ? 'Cavalier'
          : rider.ville!,
      horsesCount: rider.telephone == null || rider.telephone!.isEmpty
          ? 'Telephone non renseigne'
          : rider.telephone!,
      lastSession: rider.email,
      phone: rider.telephone ?? '',
      email: rider.email,
      color: AppColors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Cavaliers',
      subtitle: _team?.nom,
      showBack: true,
      actions: widget.canInvite
          ? [
              IconButton(
                onPressed: _openInvitePage,
                icon: const Icon(Icons.add),
              ),
            ]
          : null,
      children: [
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                SecondaryButton(label: 'Reessayer', onPressed: _loadMembers),
              ],
            ),
          )
        else if (_team == null)
          const TuniCard(
            child: Text(
              'Creez une equipe avant d ajouter des cavaliers.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        else if (_riders.isEmpty)
          TuniCard(
            child: Column(
              children: [
                const Icon(Icons.groups_outlined, color: AppColors.muted),
                const SizedBox(height: 8),
                const Text(
                  'Aucun cavalier dans cette equipe.',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                if (widget.canInvite)
                  PrimaryButton(
                    label: 'Inviter un cavalier',
                    icon: Icons.person_add_alt,
                    onPressed: _openInvitePage,
                  ),
              ],
            ),
          )
        else
          ..._riders.map(
            (rider) {
              final uiRider = _toRider(rider);
              return RiderListTile(
                rider: uiRider,
                onTap: () => openPage(context, RiderDetailsPage(rider: uiRider)),
              );
            },
          ),
      ],
    );
  }
}
