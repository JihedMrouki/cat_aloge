import 'package:cat_aloge/features/gallery/presentation/views/my_cat_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const MyCatsScreen(),
    ),
    // GoRoute(
    //   path: '/favorites',
    //   name: 'favorites',
    //   builder: (context, state) => const FavoritesScreen(),
    // ),
    // GoRoute(
    //   path: '/cat/:id',
    //   name: 'cat-detail',
    //   builder: (context, state) =>
    //       CatDetailScreen(catId: state.pathParameters['id']!),
    // ),
  ],
);
