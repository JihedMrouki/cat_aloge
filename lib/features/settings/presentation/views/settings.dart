import 'package:cat_aloge/core/theme/app_colors.dart';
import 'package:cat_aloge/core/theme/text_styles.dart';
import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart';
import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart'
    as app_entities;
import 'package:cat_aloge/features/settings/presentation/providers/settings_providers.dart';
import 'package:cat_aloge/features/settings/presentation/views/widgets/detection_stats_card.dart';
import 'package:cat_aloge/features/settings/presentation/views/widgets/drop_down_tile.dart';
import 'package:cat_aloge/features/settings/presentation/views/widgets/section_settings_widget.dart';
import 'package:cat_aloge/features/settings/presentation/views/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that returns an AsyncValue
    final settingsAsync =
        ref.watch(settingsProvider); // Assuming this is your async provider

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Settings', style: AppTextStyles.captionText),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            // In a real app, ref.refresh invalidates the provider to refetch.
            onPressed: () => ref.refresh(settingsProvider),
            tooltip: 'Refresh Settings',
          ),
        ],
      ),
      // --- FIX #1: Use .when() to handle the async states ---
      body: settingsAsync.when(
        // 1. Loading State
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        // 2. Error State
        error: (error, stackTrace) => ErrorWidget(
          error,
        ),
        // 3. Data State
        data: (settings) => _SettingsContent(settings: settings),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  final AppSettings settings;

  const _SettingsContent({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DetectionStatsCard(),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Cat Detection',
            icon: Icons.pets,
            children: [
              SettingTile.slider(
                title: 'Detection Sensitivity',
                subtitle:
                    'Higher sensitivity finds more cats but may include false positives',
                value: settings.detectionSensitivity,
                min: 0.3,
                max: 0.95,
                divisions: 13,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateDetectionSensitivity(value),
                valueFormatter: (value) => '${(value * 100).round()}%',
              ),
              DropdownSettingTile<DetectionMode>(
                // Corrected
                title: 'Detection Mode',
                subtitle: 'Balance between speed and accuracy',
                value: settings.detectionMode,
                items: const [
                  DropdownMenuItem(
                      value: DetectionMode.fast,
                      child: Text('Fast (Lower accuracy)')),
                  DropdownMenuItem(
                      value: DetectionMode.balanced,
                      child: Text('Balanced (Recommended)')),
                  DropdownMenuItem(
                      value: DetectionMode.accurate,
                      child: Text('Accurate (Slower)')),
                ],
                onChanged: (DetectionMode? mode) {
                  if (mode != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateDetectionMode(mode);
                  }
                },
              ),
              SettingTile.number(
                title: 'Max Photos to Process',
                subtitle: 'Limit processing for better performance',
                value: settings.maxPhotosToProcess,
                min: 100,
                max: 5000,
                step: 100,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateMaxPhotosToProcess(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsSection(
            title: 'Display',
            icon: Icons.display_settings,
            children: [
              // --- FIX: Explicitly use your app's ThemeMode enum ---
              SettingsSection(
                title: 'Display',
                icon: Icons.display_settings,
                children: [
                  // --- THIS IS THE CORRECT AND FINAL FIX ---
                  DropdownSettingTile(
                    // Use the prefixed type
                    title: 'Theme',
                    subtitle: 'Choose your preferred app theme',
                    value: settings
                        .themeMode, // This is already your custom ThemeMode type
                    items: const [
                      // All values must now use the prefix to match the Dropdown's type
                      DropdownMenuItem(
                        value: app_entities.ThemeMode.system,
                        child: Text('Follow System'),
                      ),
                      DropdownMenuItem(
                        value: app_entities.ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: app_entities.ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (app_entities.ThemeMode? mode) {
                      // The type here is now unambiguous
                      if (mode != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateThemeMode(mode);
                      }
                    },
                  ),

                  SettingTile.switchTile(
                    title: 'Show Confidence Scores',
                    subtitle: 'Display AI confidence on cat photos',
                    value: settings.showConfidenceScores,
                    onChanged: (value) => ref
                        .read(settingsProvider.notifier)
                        .updateShowConfidenceScores(value),
                  ),
                  SettingTile.switchTile(
                    title: 'Haptic Feedback',
                    subtitle: 'Vibrate on interactions',
                    value: settings.enableHapticFeedback,
                    onChanged: (value) => ref
                        .read(settingsProvider.notifier)
                        .updateHapticFeedback(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildActionSection(context, ref),
              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showResetDialog(context, ref),
            icon: const Icon(Icons.restore),
            label: const Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showClearCacheDialog(context, ref),
            icon: const Icon(Icons.cleaning_services),
            label: const Text('Clear Photo Cache'),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(settingsProvider.notifier).resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Photo Cache'),
        content: const Text('This will clear the cached cat photo results.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(settingsProvider.notifier).clearCache();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Photo cache cleared'),
                  backgroundColor: AppColors.success));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
