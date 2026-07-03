import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/reports/presentation/pages/compare_sessions_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/progress_statistics_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/report_details_page.dart';

class RiderHistoryPage extends StatefulWidget {
  final bool inShell;

  const RiderHistoryPage({super.key, this.inShell = false});

  @override
  State<RiderHistoryPage> createState() => _RiderHistoryPageState();
}

class _RiderHistoryPageState extends State<RiderHistoryPage> {
  final _workoutsApiClient = WorkoutsApiClient();

  bool _isLoading = true;
  String? _error;
  List<LiveSession> _sessions = [];
  String _selectedHorse = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _workoutsApiClient.close();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await _workoutsApiClient.getMyHistory();
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
    final children = _children(context);

    if (widget.inShell) {
      return ShellPage(
        title: 'Historique',
        subtitle: 'Entrainements et rapports',
        children: children,
      );
    }

    return AppPage(title: 'Historique', showBack: true, children: children);
  }

  List<Widget> _children(BuildContext context) {
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
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              SecondaryButton(label: 'Reessayer', onPressed: _loadSessions),
            ],
          ),
        ),
      ];
    }

    if (_sessions.isEmpty) {
      return const [
        TuniCard(
          child: Text(
            'Aucun entrainement trouve.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ];
    }

    final horseNames = {
      'Tous',
      ..._sessions.map((session) => session.horse.name),
    }.toList();
    final filteredSessions = _selectedHorse == 'Tous'
        ? _sessions
        : _sessions
              .where((session) => session.horse.name == _selectedHorse)
              .toList();

    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: horseNames
            .map(
              (horseName) => GestureDetector(
                onTap: () => setState(() => _selectedHorse = horseName),
                child: StatusPill(
                  horseName,
                  color: horseName == _selectedHorse
                      ? AppColors.green
                      : AppColors.gold,
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 16),
      ...filteredSessions.map(
        (session) => LiveSessionTile(
          session: session,
          onTap: () => openPage(
            context,
            ReportDetailsPage(session: session, allSessions: _sessions),
          ),
        ),
      ),
      const SizedBox(height: 6),
      MenuActionTile(
        icon: Icons.bar_chart_outlined,
        title: 'Statistiques progression',
        onTap: () => openPage(context, const ProgressStatisticsPage()),
      ),
      MenuActionTile(
        icon: Icons.compare_arrows_outlined,
        title: 'Comparer deux seances',
        onTap: () => openPage(
          context,
          CompareSessionsPage(
            baseSession: filteredSessions.first,
            sessions: _sessions,
          ),
        ),
      ),
    ];
  }
}
