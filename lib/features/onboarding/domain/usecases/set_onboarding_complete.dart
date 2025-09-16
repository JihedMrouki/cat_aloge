import 'package:cat_aloge/features/onboarding/domain/repositories/onboarding_repository.dart';

class SetOnboardingComplete {
  final OnboardingRepository repository;

  SetOnboardingComplete(this.repository);

  Future<void> call() {
    return repository.setOnboardingComplete();
  }
}
