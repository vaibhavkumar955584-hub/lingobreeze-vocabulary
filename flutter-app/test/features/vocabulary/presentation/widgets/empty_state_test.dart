import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_app/features/vocabulary/presentation/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState displays correctly and handles button tap', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            onAddPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text("You haven't saved any words yet."), findsOneWidget);
    expect(find.text("Add Your First Word"), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);

    await tester.tap(find.text("Add Your First Word"));
    expect(tapped, true);
  });
}
