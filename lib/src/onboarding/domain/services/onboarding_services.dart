import 'package:dartz/dartz.dart';
import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/onboarding/domain/core/failures.dart';

abstract class OnboardingService {
  Future<Either<OnboardingFailure, bool>> isOnboardingComplete();
  Future<Either<OnboardingFailure, Success>> markOnboardingCompleted();

}

