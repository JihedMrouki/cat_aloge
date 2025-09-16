import 'package:cat_aloge/features/gallery/data/datasources/device_photo_datasource.dart';
import 'package:cat_aloge/features/gallery/domain/entities/cat_photo.dart';
import 'package:cat_aloge/features/gallery/presentation/providers/gallery_providers.dart';
import 'package:cat_aloge/features/gallery/presentation/views/my_cat_screen.dart';
import 'package:cat_aloge/features/gallery/presentation/widgets/photo_grid_shimmer.dart';
import 'package:cat_aloge/features/gallery/presentation/widgets/photo_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'my_cat_screen_test.mocks.dart';

// 1. Generate mocks for the data source
@GenerateMocks([DevicePhotoDataSource])
void main() {
  // 2. Create mock instance
  late MockDevicePhotoDataSource mockPhotoDataSource;

  setUp(() {
    mockPhotoDataSource = MockDevicePhotoDataSource();
  });

  // Test data
  final tCatPhotos = [
    CatPhoto(id: '1', path: 'path1', fileName: 'file1', isFavorite: false, creationDate: DateTime(2023, 1, 1), fileSize: 100),
  ];

  // Helper function to pump the widget with an overridden provider
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // 3. Override the data source provider directly
          photoDataSourceProvider.overrideWithValue(mockPhotoDataSource),
        ],
        child: const MaterialApp(home: MyCatsScreen()),
      ),
    );
  }

  testWidgets('MyCatsScreen shows shimmer when loading', (WidgetTester tester) async {
    // Arrange
    // Return a future that never completes to keep the UI in the loading state
    when(mockPhotoDataSource.getCatPhotos()).thenAnswer((_) async => Future.delayed(const Duration(minutes: 1)));
    await pumpScreen(tester);

    // Assert: Initial state should be shimmer
    expect(find.byType(PhotoGridShimmer), findsOneWidget);
  });

  testWidgets('MyCatsScreen shows grid when data is loaded successfully', (WidgetTester tester) async {
    // Arrange
    when(mockPhotoDataSource.getCatPhotos()).thenAnswer((_) async => tCatPhotos);
    await pumpScreen(tester);

    // Act
    await tester.pumpAndSettle(); // Wait for futures to complete

    // Assert
    expect(find.byType(PhotoGridView), findsOneWidget);
    expect(find.byType(PhotoGridShimmer), findsNothing);
    expect(find.text('No cat photos found.'), findsNothing);
  });

  testWidgets('MyCatsScreen shows empty message when data is an empty list', (WidgetTester tester) async {
    // Arrange
    when(mockPhotoDataSource.getCatPhotos()).thenAnswer((_) async => []);
    await pumpScreen(tester);

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('No cat photos found.'), findsOneWidget);
    expect(find.byType(PhotoGridView), findsNothing);
  });

  testWidgets('MyCatsScreen shows error message on error state', (WidgetTester tester) async {
    // Arrange
    final errorMessage = 'Failed to load photos';
    when(mockPhotoDataSource.getCatPhotos()).thenThrow(Exception(errorMessage));
    await pumpScreen(tester);

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Exception: $errorMessage'), findsOneWidget);
    expect(find.byType(PhotoGridView), findsNothing);
    expect(find.byType(PhotoGridShimmer), findsNothing);
  });
}