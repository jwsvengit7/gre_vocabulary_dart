import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/onboarding/domain/core/failures.dart';
import 'package:gre_vocabulary/src/onboarding/infrastructure/data_source/onboarding_local_data_source.dart';
import 'package:gre_vocabulary/src/onboarding/infrastructure/repositories/onboarding_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'onboarding_repository_test.mocks.dart';

@GenerateMocks([OnboardingLocalDataSource])
void main() {
  late MockOnboardingLocalDataSource mockOnboardingLocalDataSource;
  late OnboardingRepository onboardingRepository;

  setUp(() {
    mockOnboardingLocalDataSource = MockOnboardingLocalDataSource();
    onboardingRepository = OnboardingRepository(
      localDataSource: mockOnboardingLocalDataSource,
    );
  });

  group(
    "isOnboardingComplete",
    () {
      test(
        "should return true if onboarding is complete",
        () async {
          // arrange
          when(
            mockOnboardingLocalDataSource.isOnboardingComplete(),
          ).thenAnswer(
            (_) => Future.value(true),
          );
          // act
          final result = await onboardingRepository.isOnboardingComplete();
          // assert
          expect(result.isRight(), true);
          expect(result.fold(id, id), true);
          verify(
            mockOnboardingLocalDataSource.isOnboardingComplete(),
          ).called(1);
        },
      );

      test(
        "should return false if onboarding is not complete",
        () async {
          // arrange
          when(
            mockOnboardingLocalDataSource.isOnboardingComplete(),
          ).thenAnswer(
            (_) => Future.value(false),
          );
          // act
          final result = await onboardingRepository.isOnboardingComplete();
          // assert
          expect(result.isRight(), true);
          expect(result.fold(id, id), false);
          verify(
            mockOnboardingLocalDataSource.isOnboardingComplete(),
          ).called(1);
        },
      );

      test(
        "should return OnboardingFailure.unexpected if local data source throws exception",
        () async {
          // arrange
          when(
            mockOnboardingLocalDataSource.isOnboardingComplete(),
          ).thenThrow(
            Exception(),
          );
          // act
          final result = await onboardingRepository.isOnboardingComplete();
          // assert
          expect(result.isLeft(), true);
          expect(result.fold(id, id), const OnboardingFailure.unexpected());
          verify(
            mockOnboardingLocalDataSource.isOnboardingComplete(),
          ).called(1);
        },
      );
    },
  );

  group(
    "markOnboardingCompleted",
    () {
      test(
        "should return Success if onboarding is marked as completed",
        () async {
          // arrange
          const tSuccess = SuccessModel();
          when(
            mockOnboardingLocalDataSource.markOnboardingCompleted(),
          ).thenAnswer(
            (_) => Future.value(tSuccess),
          );
          // act
          final result = await onboardingRepository.markOnboardingCompleted();
          // assert
          expect(result.isRight(), true);
          expect(result.fold(id, id), tSuccess);
          verify(
            mockOnboardingLocalDataSource.markOnboardingCompleted(),
          ).called(1);
        },
      );

      test(
        "should return OnboardingFailure.unexpected if local data source throws exception",
        () async {
          // arrange
          when(
            mockOnboardingLocalDataSource.markOnboardingCompleted(),
          ).thenThrow(
            Exception(),
          );
          // act
          final result = await onboardingRepository.markOnboardingCompleted();
          // assert
          expect(result.isLeft(), true);
          expect(result.fold(id, id), const OnboardingFailure.unexpected());
          verify(
            mockOnboardingLocalDataSource.markOnboardingCompleted(),
          ).called(1);
        },
      );
    },
  );
}
