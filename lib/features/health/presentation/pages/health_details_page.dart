import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/health/data/health_api_client.dart';

class HealthDetailsPage extends StatefulWidget {
  final Horse horse;

  const HealthDetailsPage({super.key, required this.horse});

  @override
  State<HealthDetailsPage> createState() => _HealthDetailsPageState();
}

class _HealthDetailsPageState extends State<HealthDetailsPage> {
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

    try {
      final records = await _healthApiClient.getHorseRecords(horseId);
      if (!mounted) return;
      setState(() => _records = records);
    } on HealthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger le detail sante.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Detail sante',
      subtitle: widget.horse.name,
      showBack: true,
      children: [
        TuniCard(
          child: Row(
            children: [
              HorsePhoto(horse: widget.horse),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Etat : Excellent',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      _records.isEmpty
                          ? 'Aucun soin signale'
                          : '${_records.length} soin(s) enregistre(s)',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const StatusPill('A jour'),
            ],
          ),
        ),
        const SectionHeader('Rappels'),
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
        else if (_records.isEmpty)
          const TuniCard(
            child: Text(
              'Aucun rappel enregistre.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        else
          ..._records.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TuniCard(
                child: InfoLine(
                  icon: Icons.notifications_active_outlined,
                  label: record.careTypeLabel,
                  value: _formatDate(record.reminderDate),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
