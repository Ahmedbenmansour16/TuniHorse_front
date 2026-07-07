import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';

class TrainerCommentPage extends StatelessWidget {
  final LiveSession? session;

  const TrainerCommentPage({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    final coachComment = session?.coachComment;
    final coachName = coachComment?.coachName ?? 'Coach';

    return AppPage(
      title: 'Commentaire coach',
      showBack: true,
      children: [
        TuniCard(
          child: Row(
            children: [
              _CoachAvatar(name: coachName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coachName,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      'Entraineur',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (session != null) ...[
          const SizedBox(height: 12),
          TuniCard(
            child: Row(
              children: [
                HorsePhoto(horse: session!.horse),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session!.horse.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '${session!.distance} - ${session!.duration}',
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
        ],
        const SectionHeader('Retour de seance'),
        TuniCard(
          child: Text(
            coachComment == null || coachComment.commentaire.trim().isEmpty
                ? 'Aucun commentaire coach pour cette seance.'
                : coachComment.commentaire,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.45),
          ),
        ),
        const SectionHeader('Analyse coach'),
        TuniCard(
          child: Column(
            children: [
              CheckLine(
                coachComment == null || coachComment.pointsForts.trim().isEmpty
                    ? 'Points forts non renseignes'
                    : coachComment.pointsForts,
              ),
              CheckLine(
                coachComment == null ||
                        coachComment.pointsAmeliorer.trim().isEmpty
                    ? 'Points a ameliorer non renseignes'
                    : coachComment.pointsAmeliorer,
              ),
              CheckLine(
                coachComment?.note == null
                    ? 'Note non renseignee'
                    : 'Note coach : ${coachComment!.note}/5',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoachAvatar extends StatelessWidget {
  final String name;

  const _CoachAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .map((part) => part.trim()[0])
        .take(2)
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.greenSoft,
      child: Text(
        initials.isEmpty ? 'C' : initials,
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
