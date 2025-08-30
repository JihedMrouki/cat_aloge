import 'package:cat_aloge/core/constants/app_constants.dart';
import 'package:cat_aloge/core/utils/extensions/context_extensions.dart';
import 'package:cat_aloge/core/utils/logger.dart';
import 'package:cat_aloge/core/widgets/custom_button.dart';
import 'package:cat_aloge/core/widgets/error_widget.dart';
import 'package:cat_aloge/core/widgets/loading_widget.dart';
import 'package:cat_aloge/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:cat_aloge/features/gallery/presentation/widgets/photo_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyCatsScreen extends ConsumerStatefulWidget {
  const MyCatsScreen({super.key});

  @override
  ConsumerState<MyCatsScreen> createState() => _MyCatsScreenState();
}

class _MyCatsScreenState extends ConsumerState<MyCatsScreen> {
  @override
  void initState() {
    super.initState();
    AppLogger.info('MyCats screen initialized');
    // Auto-load photos when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galleryProvider.notifier).loadPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  PreferredSizeWidget _buildAppBar() {
    final photoCount = ref.watch(photoCountProvider);
    final favoriteCount = ref.watch(favoriteCountProvider);

    return AppBar(
      title: const Text('My Cats'),
      actions: [
        // Photo counts
        if (photoCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$photoCount',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'photos',
                    style: context.textTheme.labelSmall?.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ),
          ),

        if (favoriteCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$favoriteCount',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'favorites',
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(galleryProvider.notifier).refreshPhotos();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    final galleryState = ref.watch(galleryProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final hasError = ref.watch(hasErrorProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final photos = ref.watch(photosProvider);

    // Loading state
    if (isLoading && !galleryState.isRefreshing) {
      return const LoadingWidget(message: AppConstants.loadingPhotos);
    }

    // Error state
    if (hasError) {
      return CustomErrorWidget(
        title: 'Oops!',
        message: errorMessage ?? AppConstants.genericError,
        onRetry: () {
          ref.read(galleryProvider.notifier).loadPhotos();
        },
        icon: Icons.pets,
      );
    }

    // Success state
    if (photos.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(galleryProvider.notifier).refreshPhotos(),
        child: PhotoGridView(
          photos: photos,
          onPhotoTap: (photo) {
            context.showSnackBar('Tapped: ${photo.name}');
            AppLogger.info('Photo tapped: ${photo.id}');
          },
        ),
      );
    }

    // Initial/empty state
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome Icon
          const Icon(Icons.pets, size: 80, color: Colors.purple),
          SizedBox(height: context.isMobile ? 16 : 24),

          // Welcome Text
          Text(
            'Welcome to ${AppConstants.appName}!',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingSM),

          Text(
            AppConstants.appDescription,
            style: context.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.spacingXL),

          // Action Buttons
          Column(
            children: [
              CustomButton(
                onPressed: () {
                  ref.read(galleryProvider.notifier).loadPhotos();
                },
                text: 'Load Cat Photos',
                icon: Icons.photo_library,
                isFullWidth: true,
              ),

              const SizedBox(height: AppConstants.spacingMD),

              CustomButton(
                onPressed: () {
                  ref.read(galleryProvider.notifier).simulateError();
                },
                text: 'Test Error State',
                icon: Icons.error,
                variant: ButtonVariant.outlined,
                isFullWidth: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
