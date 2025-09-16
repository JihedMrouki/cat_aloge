import 'package:cat_aloge/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(isOnboardingCompleteProvider, (previous, next) {
      next.whenData((isComplete) {
        if (isComplete) {
          context.go('/gallery');
        } else {
          context.go('/welcome');
        }
      });
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
