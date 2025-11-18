import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pariba/main.dart';

void main() {
  testWidgets('PariBa app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PariBaApp(showOnboarding: false));

    // Verify that the app title is displayed
    expect(find.text('PariBa'), findsWidgets);
    
    // Verify that the welcome message is displayed
    expect(find.text('Bienvenue sur PariBa'), findsOneWidget);
    
    // Verify that the start button is displayed
    expect(find.text('Commencer'), findsOneWidget);
    
    // Tap the start button
    await tester.tap(find.text('Commencer'));
    await tester.pump();
    
    // Verify that a snackbar is shown
    expect(find.text('Fonctionnalité en cours de développement'), findsOneWidget);
  });
}
