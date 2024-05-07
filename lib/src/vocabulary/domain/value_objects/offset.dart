import 'package:dartz/dartz.dart';
import 'package:gre_vocabulary/src/core/value_failure.dart';
import 'package:gre_vocabulary/src/core/value_object.dart';

class PaginationOffSet extends ValueObject<int> {
  @override
  final Either<ValueFailure<int>, int> value;

  factory PaginationOffSet(int input) {
    return PaginationOffSet._(
      _validateOffSet(input),
    );
  }

  const PaginationOffSet._(this.value);

  static Either<ValueFailure<int>, int> _validateOffSet(int input) {
    if (input < 0) {
      return left(const ValueFailure.offsetNotUpToMinimum());
    }

    return right(input);
  }
}
