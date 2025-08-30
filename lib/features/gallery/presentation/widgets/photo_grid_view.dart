import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/gallery_state.dart';
import 'cat_grid_item.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class PhotoGridView extends ConsumerWidget {
  final List<CatPhoto> photos;
  final Function(CatPhoto)? onPhotoTap;
  final bool shrinkWrap;

  const PhotoGridView({
    super.key,
    required this.photos,
    this.onPhotoTap,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (photos.isEmpty) {
      return _buildEmptyState(context);
    }

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: AppConstants.gridAspectRatio,
        crossAxisSpacing: AppConstants.gridSpacing,
        mainAxisSpacing: AppConstants.gridSpacing,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return CatGridItem(
          photo: photo,
          onTap: onPhotoTap != null ? () => onPhotoTap!(photo) : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'No Cat Photos Yet',
              style: context.textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'When you load photos, your cat pictures will appear here.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    if (context.isDesktop) return 4;
    if (context.isTablet) return 3;
    return AppConstants.gridCrossAxisCount; // 2 for mobile
  }
}
