import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/core/constants.dart';

part 'value_failure.freezed.dart';

@freezed
class ValueFailure<T> with _$ValueFailure<T> {
  const factory ValueFailure.unexpected() = _UnexpectedFailure;

  const factory ValueFailure.limitExceedMaxWordsFetch({
    @Default("Limit exceeds ${AppConstants.maxWordsFetchLimit}") String message,
  }) = _LimitExceedMaxWordsFetchFailure;
  const factory ValueFailure.limitNotUpToMinimum({
    @Default("Limit is not up to ${AppConstants.minWordsFetchLimit}")
        String message,
  }) = _LimitNotUpToMinimumFailure;

  const factory ValueFailure.offsetNotUpToMinimum({
    @Default("Offset cannot be negative") String message,
  }) = _OffsetNotUpToMinimumFailure;

  const factory ValueFailure.empty({
    @Default("Cannot be empty") String message,
    required T failedValue,
  }) = _EmptyFailure;
}
