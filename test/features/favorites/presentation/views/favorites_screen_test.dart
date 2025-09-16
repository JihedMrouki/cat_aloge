import 'package:cat_aloge/features/favorites/domain/usecases/get_favorites.dart';
import 'package:cat_aloge/features/favorites/presentation/providers/favorites_providers.dart';
import 'package:cat_aloge/features/favorites/presentation/views/favorites_screen.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/presentation/widgets/photo_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'favorites_screen_test.mocks.dart';

// 1. Generate mocks for the use case
@GenerateMocks([GetFavorites])
void main() {
  // 2. Create mock instance
  late MockGetFavorites mockGetFavoritesUseCase;

  setUp(() {
    mockGetFavoritesUseCase = MockGetFavorites();
  });

  // Test data
  final tFavoritePhotos = [
    CatPhoto(id: '1', path: 'path1', fileName: 'file1', isFavorite: true, creationDate: DateTime(2023, 1, 1), fileSize: 100),
    CatPhoto(id: '2', path: 'path2', fileName: 'file2', isFavorite: true, creationDate: DateTime(2023, 1, 2), fileSize: 200),
  ];

  // Helper function to pump the widget with overridden providers
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // 3. Override the use case provider
          getFavoritesUseCaseProvider.overrideWithValue(mockGetFavoritesUseCase),
        ],
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );
  }

  testWidgets('FavoritesScreen shows loading indicator when loading', (WidgetTester tester) async {
    // Arrange
    // Use a future that never completes to keep it in the loading state
    when(mockGetFavoritesUseCase.call()).thenAnswer((_) async => Future.delayed(const Duration(seconds: 1), () => []));
    await pumpScreen(tester);

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(PhotoGridView), findsNothing);

    // Act: Allow the future to complete and the widget to rebuild
    await tester.pumpAndSettle(); // Add this line
  });

  testWidgets('FavoritesScreen shows grid when data is loaded successfully', (WidgetTester tester) async {
    // Arrange
    when(mockGetFavoritesUseCase.call()).thenAnswer((_) async => tFavoritePhotos);
    await pumpScreen(tester);

    // Act
    await tester.pumpAndSettle(); // Wait for futures to complete

    // Assert
    expect(find.byType(PhotoGridView), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('You have no favorite cats yet!'), findsNothing);
  });

  testWidgets('FavoritesScreen shows empty message when there is no data', (WidgetTester tester) async {
    // Arrange
    when(mockGetFavoritesUseCase.call()).thenAnswer((_) async => []);
    await pumpScreen(tester);

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('You have no favorite cats yet!'), findsOneWidget);
    expect(find.byType(PhotoGridView), findsNothing);
  });

  testWidgets('FavoritesScreen shows error message on error state', (WidgetTester tester) async {
    // Arrange
    final errorMessage = 'Failed to load favorites';
    when(mockGetFavoritesUseCase.call()).thenThrow(Exception(errorMessage));
    await pumpScreen(tester);

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Exception: $errorMessage'), findsOneWidget);
    expect(find.byType(PhotoGridView), findsNothing);
  });
}