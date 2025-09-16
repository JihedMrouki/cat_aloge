import 'package:cat_aloge/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:cat_aloge/features/gallery/presentation/widgets/photo_grid_shimmer.dart';
import 'package:cat_aloge/features/gallery/presentation/widgets/photo_grid_view.dart'; // New import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
 

class MyCatsScreen extends ConsumerWidget {
  final String? isFirstScan;

  const MyCatsScreen({super.key, this.isFirstScan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(ref, context),
      body: _buildBody(ref, context),
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
      loading: () {
        final bool firstScan = isFirstScan == 'true';
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                firstScan
                    ? 'Scanning for cats in your accessible photos...'
                    : 'Refreshing gallery...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Expanded(
              child: PhotoGridShimmer(),
            ),
          ],
        );
      },
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (photos) {
        if (photos.isEmpty) {
          return const Center(child: Text('No cat photos found.'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(galleryProvider.notifier).refreshPhotos(),
          child: PhotoGridView( // Using the new public widget
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
}
