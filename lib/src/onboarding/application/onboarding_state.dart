import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const OnboardingState._();
  const factory OnboardingState.initial() = InitialOnboardingState;
  const factory OnboardingState.loading() = LoadingOnboardingState;
  const factory OnboardingState.loaded() = LoadedOnboardingState;
  const factory OnboardingState.error() = ErrorOnboardingState;
  const factory OnboardingState.onboardingCompleted() =
      OnboardingCompletedState;
  const factory OnboardingState.onboardingNotCompleted() =
      IncompleteOnboardingState;

  const factory OnboardingState.onboardingInProgress(int currentStep) =
      OnboardingInProgressState;
}
