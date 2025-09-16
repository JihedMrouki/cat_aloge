
import 'package:cat_aloge/core/theme/app_colors.dart';
import 'package:cat_aloge/core/widgets/custom_button.dart';
import 'package:cat_aloge/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((255 * 0.1).round()),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Welcome to Cat-aloge',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'The smart way to organize your cat photos.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              CustomButton(
                text: 'Get Started',
                onPressed: () {
                  ref.read(setOnboardingCompleteProvider)();
                  context.go('/permission');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
