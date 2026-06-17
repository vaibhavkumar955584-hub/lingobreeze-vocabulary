import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/vocabulary/presentation/bloc/vocabulary_bloc.dart';
import 'features/vocabulary/presentation/pages/my_vocabulary_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Database (Hive)
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('vocabulary_cache');

  bool useMockFirebase = false;

  try {
    // Attempt real Firebase initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase successfully initialized.");
  } catch (e) {
    // Graceful fallback to Mock mode if configuration files are invalid/missing
    useMockFirebase = true;
    debugPrint("==================================================================");
    debugPrint(" WARNING: Firebase could not be initialized.");
    debugPrint(" Falling back to LOCAL IN-MEMORY mock Firestore implementation.");
    debugPrint(" Reason: $e");
    debugPrint(" To use real Firestore, configure a project in Firebase Console.");
    debugPrint("==================================================================");
  }

  // Set up dependency injection container
  await di.init(useMockFirebase: useMockFirebase);

  runApp(const LingoBreezeApp());
}

class LingoBreezeApp extends StatelessWidget {
  const LingoBreezeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VocabularyBloc>(
      create: (_) => di.sl<VocabularyBloc>(),
      child: MaterialApp(
        title: 'LingoBreeze - My Vocabulary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MyVocabularyPage(),
      ),
    );
  }
}
