import 'package:cat_aloge/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:cat_aloge/features/gallery/presentation/widgets/photo_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFavorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cats'),
      ),
      body: asyncFavorites.when(
        loading: () => const Center(child: CircularProgressIndicator()), // Can use shimmer here too
        error: (err, stack) => Center(child: Text(err.toString())),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child: Text(
                'You have no favorite cats yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return PhotoGridView(
            photos: photos,
            onPhotoTap: (photo) {
              context.push('/photo/${photo.id}');
            },
          );
        },
      ),
    );
  }
}
