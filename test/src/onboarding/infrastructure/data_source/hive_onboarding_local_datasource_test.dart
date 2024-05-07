import 'package:flutter_test/flutter_test.dart';
import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/onboarding/infrastructure/data_source/db_keys.dart';
import 'package:gre_vocabulary/src/onboarding/infrastructure/data_source/onboarding_local_data_source.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';

void main() {
  late Box box;
  late HiveOnboardingLocalDataSourceImpl hiveOnboardingLocalDataSourceImpl;

  setUp(() async {
    await setUpTestHive();
    box = await Hive.openBox("test");
    hiveOnboardingLocalDataSourceImpl = HiveOnboardingLocalDataSourceImpl(box);
  });
  group("isOnboardingComplete", () {
    test("should return false if onboarding is not complete", () async {
      // arrange
      await box.put(OnboardingDbKeys.onboardingCompleteKey, false);
      // act
      final result =
          await hiveOnboardingLocalDataSourceImpl.isOnboardingComplete();
      // assert
      expect(result, false);
    });
    test("should return true if onboarding is complete", () async {
      // arrange
      await box.put(OnboardingDbKeys.onboardingCompleteKey, true);
      // act
      final result =
          await hiveOnboardingLocalDataSourceImpl.isOnboardingComplete();
      // assert
      expect(result, true);
    });
  });

  group("markOnboardingCompleted", () {
    test("should return success if onboarding is marked completed", () async {
      // arrange
      await box.put(OnboardingDbKeys.onboardingCompleteKey, false);
      // act
      final result =
          await hiveOnboardingLocalDataSourceImpl.markOnboardingCompleted();

      final isOnboardingComplete =
          await hiveOnboardingLocalDataSourceImpl.isOnboardingComplete();
      // assert
      expect(result, const SuccessModel());
      expect(isOnboardingComplete, true);
    });
  });
}
