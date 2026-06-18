import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Renders a beautiful empty state when the user has not saved any vocabulary items.
class EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyState({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Graphic Illustration Container
            Center(
              child: SizedBox(
                height: 180,
                width: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ring 1 (Farthest Back)
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Ring 2
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Floating Book Icon
                    Positioned(
                      top: 42,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppTheme.borderLight,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.06,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    // Pencil Circle
                    Positioned(
                      right: 24,
                      bottom: 30,
                      child: Transform.rotate(
                        angle: 0.18,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Main Header Text
            Text(
              "You haven't saved any words yet.",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Supporting Text
            Text(
              "Build your personal dictionary by adding new vocabulary words manually or import recommendations.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMuted,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),

            // Primary Call To Action button
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text("Add Your First Word"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
