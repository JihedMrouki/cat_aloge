import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gallery_providers.dart';

class PhotoDetailScreen extends ConsumerStatefulWidget {
  final String photoId;

  const PhotoDetailScreen({super.key, required this.photoId});

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final photos = ref.read(photosProvider);
    final initialIndex = photos.indexWhere((p) => p.id == widget.photoId);
    _currentIndex = (initialIndex == -1) ? 0 : initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(photosProvider);

    if (photos.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Photo not found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: photos.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return _PhotoView(photo: photos[index]);
            },
          ),
          // Add TopAppBar and BottomControls here, passing currentPhoto
        ],
      ),
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