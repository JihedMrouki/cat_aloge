import 'dart:io';
import 'package:cat_aloge/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Assuming you use go_router
import '../../domain/entities/cat_photo.dart';

class MyCatsScreen extends ConsumerWidget {
  const MyCatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(ref, context),
      body: _buildBody(ref, context),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(WidgetRef ref, BuildContext context) {
    final photoCount = ref.watch(photoCountProvider);
    final isLoading = ref.watch(galleryProvider).isLoading;

    return AppBar(
      elevation: 0,
      title: const Text(
        'My Cats',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        if (photoCount > 0)
          Center(
            child: Text(
              '$photoCount photos',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      ref.read(galleryProvider.notifier).refreshPhotos(),
                ),
        ),
      ],
    );
  }

  Widget _buildBody(WidgetRef ref, BuildContext context) {
    final asyncPhotos = ref.watch(galleryProvider);

    return asyncPhotos.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (photos) {
        if (photos.isEmpty) {
          return const Center(child: Text('No cat photos found.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(galleryProvider.notifier).refreshPhotos(),
          child: _PhotoGridView(
            photos: photos,
            onPhotoTap: (photo) {
              // Navigate to detail screen
              context.push('/photo/${photo.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    );
  }
}

class _PhotoGridView extends ConsumerWidget {
  final List<CatPhoto> photos;
  final Function(CatPhoto)? onPhotoTap;

  const _PhotoGridView({required this.photos, this.onPhotoTap});

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
        return _CatPhotoItem(
          photo: photo,
          onTap: onPhotoTap != null ? () => onPhotoTap!(photo) : null,
        );
      },
    );
  }
}

class _CatPhotoItem extends ConsumerWidget {
  final CatPhoto photo;
  final VoidCallback? onTap;

  const _CatPhotoItem({required this.photo, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = File(photo.path);

    return Hero(
      tag: 'photo_${photo.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                imageFile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => ref
                      .read(galleryProvider.notifier)
                      .toggleFavorite(photo.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(153),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      photo.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: photo.isFavorite ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(204),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.fileName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(photo.detectionResult?.confidence ?? 0.0 * 100).toInt()}% cat',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
