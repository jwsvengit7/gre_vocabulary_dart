import 'package:dartz/dartz.dart';
import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/onboarding/domain/core/failures.dart';
import 'package:gre_vocabulary/src/onboarding/domain/services/onboarding_services.dart';

import '../data_source/onboarding_local_data_source.dart';

class OnboardingRepository extends OnboardingService {
  final OnboardingLocalDataSource _localDataSource;

  OnboardingRepository({
    required OnboardingLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  @override
  Future<Either<OnboardingFailure, bool>> isOnboardingComplete() async {
    try {
      return right(await _localDataSource.isOnboardingComplete());
    } catch (e) {
      return left(const OnboardingFailure.unexpected());
    }
  }

  @override
  Future<Either<OnboardingFailure, Success>> markOnboardingCompleted() async {
    try {
      return right(await _localDataSource.markOnboardingCompleted());
    } catch (e) {
      return left(const OnboardingFailure.unexpected());
    }
  }
}
