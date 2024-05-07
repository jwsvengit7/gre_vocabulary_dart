import 'package:dartz/dartz.dart';
import 'package:gre_vocabulary/src/core/value_failure.dart';
import 'package:gre_vocabulary/src/core/value_object.dart';

class WordObject extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory WordObject(String input) {
    return WordObject._(
      _validateWord(input.trim().toLowerCase()),
    );
  }

  String get valueOrEmpty => value.getOrElse(() => "");

  const WordObject._(this.value);

  static Either<ValueFailure<String>, String> _validateWord(String input) {
    if (input.isEmpty) {
      return left(ValueFailure.empty(
        failedValue: input,
      ));
    }

    // check that input is not a number
    try {
      int.parse(input);
      return left(
        ValueFailure.empty(
          failedValue: input,
          message: "Word cannot be a number",
        ),
      );
    } catch (e) {
      // do nothing
    }

    // check that input has no special characters
    final RegExp regExp = RegExp(r'^[a-zA-Z\u00C0-\u00FF]*$');
    if (!regExp.hasMatch(input)) {
      return left(ValueFailure.empty(
        failedValue: input,
        message: "Word cannot have special characters",
      ));
    }

    return right(input);
  }
}
