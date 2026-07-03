import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/horses/data/horses_api_client.dart';
import 'package:tunihorse/features/horses/presentation/pages/add_horse_page.dart';
import 'package:tunihorse/features/horses/presentation/pages/horse_details_page.dart';

class RiderHorsesPage extends StatefulWidget {
  final bool inShell;

  const RiderHorsesPage({super.key, this.inShell = false});

  @override
  State<RiderHorsesPage> createState() => _RiderHorsesPageState();
}

class _RiderHorsesPageState extends State<RiderHorsesPage> {
  final _horsesApiClient = HorsesApiClient();

  bool _isLoading = true;
  String? _error;
  List<Horse> _horses = [];

  @override
  void initState() {
    super.initState();
    _loadHorses();
  }

  @override
  void dispose() {
    _horsesApiClient.close();
    super.dispose();
  }

  Future<void> _loadHorses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _horsesApiClient.getMyHorses();

      if (!mounted) return;
      setState(() {
        _horses = response.asMap().entries.map((entry) {
          return _horseFromJson(entry.value, entry.key);
        }).toList();
      });
    } on HorsesApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les chevaux.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Horse _horseFromJson(Map<String, dynamic> json, int index) {
    final age = json['age'];
    final colors = [
      const Color(0xFF8B4B24),
      const Color(0xFF8F9182),
      const Color(0xFF3E2518),
      const Color(0xFFD8D0C4),
    ];

    final photoUrl = json['photoUrl']?.toString();

    return Horse(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['nom']?.toString() ?? 'Cheval',
      race: json['race']?.toString() ?? 'Race non precisee',
      age: age == null ? 'Age non precise' : '$age ans',
      owner: 'Moi',
      status: 'Actif',
      color: colors[index % colors.length],
      photoUrl: photoUrl == null || photoUrl.isEmpty
          ? null
          : photoUrl.startsWith('http')
          ? photoUrl
          : '${ApiConstants.baseUrl}$photoUrl',
    );
  }

  Future<void> _openAddHorse() async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const AddHorsePage()));

    if (created == true) {
      await _loadHorses();
    }
  }

  List<Widget> _buildChildren() {
    if (_isLoading) {
      return const [
        TuniCard(child: Center(child: CircularProgressIndicator())),
      ];
    }

    if (_error != null) {
      return [
        TuniCard(
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: AppColors.danger),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              SecondaryButton(label: 'Reessayer', onPressed: _loadHorses),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _AddHorseTile(onTap: _openAddHorse),
      ];
    }

    return [
      if (_horses.isEmpty)
        const TuniCard(
          child: Text(
            'Aucun cheval ajoute pour le moment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ..._horses.map(
        (horse) => HorseListTile(
          horse: horse,
          onTap: () => openPage(context, HorseDetailsPage(horse: horse)),
        ),
      ),
      const SizedBox(height: 2),
      _AddHorseTile(onTap: _openAddHorse),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final children = _buildChildren();

    if (widget.inShell) {
      return ShellPage(
        title: 'Mes chevaux',
        subtitle: 'Chevaux du cavalier',
        actions: [
          IconButton(onPressed: _openAddHorse, icon: const Icon(Icons.add)),
        ],
        children: children,
      );
    }

    return AppPage(
      title: 'Mes chevaux',
      showBack: true,
      actions: [
        IconButton(onPressed: _openAddHorse, icon: const Icon(Icons.add)),
      ],
      children: children,
    );
  }
}

class _AddHorseTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddHorseTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      onTap: onTap,
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.greenSoft,
            child: Icon(Icons.add, color: AppColors.green),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouter un cheval',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  'Enregistrer un nouveau cheval',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
