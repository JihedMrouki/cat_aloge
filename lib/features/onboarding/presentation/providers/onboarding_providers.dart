import 'package:cat_aloge/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:cat_aloge/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:cat_aloge/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:cat_aloge/features/onboarding/domain/usecases/set_onboarding_complete.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((ref) {
  return OnboardingLocalDataSourceImpl();
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingLocalDataSourceProvider));
});

final isOnboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return repository.isOnboardingComplete();
});

final setOnboardingCompleteProvider = Provider<SetOnboardingComplete>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return SetOnboardingComplete(repository);
});
