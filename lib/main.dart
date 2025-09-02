import 'package:cat_aloge/core/theme/app_theme.dart';
import 'package:cat_aloge/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:cat_aloge/features/gallery/presentation/views/my_cat_screen.dart';
import 'package:cat_aloge/features/gallery/presentation/views/photo_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CatGalleryApp()));
}

class CatGalleryApp extends ConsumerWidget {
  const CatGalleryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch initialization to ensure app is ready
    final initialization = ref.watch(appInitializationProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Cat Gallery',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      builder: (context, child) {
        return initialization.when(
          loading: () => const MaterialApp(
            home: _InitializationScreen(),
            debugShowCheckedModeBanner: false,
          ),
          error: (error, stack) => MaterialApp(
            home: _ErrorScreen(error: error.toString()),
            debugShowCheckedModeBanner: false,
          ),
          data: (_) => child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// Initialization loading screen
class _InitializationScreen extends StatelessWidget {
  const _InitializationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 80, color: Colors.purple),
            SizedBox(height: 24),
            Text(
              'Cat Gallery',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Initializing...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
          ],
        ),
      ),
    );
  }
}

// Error screen for initialization failures
class _ErrorScreen extends StatelessWidget {
  final String error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to start the app:\n$error',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  main();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Router configuration with photo detail navigation
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const MyCatsScreen();
      },
    ),
    GoRoute(
      path: '/photo/:photoId',
      name: 'photo-detail',
      builder: (BuildContext context, GoRouterState state) {
        final photoId = state.pathParameters['photoId']!;
        return PhotoDetailScreen(photoId: photoId);
      },
    ),
    // Future routes can be added here:
    // GoRoute(
    //   path: '/favorites',
    //   name: 'favorites',
    //   builder: (context, state) => const FavoritesScreen(),
    // ),
    // GoRoute(
    //   path: '/settings',
    //   name: 'settings',
    //   builder: (context, state) => const SettingsScreen(),
    // ),
  ],
);
