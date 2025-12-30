import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/storage/hive_app_settings.dart';

/// Full-screen onboarding screen shown only on first app launch.
/// Allows user to choose between starting with sample data or an empty app.
class OnboardingScreen extends StatelessWidget {
  /// Hive box for persisting onboarding completion status.
  final Box<HiveAppSettings> settingsBox;

  /// Callback when user chooses to add sample data
  final VoidCallback? onAddSampleData;

  /// Callback when user chooses to start empty
  final VoidCallback? onStartEmpty;

  const OnboardingScreen({
    super.key,
    required this.settingsBox,
    this.onAddSampleData,
    this.onStartEmpty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 48.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─────────────────────────────────────────────────────
                      // APP IDENTITY SECTION
                      // ─────────────────────────────────────────────────────
                      _buildAppIdentitySection(theme, colorScheme),

                      const SizedBox(height: 48),

                      // ─────────────────────────────────────────────────────
                      // EXPLANATION SECTION
                      // ─────────────────────────────────────────────────────
                      _buildExplanationSection(theme),

                      const SizedBox(height: 40),

                      // ─────────────────────────────────────────────────────
                      // MAIN QUESTION SECTION
                      // ─────────────────────────────────────────────────────
                      _buildQuestionSection(theme),

                      const SizedBox(height: 32),

                      // ─────────────────────────────────────────────────────
                      // ACTION BUTTONS SECTION
                      // ─────────────────────────────────────────────────────
                      _buildActionButtonsSection(theme, colorScheme),

                      const SizedBox(height: 24),

                      // ─────────────────────────────────────────────────────
                      // FOOTNOTE SECTION
                      // ─────────────────────────────────────────────────────
                      _buildFootnoteSection(theme),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the app identity section with icon, name, and tagline
  Widget _buildAppIdentitySection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // App Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            size: 44,
            color: colorScheme.onPrimaryContainer,
          ),
        ),

        const SizedBox(height: 20),

        // App Name
        Text(
          'Grocery Ledger',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Tagline
        Text(
          'Track your monthly grocery spending',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the explanation section describing the app and sample data
  Widget _buildExplanationSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'This app helps you manage grocery lists and track your spending. '
        'To help you get started, we can add some sample items so you can '
        'see how everything works.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the main question section
  Widget _buildQuestionSection(ThemeData theme) {
    return Text(
      'Would you like sample data to get started?',
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the action buttons (primary and secondary)
  Widget _buildActionButtonsSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primary Button - Add Sample Data
        FilledButton(
          onPressed: onAddSampleData,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Yes, add sample data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimary,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Button - Start Empty
        OutlinedButton(
          onPressed: onStartEmpty,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            side: BorderSide(
              color: colorScheme.outline,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'No, start empty',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the reassuring footnote section
  Widget _buildFootnoteSection(ThemeData theme) {
    return Text(
      'You can remove or change everything later.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
      ),
      textAlign: TextAlign.center,
    );
  }
}
