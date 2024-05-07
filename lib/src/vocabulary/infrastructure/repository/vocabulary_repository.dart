import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:dartz/dartz.dart';
import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/core/constants.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/get_words_response.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word_details.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/services/vocabulary_service.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/data_source/local_data_source.dart';

import '../../domain/core/exceptions.dart';
import '../../domain/core/failures.dart';
import '../../domain/value_objects/value_objects.dart';
import 'wordlists_csv_parsers/csv_parser.dart';

class VocabularyRepository implements VocabularyServiceFacade {
  final LocalDataSource _localDataSource;
  final CSVListsParser _csvListsParser;

  const VocabularyRepository({
    required LocalDataSource localDataSource,
    required CSVListsParser csvListsParser,
  })  : _localDataSource = localDataSource,
        _csvListsParser = csvListsParser;
  @override
  Future<Either<VocabularyFailure, Success>> loadAllWordsIntoDb() async {
    // because the words are coming from a csv file,
    // we need to check if the words are already loaded into the db
    // if they are, then we don't need to load them again
    try {
      final areWordsLoaded = await _localDataSource.areWordsLoaded();
      if (areWordsLoaded) {
        return right(const Success(message: 'Words are already loaded'));
      }

      final parsingResponseOrFailure = await _csvListsParser.parse();

      final res = parsingResponseOrFailure
          .fold<Future<Either<VocabularyFailure, Success>>>(
        (failure) async {
          return left(failure);
        },
        (parsingResponse) async {
          try {
            log("Saving words into db...");
            log("Words count: ${parsingResponse.length}");
            await _localDataSource.saveAllWords(parsingResponse);
            log("Words saved");
          } catch (e) {
            return left(
              const VocabularyFailure.unexpected(),
            );
          }
          return right(const Success(message: 'Words are loaded'));
        },
      );
      return res;
    } catch (e) {
      return left(const VocabularyFailure.unexpected());
    }
  }

  @override
  Future<Either<VocabularyFailure, GetWordsResponse<Word>>> getAllWords({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  }) async {
    return _handleFailure(
      () async {
        final res = await _localDataSource.getAllWords(
          limit: limit.getOrCrash(),
          offset: offset.getOrCrash(),
        );
        return right(res);
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, GetWordsResponse<Word>>>
      getAllWordsForSource({
    required PaginationLimit limit,
    required PaginationOffSet offset,
    required WordsListKey source,
  }) async {
    return _handleFailure(
      () async {
        final res = await _localDataSource.getAllWordsForSource(
          source: source,
          limit: limit.getOrCrash(),
          offset: offset.getOrCrash(),
        );
        return right(res);
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllWordDetails({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.getAllWordDetails(
            limit: limit.getOrCrash(),
            offset: offset.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, WordDetails>> getWordDetails({
    required WordObject word,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.getWordDetails(
            word: word.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, Success>> markWordAsShown({
    required WordObject word,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.markWordAsShown(
            word: word.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, Success>> markWordAsToBeRemembered(
      {required WordObject word}) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.markWordAsToBeRemembered(
            word: word.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, Success>> clearWordShowHistory({
    required WordObject word,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.clearWordShowHistory(
            word: word.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, Success>> markWordAsMemorized({
    required WordObject word,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.markWordAsMemorized(
            word: word.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, Success>> removeWordFromMemorized({
    required WordObject word,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.removeWordFromMemorized(
            word: word.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, Success>> removeWordFromToBeRemembered({
    required WordObject word,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.removeWordFromToBeRemembered(
            word: word.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllMemorizedWords({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.getAllMemorizedWords(
            limit: limit.getOrCrash(),
            offset: offset.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllShownWords({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.getAllShownWords(
            limit: limit.getOrCrash(),
            offset: offset.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllToBeRememberedWords({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.getAllToBeRememberedWords(
            limit: limit.getOrCrash(),
            offset: offset.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, GetWordsResponse<WordDetails>>>
      getAllWordsShownToday({
    required PaginationLimit limit,
    required PaginationOffSet offset,
  }) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.getAllWordsShownToday(
            limit: limit.getOrCrash(),
            offset: offset.getOrCrash(),
          ),
        );
      },
    );
  }

  @override
  Future<Either<VocabularyFailure, List<Word>>> searchWord(String query) async {
    return _handleFailure(
      () async {
        return right(
          await _localDataSource.searchWord(
            query: query,
          ),
        );
      },
    );
  }

  VocabularyResponse<T> _handleFailure<T>(
    VocabularyResponse<T> Function() f,
  ) async {
    try {
      return await f();
    } on VocabularyException catch (e) {
      return e.when(
        wordNotFound: _wordNotFound,
        unableToParseCSV: _unableToParseCSV,
        valueError: _handleValueFailure,
        wordSourceNotListed: _wordSourceNotListed,
      );
    } on UnexpectedValueError catch (e) {
      return _handleValueFailure(e.valueFailure);
    } catch (e) {
      return left(const VocabularyFailure.unexpected());
    }
  }

  @override
  Future<Either<VocabularyFailure, List<WordDetails>>> getNextWordsToBeShown({
    required int noOfWords,
    required int shownThreshold,
  }) async {
    return _handleFailure(
      () async {
        String message = "";
        if (noOfWords < 1) {
          message = "Number of words to be shown should be greater than 0";
        }
        if (shownThreshold < 1) {
          message = "Shown threshold should be greater than 0";
        }
        if (message.isNotEmpty) {
          return left(VocabularyFailure.valueError(message: message));
        }

        final words = await _getWordsToBeShown(
          noOfWords,
          shownThreshold,
        );

        return right(words);
      },
    );
  }

  Future<List<WordDetails>> _getWordsToBeShown(
    int noOfWords,
    int shownThreshold,
  ) async {
    // Get all memorized words
    final memorizedWordsIndexes = await _localDataSource.allMemorizedIndexes();

    // Get all recently shown words
    final recentlyShownWordsIndexes =
        await _localDataSource.allRecentlyShownIndexes(
      const Duration(days: 3),
    ); // TODO: Make this configurable

    // Get all words count
    final allWordsCount = await _localDataSource.allWordsCount();

    if (memorizedWordsIndexes.length == allWordsCount) {
      return [];
    }

    final indexesToBeShown = <int>[];

    // Get the number of words to be shown
    final indexesToBeShownCount =
        math.min(noOfWords, allWordsCount - memorizedWordsIndexes.length);

    while (indexesToBeShown.length < indexesToBeShownCount) {
      final randomIndex = math.Random().nextInt(allWordsCount);
      if (memorizedWordsIndexes.contains(randomIndex) ||
          recentlyShownWordsIndexes.contains(randomIndex)) {
        continue;
      }
      indexesToBeShown.add(randomIndex);
    }

    final wordsToBeShown = await _localDataSource.getWordsByIndexes(
      indexesToBeShown,
    );

    // get the words details from words to be shown
    final wordsToBeShownDetails = await _localDataSource.getWordsDetailsByWords(
      wordsToBeShown,
    );

    return wordsToBeShownDetails;
  }

  VocabularyResponse<T> _handleValueFailure<T>(ValueFailure valueFailure) {
    final res = valueFailure.maybeWhen<String>(
      limitExceedMaxWordsFetch: (String message) => message,
      limitNotUpToMinimum: (String message) => message,
      orElse: () => "Unexpected Error",
    );

    return left(VocabularyFailure.valueError(message: res));
  }

  VocabularyResponse<T> _unableToParseCSV<T>() {
    return left(const VocabularyFailure.unableToParseCSV());
  }

  VocabularyResponse<T> _wordNotFound<T>(String message, String word) {
    return left(VocabularyFailure.wordNotFound(message: message, word: word));
  }

  VocabularyResponse<T> _wordSourceNotListed<T>(String message) {
    return left(VocabularyFailure.wordSourceNotListed(message: message));
  }
}

typedef VocabularyResponse<T> = FutureOr<Either<VocabularyFailure, T>>;
