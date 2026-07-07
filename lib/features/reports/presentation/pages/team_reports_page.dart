import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/reports/presentation/pages/compare_sessions_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/report_details_page.dart';

class TeamReportsPage extends StatefulWidget {
  const TeamReportsPage({super.key});

  @override
  State<TeamReportsPage> createState() => _TeamReportsPageState();
}

class _TeamReportsPageState extends State<TeamReportsPage> {
  final _workoutsApiClient = WorkoutsApiClient();

  bool _isLoading = true;
  String? _error;
  List<LiveSession> _sessions = [];

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
      setState(() => _error = 'Impossible de charger les rapports.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Rapports partages',
      showBack: true,
      actions: [
        IconButton(
          onPressed: _loadSessions,
          icon: const Icon(Icons.refresh_outlined),
        ),
      ],
      children: _children(context),
    );
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
            'Aucun rapport trouve pour cette equipe.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ];
    }

    return [
      ..._sessions.map(
        (session) => LiveSessionTile(
          session: session,
          onTap: () => openPage(
            context,
            ReportDetailsPage(session: session, allSessions: _sessions),
          ),
        ),
      ),
      const SizedBox(height: 6),
      PrimaryButton(
        label: 'Comparer deux seances',
        icon: Icons.compare_arrows_outlined,
        onPressed: () => openPage(
          context,
          CompareSessionsPage(baseSession: _sessions.first, sessions: _sessions),
        ),
      ),
    ];
  }
}
