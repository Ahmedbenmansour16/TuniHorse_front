import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/health/data/health_api_client.dart';
import 'package:tunihorse/features/health/presentation/pages/add_health_record_page.dart';
import 'package:tunihorse/features/health/presentation/pages/health_details_page.dart';
import 'package:tunihorse/features/health/presentation/pages/medical_history_page.dart';

class HorseHealthPage extends StatefulWidget {
  final Horse horse;

  const HorseHealthPage({super.key, required this.horse});

  @override
  State<HorseHealthPage> createState() => _HorseHealthPageState();
}

class _HorseHealthPageState extends State<HorseHealthPage> {
  final _healthApiClient = HealthApiClient();

  bool _isLoading = true;
  String? _error;
  List<HealthRecordItem> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _healthApiClient.close();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    final horseId = widget.horse.id;

    if (horseId == null || horseId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Cheval non synchronise avec la base.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final records = await _healthApiClient.getHorseRecords(horseId);
      if (!mounted) return;
      setState(() => _records = records);
    } on HealthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger la sante.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openAddRecord() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddHealthRecordPage(horse: widget.horse),
      ),
    );

    if (created == true) {
      await _loadRecords();
    }
  }

  List<HealthRecordItem> get _upcomingRecords {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    return _records
        .where((record) => !record.reminderDate.isBefore(startOfToday))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Sante - ${widget.horse.name}',
      showBack: true,
      children: [
        TuniCard(
          onTap: () =>
              openPage(context, HealthDetailsPage(horse: widget.horse)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Etat de sante',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Excellent',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: _error == null
                        ? AppColors.green
                        : AppColors.danger,
                    child: Icon(
                      _error == null ? Icons.check : Icons.warning_amber,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _records.isEmpty
                    ? 'Aucun soin ajoute'
                    : '${_records.length} soin(s) enregistre(s)',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SectionHeader('Rappels a venir'),
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                SecondaryButton(label: 'Reessayer', onPressed: _loadRecords),
              ],
            ),
          )
        else if (_upcomingRecords.isEmpty)
          const TuniCard(
            child: Text(
              'Aucun rappel a venir.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        else
          TuniCard(
            child: Column(
              children: _upcomingRecords
                  .map((record) => _HealthReminderLine(record: record))
                  .toList(),
            ),
          ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: 'Ajouter un soin / rappel',
          onPressed: _openAddRecord,
        ),
        const SizedBox(height: 10),
        MenuActionTile(
          icon: Icons.history,
          title: 'Historique medical',
          onTap: () =>
              openPage(context, MedicalHistoryPage(horse: widget.horse)),
        ),
      ],
    );
  }
}

class _HealthReminderLine extends StatelessWidget {
  final HealthRecordItem record;

  const _HealthReminderLine({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.careTypeLabel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  'Rappel le ${_formatDate(record.reminderDate)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
