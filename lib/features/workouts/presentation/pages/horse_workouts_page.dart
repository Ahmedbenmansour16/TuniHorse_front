import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/reports/presentation/pages/report_details_page.dart';

class HorseWorkoutsPage extends StatefulWidget {
  final Horse? horse;

  const HorseWorkoutsPage({super.key, this.horse});

  @override
  State<HorseWorkoutsPage> createState() => _HorseWorkoutsPageState();
}

class _HorseWorkoutsPageState extends State<HorseWorkoutsPage> {
  final _workoutsApiClient = WorkoutsApiClient();

  bool _isLoading = true;
  String? _error;
  List<LiveSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  @override
  void dispose() {
    _workoutsApiClient.close();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    final horseId = widget.horse?.id;

    if (widget.horse != null && (horseId == null || horseId.isEmpty)) {
      setState(() {
        _isLoading = false;
        _error = 'Ce cheval n a pas encore d identifiant MongoDB.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = horseId == null || horseId.isEmpty
          ? await _workoutsApiClient.getMyHistory()
          : await _workoutsApiClient.getHorseHistory(horseId);

      if (!mounted) return;
      setState(() => _sessions = sessions);
    } on WorkoutsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les entrainements.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horse = widget.horse;

    return AppPage(
      title: horse == null
          ? 'Tous les entrainements'
          : 'Entrainements - ${horse.name}',
      showBack: true,
      actions: [
        IconButton(onPressed: _loadWorkouts, icon: const Icon(Icons.refresh)),
      ],
      children: [
        if (horse != null) _HorseHeader(horse: horse),
        if (horse != null) const SizedBox(height: 14),
        ..._buildContent(),
      ],
    );
  }

  List<Widget> _buildContent() {
    if (_isLoading) {
      return const [
        TuniCard(child: Center(child: CircularProgressIndicator())),
      ];
    }

    if (_error != null) {
      return [
        TuniCard(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              SecondaryButton(label: 'Reessayer', onPressed: _loadWorkouts),
            ],
          ),
        ),
      ];
    }

    if (_sessions.isEmpty) {
      return [
        TuniCard(
          child: Text(
            widget.horse == null
                ? 'Aucun entrainement trouve.'
                : 'Aucun entrainement trouve pour ${widget.horse!.name}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ];
    }

    return [
      ..._sessions.map(
        (session) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TuniCard(
            onTap: () => openPage(
              context,
              ReportDetailsPage(session: session, allSessions: _sessions),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(session.startedAt),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        session.rider.name,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    session.duration,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    session.distance,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                StatusPill(session.gait),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _HorseHeader extends StatelessWidget {
  final Horse horse;

  const _HorseHeader({required this.horse});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      child: Row(
        children: [
          HorsePhoto(horse: horse),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  horse.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '${horse.race} - ${horse.age}',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
