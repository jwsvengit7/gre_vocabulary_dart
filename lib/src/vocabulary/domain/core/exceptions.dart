import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gre_vocabulary/src/core/value_failure.dart';

part 'exceptions.freezed.dart';

@freezed
class VocabularyException with _$VocabularyException implements Exception {
  const VocabularyException._();
  const factory VocabularyException.wordNotFound({
    @Default('Word Not found in DB') String message,
    required String word,
  }) = WordNotFoundException;
  const factory VocabularyException.unableToParseCSV() =
      _UnableToParseCSVException;
  const factory VocabularyException.valueError({
    required ValueFailure valueFailure,
  }) = _VocabularyValueError;
  const factory VocabularyException.wordSourceNotListed({
    @Default('Word Source Not found in DB') String message,
  }) = WordSourceNotListedException;
}
