import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/reports/data/workouts_api_client.dart';

class AddTrainerCommentPage extends StatefulWidget {
  final LiveSession session;

  const AddTrainerCommentPage({super.key, required this.session});

  @override
  State<AddTrainerCommentPage> createState() => _AddTrainerCommentPageState();
}

class _AddTrainerCommentPageState extends State<AddTrainerCommentPage> {
  final _workoutsApiClient = WorkoutsApiClient();
  final _pointsFortsController = TextEditingController();
  final _pointsAmeliorerController = TextEditingController();
  final _commentController = TextEditingController();

  int _note = 4;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final comment = widget.session.coachComment;
    _note = comment?.note ?? 4;
    _pointsFortsController.text = comment?.pointsForts ?? '';
    _pointsAmeliorerController.text = comment?.pointsAmeliorer ?? '';
    _commentController.text = comment?.commentaire ?? '';
  }

  @override
  void dispose() {
    _workoutsApiClient.close();
    _pointsFortsController.dispose();
    _pointsAmeliorerController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_commentController.text.trim().isEmpty) {
      _showError('Le commentaire est obligatoire.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updated = await _workoutsApiClient.updateCoachComment(
        session: widget.session,
        note: _note,
        pointsForts: _pointsFortsController.text.trim(),
        pointsAmeliorer: _pointsAmeliorerController.text.trim(),
        commentaire: _commentController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire coach enregistre.')),
      );
      Navigator.of(context).pop(updated);
    } on WorkoutsApiException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Impossible d enregistrer le commentaire coach.');
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
    final session = widget.session;

    return AppPage(
      title: 'Commentaire coach',
      showBack: true,
      children: [
        TuniCard(
          child: Row(
            children: [
              HorsePhoto(horse: session.horse),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.horse.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${session.distance} - ${session.duration}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionHeader('Note generale'),
        Row(
          children: List.generate(
            5,
            (index) => IconButton(
              onPressed: () => setState(() => _note = index + 1),
              icon: Icon(
                index < _note ? Icons.star : Icons.star_border,
                color: AppColors.gold,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _pointsFortsController,
          decoration: const InputDecoration(
            labelText: 'Points forts',
            hintText: 'Bonne regularite au trot.',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pointsAmeliorerController,
          decoration: const InputDecoration(
            labelText: 'Points a ameliorer',
            hintText: 'Travailler la recuperation apres le galop.',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          minLines: 4,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Commentaire'),
        ),
        const SizedBox(height: 22),
        PrimaryButton(
          label: _isSaving ? 'Enregistrement...' : 'Enregistrer',
          icon: Icons.save_outlined,
          onPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }
}
