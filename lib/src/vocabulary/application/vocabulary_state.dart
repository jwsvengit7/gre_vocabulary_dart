import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word_details.dart';

part 'vocabulary_state.freezed.dart';

@freezed
class VocabularyState with _$VocabularyState {
  const VocabularyState._();
  const factory VocabularyState.initial() = InitialVocabularyState;
  const factory VocabularyState.loading() = LoadingVocabularyState;
  const factory VocabularyState.success({
    required String data,
  }) = SuccessVocabularyState;

  const factory VocabularyState.error({
    required String error,
  }) = ErrorVocabularyState;

  const factory VocabularyState.searching({
    required String data,
  }) = SearchingVocabularyState;

  const factory VocabularyState.searchSuccess({
    required List<Word> words,
  }) = SearchSuccessVocabularyState;

  const factory VocabularyState.searchError({
    required String error,
  }) = SearchErrorVocabularyState;

  const factory VocabularyState.loadWordsToBeShownFailure({
    required String error,
  }) = LoadWordsToBeShownFailureState;

  const factory VocabularyState.nextWordsLoaded({
    required List<WordDetails> words,
  }) = NextWordsLoadedState;
}
