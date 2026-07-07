import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/reports/presentation/pages/add_trainer_comment_page.dart';
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

  Future<void> _openTrainerComment() async {
    final updated = await Navigator.of(context).push<LiveSession>(
      MaterialPageRoute(
        builder: (_) => AddTrainerCommentPage(session: _session),
      ),
    );

    if (!mounted || updated == null) return;
    setState(() => _session = updated);
  }

  @override
  Widget build(BuildContext context) {
    final isTrainer = AuthSessionStore.session?.isTrainer ?? false;

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
        const SectionHeader('Vitesse par kilometre'),
        _SpeedByKilometerCard(session: _session),
        const SizedBox(height: 14),
        SectionHeader(
          'Commentaire coach',
          action: 'Details',
          onAction: () => openPage(
            context,
            TrainerCommentPage(session: _session),
          ),
        ),
        _CoachCommentCard(session: _session),
        if (isTrainer) ...[
          const SizedBox(height: 12),
          PrimaryButton(
            label: _session.coachComment == null
                ? 'Ajouter commentaire coach'
                : 'Modifier commentaire coach',
            icon: Icons.edit_note_outlined,
            onPressed: _openTrainerComment,
          ),
        ],
        const SectionHeader('Commentaire cavalier'),
        _RiderCommentCard(session: _session),
        if (!isTrainer) ...[
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Ajouter mon commentaire',
            icon: Icons.edit_note_outlined,
            onPressed: () =>
                openPage(context, AddRiderCommentPage(session: _session)),
          ),
        ],
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
    final gaitAnalysis = _normalizedGaits(session);

    return TuniCard(
      child: Column(
        children: [
          _GaitDonutChart(gaits: gaitAnalysis, totalDuration: session.duration),
          const SizedBox(height: 10),
          ...gaitAnalysis.map((gait) => _GaitLegendLine(gait: gait)),
        ],
      ),
    );
  }

  List<GaitStat> _normalizedGaits(LiveSession session) {
    final values = session.gaitAnalysis;
    if (values.isNotEmpty) return values;

    final minutes = (session.durationSeconds ?? 0) ~/ 60;
    return [
      GaitStat(
        gait: 'Pas',
        minutes: (minutes * .25).round(),
        distanceKm: (session.distanceKm ?? 0) * .2,
        percentage: 25,
      ),
      GaitStat(
        gait: 'Trot',
        minutes: (minutes * .50).round(),
        distanceKm: (session.distanceKm ?? 0) * .55,
        percentage: 50,
      ),
      GaitStat(
        gait: 'Galop',
        minutes: (minutes * .25).round(),
        distanceKm: (session.distanceKm ?? 0) * .25,
        percentage: 25,
      ),
    ];
  }
}

class _GaitDonutChart extends StatelessWidget {
  final List<GaitStat> gaits;
  final String totalDuration;

  const _GaitDonutChart({required this.gaits, required this.totalDuration});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: CustomPaint(
        painter: _GaitDonutPainter(gaits: gaits),
        child: Center(
          child: Text(
            '$totalDuration\nDuree totale',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _GaitDonutPainter extends CustomPainter {
  final List<GaitStat> gaits;

  const _GaitDonutPainter({required this.gaits});

  @override
  void paint(Canvas canvas, Size size) {
    final total = gaits.fold<int>(
      0,
      (sum, gait) => sum + math.max(0, gait.percentage),
    );
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .34;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.butt;

    if (total <= 0) {
      paint.color = AppColors.border;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    var start = -math.pi / 2;
    for (final gait in gaits) {
      final sweep = gait.percentage / total * math.pi * 2;
      paint.color = _gaitColor(gait.gait);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _GaitDonutPainter oldDelegate) {
    return oldDelegate.gaits != gaits;
  }
}

class _GaitLegendLine extends StatelessWidget {
  final GaitStat gait;

  const _GaitLegendLine({required this.gait});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _gaitColor(gait.gait),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              gait.gait,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            '${gait.percentage}%  ${gait.minutes} min  ${gait.distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedByKilometerCard extends StatelessWidget {
  final LiveSession session;

  const _SpeedByKilometerCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final points = _speedPoints(session);

    return TuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 190,
            child: CustomPaint(
              painter: _SpeedByKilometerPainter(points: points),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ReportMetric(
                  label: 'Vitesse moy.',
                  value: session.speed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReportMetric(
                  label: 'Vitesse max',
                  value: _speedLabel(session.maxSpeedKmh),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReportMetric(
                  label: 'Points',
                  value: '${points.length} km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedByKilometerPainter extends CustomPainter {
  final List<SpeedPoint> points;

  const _SpeedByKilometerPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0;
    const top = 12.0;
    const right = 12.0;
    const bottom = 30.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = AppColors.muted
      ..strokeWidth = 1.2;

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }
    canvas.drawLine(chart.bottomLeft, chart.bottomRight, axisPaint);
    canvas.drawLine(chart.bottomLeft, chart.topLeft, axisPaint);

    if (points.isEmpty) return;

    final maxSpeed = points
        .map((point) => point.speedKmh)
        .fold<double>(0, (max, value) => value > max ? value : max);
    final upper = math.max(10, maxSpeed * 1.18);
    final count = math.max(1, points.length - 1);

    Offset pointOffset(int index) {
      final point = points[index];
      final x = chart.left + chart.width * index / count;
      final y = chart.bottom - (point.speedKmh / upper) * chart.height;
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointOffset(0).dx, pointOffset(0).dy);
    for (var i = 1; i < points.length; i++) {
      final point = pointOffset(i);
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < points.length; i++) {
      final offset = pointOffset(i);
      canvas.drawCircle(offset, 4.5, Paint()..color = AppColors.green);
      canvas.drawCircle(offset, 2, Paint()..color = Colors.white);

      if (i == 0 || i == points.length - 1 || i.isEven) {
        labelPainter.text = TextSpan(
          text: '${points[i].kilometer}',
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        );
        labelPainter.layout();
        labelPainter.paint(
          canvas,
          Offset(offset.dx - labelPainter.width / 2, chart.bottom + 8),
        );
      }
    }

    labelPainter.text = TextSpan(
      text: '${upper.toStringAsFixed(0)} km/h',
      style: const TextStyle(color: AppColors.muted, fontSize: 10),
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(0, chart.top - 3));

    labelPainter.text = const TextSpan(
      text: 'km',
      style: TextStyle(color: AppColors.muted, fontSize: 10),
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(chart.right - labelPainter.width, chart.bottom + 8));
  }

  @override
  bool shouldRepaint(covariant _SpeedByKilometerPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _CoachCommentCard extends StatelessWidget {
  final LiveSession session;

  const _CoachCommentCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final comment = session.coachComment;

    if (comment == null) {
      return const TuniCard(
        child: Text(
          'Aucun commentaire coach pour cette seance.',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
        ),
      );
    }

    return TuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined, color: AppColors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  comment.coachName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (comment.note != null)
                StatusPill('${comment.note}/5', color: AppColors.gold),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.commentaire.trim().isEmpty
                ? 'Commentaire non renseigne.'
                : comment.commentaire,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4),
          ),
          const SizedBox(height: 10),
          CheckLine(
            comment.pointsForts.trim().isEmpty
                ? 'Points forts non renseignes'
                : comment.pointsForts,
          ),
          CheckLine(
            comment.pointsAmeliorer.trim().isEmpty
                ? 'Points a ameliorer non renseignes'
                : comment.pointsAmeliorer,
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
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
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

Color _gaitColor(String gait) {
  final normalized = gait.toLowerCase();
  if (normalized.contains('galop')) return AppColors.danger;
  if (normalized.contains('trot')) return AppColors.gold;
  if (normalized.contains('pas')) return AppColors.green;
  return AppColors.muted;
}

List<SpeedPoint> _speedPoints(LiveSession session) {
  if (session.speedByKilometer.isNotEmpty) {
    return session.speedByKilometer;
  }

  final distance = (session.distanceKm ?? 0).round();
  final count = distance <= 0 ? 1 : distance;
  final average = session.averageSpeedKmh ?? 0;
  final max = session.maxSpeedKmh ?? average;

  return List.generate(count, (index) {
    final progress = count == 1 ? 0.0 : index / (count - 1);
    final wave = math.sin(progress * math.pi);

    return SpeedPoint(
      kilometer: index + 1,
      speedKmh: average + (max - average) * wave * 0.72,
    );
  });
}

String _speedLabel(double? value) {
  if (value == null || value <= 0) return '--';
  return '${value.toStringAsFixed(1).replaceAll('.', ',')} km/h';
}
