import 'package:cat_aloge/features/favorites/data/repository/faorites_repository_impl.dart';
import 'package:cat_aloge/features/favorites/domain/usecases/get_favorites.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getFavoritesUseCaseProvider = Provider<GetFavorites>((ref) {
  final repository = ref.watch(favoritesRepositoryProvider);
  return GetFavorites(repository);
});

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<CatPhoto>>>((ref) {
  return FavoritesNotifier(ref.watch(getFavoritesUseCaseProvider));
});

class FavoritesNotifier extends StateNotifier<AsyncValue<List<CatPhoto>>> {
  final GetFavorites _getFavoritesUseCase;

  FavoritesNotifier(this._getFavoritesUseCase) : super(const AsyncValue.loading()) {
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    state = const AsyncValue.loading();
    try {
      final favorites = await _getFavoritesUseCase();
      state = AsyncValue.data(favorites);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
