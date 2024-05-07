import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
class VocabularyFailure with _$VocabularyFailure {
  const VocabularyFailure._();
  const factory VocabularyFailure.unexpected({
    @Default('Some error occurred') String message,
  }) = UnexpectedVocabularyFailure;
  const factory VocabularyFailure.unableToParseCSV() = UnableToParseCSVFailure;
  const factory VocabularyFailure.valueError({
    required String message,
  }) = VocabularyValueFailure;
  const factory VocabularyFailure.wordNotFound({
    @Default('Word Not found in DB') String message,
    required String word,
  }) = WordNotFoundFailure;
  const factory VocabularyFailure.wordSourceNotListed({
    @Default('Word source not listed') String message,
  }) = WordSourceNotListedFailure;
}
