import 'package:dartz/dartz.dart';
import 'package:gre_vocabulary/src/core/value_failure.dart';
import 'package:gre_vocabulary/src/core/value_object.dart';

import '../core/constants.dart';

class PaginationLimit extends ValueObject<int> {
  @override
  final Either<ValueFailure<int>, int> value;

  factory PaginationLimit(int input) {
    return PaginationLimit._(
      _validateLimit(input),
    );
  }

  const PaginationLimit._(this.value);

  static Either<ValueFailure<int>, int> _validateLimit(int input) {
    if (input < AppConstants.minWordsFetchLimit) {
      return left(const ValueFailure.limitNotUpToMinimum());
    }

    if (input > AppConstants.maxWordsFetchLimit) {
      return left(const ValueFailure.limitExceedMaxWordsFetch());
    }

    return right(input);
  }
}
