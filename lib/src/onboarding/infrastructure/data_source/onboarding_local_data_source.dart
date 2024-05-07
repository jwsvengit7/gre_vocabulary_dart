import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/onboarding/infrastructure/data_source/db_keys.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingComplete();

  Future<SuccessModel> markOnboardingCompleted();
}

class HiveOnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final Box<dynamic> _hiveBox;

  HiveOnboardingLocalDataSourceImpl(this._hiveBox);

  @override
  Future<bool> isOnboardingComplete() async {
    return _hiveBox.get(
      OnboardingDbKeys.onboardingCompleteKey,
      defaultValue: false,
    ) as bool;
  }

  @override
  Future<SuccessModel> markOnboardingCompleted() async {
    await _hiveBox.put(
      OnboardingDbKeys.onboardingCompleteKey,
      true,
    );
    return const SuccessModel();
  }
}
