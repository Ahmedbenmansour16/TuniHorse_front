import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/health/data/health_api_client.dart';

class MedicalHistoryPage extends StatefulWidget {
  final Horse horse;

  const MedicalHistoryPage({super.key, required this.horse});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage> {
  final _healthApiClient = HealthApiClient();

  bool _isLoading = true;
  String? _error;
  List<HealthRecordItem> _records = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _healthApiClient.close();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final horseId = widget.horse.id;

    if (horseId == null || horseId.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Cheval non synchronise avec la base.';
      });
      return;
    }

    try {
      final records = await _healthApiClient.getHorseHistory(horseId);
      if (!mounted) return;
      setState(() => _records = records);
    } on HealthApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger l historique.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Historique medical',
      subtitle: widget.horse.name,
      showBack: true,
      children: [
        if (_isLoading)
          const TuniCard(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          TuniCard(
            child: Column(
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                SecondaryButton(label: 'Reessayer', onPressed: _loadHistory),
              ],
            ),
          )
        else if (_records.isEmpty)
          const TuniCard(
            child: Text(
              'Aucun soin dans l historique.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          )
        else
          ..._records.map((record) => _HistoryTile(record: record)),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HealthRecordItem record;

  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TuniCard(
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.greenSoft,
              child: Icon(Icons.check, color: AppColors.green),
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
                    'Soin le ${_formatDate(record.dateSoin)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Rappel le ${_formatDate(record.reminderDate)}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const StatusPill('Effectue'),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
