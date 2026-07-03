import 'package:flutter/material.dart';
import 'package:tunihorse/core/theme/app_theme.dart';
import 'package:tunihorse/features/auth/presentation/pages/splash_page.dart';

void main() {
  runApp(const TuniHorseApp());
}

class TuniHorseApp extends StatelessWidget {
  const TuniHorseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TuniHorse',
      theme: AppTheme.light(),
      home: const SplashPage(),
    );
  }
}
