import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunihorse/core/widgets/horseshoe_mark.dart';
import 'package:tunihorse/main.dart';

void main() {
  testWidgets('shows TuniHorse splash screen', (tester) async {
    await tester.pumpWidget(const TuniHorseApp());

    expect(find.text('TuniHorse'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.byType(HorseshoeMark), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsNothing);
  });
}
