import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/health/data/health_api_client.dart';

class AddHealthRecordPage extends StatefulWidget {
  final Horse horse;

  const AddHealthRecordPage({super.key, required this.horse});

  @override
  State<AddHealthRecordPage> createState() => _AddHealthRecordPageState();
}

class _AddHealthRecordPageState extends State<AddHealthRecordPage> {
  final _healthApiClient = HealthApiClient();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();

  List<HealthCareTypeOption> _types = [];
  HealthCareTypeOption? _selectedType;
  DateTime _dateSoin = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingTypes = true;

  DateTime? get _reminderDate {
    final selectedType = _selectedType;
    if (selectedType == null) return null;

    return _dateSoin.add(Duration(days: selectedType.reminderDays));
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_dateSoin);
    _loadTypes();
  }

  @override
  void dispose() {
    _healthApiClient.close();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    try {
      final types = await _healthApiClient.getCareTypes();
      if (!mounted) return;

      setState(() {
        _types = types;
        _isLoadingTypes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingTypes = false);
      _showError('Impossible de charger les types de soin.');
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateSoin,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (selected == null) return;

    setState(() {
      _dateSoin = selected;
      _dateController.text = _formatDate(selected);
    });
  }

  Future<void> _save() async {
    final horseId = widget.horse.id;

    if (horseId == null || horseId.isEmpty) {
      _showError('Cheval non synchronise avec la base.');
      return;
    }

    if (_selectedType == null) {
      _showError('Selectionnez un type de soin.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _healthApiClient.createRecord(
        horseId: horseId,
        careTypeId: _selectedType!.id,
        dateSoin: _dateSoin,
        notes: _notesController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on HealthApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Erreur pendant l ajout du soin.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  String _formatDate(DateTime date) {
    return '${_two(date.day)}/${_two(date.month)}/${date.year}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Ajouter un soin',
      subtitle: widget.horse.name,
      showBack: true,
      children: [
        DropdownButtonFormField<HealthCareTypeOption>(
          value: _selectedType,
          decoration: InputDecoration(
            labelText: 'Type de soin',
            hintText: _isLoadingTypes ? 'Chargement...' : 'Selectionner',
          ),
          items: _types
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(),
          onChanged: _isLoadingTypes
              ? null
              : (value) => setState(() => _selectedType = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _dateController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Date du soin',
            suffixIcon: Icon(Icons.calendar_month),
          ),
          onTap: _pickDate,
        ),
        const SizedBox(height: 12),
        TuniCard(
          color: AppColors.greenSoft,
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
                    const Text(
                      'Date de rappel',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      _selectedType?.reminderLabel ?? 'Choisir un type de soin',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _reminderDate == null ? '--' : _formatDate(_reminderDate!),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          minLines: 3,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Optionnel',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: _isLoading ? 'Enregistrement...' : 'Enregistrer',
          onPressed: _isLoading ? null : _save,
        ),
      ],
    );
  }
}
