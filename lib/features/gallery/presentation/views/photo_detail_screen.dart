import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_providers.dart';

class PhotoDetailScreen extends ConsumerWidget {
  final String photoId;

  const PhotoDetailScreen({super.key, required this.photoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPhotos = ref.watch(galleryProvider);

    return asyncPhotos.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
        body: Center(child: Text('Error: $error', style: const TextStyle(color: Colors.white))),
      ),
      data: (photos) {
        final initialIndex = photos.indexWhere((p) => p.id == photoId);
        if (initialIndex == -1) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
            body: const Center(
              child: Text('Photo not found.', style: TextStyle(color: Colors.white)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return _PhotoView(photo: photos[index]);
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoView extends StatelessWidget {
  final CatPhoto photo;

  const _PhotoView({required this.photo});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Center(
        child: Hero(
          tag: 'photo_${photo.id}',
          child: Image.asset(
            photo.path,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 64),
              );
            },
          ),
        ),
      ),
    );
  }
}
