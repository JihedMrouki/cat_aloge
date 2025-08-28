import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(FavoriteCatModelAdapter());

  // Open Hive boxes
  await Hive.openBox<FavoriteCatModel>(HiveBoxes.favorites);

  runApp(ProviderScope(child: const CatGalleryApp()));
}
