import 'package:dartz/dartz.dart';
import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/core/failures.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word.dart';

import '../core/constants.dart';
import '../entities/get_words_response.dart';
import '../entities/word_details.dart';
import '../value_objects/limit.dart';
import '../value_objects/offset.dart';
import '../value_objects/word.dart';

abstract class VocabularyServiceFacade {
  Future<Either<VocabularyFailure, Success>> loadAllWordsIntoDb();
  Future<Either<VocabularyFailure, GetWordsResponse<Word>>> getAllWords({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  });

  Future<Either<VocabularyFailure, GetWordsResponse<Word>>>
      getAllWordsForSource({
    required PaginationLimit limit,
    required PaginationOffSet offset,
    required WordsListKey source,
  });

  ///
  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllWordDetails({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  });

  Future<Either<VocabularyFailure, WordDetails>> getWordDetails({
    required WordObject word,
  });

  Future<Either<VocabularyFailure, Success>> markWordAsMemorized({
    required WordObject word,
  });

  Future<Either<VocabularyFailure, Success>> removeWordFromMemorized({
    required WordObject word,
  });

  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllMemorizedWords({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  });

  Future<Either<VocabularyFailure, Success>> markWordAsShown({
    required WordObject word,
  });

  Future<Either<VocabularyFailure, Success>> clearWordShowHistory({
    required WordObject word,
  });

  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllShownWords({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  });

  Future<Either<VocabularyFailure, Success>> markWordAsToBeRemembered({
    required WordObject word,
  });

  Future<Either<VocabularyFailure, Success>> removeWordFromToBeRemembered({
    required WordObject word,
  });

  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllToBeRememberedWords({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  });

  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllWordsShownToday({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  });

  Future<Either<VocabularyFailure, List<WordDetails>>> getNextWordsToBeShown({
    /// number of words to be returned
    required int noOfWords,

    /// words shown times above this threshold will not be returned
    required int shownThreshold,
  });

  Future<Either<VocabularyFailure, List<Word>>> searchWord(String query);
}
