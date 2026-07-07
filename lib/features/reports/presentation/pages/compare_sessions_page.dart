import 'package:flutter/material.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';

class CompareSessionsPage extends StatefulWidget {
  final LiveSession? baseSession;
  final List<LiveSession> sessions;

  const CompareSessionsPage({
    super.key,
    this.baseSession,
    this.sessions = const [],
  });

  @override
  State<CompareSessionsPage> createState() => _CompareSessionsPageState();
}

class _CompareSessionsPageState extends State<CompareSessionsPage> {
  final _workoutsApiClient = WorkoutsApiClient();

  late List<LiveSession> _loadedSessions;
  late int _firstIndex;
  late int _secondIndex;
  bool _isLoading = false;
  String? _error;

  List<LiveSession> get _sessions {
    if (_loadedSessions.isNotEmpty) return _loadedSessions;
    final base = widget.baseSession;
    return base == null ? [] : [base];
  }

  @override
  void initState() {
    super.initState();
    _loadedSessions = widget.sessions;
    _firstIndex = _sessionIndex(widget.baseSession);
    _secondIndex = _firstDifferentIndex(_firstIndex);
    _loadAllSessionsIfNeeded();
  }

  @override
  void dispose() {
    _workoutsApiClient.close();
    super.dispose();
  }

  Future<void> _loadAllSessionsIfNeeded() async {
    if (widget.sessions.length >= 3) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessions = await _workoutsApiClient.getMyHistory();
      if (!mounted || sessions.isEmpty) return;
      setState(() {
        _loadedSessions = sessions;
        _firstIndex = _sessionIndex(widget.baseSession);
        _secondIndex = _firstDifferentIndex(_firstIndex);
      });
    } on WorkoutsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger toutes les seances.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _sessionIndex(LiveSession? session) {
    if (session == null) return 0;

    final exactIndex = _sessions.indexWhere((item) => identical(item, session));
    if (exactIndex != -1) return exactIndex;

    final sameValuesIndex = _sessions.indexWhere(
      (item) =>
          item.horse.name == session.horse.name &&
          item.distance == session.distance &&
          item.duration == session.duration,
    );

    return sameValuesIndex == -1 ? 0 : sameValuesIndex;
  }

  int _firstDifferentIndex(int index) {
    if (_sessions.length < 2) return index;
    return index == 0 ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _sessions;

    return AppPage(
      title: 'Comparer seances',
      showBack: true,
      children: [
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator())),
        if (_error != null)
          TuniCard(child: Text(_error!, textAlign: TextAlign.center)),
        if (sessions.isEmpty)
          const TuniCard(
            child: Text(
              'Aucune seance disponible pour la comparaison.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        else
          _CompareContent(
            sessions: sessions,
            firstIndex: _firstIndex.clamp(0, sessions.length - 1).toInt(),
            secondIndex: _secondIndex.clamp(0, sessions.length - 1).toInt(),
            onSecondChanged: (index) => setState(() => _secondIndex = index),
          ),
      ],
    );
  }
}

class _CompareContent extends StatelessWidget {
  final List<LiveSession> sessions;
  final int firstIndex;
  final int secondIndex;
  final ValueChanged<int> onSecondChanged;

  const _CompareContent({
    required this.sessions,
    required this.firstIndex,
    required this.secondIndex,
    required this.onSecondChanged,
  });

  @override
  Widget build(BuildContext context) {
    final first = sessions[firstIndex];
    final second = sessions[secondIndex];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SessionCard(title: 'Seance A', session: first),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SessionSelectorCard(
                title: 'Seance B',
                sessions: sessions,
                selectedIndex: secondIndex,
                onChanged: onSecondChanged,
              ),
            ),
          ],
        ),
        const SectionHeader('Comparaison'),
        TuniCard(
          child: Column(
            children: [
              _CompareLine(
                label: 'Distance',
                left: first.distance,
                right: second.distance,
              ),
              _CompareLine(
                label: 'Duree',
                left: first.duration,
                right: second.duration,
              ),
              _CompareLine(
                label: 'Allure',
                left: first.gait,
                right: second.gait,
              ),
              _CompareLine(
                label: 'Vitesse',
                left: first.speed,
                right: second.speed,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TuniCard(
          child: Text(
            first.distance == second.distance &&
                    first.duration == second.duration
                ? 'Vous comparez la meme seance. Selectionnez une autre seance dans la section B.'
                : 'La comparaison met en evidence les differences de distance, duree, allure et vitesse entre les deux entrainements.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String title;
  final LiveSession session;

  const _SessionCard({required this.title, required this.session});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            session.horse.name,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${session.distance} - ${session.duration}',
            style: const TextStyle(color: Color(0xFF777B72), fontSize: 12),
          ),
          const SizedBox(height: 8),
          StatusPill(session.gait),
        ],
      ),
    );
  }
}

class _SessionSelectorCard extends StatelessWidget {
  final String title;
  final List<LiveSession> sessions;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SessionSelectorCard({
    required this.title,
    required this.sessions,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: selectedIndex,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Choisir une seance',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: List.generate(sessions.length, (index) {
              final session = sessions[index];
              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  '${session.horse.name} - ${session.distance}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _CompareLine extends StatelessWidget {
  final String label;
  final String left;
  final String right;

  const _CompareLine({
    required this.label,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(width: 86, child: Text(label, textAlign: TextAlign.center)),
          Expanded(
            child: Text(
              right,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
