import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/horses/presentation/pages/horse_details_page.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';

class TeamHorsesPage extends StatefulWidget {
  const TeamHorsesPage({super.key});

  @override
  State<TeamHorsesPage> createState() => _TeamHorsesPageState();
}

class _TeamHorsesPageState extends State<TeamHorsesPage> {
  final _teamsApiClient = TeamsApiClient();

  bool _isLoading = true;
  String? _error;
  List<Horse> _horses = [];

  @override
  void initState() {
    super.initState();
    _loadHorses();
  }

  @override
  void dispose() {
    _teamsApiClient.close();
    super.dispose();
  }

  Future<void> _loadHorses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final team = await _teamsApiClient.getMyTeam();
      final response = team == null
          ? <Map<String, dynamic>>[]
          : await _teamsApiClient.getTeamHorses(team.id);

      if (!mounted) return;
      setState(() {
        _horses = response.asMap().entries.map((entry) {
          return _horseFromJson(entry.value, entry.key);
        }).toList();
      });
    } on TeamsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = "Impossible de charger les chevaux de l'equipe.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Horse _horseFromJson(Map<String, dynamic> json, int index) {
    final colors = [
      const Color(0xFF8B4B24),
      const Color(0xFF8F9182),
      const Color(0xFF3E2518),
      const Color(0xFFD8D0C4),
    ];
    final photoUrl = json['photoUrl']?.toString();
    final age = json['age'];

    return Horse(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['nom']?.toString() ?? 'Cheval',
      race: json['race']?.toString() ?? 'Race non precisee',
      age: age == null ? 'Age non precise' : '$age ans',
      owner: json['proprietaireId']?.toString() ?? '',
      status: 'Actif',
      color: colors[index % colors.length],
      photoUrl: photoUrl == null || photoUrl.isEmpty
          ? null
          : photoUrl.startsWith('http')
          ? photoUrl
          : '${ApiConstants.baseUrl}$photoUrl',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: "Chevaux de l'equipe",
      showBack: true,
      actions: [
        IconButton(onPressed: _loadHorses, icon: const Icon(Icons.refresh)),
      ],
      children: [
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: AppColors.danger),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                SecondaryButton(label: 'Reessayer', onPressed: _loadHorses),
              ],
            ),
          )
        else if (_horses.isEmpty)
          const TuniCard(
            child: Text(
              "Aucun cheval dans l'equipe pour le moment.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        else
          ..._horses.map(
            (horse) => HorseListTile(
              horse: horse,
              onTap: () => openPage(context, HorseDetailsPage(horse: horse)),
            ),
          ),
      ],
    );
  }
}
