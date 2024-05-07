import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_vocabulary/src/onboarding/domain/services/onboarding_services.dart';

import 'onboarding_state.dart';

class OnboardingController extends StateNotifier<OnboardingState> {
  final OnboardingService _service;
  OnboardingController({
    required OnboardingService service,
  })  : _service = service,
        super(
          const InitialOnboardingState(),
        );

  Future<void> checkOnboardingStatus() async {
    log("checkOnboardingStatus");
    state = const LoadingOnboardingState();
    final result = await _service.isOnboardingComplete();
    result.fold(
      (onboardingFailure) => state = const IncompleteOnboardingState(),
      (isOnboardingCompleted) => state = isOnboardingCompleted
          ? const OnboardingCompletedState()
          : const IncompleteOnboardingState(),
    );
    log("checkOnboardingStatus: $state");
  }

  Future<void> markOnboardingCompleted() async {
    state = const LoadingOnboardingState();
    final result = await _service.markOnboardingCompleted();
    result.fold(
      (onboardingFailure) => state = const ErrorOnboardingState(),
      (success) => state = const OnboardingCompletedState(),
    );
  }
}
