import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/presentation/widgets/cat_photo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoGridView extends ConsumerWidget {
  final List<CatPhoto> photos;
  final Function(CatPhoto)? onPhotoTap;

  const PhotoGridView({required this.photos, this.onPhotoTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return CatPhotoItem( // Use the new public widget
          photo: photo,
          onTap: onPhotoTap != null ? () => onPhotoTap!(photo) : null,
        );
      },
    );
  }
}