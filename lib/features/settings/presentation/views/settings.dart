import 'package:cat_aloge/core/theme/app_colors.dart';
import 'package:cat_aloge/core/theme/text_styles.dart';
import 'package:cat_aloge/core/utils/extensions/context_extensions.dart';
import 'package:cat_aloge/features/settings/domain/entities/app_settings.dart' hide ThemeMode;
import 'package:cat_aloge/features/settings/presentation/providers/settings_providers.dart';
import 'package:cat_aloge/features/settings/presentation/views/widgets/detection_stats_card.dart';
import 'package:cat_aloge/features/settings/presentation/views/widgets/section_settings_widget.dart';
import 'package:cat_aloge/features/settings/presentation/views/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  static const String routeName = '/settings';
  
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTextStyles.captionText,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () => ref.refresh(settingsProvider),
            tooltip: 'Refresh Settings',
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => _ErrorView(
          error: error.toString(),
          onRetry: () => ref.refresh(settingsProvider),
        ),
        data: (settings) => _SettingsContent(settings: settings),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  
  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Settings Error',
              style: AppTextStyles.captionText.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionText.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
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
          // Detection Statistics Card
          const DetectionStatsCard(),
          
          const SizedBox(height: 24),
          
          // Cat Detection Settings
          SettingsSection(
            title: 'Cat Detection',
            icon: Icons.pets,
            children: [
              SettingTile.slider(
                title: 'Detection Sensitivity',
                subtitle: 'Higher sensitivity finds more cats but may include false positives',
                value: settings.detectionSensitivity,
                min: 0.3,
                max: 0.95,
                divisions: 13,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateDetectionSensitivity(value),
                valueFormatter: (value) => '${(value * 100).round()}%',
              ),
              
              SettingTile.dropdown(
                title: 'Detection Mode',
                subtitle: 'Balance between speed and accuracy',
                value: settings.detectionMode,
                items: const [
                  DropdownMenuItem(
                    value: DetectionMode.fast,
                    child: Text('Fast (Lower accuracy)'),
                  ),
                  DropdownMenuItem(
                    value: DetectionMode.balanced,
                    child: Text('Balanced (Recommended)'),
                  ),
                  DropdownMenuItem(
                    value: DetectionMode.accurate,
                    child: Text('Accurate (Slower)'),
                  ),
                ],
                onChanged: (mode) => ref
                    .read(settingsProvider.notifier)
                    .updateDetectionMode(mode!),
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
          
          // Display Settings
          SettingsSection(
            title: 'Display',
            icon: Icons.display_settings,
            children: [
              SettingTile.dropdown(
                title: 'Theme',
                subtitle: 'Choose your preferred app theme',
                value: settings.themeMode,
                items:  [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Follow System'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
                onChanged: (mode) => ref
                    .read(settingsProvider.notifier)
                    .updateThemeMode(mode),
              ),
              
              SettingTile.switch(
                title: 'Show Confidence Scores',
                subtitle: 'Display AI confidence on cat photos',
                value: settings.showConfidenceScores,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateShowConfidenceScores(value),
              ),
              
              SettingTile.switch(
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on interactions',
                value: settings.enableHapticFeedback,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateHapticFeedback(value),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Performance Settings
          SettingsSection(
            title: 'Performance',
            icon: Icons.speed,
            children: [
              SettingTile.switch(
                title: 'Background Scanning',
                subtitle: 'Automatically scan new photos (uses more battery)',
                value: settings.enableBackgroundScanning,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateBackgroundScanning(value),
              ),
              
              SettingTile.switch(
                title: 'Auto Refresh Gallery',
                subtitle: 'Periodically check for new cat photos',
                value: settings.autoRefreshGallery,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateAutoRefresh(value),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionSection(context, ref),
          
          const SizedBox(height: 32),
          
          // App Info
          _buildAppInfoSection(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildActionSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Reset to Defaults
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton.icon(
            onPressed: () => _showResetDialog(context, ref),
            icon: const Icon(Icons.restore),
            label: const Text('Reset to Defaults'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        
        // Clear Cache
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showClearCacheDialog(context),
            icon: const Icon(Icons.cleaning_services),
            label: const Text('Clear Photo Cache'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cat Gallery',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Version 1.0.0 (Phase 3)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          const Divider(color: AppColors.outline),
          
          const SizedBox(height: 16),
          
          _buildInfoRow('AI Model', 'TensorFlow Lite Cat Detection'),
          const SizedBox(height: 8),
          _buildInfoRow('Privacy', 'All processing on-device'),
          const SizedBox(height: 8),
          _buildInfoRow('Architecture', 'Clean Architecture + Riverpod'),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.captionText.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.captionText,
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
  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(settingsProvider.notifier).resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),);
  }
  
  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Photo Cache'),
        content: const Text(
          'This will clear the cached cat photo results. The app will need to re-scan your photos next time you open the gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo cache cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}}