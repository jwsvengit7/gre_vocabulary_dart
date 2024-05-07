import 'dart:developer';

import 'package:clock/clock.dart';
import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/core/exceptions.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/get_words_response_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/isar_word_details_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/isar_word_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_details_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';
import 'package:hive/hive.dart';
import 'package:isar/isar.dart';

import '../../domain/core/constants.dart';
import 'db_keys.dart';
import 'local_data_source.dart';

abstract class IDataBase {
  final Box generalDataBox;
  final Isar isar;

  const IDataBase({
    required this.generalDataBox,
    required this.isar,
  });
}

class DB extends IDataBase {
  DB({
    required super.generalDataBox,
    required super.isar,
  });
}

class IsarLocalDataSource implements LocalDataSource {
  final IDataBase _hiveBoxes;

  IsarLocalDataSource({
    required IDataBase hiveBoxes,
  }) : _hiveBoxes = hiveBoxes;

  @override
  Future<bool> areWordsLoaded() async {
    return await _hiveBoxes.generalDataBox.get(DBKeys.wordsLoaded) ?? false;
  }

  @override
  Future<SuccessModel> saveAllWords(List<WordModel> allWords) async {
    // clear the db
    await _hiveBoxes.isar.writeTxn(() async {
      await _hiveBoxes.isar.words.clear();
    });

    try {
      final words = <IsarWordModel>[];

      for (final word in allWords) {
        try {
          words.add(IsarWordModel.fromWordModel(word));
        } catch (e) {
          log("Error at word: ${word.value} $e");
        }
      }

      await _hiveBoxes.isar.writeTxn(() async {
        words.sort(
          (a, b) => a.value.compareTo(b.value),
        );

        await _hiveBoxes.isar.words.putAll(words);
      });
    } catch (e) {
      log(e.toString());
    }

    await _hiveBoxes.generalDataBox.put(DBKeys.wordsLoaded, true);

    return const SuccessModel();
  }

  @override
  Future<GetWordsResponseModel<WordModel>> getAllWords({
    required int limit,
    required int offset,
  }) async {
    final isarWords = await _hiveBoxes.isar.words
        .where()
        .offset(offset)
        .limit(limit)
        .findAll();

    final totalCount = await _hiveBoxes.isar.words.count();

    final wordModels = isarWords
        .map(
          (e) => e.toWordModel(),
        )
        .toList();

    return GetWordsResponseModel(
      words: wordModels,
      totalWords: totalCount,
      currentPage: offset <= 0 ? 1 : (offset ~/ limit) + 1,
      totalPages: (totalCount / limit).ceil(),
      wordsPerPage: limit,
    );
  }

  @override
  Future<WordModel> getWord(String word) async {
    final isarWordModel =
        await _hiveBoxes.isar.words.where().valueEqualTo(word).findFirst();

    if (isarWordModel == null) {
      throw WordNotFoundException(word: word, message: 'Word not found: $word');
    }

    return isarWordModel.toWordModel();
  }

  @override
  Future<WordDetailsModel> getWordDetails({required String word}) async {
    final wordModel = await getWord(word);
    final isarWordDetails = await _getWordDetailsFromWord(word);

    if (isarWordDetails == null) {
      return WordDetailsModel.freshFromWordModel(wordModel);
    }

    return _getWordDetailsModelFromIsarWordDetailsModel(
      isarWordDetails,
      wordModel,
    );
  }

  @override
  Future<int> allWordsCount() async {
    return await _hiveBoxes.isar.words.count();
  }

  @override
  Future<SuccessModel> markWordAsShown({required String word}) async {
    final wordModel = await getWord(word);

    // get the word details
    final wordDetails = await _getWordDetailsFromWord(word) ??
        IsarWordDetailsModel.fresh(
          word: word,
          id: wordModel.id,
        );

    await _hiveBoxes.isar.writeTxn(() async {
      await _hiveBoxes.isar.wordDetails.put(
        wordDetails.copyWith(
          shownCount: wordDetails.shownCount + 1,
          lastShownDate: clock.now(),
        ),
      );
    });

    return const SuccessModel();
  }

  @override
  Future<GetWordsResponseModel<WordDetailsModel>> getAllWordDetails({
    required int limit,
    required int offset,
  }) async {
    final wordDetails = await _hiveBoxes.isar.wordDetails
        .where()
        .sortByLastShownDateDesc()
        .offset(offset)
        .limit(limit)
        .findAll();

    final totalCount = await _hiveBoxes.isar.wordDetails.count();

    final wordDetailsModels = <WordDetailsModel>[];

    for (final wordDetail in wordDetails) {
      final wordModel = await getWord(wordDetail.word);
      wordDetailsModels.add(
        _getWordDetailsModelFromIsarWordDetailsModel(
          wordDetail,
          wordModel,
        ),
      );
    }

    return GetWordsResponseModel(
      words: wordDetailsModels,
      totalWords: totalCount,
      currentPage: offset <= 0 ? 1 : (offset ~/ limit) + 1,
      totalPages: (totalCount / limit).ceil(),
      wordsPerPage: limit,
    );
  }

  @override
  Future<SuccessModel> markWordAsMemorized({required String word}) async {
    final wordModel = await getWord(word);

    // get the word details
    final wordDetails = await _getWordDetailsFromWord(word) ??
        IsarWordDetailsModel(
          word: word,
          id: wordModel.id,
          shownCount: 0,
          show: true,
          lastShownDate: clock.now(),
          isMemorized: true,
          dateMemorized: clock.now(),
          isToBeRemembered: false,
        );

    await _hiveBoxes.isar.writeTxn(() async {
      await _hiveBoxes.isar.wordDetails.put(
        wordDetails.copyWith(
          isMemorized: true,
          dateMemorized: clock.now(),
        ),
      );
    });

    return const SuccessModel();
  }

  @override
  Future<SuccessModel> removeWordFromMemorized({
    required String word,
  }) async {
    // get the word details
    IsarWordDetailsModel? wordDetails = await _getWordDetailsFromWord(word);

    if (wordDetails != null) {
      await _hiveBoxes.isar.writeTxn(() async {
        await _hiveBoxes.isar.wordDetails.put(
          wordDetails.copyWith(
            isMemorized: false,
            dateMemorized: clock.now(),
          ),
        );
      });
    }

    return const SuccessModel();
  }

  @override
  Future<GetWordsResponseModel<WordDetailsModel>> getAllMemorizedWords({
    required int limit,
    required int offset,
  }) async {
    final query = _hiveBoxes.isar.wordDetails.filter().isMemorizedEqualTo(true);
    final totalCount = await query.count();

    if (totalCount == 0) {
      return GetWordsResponseModel.empty();
    }

    final isarWordDetailsModels = await query
        .sortByLastShownDateDesc()
        .offset(offset)
        .limit(limit)
        .findAll();

    final wordDetailsModels = <WordDetailsModel>[];
    for (final wordDetail in isarWordDetailsModels) {
      final wordModel = await getWord(wordDetail.word);
      wordDetailsModels.add(
        _getWordDetailsModelFromIsarWordDetailsModel(
          wordDetail,
          wordModel,
        ),
      );
    }

    return GetWordsResponseModel(
      words: wordDetailsModels,
      totalWords: totalCount,
      currentPage: _calculateCurrentPage(offset, limit, totalCount),
      totalPages: (totalCount / limit).ceil(),
      wordsPerPage: limit,
    );
  }

  @override
  Future<List<int>> allMemorizedIndexes() async {
    final query = _hiveBoxes.isar.wordDetails.filter().isMemorizedEqualTo(true);

    final wordDetails = await query.sortByLastShownDateDesc().findAll();

    if (wordDetails.isEmpty) {
      return [];
    }

    return wordDetails.map((e) => e.id!).toList();
  }

  @override
  Future<List<int>> allRecentlyShownIndexes(Duration duration) async {
    final value = clock.now().subtract(duration);
    final query =
        _hiveBoxes.isar.wordDetails.filter().lastShownDateGreaterThan(value);
    final totalCount = await query.count();

    if (totalCount == 0) {
      log('No recently shown words');
      return [];
    }

    final wordDetails = await query.sortByLastShownDateDesc().findAll();

    if (wordDetails.isEmpty) {
      return [];
    }

    return wordDetails.map((e) => e.id!).toList();
  }

  @override
  Future<SuccessModel> clearWordShowHistory({required String word}) async {
    final wordDetails = await _getWordDetailsFromWord(word);

    if (wordDetails != null) {
      await _hiveBoxes.isar.writeTxn(() async {
        await _hiveBoxes.isar.wordDetails.put(
          wordDetails.copyWith(
            shownCount: 0,
            lastShownDate: clock.now(),
            isMemorized: false,
          ),
        );
      });
    }

    return const SuccessModel();
  }

  @override
  Future<SuccessModel> markWordAsToBeRemembered({required String word}) async {
    final wordModel = await getWord(word);

    // get the word details
    final wordDetails = await _getWordDetailsFromWord(word) ??
        IsarWordDetailsModel(
          word: word,
          id: wordModel.id,
          shownCount: 0,
          show: true,
          lastShownDate: clock.now(),
          isMemorized: false,
          isToBeRemembered: false,
        );

    await _hiveBoxes.isar.writeTxn(() async {
      await _hiveBoxes.isar.wordDetails.put(
        wordDetails.copyWith(
          isToBeRemembered: true,
        ),
      );
    });

    return const SuccessModel();
  }

  @override
  Future<SuccessModel> removeWordFromToBeRemembered(
      {required String word}) async {
    final wordDetails = await _getWordDetailsFromWord(word);

    if (wordDetails != null) {
      await _hiveBoxes.isar.writeTxn(() async {
        await _hiveBoxes.isar.wordDetails.put(
          wordDetails.copyWith(
            isToBeRemembered: false,
          ),
        );
      });
    }

    return const SuccessModel();
  }

  @override
  Future<GetWordsResponseModel<WordDetailsModel>> getAllToBeRememberedWords({
    required int limit,
    required int offset,
  }) async {
    final query =
        _hiveBoxes.isar.wordDetails.filter().isToBeRememberedEqualTo(true);

    final totalCount = await query.count();

    if (totalCount == 0) {
      return GetWordsResponseModel.empty();
    }

    final wordDetails = await query
        .sortByLastShownDateDesc()
        .offset(offset)
        .limit(limit)
        .findAll();

    final wordDetailsModels = <WordDetailsModel>[];

    for (final wordDetail in wordDetails) {
      final wordModel = await getWord(wordDetail.word);
      wordDetailsModels.add(
        _getWordDetailsModelFromIsarWordDetailsModel(
          wordDetail,
          wordModel,
        ),
      );
    }

    return GetWordsResponseModel(
      words: wordDetailsModels,
      totalWords: totalCount,
      currentPage: _calculateCurrentPage(offset, limit, totalCount),
      totalPages: (totalCount / limit).ceil(),
      wordsPerPage: limit,
    );
  }

  @override
  Future<GetWordsResponseModel<WordModel>> getAllWordsForSource({
    required WordsListKey source,
    required int limit,
    required int offset,
  }) async {
    final query = _hiveBoxes.isar.words.filter().sourceEqualTo(source);

    final totalCount = await query.count();

    if (totalCount == 0) {
      throw WordSourceNotListedException(
        message: "Word source '$source' is not listed",
      );
    }

    final wordModels =
        await query.sortByValue().offset(offset).limit(limit).findAll();

    return GetWordsResponseModel(
      words: wordModels.map((e) => e.toWordModel()).toList(),
      totalWords: totalCount,
      currentPage: _calculateCurrentPage(offset, limit, totalCount),
      totalPages: (totalCount / limit).ceil(),
      wordsPerPage: limit,
    );
  }

  @override
  Future<GetWordsResponseModel<WordDetailsModel>> getAllShownWords({
    required int limit,
    required int offset,
  }) async {
    final query = _hiveBoxes.isar.wordDetails.filter().shownCountGreaterThan(0);

    final totalCount = await query.count();

    if (totalCount == 0) {
      return GetWordsResponseModel.empty();
    }

    final wordDetails = await query
        .sortByLastShownDateDesc()
        .offset(offset)
        .limit(limit)
        .findAll();

    final wordDetailsModels = <WordDetailsModel>[];

    for (final wordDetail in wordDetails) {
      final wordModel = await getWord(wordDetail.word);
      wordDetailsModels.add(
        _getWordDetailsModelFromIsarWordDetailsModel(
          wordDetail,
          wordModel,
        ),
      );
    }

    return GetWordsResponseModel(
      words: wordDetailsModels,
      totalWords: totalCount,
      currentPage: _calculateCurrentPage(offset, limit, totalCount),
      totalPages: (totalCount / limit).ceil(),
      wordsPerPage: limit,
    );
  }

  @override
  Future<GetWordsResponseModel<WordModel>> getHitWords({
    required int limit,
    required int offset,
  }) async {
    final query = _hiveBoxes.isar.words.filter().isHitWordEqualTo(true);

    final totalCount = await query.count();

    if (totalCount == 0) {
      return GetWordsResponseModel.empty();
    }

    final wordModels =
        await query.sortByValue().offset(offset).limit(limit).findAll();

    return GetWordsResponseModel(
      words: wordModels.map((e) => e.toWordModel()).toList(),
      totalWords: totalCount,
      currentPage: _calculateCurrentPage(offset, limit, totalCount),
      totalPages: (totalCount / limit).ceil(),
      wordsPerPage: limit,
    );
  }

  @override
  Future<List<WordModel>> getWordsByIndexes(
    List<int> indexesToBeShown,
  ) async {
    final wordDetails = <WordModel>[];

    for (final index in indexesToBeShown) {
      if (index <= 0) {
        // instead of throwing an exception, we just ignore the index
        continue;
      }

      final word = await _hiveBoxes.isar.words.get(index);

      if (word == null) {
        continue;
      }

      wordDetails.add(
        word.toWordModel(),
      );
    }

    return wordDetails;
  }

  @override
  Future<GetWordsResponseModel<WordDetailsModel>> getAllWordsShownToday(
      {required int limit, required int offset}) async {
    final today = _getToday();

    final query =
        _hiveBoxes.isar.wordDetails.filter().lastShownDateGreaterThan(today);

    final totalCount = await query.count();

    if (totalCount == 0) {
      return GetWordsResponseModel.empty();
    }

    final wordDetails = await query
        .sortByLastShownDateDesc()
        .offset(offset)
        .limit(limit)
        .findAll();

    final wordDetailsModels = <WordDetailsModel>[];

    for (final wordDetail in wordDetails) {
      final wordModel = await getWord(wordDetail.word);
      wordDetailsModels.add(
        _getWordDetailsModelFromIsarWordDetailsModel(
          wordDetail,
          wordModel,
        ),
      );
    }

    return GetWordsResponseModel(
      words: wordDetailsModels,
      totalWords: totalCount,
      currentPage: _calculateCurrentPage(offset, limit, totalCount),
      totalPages: (totalCount / limit).ceil(),
      wordsPerPage: limit,
    );
  }

  int _calculateCurrentPage(int offset, int limit, int totalCount) {
    if (totalCount == 0) {
      return 0;
    }

    return offset <= 0 ? 1 : (offset ~/ limit) + 1;
  }

  WordDetailsModel _getWordDetailsModelFromIsarWordDetailsModel(
    IsarWordDetailsModel isarWordDetails,
    WordModel wordModel,
  ) =>
      WordDetailsModel(
        word: wordModel,
        shownCount: isarWordDetails.shownCount,
        lastShownDate: isarWordDetails.lastShownDate,
        show: isarWordDetails.show,
        dateMemorized: isarWordDetails.dateMemorized,
        isToBeRemembered: isarWordDetails.isToBeRemembered,
        isMemorized: isarWordDetails.isMemorized,
      );

  Future<IsarWordDetailsModel?> _getWordDetailsFromWord(String word) async {
    return await _hiveBoxes.isar.wordDetails
        .where()
        .wordEqualTo(word)
        .findFirst();
  }

  DateTime _getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Future<List<WordModel>> searchWord({required String query}) async {
    final words = await _hiveBoxes.isar.words
        .filter()
        .valueStartsWith(query)
        .sortByValue()
        .limit(20)
        .findAll();
    return words.map((e) => e.toWordModel()).toList();
  }

  @override
  Future<List<WordDetailsModel>> getWordsDetailsByWords(
      List<WordModel> wordsToBeShown) async {
    final wordsWithDetails = <WordDetailsModel>[];
    for (final word in wordsToBeShown) {
      final value = word.value.getOrElse("");
      if (value.isEmpty) continue;
      final wordDetails = await getWordDetails(word: value);
      wordsWithDetails.add(wordDetails);
    }
    return wordsWithDetails;
  }
}
