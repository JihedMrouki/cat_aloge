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

// lib/features/gallery/presentation/views/my_cat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/gallery_providers.dart';
import '../../domain/entities/cat_photo.dart';

class MyCatsScreen extends ConsumerStatefulWidget {
  const MyCatsScreen({super.key});

  @override
  ConsumerState<MyCatsScreen> createState() => _MyCatsScreenState();
}

class _MyCatsScreenState extends ConsumerState<MyCatsScreen> {
  @override
  void initState() {
    super.initState();
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'photos',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(fontSize: 9),
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'favorites',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    final asyncPhotos = ref.watch(galleryProvider);

    return asyncPhotos.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your cat photos...'),
          ],
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Oops! Something went wrong'),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(galleryProvider.notifier).loadPhotos();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
      data: (photos) {
        if (photos.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(galleryProvider.notifier).refreshPhotos(),
          child: _PhotoGridView(photos: photos),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 80, color: Colors.purple),
            const SizedBox(height: 16),
            Text(
              'Welcome to Cat Gallery!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your cat photos will appear here',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(galleryProvider.notifier).loadPhotos();
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Load Cat Photos'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGridView extends ConsumerWidget {
  final List<CatPhoto> photos;

  const _PhotoGridView({required this.photos});

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
        return _CatPhotoItem(photo: photo);
      },
    );
  }
}

class _CatPhotoItem extends ConsumerWidget {
  final CatPhoto photo;

  const _CatPhotoItem({required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // Photo
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pets, size: 40, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      '🐱',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Favorite button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                ref.read(galleryProvider.notifier).toggleFavorite(photo.id);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
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

          // Info overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    photo.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        size: 10,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(photo.confidence * 100).toInt()}% cat',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
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
    );
  }
}
