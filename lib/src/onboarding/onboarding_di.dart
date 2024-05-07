import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_vocabulary/src/onboarding/domain/services/onboarding_services.dart';
import 'package:gre_vocabulary/src/onboarding/infrastructure/data_source/onboarding_local_data_source.dart';
import 'package:gre_vocabulary/src/onboarding/infrastructure/repositories/onboarding_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'application/onboarding_controller.dart';
import 'application/onboarding_state.dart';

final onboardingLocalDataSourceProvider =
    FutureProvider.autoDispose<OnboardingLocalDataSource>((ref) async {
  final box = await Hive.openBox("onboarding");
  return HiveOnboardingLocalDataSourceImpl(box);
});

final onboardingServiceProvider =
    FutureProvider.autoDispose<OnboardingService>((ref) async {
  final onboardingLocalDataSource =
      await ref.watch(onboardingLocalDataSourceProvider.future);
  return OnboardingRepository(
    localDataSource: onboardingLocalDataSource,
  );
});

final onboardingControllerProvider =
    StateNotifierProvider.autoDispose<OnboardingController, OnboardingState>(
  (ref) {
    final onboardingService = ref.watch(onboardingServiceProvider);
    return onboardingService.maybeWhen(orElse: () {
      throw Exception("Onboarding service is not ready");
    }, data: (data) {
      return OnboardingController(
        service: data,
      );
    });
  },
);
