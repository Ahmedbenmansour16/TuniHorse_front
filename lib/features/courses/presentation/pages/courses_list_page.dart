import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/core/widgets/app_page.dart';
import 'package:tunihorse/core/widgets/ui_components.dart';
import 'package:tunihorse/features/courses/data/courses_api_client.dart';
import 'package:tunihorse/features/courses/presentation/pages/course_details_page.dart';

class CoursesListPage extends StatefulWidget {
  final bool inShell;

  const CoursesListPage({super.key, this.inShell = false});

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  final _coursesApiClient = CoursesApiClient();

  bool _isLoading = true;
  String? _error;
  List<CourseInfo> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _coursesApiClient.close();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _coursesApiClient.getCourses();
      if (!mounted) return;
      setState(() {
        _courses = response.map(_courseFromJson).toList();
      });
    } on CoursesApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible de charger les courses.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  CourseInfo _courseFromJson(Map<String, dynamic> json) {
    final dateCourse = DateTime.tryParse(json['dateCourse']?.toString() ?? '');
    final dateText = json['dateTexte']?.toString();

    return CourseInfo(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      dateCourse: dateCourse,
      name: json['nom']?.toString() ?? 'Course',
      category: json['categorie']?.toString() ?? 'Endurance',
      date: dateText == null || dateText.isEmpty
          ? _formatDate(dateCourse)
          : dateText,
      place: json['lieu']?.toString() ?? '',
      organisation: json['organisation']?.toString() ?? '',
      countdown: _countdown(dateCourse),
      color: AppColors.green,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _countdown(DateTime? date) {
    if (date == null) return '--';
    final today = DateTime.now();
    final days = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(today.year, today.month, today.day)).inDays;

    if (days < 0) return 'Passe';
    if (days == 0) return 'Aujourd hui';
    return 'J-$days';
  }

  List<Widget> _children() {
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
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              SecondaryButton(label: 'Reessayer', onPressed: _loadCourses),
            ],
          ),
        ),
      ];
    }

    if (_courses.isEmpty) {
      return const [
        TuniCard(
          child: Text(
            'Aucune course endurance disponible.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ];
    }

    return _courses
        .map(
          (course) => CourseTile(
            course: course,
            onTap: () => openPage(context, CourseDetailsPage(course: course)),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.inShell) {
      return ShellPage(
        title: 'Toutes les courses',
        subtitle: 'Endurance FTSE',
        children: _children(),
      );
    }

    return AppPage(
      title: 'Toutes les courses',
      showBack: true,
      children: _children(),
    );
  }
}
