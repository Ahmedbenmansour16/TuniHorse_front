import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/data/courses_api_client.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_details_page.dart';
import 'package:tunihorse/features/courses/presentation/pages/courses_list_page.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';
import 'package:tunihorse/features/health/data/health_api_client.dart';
import 'package:tunihorse/features/health/presentation/pages/horse_health_page.dart';
import 'package:tunihorse/features/notifications/presentation/pages/notifications_page.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';
import 'package:tunihorse/features/reports/presentation/pages/report_details_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/rider_history_page.dart';
import 'package:tunihorse/features/workouts/presentation/pages/start_workout_page.dart';

class RiderHomePage extends StatelessWidget {
  const RiderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final fullName =
        AuthSessionStore.session?.user?['nomComplet']?.toString() ?? 'Cavalier';
    final firstName = fullName.trim().split(' ').first;

    return ShellPage(
      title: 'Bonjour $firstName',
      subtitle: 'Pret pour une nouvelle seance ?',
      actions: [
        IconButton(
          onPressed: () => openPage(context, const CoursesListPage()),
          icon: const Icon(Icons.emoji_events_outlined),
        ),
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
                      'Demarrer une seance',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Suivez vos performances en temps reel',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => openPage(context, const StartWorkoutPage()),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ],
          ),
        ),
        SecondaryButton(
          label: 'Afficher toutes les courses',
          icon: Icons.emoji_events_outlined,
          onPressed: () => openPage(context, const CoursesListPage()),
        ),
        const SectionHeader('Statistiques ce mois'),
        const _MonthStatsSection(),
        const _NextHealthReminderSection(),
        const _NextCourseSection(),
        SectionHeader(
          'Derniers entrainements',
          action: 'Tout voir',
          onAction: () => openPage(context, const RiderHistoryPage()),
        ),
        const _LatestWorkoutsSection(),
      ],
    );
  }
}

class _MonthStatsSection extends StatefulWidget {
  const _MonthStatsSection();

  @override
  State<_MonthStatsSection> createState() => _MonthStatsSectionState();
}

class _MonthStatsSectionState extends State<_MonthStatsSection> {
  final _workoutsApiClient = WorkoutsApiClient();

  bool _isLoading = true;
  String? _error;
  RiderMonthStats _stats = const RiderMonthStats.empty();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _workoutsApiClient.close();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _workoutsApiClient.getMyMonthStats();
      if (!mounted) return;
      setState(() => _stats = stats);
    } on WorkoutsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les statistiques.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const TuniCard(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return TuniCard(
        child: Column(
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            SecondaryButton(label: 'Reessayer', onPressed: _loadStats),
          ],
        ),
      );
    }

    return MetricGrid(stats: _stats.toTrainerStats());
  }
}

class _NextHealthReminderSection extends StatefulWidget {
  const _NextHealthReminderSection();

  @override
  State<_NextHealthReminderSection> createState() =>
      _NextHealthReminderSectionState();
}

class _NextHealthReminderSectionState
    extends State<_NextHealthReminderSection> {
  final _healthApiClient = HealthApiClient();

  bool _isLoading = true;
  String? _error;
  NextHealthReminder? _reminder;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  @override
  void dispose() {
    _healthApiClient.close();
    super.dispose();
  }

  Future<void> _loadReminder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reminder = await _healthApiClient.getNextReminder();
      if (!mounted) return;
      setState(() => _reminder = reminder);
    } on HealthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger le rappel sante.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminder = _reminder;

    return Column(
      children: [
        SectionHeader(
          'Prochain rappel sante',
          action: reminder == null ? null : 'Voir',
          onAction: reminder == null
              ? null
              : () => openPage(
                    context,
                    HorseHealthPage(horse: reminder.horse),
                  ),
        ),
        _buildContent(context, reminder),
      ],
    );
  }

  Widget _buildContent(BuildContext context, NextHealthReminder? reminder) {
    if (_isLoading) {
      return const TuniCard(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return TuniCard(
        child: Column(
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            SecondaryButton(label: 'Reessayer', onPressed: _loadReminder),
          ],
        ),
      );
    }

    if (reminder == null) {
      return const TuniCard(
        child: Row(
          children: [
            Icon(Icons.event_note_outlined, color: AppColors.muted, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucun rappel sante a venir',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );
    }

    return TuniCard(
      onTap: () => openPage(context, HorseHealthPage(horse: reminder.horse)),
      child: Row(
        children: [
          const Icon(
            Icons.event_note_outlined,
            color: AppColors.danger,
            size: 34,
          ),
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
                  '${_durationLabel(reminder.reminderDate)} - ${reminder.horse.name}',
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
    );
  }

  String _durationLabel(DateTime reminderDate) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final reminderOnly = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
    );
    final days = reminderOnly.difference(todayOnly).inDays;

    if (days == 0) return 'Aujourd hui';
    if (days == 1) return 'Demain';
    return 'Dans $days jours';
  }
}

class _LatestWorkoutsSection extends StatefulWidget {
  const _LatestWorkoutsSection();

  @override
  State<_LatestWorkoutsSection> createState() => _LatestWorkoutsSectionState();
}

class _LatestWorkoutsSectionState extends State<_LatestWorkoutsSection> {
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
      final sessions = await _workoutsApiClient.getMyHistory(limit: 2);
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
    if (_isLoading) {
      return const TuniCard(child: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return TuniCard(
        child: Column(
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            SecondaryButton(label: 'Reessayer', onPressed: _loadSessions),
          ],
        ),
      );
    }

    if (_sessions.isEmpty) {
      return const TuniCard(
        child: Text(
          'Aucun entrainement trouve.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      );
    }

    return Column(
      children: _sessions
          .map(
            (session) => LiveSessionTile(
              session: session,
              onTap: () => openPage(
                context,
                ReportDetailsPage(session: session, allSessions: _sessions),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _NextCourseSection extends StatefulWidget {
  const _NextCourseSection();

  @override
  State<_NextCourseSection> createState() => _NextCourseSectionState();
}

class _NextCourseSectionState extends State<_NextCourseSection> {
  final _coursesApiClient = CoursesApiClient();

  bool _isLoading = true;
  String? _error;
  _CourseWithDate? _nextCourse;

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

  _CourseWithDate? _findNextCourse(List<Map<String, dynamic>> response) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final upcomingCourses = <_CourseWithDate>[];

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

  _CourseWithDate? _courseFromJson(Map<String, dynamic> json) {
    final dateCourse = DateTime.tryParse(json['dateCourse']?.toString() ?? '');
    if (dateCourse == null) return null;

    final dateText = json['dateTexte']?.toString();

    return _CourseWithDate(
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

class _CourseWithDate {
  final DateTime date;
  final CourseInfo course;

  const _CourseWithDate({required this.date, required this.course});
}
