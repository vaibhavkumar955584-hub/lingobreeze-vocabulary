import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabulary_app/features/vocabulary/presentation/pages/my_vocabulary_page.dart';
import 'package:vocabulary_app/features/vocabulary/presentation/bloc/vocabulary_bloc.dart';
import 'package:vocabulary_app/features/vocabulary/presentation/bloc/vocabulary_event.dart';
import 'package:vocabulary_app/features/vocabulary/presentation/bloc/vocabulary_state.dart';

class MockVocabularyBloc extends MockBloc<VocabularyEvent, VocabularyState>
    implements VocabularyBloc {}

void main() {
  late MockVocabularyBloc mockBloc;

  setUp(() {
    mockBloc = MockVocabularyBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<VocabularyBloc>.value(
        value: mockBloc,
        child: const MyVocabularyPage(),
      ),
    );
  }

  testWidgets('renders empty state UI elements when state is VocabularyEmpty',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockBloc.state).thenReturn(const VocabularyEmpty(apiWords: []));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('LingoBreeze'), findsOneWidget);
    expect(find.text("You haven't saved any words yet."), findsOneWidget);
    expect(find.text('Add Your First Word'), findsOneWidget);
  });
}
