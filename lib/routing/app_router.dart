import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    // Onboarding Routes
    AutoRoute(page: WelcomeRoute.page, path: '/', initial: true),
    AutoRoute(page: AllowAccessRoute.page, path: '/allow-access'),

    // Main App Routes
    AutoRoute(page: MyCatsRoute.page, path: '/gallery'),
    AutoRoute(page: CatDetailRoute.page, path: '/cat-detail'),
    AutoRoute(page: FavoritesRoute.page, path: '/favorites'),
  ];
}

final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());

// Route Pages
@RoutePage()
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreenView();
  }
}

@RoutePage()
class AllowAccessScreen extends StatelessWidget {
  const AllowAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AllowAccessScreenView();
  }
}

@RoutePage()
class MyCatsScreen extends StatelessWidget {
  const MyCatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyCatsScreenView();
  }
}

@RoutePage()
class CatDetailScreen extends StatelessWidget {
  final String catId;

  const CatDetailScreen({super.key, required this.catId});

  @override
  Widget build(BuildContext context) {
    return CatDetailScreenView(catId: catId);
  }
}

@RoutePage()
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FavoritesScreenView();
  }
}
