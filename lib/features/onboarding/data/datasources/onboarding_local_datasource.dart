import 'package:hive/hive.dart';
import 'package:cat_aloge/core/constants/hive_boxes.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  @override
  Future<bool> isOnboardingComplete() async {
    final box = await Hive.openBox(HiveBoxes.userPreferences);
    return box.get(_onboardingCompleteKey, defaultValue: false);
  }

  @override
  Future<void> setOnboardingComplete() async {
    final box = await Hive.openBox(HiveBoxes.userPreferences);
    await box.put(_onboardingCompleteKey, true);
  }
}
