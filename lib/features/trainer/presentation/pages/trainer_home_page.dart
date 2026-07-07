import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';
import 'package:tunihorse/features/courses/data/courses_api_client.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_details_page.dart';
import 'package:tunihorse/features/health/data/health_api_client.dart';
import 'package:tunihorse/features/health/presentation/pages/horse_health_page.dart';
import 'package:tunihorse/features/health/presentation/pages/trainer_health_reminders_page.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/reports/presentation/pages/team_reports_page.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_details_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/live_sessions_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/live_tracking_page.dart';

class TrainerHomePage extends StatelessWidget {
  const TrainerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fullName =
        AuthSessionStore.session?.user?['nomComplet']?.toString() ??
        'Entraineur';
    final firstName = fullName.trim().isEmpty
        ? 'Entraineur'
        : fullName.trim().split(' ').first;

    return ShellPage(
      title: 'Bonjour $firstName',
      subtitle: 'Entraineur',
      actions: [
        IconButton(
          onPressed: () => openPage(context, const NotificationsPage()),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
      children: [
        GreenHeroCard(
          child: Row(
            children: [
              const Icon(
                Icons.play_circle_fill,
                color: AppColors.gold,
                size: 48,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Démarrer une séance',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sélectionner un cheval avant de commencer',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => openPage(context, const LiveSessionsPage()),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          ),
        ),
        const _TrainerMonthStatsSection(),
        SectionHeader(
          'Séances en cours',
          action: 'Voir tout',
          onAction: () => openPage(context, const LiveSessionsPage()),
        ),
        LiveSessionTile(
          session: liveSessions.first,
          onTap: () =>
              openPage(context, LiveTrackingPage(session: liveSessions.first)),
        ),
        const _TrainerNextCourseSection(),
        const _TrainerHealthRemindersSection(),
        const SectionHeader('Accès rapides'),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.groups,
                label: 'Équipe',
                onTap: () => openPage(context, const TeamDetailsPage()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickAction(
                icon: Icons.article,
                label: 'Rapports',
                onTap: () => openPage(context, const TeamReportsPage()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickAction(
                icon: Icons.favorite,
                label: 'Sante',
                onTap: () =>
                    openPage(context, const TrainerHealthRemindersPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrainerMonthStatsSection extends StatefulWidget {
  const _TrainerMonthStatsSection();

  @override
  State<_TrainerMonthStatsSection> createState() =>
      _TrainerMonthStatsSectionState();
}

class _TrainerMonthStatsSectionState extends State<_TrainerMonthStatsSection> {
  final _workoutsApiClient = WorkoutsApiClient();
  final _teamsApiClient = TeamsApiClient();

  bool _isLoading = true;
  String? _error;
  List<TrainerStat> _stats = const [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _workoutsApiClient.close();
    _teamsApiClient.close();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final team = await _teamsApiClient.getMyTeam();
      final monthStats = await _workoutsApiClient.getMyMonthStats();
      if (!mounted) return;

      setState(() {
        _stats = [
          TrainerStat(
            label: 'Cavaliers',
            value: '${team?.cavaliers.length ?? 0}',
            icon: Icons.groups_outlined,
          ),
          TrainerStat(
            label: 'Chevaux',
            value: '${monthStats.chevaux}',
            icon: Icons.hdr_strong,
          ),
          TrainerStat(
            label: 'Seances',
            value: '${monthStats.seances}',
            icon: Icons.timer_outlined,
          ),
          TrainerStat(
            label: 'Distance',
            value: _distanceLabel(monthStats.distanceKm),
            icon: Icons.route,
          ),
        ];
      });
    } on WorkoutsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } on TeamsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les statistiques.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _distanceLabel(double value) {
    final rounded = value % 1 == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1).replaceAll('.', ',');
    return '$rounded km';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader('Statistiques ce mois'),
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                SecondaryButton(label: 'Reessayer', onPressed: _loadStats),
              ],
            ),
          )
        else
          MetricGrid(stats: _stats),
      ],
    );
  }
}

class _TrainerHealthRemindersSection extends StatefulWidget {
  const _TrainerHealthRemindersSection();

  @override
  State<_TrainerHealthRemindersSection> createState() =>
      _TrainerHealthRemindersSectionState();
}

class _TrainerHealthRemindersSectionState
    extends State<_TrainerHealthRemindersSection> {
  final _healthApiClient = HealthApiClient();

  bool _isLoading = true;
  String? _error;
  List<NextHealthReminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  @override
  void dispose() {
    _healthApiClient.close();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reminders = await _healthApiClient.getUpcomingReminders(limit: 2);
      if (!mounted) return;
      setState(() => _reminders = reminders);
    } on HealthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les rappels sante.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          'Rappels sante',
          action: 'Voir plus',
          onAction: () =>
              openPage(context, const TrainerHealthRemindersPage()),
        ),
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                SecondaryButton(label: 'Reessayer', onPressed: _loadReminders),
              ],
            ),
          )
        else if (_reminders.isEmpty)
          const TuniCard(
            child: Text(
              'Aucun rappel sante a venir.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          )
        else
          TuniCard(
            child: Column(
              children: _reminders
                  .map((reminder) => _TrainerHealthReminderRow(reminder))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _TrainerHealthReminderRow extends StatelessWidget {
  final NextHealthReminder reminder;

  const _TrainerHealthReminderRow(this.reminder);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openPage(context, HorseHealthPage(horse: reminder.horse)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            HorsePhoto(horse: reminder.horse, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.careTypeLabel,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${reminder.horse.name} - ${_durationLabel(reminder.reminderDate)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  String _durationLabel(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final days = dateOnly.difference(todayOnly).inDays;

    if (days == 0) return 'Aujourd hui';
    if (days == 1) return 'Demain';
    return 'Dans $days jours';
  }
}

class _TrainerNextCourseSection extends StatefulWidget {
  const _TrainerNextCourseSection();

  @override
  State<_TrainerNextCourseSection> createState() =>
      _TrainerNextCourseSectionState();
}

class _TrainerNextCourseSectionState extends State<_TrainerNextCourseSection> {
  final _coursesApiClient = CoursesApiClient();

  bool _isLoading = true;
  String? _error;
  _TrainerCourseWithDate? _nextCourse;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _coursesApiClient.close();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _coursesApiClient.getCourses();
      if (!mounted) return;
      setState(() => _nextCourse = _findNextCourse(response));
    } on CoursesApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les courses.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  _TrainerCourseWithDate? _findNextCourse(List<Map<String, dynamic>> response) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final upcomingCourses = <_TrainerCourseWithDate>[];

    for (final json in response) {
      final course = _courseFromJson(json);
      if (course == null) continue;

      final courseDay = DateTime(
        course.date.year,
        course.date.month,
        course.date.day,
      );

      if (!courseDay.isBefore(todayOnly)) {
        upcomingCourses.add(course);
      }
    }

    upcomingCourses.sort((a, b) => a.date.compareTo(b.date));
    return upcomingCourses.isEmpty ? null : upcomingCourses.first;
  }

  _TrainerCourseWithDate? _courseFromJson(Map<String, dynamic> json) {
    final dateCourse = DateTime.tryParse(json['dateCourse']?.toString() ?? '');
    if (dateCourse == null) return null;

    final dateText = json['dateTexte']?.toString();

    return _TrainerCourseWithDate(
      date: dateCourse,
      course: CourseInfo(
        id: json['id']?.toString() ?? json['_id']?.toString(),
        dateCourse: dateCourse,
        name: json['nom']?.toString() ?? 'Course',
        category: json['categorie']?.toString() ?? 'Endurance',
        date: dateText == null || dateText.isEmpty
            ? _formatDate(dateCourse)
            : dateText,
        place: json['lieu']?.toString() ?? '',
        organisation: json['organisation']?.toString() ?? '',
        countdown: _countdown(dateCourse),
        color: AppColors.green,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _countdown(DateTime? date) {
    if (date == null) return '--';
    final today = DateTime.now();
    final days = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;

    if (days < 0) return 'Passe';
    if (days == 0) return 'Aujourd hui';
    return 'J-$days';
  }

  @override
  Widget build(BuildContext context) {
    final nextCourse = _nextCourse?.course;

    return Column(
      children: [
        SectionHeader(
          'Prochaine course',
          action: nextCourse == null ? null : 'Details',
          onAction: nextCourse == null
              ? null
              : () => openPage(context, CourseDetailsPage(course: nextCourse)),
        ),
        _buildContent(context, nextCourse),
      ],
    );
  }

  Widget _buildContent(BuildContext context, CourseInfo? nextCourse) {
    if (_isLoading) {
      return const TuniCard(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return TuniCard(
        child: Column(
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            SecondaryButton(label: 'Reessayer', onPressed: _loadCourses),
          ],
        ),
      );
    }

    if (nextCourse == null) {
      return const TuniCard(
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, color: AppColors.muted),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pas de course prochaine',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    }

    return CourseTile(
      course: nextCourse,
      onTap: () => openPage(context, CourseDetailsPage(course: nextCourse)),
    );
  }
}

class _TrainerCourseWithDate {
  final DateTime date;
  final CourseInfo course;

  const _TrainerCourseWithDate({required this.date, required this.course});
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: AppColors.green),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
