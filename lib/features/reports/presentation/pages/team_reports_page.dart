import 'package:flutter/material.dart';
import 'package:tunihorse/core/data/mock_data.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/reports/presentation/pages/compare_reports_page.dart';
import 'package:tunihorse/features/reports/presentation/pages/report_details_page.dart';

class TeamReportsPage extends StatelessWidget {
  const TeamReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Rapports partagés',
      showBack: true,
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
      ],
      children: [
        ...liveSessions.map(
          (session) => LiveSessionTile(
            session: session,
            onTap: () => openPage(context, ReportDetailsPage(session: session)),
          ),
        ),
        PrimaryButton(
          label: 'Comparer deux séances',
          onPressed: () => openPage(context, const CompareReportsPage()),
        ),
      ],
    );
  }
}
