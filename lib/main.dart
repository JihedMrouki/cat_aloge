import 'package:cat_aloge/core/theme/app_theme.dart';
import 'package:cat_aloge/features/gallery/presentation/views/my_cat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: CatGalleryApp()));
}

class CatGalleryApp extends StatelessWidget {
  const CatGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cat Gallery',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

// Simple GoRouter configuration
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
  ],
);
