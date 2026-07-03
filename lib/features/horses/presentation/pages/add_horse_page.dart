import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/horseshoe_mark.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/horses/data/horses_api_client.dart';

class AddHorsePage extends StatefulWidget {
  const AddHorsePage({super.key});

  @override
  State<AddHorsePage> createState() => _AddHorsePageState();
}

class _AddHorsePageState extends State<AddHorsePage> {
  final _horsesApiClient = HorsesApiClient();
  final _imagePicker = ImagePicker();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _chipController = TextEditingController();
  final _weightController = TextEditingController();

  List<_HorseRaceOption> _races = [];
  _HorseRaceOption? _selectedRace;
  DateTime? _birthDate;
  XFile? _photo;
  Uint8List? _photoBytes;
  String _sex = 'MALE';
  bool _isLoading = false;
  bool _isLoadingRaces = true;

  int? get _age {
    final birthDate = _birthDate;
    if (birthDate == null) return null;

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    final birthdayThisYear = DateTime(
      today.year,
      birthDate.month,
      birthDate.day,
    );

    if (birthdayThisYear.isAfter(today)) {
      age--;
    }

    return age < 0 ? 0 : age;
  }

  @override
  void initState() {
    super.initState();
    _loadRaces();
  }

  @override
  void dispose() {
    _horsesApiClient.close();
    _nameController.dispose();
    _birthDateController.dispose();
    _chipController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadRaces() async {
    try {
      final response = await _horsesApiClient.getHorseRaces();
      if (!mounted) return;

      setState(() {
        _races = response.map(_HorseRaceOption.fromJson).toList();
        _isLoadingRaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingRaces = false);
      _showError('Impossible de charger les races cheval.');
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    setState(() {
      _photo = picked;
      _photoBytes = bytes;
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 5),
      firstDate: DateTime(1980),
      lastDate: now,
    );

    if (selected == null) return;

    setState(() {
      _birthDate = selected;
      _birthDateController.text = _formatDate(selected);
    });
  }

  Future<void> _saveHorse() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showError('Nom du cheval obligatoire.');
      return;
    }

    if (_birthDate == null) {
      _showError('Date de naissance obligatoire.');
      return;
    }

    if (_selectedRace == null) {
      _showError('Race du cheval obligatoire.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _horsesApiClient.createHorse(
        nom: name,
        raceId: _selectedRace!.id,
        race: _selectedRace!.label,
        age: _age,
        dateNaissance: _toIsoDate(_birthDate!),
        sexe: _sex,
        poidsKg: _parseDouble(_weightController.text),
        numeroPuce: _chipController.text,
        photoPath: _photo?.path,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on HorsesApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Erreur pendant l ajout du cheval.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double? _parseDouble(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    return normalized.isEmpty ? null : double.tryParse(normalized);
  }

  String _formatDate(DateTime date) {
    return '${_two(date.day)}/${_two(date.month)}/${date.year}';
  }

  String _toIsoDate(DateTime date) {
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Ajouter un cheval',
      showBack: true,
      children: [
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(70),
            onTap: _pickPhoto,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.24),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: _photoBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HorseshoeMark(size: 48, color: AppColors.green),
                        SizedBox(height: 8),
                        Text(
                          'Choisir photo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    )
                  : Image.memory(_photoBytes!, fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du cheval',
            hintText: 'Sultan',
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<_HorseRaceOption>(
          value: _selectedRace,
          decoration: InputDecoration(
            labelText: 'Race du cheval',
            hintText: _isLoadingRaces ? 'Chargement...' : 'Selectionner',
          ),
          items: _races
              .map(
                (race) =>
                    DropdownMenuItem(value: race, child: Text(race.label)),
              )
              .toList(),
          onChanged: _isLoadingRaces
              ? null
              : (value) => setState(() => _selectedRace = value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _birthDateController,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Date de naissance',
            hintText: 'JJ/MM/AAAA',
            suffixIcon: Icon(Icons.calendar_month),
          ),
          onTap: _pickBirthDate,
        ),
        const SizedBox(height: 12),
        TuniCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.cake_outlined, color: AppColors.green),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Age calcule automatiquement',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                _age == null ? '--' : '$_age ans',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _sex,
          decoration: const InputDecoration(labelText: 'Sexe'),
          items: const [
            DropdownMenuItem(value: 'MALE', child: Text('Male')),
            DropdownMenuItem(value: 'FEMALE', child: Text('Femelle')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _sex = value);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _chipController,
          decoration: const InputDecoration(
            labelText: 'Numero de puce',
            hintText: 'Optionnel',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Poids (kg)',
            hintText: '420',
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: _isLoading ? 'Enregistrement...' : 'Enregistrer',
          onPressed: _isLoading ? null : _saveHorse,
        ),
      ],
    );
  }
}

class _HorseRaceOption {
  final String id;
  final String code;
  final String label;

  const _HorseRaceOption({
    required this.id,
    required this.code,
    required this.label,
  });

  factory _HorseRaceOption.fromJson(Map<String, dynamic> json) {
    return _HorseRaceOption(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}
