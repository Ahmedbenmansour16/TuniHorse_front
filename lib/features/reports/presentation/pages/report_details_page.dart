import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/core/widgets/visual_widgets.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/reports/presentation/pages/add_rider_comment_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/compare_sessions_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/trainer_comment_page.dart';

class ReportDetailsPage extends StatefulWidget {
  final LiveSession session;
  final List<LiveSession> allSessions;

  const ReportDetailsPage({
    super.key,
    required this.session,
    this.allSessions = const [],
  });

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  final _workoutsApiClient = WorkoutsApiClient();

  late LiveSession _session;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _loadReport();
  }

  @override
  void dispose() {
    _workoutsApiClient.close();
    super.dispose();
  }

  Future<void> _loadReport() async {
    if (widget.session.workoutId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reportSession = await _workoutsApiClient.getReportByWorkout(
        widget.session,
      );
      if (!mounted) return;
      setState(() => _session = reportSession);
    } on WorkoutsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger le rapport.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Rapport de seance',
      showBack: true,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share)),
      ],
      children: [
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator())),
        if (_error != null)
          TuniCard(
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                SecondaryButton(label: 'Reessayer', onPressed: _loadReport),
              ],
            ),
          ),
        _ReportSummaryCard(session: _session),
        const SectionHeader('Analyse des allures'),
        _GaitAnalysisCard(session: _session),
        const SizedBox(height: 14),
        MenuActionTile(
          icon: Icons.comment_outlined,
          title: 'Commentaire coach',
          onTap: () => openPage(context, TrainerCommentPage(session: _session)),
        ),
        const SectionHeader('Commentaire du cavalier'),
        _RiderCommentCard(session: _session),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Ajouter mon commentaire',
          icon: Icons.edit_note_outlined,
          onPressed: () =>
              openPage(context, AddRiderCommentPage(session: _session)),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'Comparer avec une autre seance',
          icon: Icons.compare_arrows_outlined,
          onPressed: () => openPage(
            context,
            CompareSessionsPage(
              baseSession: _session,
              sessions: widget.allSessions,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  final LiveSession session;

  const _ReportSummaryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HorsePhoto(horse: session.horse),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.horse.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      session.rider.name,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    Text(
                      _formatDate(session.startedAt),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _ReportMetric(label: 'Duree', value: session.duration),
              _ReportMetric(label: 'Distance', value: session.distance),
              _ReportMetric(label: 'Vitesse moy.', value: session.speed),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _GaitAnalysisCard extends StatelessWidget {
  final LiveSession session;

  const _GaitAnalysisCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final gaitAnalysis = session.gaitAnalysis;

    return TuniCard(
      child: Column(
        children: [
          const GaitDonutChart(),
          if (gaitAnalysis.isEmpty)
            const InfoLine(
              icon: Icons.circle,
              label: 'Allure dominante',
              value: 'Donnees non disponibles',
            )
          else
            ...gaitAnalysis.map(
              (gait) => InfoLine(
                icon: Icons.circle,
                label: gait.gait,
                value:
                    '${gait.percentage}% - ${gait.minutes} min - ${gait.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km',
              ),
            ),
        ],
      ),
    );
  }
}

class _RiderCommentCard extends StatelessWidget {
  final LiveSession session;

  const _RiderCommentCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_outline, color: AppColors.green, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.rider.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  session.riderComment == null ||
                          session.riderComment!.trim().isEmpty
                      ? 'Aucun commentaire cavalier pour cette seance.'
                      : session.riderComment!,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ReportMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
