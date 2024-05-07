import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/core/constants.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';

import '../models/get_words_response_model.dart';
import '../models/word_details_model.dart';

abstract class LocalDataSource {
  Future<bool> areWordsLoaded();

  Future<SuccessModel> saveAllWords(List<WordModel> allWords);

  Future<GetWordsResponseModel<WordModel>> getAllWords({
    required int limit,
    required int offset,
  });

  Future<WordModel> getWord(String word);

  Future<GetWordsResponseModel<WordModel>> getAllWordsForSource({
    required WordsListKey source,
    required int limit,
    required int offset,
  });

  Future<GetWordsResponseModel<WordModel>> getHitWords({
    required int limit,
    required int offset,
  });

  Future<GetWordsResponseModel<WordDetailsModel>> getAllWordDetails({
    required int limit,
    required int offset,
  });

  Future<WordDetailsModel> getWordDetails({required String word});

  Future<SuccessModel> markWordAsShown({required String word});

  Future<SuccessModel> markWordAsToBeRemembered({
    required String word,
  });

  Future<SuccessModel> clearWordShowHistory({required String word});

  Future<SuccessModel> markWordAsMemorized({required String word});

  Future<SuccessModel> removeWordFromMemorized({required String word});

  Future<SuccessModel> removeWordFromToBeRemembered({required String word});

  Future<GetWordsResponseModel<WordDetailsModel>> getAllMemorizedWords({
    required int limit,
    required int offset,
  });

  Future<GetWordsResponseModel<WordDetailsModel>> getAllShownWords({
    required int limit,
    required int offset,
  });

  Future<GetWordsResponseModel<WordDetailsModel>> getAllToBeRememberedWords({
    required int limit,
    required int offset,
  });

  Future<GetWordsResponseModel<WordDetailsModel>> getAllWordsShownToday({
    required int limit,
    required int offset,
  });

  Future<List<int>> allMemorizedIndexes();

  Future<int> allWordsCount();

  Future<List<int>> allRecentlyShownIndexes(Duration duration);

  Future<List<WordModel>> getWordsByIndexes(List<int> indexesToBeShown);

  Future<List<WordModel>> searchWord({required String query});

  Future<List<WordDetailsModel>> getWordsDetailsByWords(
      List<WordModel> wordsToBeShown);
}
