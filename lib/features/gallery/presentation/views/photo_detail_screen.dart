import 'dart:io';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_aloge/features/sharing/presentation/providers/sharing_providers.dart';
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
                  actions: [
                    Consumer(builder: (context, ref, child) {
                      final shareCatPhoto = ref.watch(shareCatPhotoProvider);
                      return IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () async {
                          final currentPhoto = photos[initialIndex];
                          if (currentPhoto.detectionResult != null) {
                            try {
                              await shareCatPhoto(
                                photoPath: currentPhoto.path,
                                confidence: currentPhoto.detectionResult!.confidence,
                                additionalText: 'Check out this cat photo from Cat-aloge!',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Photo shared successfully!')),
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to share photo: $e')),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No detection data to share.')),
                            );
                          }
                        },
                      );
                    }),
                  ],
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
      child: Stack( // Changed to Stack to allow overlay
        children: [
          Center(
            child: Hero(
              tag: 'photo_${photo.id}',
              child: Image.file(
                File(photo.path),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey, size: 64),
                  );
                },
              ),
            ),
          ),
          Positioned( // New: Metadata Overlay
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.black54, // Semi-transparent background
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'File Name: ${photo.fileName}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Path: ${photo.path}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Date: ${photo.creationDate.toLocal().toString().split(' ')[0]}', // Format date
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    'Size: ${(photo.fileSize / 1024 / 1024).toStringAsFixed(2)} MB', // Convert bytes to MB
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  if (photo.detectionResult != null)
                    Text(
                      'Cat Confidence: ${(photo.detectionResult!.confidence * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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