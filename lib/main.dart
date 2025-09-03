import 'package:cat_aloge/core/constants/hive_boxes.dart';
import 'package:cat_aloge/features/gallery/presentation/views/my_cat_screen.dart';
import 'package:cat_aloge/features/gallery/presentation/views/photo_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

final appInitializationProvider = FutureProvider<void>((ref) async {
  try {
    // Step 1: Initialize Hive for Flutter.
    await Hive.initFlutter();

    // Step 2: Open essential Hive boxes needed by the app.
    await Hive.openBox(HiveBoxes.settings);
    await Hive.openBox(HiveBoxes.detectionStats);

    // Add any other async initialization tasks here.
  } catch (e) {
    // If any part of initialization fails, throw an error.
    // The FutureProvider will catch this and enter an AsyncError state.
    debugPrint("FATAL: Error during app initialization: $e");
    rethrow;
  }
});

// =========================================================================
// APP ENTRY POINT
// =========================================================================

void main() async {
  // Ensure Flutter bindings are ready before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  // Wrap the entire app in a ProviderScope to enable Riverpod.
  runApp(const ProviderScope(child: CatGalleryApp()));
}

// =========================================================================
// ROOT WIDGET
// =========================================================================

class CatGalleryApp extends ConsumerWidget {
  const CatGalleryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the initialization provider. The app's UI will react to its state.
    final initialization = ref.watch(appInitializationProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Cat Gallery',
      // theme: AppTheme.lightTheme, // You can add your theme data here.
      routerConfig: _router,
      builder: (context, child) {
        // This builder shows the correct screen based on the initialization state.
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

// =========================================================================
// UI HELPERS (Initialization and Error Screens)
// =========================================================================

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
            Text('Cat Gallery',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple)),
            SizedBox(height: 16),
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple)),
          ],
        ),
      ),
    );
  }
}

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
              const Text('Initialization Error',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 16),
              Text('Failed to start the app:\n$error',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// ROUTER CONFIGURATION
// =========================================================================

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
  ],
);
