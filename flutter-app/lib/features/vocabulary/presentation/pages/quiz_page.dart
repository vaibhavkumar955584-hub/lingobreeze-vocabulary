import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/vocabulary_word.dart';

class QuizPage extends StatefulWidget {
  final List<VocabularyWord> words;
  const QuizPage({super.key, required this.words});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  int _score = 0;
  bool? _isCorrect;
  late List<VocabularyWord> _quizWords;

  @override
  void initState() {
    super.initState();
    _quizWords = List.from(widget.words)..shuffle();
    _quizWords = _quizWords.take(10).toList();
  }

  void _checkAnswer(String selectedTranslation) {
    if (_isCorrect != null) return;

    final correct = _quizWords[_currentIndex].translation;
    setState(() {
      _isCorrect = (selectedTranslation == correct);
      if (_isCorrect!) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_currentIndex < _quizWords.length - 1) {
        setState(() {
          _currentIndex++;
          _isCorrect = null;
        });
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Complete!"),
        content: Text("Your score: $_score / ${_quizWords.length}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return from QuizPage
            },
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizWords.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Not enough words for a quiz!")),
      );
    }

    final currentWord = _quizWords[_currentIndex];
    final options = _getOptions(currentWord);

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz: ${_currentIndex + 1}/${_quizWords.length}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "How do you say...",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            Text(
              currentWord.word,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ...options.map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: _getButtonColor(opt),
                    foregroundColor: _getButtonTextColor(opt),
                  ),
                  onPressed: () => _checkAnswer(opt),
                  child: Text(
                    opt,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getOptions(VocabularyWord current) {
    final others = widget.words.where((w) => w.id != current.id).toList()
      ..shuffle();
    final wrongOptions = others.take(3).map((w) => w.translation).toList();
    return (wrongOptions..add(current.translation))..shuffle();
  }

  Color _getButtonColor(String opt) {
    if (_isCorrect == null) return Colors.white;
    if (opt == _quizWords[_currentIndex].translation) return Colors.green;
    return (_isCorrect == false) ? Colors.red.shade100 : Colors.white;
  }

  Color _getButtonTextColor(String opt) {
    if (_isCorrect != null && opt == _quizWords[_currentIndex].translation) {
      return Colors.white;
    }
    return AppTheme.textDark;
  }
}
