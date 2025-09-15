import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class CatGridItem extends ConsumerWidget {
  final CatPhoto photo;
  final VoidCallback? onTap;

  const CatGridItem({super.key, required this.photo, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Photo placeholder (since we don't have real images yet)
            _buildPhotoPlaceholder(context),

            // Favorite overlay
            _buildFavoriteOverlay(ref),

            // Photo info overlay
            _buildInfoOverlay(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(26),
            AppColors.secondary.withAlpha(26),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 40, color: AppColors.primary.withAlpha(153)),
          const SizedBox(height: AppConstants.spacingSM),
          Text('🐱', style: context.textTheme.headlineLarge),
        ],
      ),
    );
  }

  Widget _buildFavoriteOverlay(WidgetRef ref) {
    return Positioned(
      top: AppConstants.spacingSM,
      right: AppConstants.spacingSM,
      child: GestureDetector(
        onTap: () {
          ref.read(galleryProvider.notifier).toggleFavorite(photo.id);
          // Show feedback
          // context.showSnackBar(
          //   photo.isFavorite
          //     ? AppConstants.photoRemoved
          //     : AppConstants.photoSaved,
          // );
        },
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingXS),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(128),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            photo.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: photo.isFavorite ? AppColors.error : AppColors.surface,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoOverlay(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingSM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withAlpha(178)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              photo.fileName,
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (photo.detectionResult != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 12,
                    color: AppColors.surface.withAlpha(204),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(photo.detectionResult!.confidence * 100).toInt()}% cat',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.surface.withAlpha(204),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
