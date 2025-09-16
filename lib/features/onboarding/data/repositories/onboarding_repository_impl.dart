import 'package:cat_aloge/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:cat_aloge/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl(this.localDataSource);

  @override
  Future<bool> isOnboardingComplete() {
    return localDataSource.isOnboardingComplete();
  }

  @override
  Future<void> setOnboardingComplete() {
    return localDataSource.setOnboardingComplete();
  }
}
