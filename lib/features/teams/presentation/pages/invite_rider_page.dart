import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';

class InviteRiderPage extends StatefulWidget {
  const InviteRiderPage({super.key});

  @override
  State<InviteRiderPage> createState() => _InviteRiderPageState();
}

class _InviteRiderPageState extends State<InviteRiderPage> {
  final _teamsApiClient = TeamsApiClient();
  final _searchController = TextEditingController();
  final _messageController = TextEditingController();

  TrainerTeamInfo? _team;
  TeamRiderInfo? _selectedRider;
  List<TeamRiderInfo> _searchResults = [];
  Timer? _searchDebounce;
  bool _isLoadingTeam = true;
  bool _isSearching = false;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _teamsApiClient.close();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadTeam() async {
    try {
      final team = await _teamsApiClient.getMyTeam();
      if (!mounted) return;
      setState(() {
        _team = team;
        _isLoadingTeam = false;
      });
    } on TeamsApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoadingTeam = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger votre equipe.';
        _isLoadingTeam = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _selectedRider = null);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _searchRiders(value);
    });
  }

  Future<void> _searchRiders(String query) async {
    setState(() => _isSearching = true);

    try {
      final riders = await _teamsApiClient.searchRiders(query);
      if (!mounted) return;
      setState(() => _searchResults = riders);
    } catch (_) {
      if (!mounted) return;
      setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _sendInvitation() async {
    final rider = _selectedRider;

    if (_team == null) {
      _showError('Vous devez creer une equipe avant d inviter un cavalier.');
      return;
    }

    if (rider == null) {
      _showError('Selectionnez un cavalier.');
      return;
    }

    setState(() => _isSending = true);

    try {
      await _teamsApiClient.sendInvitation(
        cavalierId: rider.id,
        message: _messageController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation envoyee au cavalier.')),
      );
      Navigator.of(context).pop(true);
    } on TeamsApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      _showError("Erreur pendant l'envoi de l invitation.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _selectRider(TeamRiderInfo rider) {
    setState(() {
      _selectedRider = rider;
      _searchController.text = rider.nomComplet;
      _searchResults = [];
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = _team;

    return AppPage(
      title: 'Inviter un cavalier',
      showBack: true,
      children: [
        if (_isLoadingTeam)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(child: Text(_error!, textAlign: TextAlign.center))
        else if (team == null)
          const TuniCard(
            child: Text(
              'Creez une equipe avant d envoyer une invitation.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        else ...[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher un cavalier',
              hintText: 'Nom, email ou telephone',
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search),
            ),
            onChanged: _onSearchChanged,
            onTap: () => _searchRiders(_searchController.text),
          ),
          if (_searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            TuniCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: _searchResults
                    .map(
                      (rider) => ListTile(
                        dense: true,
                        title: Text(
                          rider.nomComplet,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(rider.email),
                        trailing: rider.teamId == null
                            ? const Icon(Icons.add, color: AppColors.green)
                            : const StatusPill('Deja en equipe'),
                        onTap: rider.teamId == null
                            ? () => _selectRider(rider)
                            : null,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (_selectedRider != null) ...[
            const SizedBox(height: 8),
            TuniCard(
              color: AppColors.greenSoft,
              child: InfoLine(
                icon: Icons.person_outline,
                label: 'Cavalier',
                value: _selectedRider!.nomComplet,
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            minLines: 4,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Message envoye avec l invitation',
            ),
          ),
          const SizedBox(height: 16),
          TuniCard(
            color: AppColors.greenSoft,
            child: InfoLine(
              icon: Icons.key,
              label: 'Code equipe',
              value: team.codeInvitation,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: _isSending ? 'Envoi...' : 'Envoyer invitation',
            icon: Icons.send_outlined,
            onPressed: _isSending ? null : _sendInvitation,
          ),
        ],
      ],
    );
  }
}
