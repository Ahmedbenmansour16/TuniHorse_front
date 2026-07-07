import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/health/data/health_api_client.dart';
import 'package:tunihorse/features/health/presentation/pages/horse_health_page.dart';

class TrainerHealthRemindersPage extends StatefulWidget {
  const TrainerHealthRemindersPage({super.key});

  @override
  State<TrainerHealthRemindersPage> createState() =>
      _TrainerHealthRemindersPageState();
}

class _TrainerHealthRemindersPageState
    extends State<TrainerHealthRemindersPage> {
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
      final reminders = await _healthApiClient.getUpcomingReminders();
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
    return AppPage(
      title: 'Rappels sante',
      subtitle: 'Tous les chevaux',
      showBack: true,
      actions: [
        IconButton(onPressed: _loadReminders, icon: const Icon(Icons.refresh)),
      ],
      children: [
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
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
          ..._reminders.map(
            (reminder) => _TrainerReminderTile(reminder: reminder),
          ),
      ],
    );
  }
}

class _TrainerReminderTile extends StatelessWidget {
  final NextHealthReminder reminder;

  const _TrainerReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TuniCard(
        onTap: () => openPage(context, HorseHealthPage(horse: reminder.horse)),
        child: Row(
          children: [
            HorsePhoto(horse: reminder.horse, size: 48),
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
            StatusPill(_formatDate(reminder.reminderDate)),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
