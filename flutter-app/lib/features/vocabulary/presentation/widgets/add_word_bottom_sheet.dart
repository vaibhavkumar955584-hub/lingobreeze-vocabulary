import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/vocabulary_bloc.dart';
import '../bloc/vocabulary_event.dart';
import '../bloc/vocabulary_state.dart';

/// Modal bottom sheet displaying the 'Add Word' form with validation and keyboard safety.
class AddWordBottomSheet extends StatefulWidget {
  const AddWordBottomSheet({super.key});

  @override
  State<AddWordBottomSheet> createState() => _AddWordBottomSheetState();
}

class _AddWordBottomSheetState extends State<AddWordBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _wordController;
  late final TextEditingController _meaningController;
  late final TextEditingController _translationController;

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController();
    _meaningController = TextEditingController();
    _translationController = TextEditingController();

    // Register text listeners to reactively validate and toggle the Save button state
    _wordController.addListener(_validateForm);
    _meaningController.addListener(_validateForm);
    _translationController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  /// Evaluates fields to toggle form validity status and rebuild the UI.
  void _validateForm() {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    final translation = _translationController.text.trim();

    final isValid = word.isNotEmpty && meaning.isNotEmpty && translation.isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  /// Triggers BLoC event to save the word.
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<VocabularyBloc>().add(
            AddWordEvent(
              word: _wordController.text.trim(),
              meaning: _meaningController.text.trim(),
              translation: _translationController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Bottom padding to push layout above virtual keyboard
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<VocabularyBloc, VocabularyState>(
      listenWhen: (previous, current) =>
          current is VocabularyAddSuccess || current is VocabularyAddFailure,
      listener: (context, state) {
        if (state is VocabularyAddSuccess) {
          // Close the bottom sheet on success
          Navigator.of(context).pop();
        } else if (state is VocabularyAddFailure) {
          // Show database failure alert
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 8,
          bottom: 24 + keyboardPadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                "Add Word",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Word field
                    TextFormField(
                      controller: _wordController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: "Word",
                        hintText: "Enter the vocabulary word (e.g. Apple)",
                        prefixIcon: Icon(Icons.abc_rounded, color: AppTheme.textMuted),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Word is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Meaning field
                    TextFormField(
                      controller: _meaningController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      minLines: 1,
                      decoration: const InputDecoration(
                        labelText: "Meaning",
                        hintText: "Enter the definition/meaning (e.g. A fruit)",
                        prefixIcon: Icon(Icons.info_outline_rounded, color: AppTheme.textMuted),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Meaning is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Translation field
                    TextFormField(
                      controller: _translationController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: "Translation",
                        hintText: "Enter translation (e.g. Manzana)",
                        prefixIcon: Icon(Icons.g_translate_rounded, color: AppTheme.textMuted),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Translation is required";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Buttons Section
              BlocBuilder<VocabularyBloc, VocabularyState>(
                builder: (context, state) {
                  final isAdding = state is VocabularyAddingWord;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Cancel Button
                      TextButton(
                        onPressed: isAdding ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          foregroundColor: AppTheme.textMuted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Save Button
                      ElevatedButton(
                        onPressed: (_isFormValid && !isAdding) ? _submitForm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.borderLight,
                          disabledForegroundColor: AppTheme.textMuted,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isAdding
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "Save Word",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
