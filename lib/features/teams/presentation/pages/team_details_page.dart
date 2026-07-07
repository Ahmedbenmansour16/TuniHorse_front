import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/horseshoe_mark.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_selections_page.dart';
import 'package:tunihorse/features/horses/presentation/pages/team_horses_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/team_reports_page.dart';
import 'package:tunihorse/features/teams/data/teams_api_client.dart';
import 'package:tunihorse/features/teams/presentation/pages/invite_rider_page.dart';
import 'package:tunihorse/features/teams/presentation/pages/team_members_page.dart';

class TeamDetailsPage extends StatefulWidget {
  final bool inShell;

  const TeamDetailsPage({super.key, this.inShell = false});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  final _teamsApiClient = TeamsApiClient();
  final _imagePicker = ImagePicker();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  TrainerTeamInfo? _team;
  XFile? _photo;
  Uint8List? _photoBytes;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  @override
  void dispose() {
    _teamsApiClient.close();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadTeam() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final team = await _teamsApiClient.getMyTeam();
      if (!mounted) return;
      setState(() => _team = team);
    } on TeamsApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger votre equipe.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Future<void> _createTeam() async {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      _showError("Nom de l'equipe obligatoire.");
      return;
    }

    if (location.isEmpty) {
      _showError("Localisation de l'ecurie obligatoire.");
      return;
    }

    setState(() => _isSaving = true);

    try {
      final team = await _teamsApiClient.createTeam(
        nom: name,
        ville: location,
        photoPath: _photo?.path,
      );

      if (!mounted) return;
      setState(() {
        _team = team;
        _photo = null;
        _photoBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipe creee avec succes.')),
      );
    } on TeamsApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      _showError("Erreur pendant la creation de l'equipe.");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = _team;
    final title = 'Mon equipe';
    final subtitle = team == null ? 'Creez votre equipe' : team.nom;
    final actions = [
      IconButton(onPressed: _loadTeam, icon: const Icon(Icons.refresh)),
    ];
    final children = [
      if (_isLoading)
        const TuniCard(child: Center(child: CircularProgressIndicator()))
      else if (_error != null)
        _ErrorCard(message: _error!, onRetry: _loadTeam)
      else if (team == null)
        _CreateTeamForm(
          nameController: _nameController,
          locationController: _locationController,
          photoBytes: _photoBytes,
          isSaving: _isSaving,
          onPickPhoto: _pickPhoto,
          onSubmit: _createTeam,
        )
      else
        _TeamContent(team: team),
    ];

    if (!widget.inShell) {
      return AppPage(
        title: title,
        subtitle: subtitle,
        showBack: true,
        actions: actions,
        children: children,
      );
    }

    return ShellPage(
      title: title,
      subtitle: subtitle,
      actions: actions,
      children: children,
    );
  }
}

class _CreateTeamForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController locationController;
  final Uint8List? photoBytes;
  final bool isSaving;
  final VoidCallback onPickPhoto;
  final VoidCallback onSubmit;

  const _CreateTeamForm({
    required this.nameController,
    required this.locationController,
    required this.photoBytes,
    required this.isSaving,
    required this.onPickPhoto,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Creer une equipe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            "Ajoutez les informations de votre ecurie pour commencer.",
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onPickPhoto,
              child: Container(
                width: 148,
                height: 112,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: photoBytes == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HorseshoeMark(size: 42, color: AppColors.green),
                          SizedBox(height: 8),
                          Text(
                            'Choisir image',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      )
                    : Image.memory(photoBytes!, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Nom de l'equipe",
              hintText: 'Ecurie des Pins',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: "Localisation de l'ecurie",
              hintText: 'Sousse, Tunisie',
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: isSaving ? 'Creation...' : "Creer l'equipe",
            icon: Icons.add_business_outlined,
            onPressed: isSaving ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _TeamContent extends StatelessWidget {
  final TrainerTeamInfo team;

  const _TeamContent({required this.team});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TuniCard(
          child: Column(
            children: [
              Row(
                children: [
                  _TeamPhoto(photoUrl: team.photoUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.nom,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          team.ville,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        Text(
                          'Code equipe : ${team.codeInvitation}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InfoLine(
                icon: Icons.location_on_outlined,
                label: 'Localisation',
                value: team.ville,
              ),
              InfoLine(
                icon: Icons.groups_outlined,
                label: 'Cavaliers',
                value: team.cavaliers.length.toString(),
              ),
              InfoLine(
                icon: Icons.key_outlined,
                label: 'Invitation',
                value: team.codeInvitation,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MenuActionTile(
          icon: Icons.groups_outlined,
          title: "Membres de l'equipe",
          onTap: () => openPage(context, const TeamMembersPage()),
        ),
        MenuActionTile(
          icon: Icons.hdr_strong,
          title: "Chevaux de l'equipe",
          onTap: () => openPage(context, const TeamHorsesPage()),
        ),
        MenuActionTile(
          icon: Icons.article_outlined,
          title: 'Rapports partages',
          onTap: () => openPage(context, const TeamReportsPage()),
        ),
        MenuActionTile(
          icon: Icons.emoji_events_outlined,
          title: 'Courses & selections',
          onTap: () => openPage(context, const CourseSelectionsPage()),
        ),
        MenuActionTile(
          icon: Icons.person_add_alt,
          title: 'Inviter un cavalier',
          onTap: () => openPage(context, const InviteRiderPage()),
        ),
      ],
    );
  }
}

class _TeamPhoto extends StatelessWidget {
  final String? photoUrl;

  const _TeamPhoto({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl(photoUrl);

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        color: AppColors.gold.withValues(alpha: 0.14),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? const Center(
              child: HorseshoeMark(size: 42, color: AppColors.green),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: HorseshoeMark(size: 42, color: AppColors.green),
                );
              },
            ),
    );
  }

  String? _resolvedUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '${ApiConstants.baseUrl}$value';
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return TuniCard(
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          SecondaryButton(label: 'Reessayer', onPressed: onRetry),
        ],
      ),
    );
  }
}
