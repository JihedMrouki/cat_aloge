import 'package:cat_aloge/core/theme/app_colors.dart';
import 'package:cat_aloge/core/theme/text_styles.dart';
import 'package:cat_aloge/features/permissions/domain/entities/permission_state.dart';
import 'package:cat_aloge/features/permissions/views/providers/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PhotoPermissionScreen extends ConsumerWidget {
  static const String routeName = '/permission';

  const PhotoPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionAsync = ref.watch(photoPermissionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: permissionAsync.when(
          loading: () => const _LoadingView(),
          error: (error, stack) => _ErrorView(
            error: error.toString(),
            onRetry: () =>
                ref.read(photoPermissionProvider.notifier).recheckPermission(),
          ),
          data: (permissionState) {
            if (permissionState.isGranted) {
              // Permission granted - navigate to main gallery
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go('/gallery?isFirstScan=true');
              });
              return const _PermissionGrantedView();
            }

            return _PermissionRequestView(
              permissionState: permissionState,
              onRequestPermission: () => ref
                  .read(photoPermissionProvider.notifier)
                  .requestPermission(),
              onOpenSettings: () =>
                  ref.read(photoPermissionProvider.notifier).openSettings(),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Checking photo permissions...',
            style: AppTextStyles.captionText,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Permission Error',
              style: AppTextStyles.captionText.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionText.copyWith(
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionGrantedView extends StatelessWidget {
  const _PermissionGrantedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          Text('Permission Granted!', style: AppTextStyles.captionText),
          const SizedBox(height: 8),
          Text('Loading your cat photos...', style: AppTextStyles.captionText),
        ],
      ),
    );
  }
}

class _PermissionRequestView extends StatelessWidget {
  final PermissionState permissionState;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSettings;

  const _PermissionRequestView({
    required this.permissionState,
    required this.onRequestPermission,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cat illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(Icons.pets, size: 64, color: AppColors.primary),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            _getTitle(),
            style: AppTextStyles.captionText,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            permissionState.message,
            style: AppTextStyles.captionText.copyWith(
              color: AppColors.gray900,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),
          Text(
            '(You may be asked to select specific photos or allow access to your entire library.)',
            style: AppTextStyles.captionText.copyWith(
              color: AppColors.gray500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Feature benefits
          _buildFeatureBenefits(),

          const SizedBox(height: 32),

          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (permissionState.status) {
      case PhotoPermissionStatus.notRequested:
        return 'Find Your Cat Photos';
      case PhotoPermissionStatus.denied:
        return 'Photo Access Needed';
      case PhotoPermissionStatus.permanentlyDenied:
        return 'Enable Photo Access';
      case PhotoPermissionStatus.restricted:
        return 'Photo Access Restricted';
      case PhotoPermissionStatus.granted:
        return 'Permission Granted!';
    }
  }

  Widget _buildFeatureBenefits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withAlpha(51)),
      ),
      child: Column(
        children: [
          _buildBenefitItem(
            icon: Icons.search,
            title: 'Auto Cat Detection',
            description: 'AI finds all your cat photos automatically',
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.favorite,
            title: 'Smart Organization',
            description: 'Keep your favorite cat moments in one place',
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.security,
            title: 'Privacy First',
            description: 'All processing happens on your device',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.captionText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTextStyles.captionText.copyWith(
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (permissionState.isPermanentlyDenied) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please enable photo access in Settings > Privacy & Security > Photos',
            style: AppTextStyles.captionText.copyWith(
              color: AppColors.gray900,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (permissionState.canRequestAgain) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRequestPermission,
              icon: const Icon(Icons.photo_library),
              label: const Text('Grant Photo Access'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _showPermissionInfoDialog(context);
            },
            child: Text(
              'Why do we need this permission?',
              style: AppTextStyles.captionText.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      );
    }

    return Container(); // No action available
  }

  void _showPermissionInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Access Permission'),
        content: const Text(
          'Cat Gallery needs access to your photos to:\n\n'
          '• Scan your photo library for cat pictures\n'
          '• Use AI to automatically detect cats\n'
          '• Let you organize and favorite your cat photos\n\n'
          'Your photos never leave your device. All processing happens locally for maximum privacy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRequestPermission();
            },
            child: const Text('Grant Access'),
          ),
        ],
      ),
    );
  }
}
