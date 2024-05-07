import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class OnboardingFailure with _$OnboardingFailure {
  const OnboardingFailure._();
  const factory OnboardingFailure.unexpected() = UnexpectedOnboardingFailure;
}
