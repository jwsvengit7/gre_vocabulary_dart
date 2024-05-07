import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/core/constants.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/core/exceptions.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/data_source/db_keys.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/data_source/isar_local_data_source.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/get_words_response_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/isar_word_details_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/isar_word_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_details_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_test/hive_test.dart';
import 'package:isar/isar.dart';
import 'package:mockito/annotations.dart';
import 'package:path/path.dart' as path;

//TODO: refactor this test

@GenerateMocks(
  [],
)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late IDataBase dataBase;

  late IsarLocalDataSource isarLocalDataSource;

  // generate 10 random words
  const tWords = [
    'abandon',
    'ability',
    'able',
    'abortion',
    'about',
    'above',
    'abroad',
    'absence',
    'absolute',
    'absolutely',
  ];

  final tAllWords = List.generate(
    10,
    (index) => WordModel(
      id: index + 1,
      value: WordObject(tWords[index]),
      definition: 'test definition $index',
      example: 'test example $index',
      isHitWord: index % 2 == 0,
      source: 'test source $index',
    ),
  );

  List<WordDetailsModel> getTWordDetails() => tAllWords
      .map((word) => WordDetailsModel(
            word: word,
            shownCount: 0,
            show: true,
            isMemorized: false,
            isToBeRemembered: false,
            lastShownDate: DateTime.now(),
          ))
      .toList();

  setUp(() async {
    await setUpTestHive();

    final tGeneralBox = await Hive.openBox('vocab_general_data');

    // await Isar.initializeIsarCore(download: true);
    final dartToolDir = path.join(Directory.current.path, '.dart_tool');
    final testTempPath = path.join(dartToolDir, 'test', 'tmp');

    // close all isar instances

    // check if isar instance is already open
    var isar = Isar.getInstance("isar");

    // if yes, close it
    if (isar != null) {
      await isar.writeTxn(() async => await isar.clear());
      await isar.close();
    }

    final tIsar = await Isar.open(
      [IsarWordModelSchema, IsarWordDetailsModelSchema],
      directory: testTempPath,
      name: 'isar',
    );

    // clear all boxes
    dataBase = DB(
      generalDataBox: tGeneralBox,
      isar: tIsar,
    );
    isarLocalDataSource = IsarLocalDataSource(hiveBoxes: dataBase);
  });

  tearDown(() async {
    await dataBase.isar.writeTxn(() async {
      await dataBase.isar.clear();
    });
    await dataBase.isar.close();
  });

  group('areWordsLoaded', () {
    test('should return false if wordsLoaded is not set', () async {
      final result = await isarLocalDataSource.areWordsLoaded();
      expect(result, false);
    });

    test('should return true if wordsLoaded is set', () async {
      await dataBase.generalDataBox.put(DBKeys.wordsLoaded, true);
      final result = await isarLocalDataSource.areWordsLoaded();
      expect(result, true);
    });
  });

  group(
    "saveAllWords",
    () {
      test(
        "should save all words to the isar db",
        () async {
          // act
          await isarLocalDataSource.saveAllWords(
            tAllWords
                .map((e) => WordModel(
                      value: e.value,
                      definition: e.definition,
                      example: e.example,
                      source: e.source,
                      isHitWord: e.isHitWord,
                    ))
                .toList(),
          );

          final result = await dataBase.isar.words.where().findAll();
          final wordModels = result
              .map(
                (e) => WordModel(
                  id: e.id,
                  value: WordObject(e.value),
                  definition: e.definition,
                  example: e.example,
                  isHitWord: e.isHitWord,
                  source: e.source,
                ),
              )
              .toList();

          // assert
          expect(result.length, tAllWords.length);
          expect(wordModels, tAllWords);
        },
      );

      test(
        "should store wordsLoaded in hive general box",
        () async {
          // act
          await isarLocalDataSource.saveAllWords(tAllWords);

          // assert
          expect(
            dataBase.generalDataBox.get(DBKeys.wordsLoaded),
            true,
          );
        },
      );
    },
  );

  group(
    "getAllWords",
    () {
      test(
        "should return all words from the isar db",
        () async {
          // arrange
          const tOffset = 0;
          const tLimit = 5;
          await isarLocalDataSource.saveAllWords(tAllWords);
          final tWordsResponseModel = GetWordsResponseModel(
            words: tAllWords.sublist(0, 5),
            totalWords: 10,
            currentPage: tOffset <= 0 ? 1 : (tOffset ~/ tLimit) + 1,
            totalPages: (10 / tLimit).ceil(),
            wordsPerPage: tLimit,
          );

          // act
          final result =
              await isarLocalDataSource.getAllWords(limit: 5, offset: 0);

          // assert
          expect(result.words.length, 5);
          expect(result.words, tAllWords.sublist(0, 5));
          expect(result, tWordsResponseModel);
        },
      );

      // test that offset works
      test(
        "should return correct offsets words from the isar db",
        () async {
          // arrange
          const tOffset = 5;
          const tLimit = 5;
          await isarLocalDataSource.saveAllWords(tAllWords);
          final tWordsResponseModel = GetWordsResponseModel(
            words: tAllWords.sublist(5, 10),
            totalWords: 10,
            currentPage: tOffset <= 0 ? 1 : (tOffset ~/ tLimit) + 1,
            totalPages: (10 / tLimit).ceil(),
            wordsPerPage: tLimit,
          );

          // act
          final result =
              await isarLocalDataSource.getAllWords(limit: 5, offset: 5);

          // assert
          expect(result.totalWords, 10);
          expect(result.words.length, 5);
          expect(result.words.map((e) => e.copyWith(id: -1)),
              tAllWords.sublist(5, 10).map((e) => e.copyWith(id: -1)));
          expect(result, tWordsResponseModel);
        },
      );
    },
  );

  group(
    "allWordsCount",
    () {
      test(
        "allWordsCount 1",
        () async {
          // arrange
          await isarLocalDataSource.saveAllWords(tAllWords);

          // act
          final count = await isarLocalDataSource.allWordsCount();

          // assert
          expect(count, tAllWords.length);
        },
      );

      test(
        "allWordsCount 2",
        () async {
          // arrange
          final sublist = tAllWords.sublist(0, 5);
          await isarLocalDataSource.saveAllWords(sublist);

          // act
          final count = await isarLocalDataSource.allWordsCount();

          // assert
          expect(count, sublist.length);
        },
      );
    },
  );

  group("getWord", () {
    test("should return word from the isar db", () async {
      // arrange
      final tWord = WordModel(
        value: WordObject("jungle"),
        definition: "jungle is a test word",
        example: "test",
        source: "test",
      );
      await isarLocalDataSource.saveAllWords([tWord]);

      // act
      final result = await isarLocalDataSource.getWord("jungle");

      // assert
      expect(result, tWord.copyWith(id: 1));
    });

    test("should throw a WordNotFoundException if word is not in the Words DB",
        () async {
      // arrange
      final tWord = WordModel(
        value: WordObject("jungle"),
        definition: "jungle is a test word",
        example: "test",
        source: "test",
      );
      await isarLocalDataSource.saveAllWords([tWord]);
      // act
      final call = isarLocalDataSource.getWord;

      final count = await isarLocalDataSource.allWordsCount();

      // assert
      expect(count, 1);
      expect(() => call("abandon"), throwsA(isA<WordNotFoundException>()));
    });
  });

  group(
    "markWordAsShown",
    () {
      test("should mark word as shown", () async {
        // arrange
        final tWord = WordModel(
          value: WordObject("jungle"),
          definition: "jungle is a test word",
          example: "test",
          source: "test",
        );
        await isarLocalDataSource.saveAllWords([tWord]);

        // act
        await isarLocalDataSource.markWordAsShown(
          word: tWord.value.getOrCrash(),
        );

        // assert
        final result = await dataBase.isar.wordDetails
            .where()
            .wordEqualTo("jungle")
            .findFirst();

        expect(result, isNotNull);
        expect(result!.shownCount, 1);
      });

      test("should increment shownCount ", () async {
        // arrange
        final tWord = WordModel(
          value: WordObject("jungle"),
          definition: "jungle is a test word",
          example: "test",
          source: "test",
        );
        await isarLocalDataSource.saveAllWords([tWord]);

        // act
        await isarLocalDataSource.markWordAsShown(
          word: tWord.value.getOrCrash(),
        );
        await isarLocalDataSource.markWordAsShown(
          word: tWord.value.getOrCrash(),
        );

        // assert
        final result = await dataBase.isar.wordDetails
            .where()
            .wordEqualTo("jungle")
            .findFirst();

        expect(result, isNotNull);
        expect(result!.shownCount, 2);
      });

      test(
        "should throw a WordNotFoundException if word is not in the Words DB",
        () async {
          // arrange
          final tWord = WordModel(
            value: WordObject("notInDb"),
            definition: "notInDb",
            example: "notInDb",
            source: "notInDb",
          );

          // act
          final call = isarLocalDataSource.markWordAsShown;

          // assert
          expect(
            () => call(word: tWord.value.getOrCrash()),
            throwsA(
              isA<WordNotFoundException>(),
            ),
          );
        },
      );
    },
  );

  group(
    "getAllWordDetails",
    () {
      test(
        "should return all word details from the isar db with the right offset and limit",
        () async {
          // arrange
          const firstOffSet = 0;
          const secondOffSet = 5;
          const tLimit = 5;

          await isarLocalDataSource.saveAllWords(tAllWords);

          // we need to sort the words details by last shown date in ascending order
          final tWordDetails = getTWordDetails();

          tWordDetails
              .sort((a, b) => a.lastShownDate.compareTo(b.lastShownDate));
          final firstResponse = GetWordsResponseModel<WordDetailsModel>(
            words: tWordDetails.sublist(0, 5),
            totalWords: 10,
            currentPage: firstOffSet <= 0 ? 1 : (firstOffSet ~/ tLimit) + 1,
            totalPages: (10 / tLimit).ceil(),
            wordsPerPage: tLimit,
          );

          final secondResponse = GetWordsResponseModel<WordDetailsModel>(
            words: tWordDetails.sublist(5, 10),
            totalWords: 10,
            currentPage: (secondOffSet ~/ tLimit) + 1,
            totalPages: (10 / tLimit).ceil(),
            wordsPerPage: tLimit,
          );

          // act
          // mark all the words as shown
          for (final word in tAllWords) {
            await isarLocalDataSource.markWordAsShown(
              word: word.value.getOrCrash(),
            );
          }

          final firstResult =
              await isarLocalDataSource.getAllWordDetails(limit: 5, offset: 0);

          final secondResult =
              await isarLocalDataSource.getAllWordDetails(limit: 5, offset: 5);

          final firstReturnedWords =
              firstResult.words.map((e) => e.word).toList();
          final secondReturnedWords =
              secondResult.words.map((e) => e.word).toList();

          final firstExpectedWords =
              tWordDetails.reversed.map((e) => e.word).toList().sublist(0, 5);
          final secondExpectedWords =
              tWordDetails.reversed.map((e) => e.word).toList().sublist(5, 10);

          // assert
          expect(firstResult.words.length, firstResponse.words.length);
          expect(firstReturnedWords, firstExpectedWords);
          expect(firstResult.totalPages, firstResponse.totalPages);
          expect(firstResult.currentPage, firstResponse.currentPage);
          expect(firstResult.totalWords, firstResponse.totalWords);

          expect(secondResult.words.length, secondResponse.words.length);
          expect(secondReturnedWords, secondExpectedWords);
          expect(secondResult.totalPages, secondResponse.totalPages);
          expect(secondResult.currentPage, secondResponse.currentPage);
          expect(secondResult.totalWords, secondResponse.totalWords);
        },
      );
    },
  );

  group(
    "markWordAsMemorized",
    () {
      test("should mark word as memorized", () async {
        // arrange
        final tWord = WordModel(
          value: WordObject("jungle"),
          definition: "jungle is a test word",
          example: "test",
          source: "test",
        );
        await isarLocalDataSource.saveAllWords([tWord]);

        // act
        await isarLocalDataSource.markWordAsMemorized(
          word: tWord.value.getOrCrash(),
        );

        // assert
        final result = await dataBase.isar.wordDetails
            .where()
            .wordEqualTo("jungle")
            .findFirst();

        expect(result, isNotNull);
        expect(result!.isMemorized, true);
      });

      test(
        "should throw a WordNotFoundException if word is not in the Words DB",
        () async {
          // arrange
          final tWord = WordModel(
            value: WordObject("notInDb"),
            definition: "notInDb",
            example: "notInDb",
            source: "notInDb",
          );

          // act
          final call = isarLocalDataSource.markWordAsMemorized;

          // assert
          expect(
            () => call(word: tWord.value.getOrCrash()),
            throwsA(
              isA<WordNotFoundException>(),
            ),
          );
        },
      );
    },
  );

  test("removeWordFromMemorized: should remove word from memorized", () async {
    // arrange
    final tWord = WordModel(
      value: WordObject("jungle"),
      definition: "jungle is a test word",
      example: "test",
      source: "test",
    );
    await isarLocalDataSource.saveAllWords([tWord]);

    // act
    await isarLocalDataSource.markWordAsMemorized(
      word: tWord.value.getOrCrash(),
    );
    await isarLocalDataSource.removeWordFromMemorized(
      word: tWord.value.getOrCrash(),
    );

    // assert
    final result = await dataBase.isar.wordDetails
        .where()
        .wordEqualTo("jungle")
        .findFirst();

    expect(result, isNotNull);
    expect(result!.isMemorized, false);
  });

  group("getWordDetails", () {
    test("should return word details from the isar db", () async {
      // arrange
      final tWord = WordModel(
        value: WordObject("absolutely"),
        definition: "absolutely is a test word",
        example: "test",
        source: "test",
      );
      await isarLocalDataSource.saveAllWords([tWord]);

      // we need to interact with the word details to make sure it is saved in the db
      await isarLocalDataSource.markWordAsShown(word: tWord.value.getOrCrash());

      // act
      final result = await isarLocalDataSource.getWordDetails(
        word: tWord.value.getOrCrash(),
      );

      // assert
      expect(result.word.value.getOrCrash(), tWord.value.getOrCrash());
      expect(result.shownCount, 1);
      expect(result.isMemorized, false);
    });

    test(
      "should throw a WordNotFoundException if word is not in the Words DB",
      () async {
        // arrange
        final tWord = WordModel(
          value: WordObject("notInDb"),
          definition: "notInDb",
          example: "notInDb",
          source: "notInDb",
        );

        // act
        final call = isarLocalDataSource.getWordDetails;

        // assert
        expect(
          () => call(word: tWord.value.getOrCrash()),
          throwsA(
            isA<WordNotFoundException>(),
          ),
        );
      },
    );

    test(
      'should return a fresh word details with word when word details not registered',
      () async {
        // arrange
        final tWord = WordModel(
          value: WordObject("absolutely"),
          definition: "absolutely is a test word",
          example: "test",
          source: "test",
        );
        await isarLocalDataSource.saveAllWords([tWord]);

        // act
        final result = await isarLocalDataSource.getWordDetails(
          word: tWord.value.getOrCrash(),
        );

        // assert
        expect(result.word.value.getOrCrash(), tWord.value.getOrCrash());
        expect(result.shownCount, 0);
        expect(result.isMemorized, false);
      },
    );
  });

  group(
    "getAllMemorizedWords",
    () {
      test(
        "should return all word details from the isar db with the right offset and limit",
        () async {
          // arrange
          const firstOffSet = 0;
          const tLimit = 3;
          const secondOffSet = firstOffSet + tLimit;
          const thirdOffSet = secondOffSet + tLimit;

          await isarLocalDataSource.saveAllWords(tAllWords);

          final tWordDetails = getTWordDetails().sublist(0, 9);
          // we need to sort the words details by
          // last shown date in ascending order
          tWordDetails
              .sort((a, b) => a.lastShownDate.compareTo(b.lastShownDate));
          final firstResponse = GetWordsResponseModel<WordDetailsModel>(
            words: tWordDetails.sublist(firstOffSet, secondOffSet),
            totalWords: tWordDetails.length,
            currentPage: firstOffSet <= 0 ? 1 : (firstOffSet ~/ tLimit) + 1,
            totalPages: (tWordDetails.length / tLimit).ceil(),
            wordsPerPage: tLimit,
          );

          final secondResponse = GetWordsResponseModel<WordDetailsModel>(
            words: tWordDetails.sublist(secondOffSet, thirdOffSet),
            totalWords: tWordDetails.length,
            currentPage: (secondOffSet ~/ tLimit) + 1,
            totalPages: (tWordDetails.length / tLimit).ceil(),
            wordsPerPage: tLimit,
          );

          final thirdResponse = GetWordsResponseModel<WordDetailsModel>(
            words: tWordDetails.sublist(thirdOffSet),
            totalWords: tWordDetails.length,
            currentPage: (thirdOffSet ~/ tLimit) + 1,
            totalPages: (tWordDetails.length / tLimit).ceil(),
            wordsPerPage: tLimit,
          );

          // act
          // mark all the words as shown
          for (final word in tAllWords) {
            await isarLocalDataSource.markWordAsShown(
              word: word.value.getOrCrash(),
            );
          }
          // mark all the words as memorized
          for (final wordDetails in tWordDetails) {
            final word = wordDetails.word.value.getOrCrash();
            await isarLocalDataSource.markWordAsMemorized(word: word);
          }

          final firstResult = await isarLocalDataSource.getAllMemorizedWords(
              limit: tLimit, offset: firstOffSet);

          final secondResult = await isarLocalDataSource.getAllMemorizedWords(
              limit: tLimit, offset: secondOffSet);

          final thirdResult = await isarLocalDataSource.getAllMemorizedWords(
              limit: tLimit, offset: thirdOffSet);

          final firstReturnedWords =
              firstResult.words.map((e) => e.word).toList();
          final secondReturnedWords =
              secondResult.words.map((e) => e.word).toList();

          final thirdReturnedWords =
              thirdResult.words.map((e) => e.word).toList();

          final firstExpectedWords = tWordDetails.reversed
              .map((e) => e.word)
              .toList()
              .sublist(firstOffSet, secondOffSet);
          final secondExpectedWords = tWordDetails.reversed
              .map((e) => e.word)
              .toList()
              .sublist(secondOffSet, thirdOffSet);

          final thirdExpectedWords = tWordDetails.reversed
              .map((e) => e.word)
              .toList()
              .sublist(thirdOffSet);

          // assert
          expect(firstResult.words.length, firstResponse.words.length);
          expect(firstReturnedWords, firstExpectedWords);
          expect(firstResult.totalPages, firstResponse.totalPages);
          expect(firstResult.currentPage, firstResponse.currentPage);
          expect(firstResult.totalWords, firstResponse.totalWords);

          expect(secondResult.words.length, secondResponse.words.length);
          expect(secondReturnedWords, secondExpectedWords);
          expect(secondResult.totalPages, secondResponse.totalPages);
          expect(secondResult.currentPage, secondResponse.currentPage);
          expect(secondResult.totalWords, secondResponse.totalWords);

          expect(thirdResult.words.length, thirdResponse.words.length);
          expect(thirdReturnedWords, thirdExpectedWords);
          expect(thirdResult.totalPages, thirdResponse.totalPages);
          expect(thirdResult.currentPage, thirdResponse.currentPage);
          expect(thirdResult.totalWords, thirdResponse.totalWords);
        },
      );

      test("should not fail when no memorized words", () async {
        // arrange
        await isarLocalDataSource.saveAllWords(tAllWords);

        // act
        final result =
            await isarLocalDataSource.getAllMemorizedWords(limit: 3, offset: 0);

        // assert
        expect(result.words.length, 0);
        expect(result.totalPages, 0);
        expect(result.currentPage, 0);
        expect(result.totalWords, 0);
      });
    },
  );

  group("allMemorizedIndexes", () {
    test("should return all the memorized indexes", () async {
      // arrange
      final tWordDetailsModel = getTWordDetails().sublist(1, 9);
      await isarLocalDataSource.saveAllWords(tAllWords);
      // mark as shown and memorized
      for (final wordDetails in tWordDetailsModel) {
        final word = wordDetails.word.value.getOrCrash();
        await isarLocalDataSource.markWordAsShown(word: word);
        await isarLocalDataSource.markWordAsMemorized(word: word);
      }

      // act
      final allMemorizedIndexes =
          await isarLocalDataSource.allMemorizedIndexes();
      final allMemorizedWords = await isarLocalDataSource.getAllMemorizedWords(
        limit: 100,
        offset: 0,
      );

      // assert
      expect(allMemorizedIndexes.length, allMemorizedWords.words.length);
      expect(
        allMemorizedIndexes,
        allMemorizedWords.words.map((e) => e.word.id ?? -1).toList(),
      );
    });

    test("should return an empty list when no memorized words", () async {
      // arrange
      await isarLocalDataSource.saveAllWords(tAllWords);

      // act
      final allMemorizedIndexes =
          await isarLocalDataSource.allMemorizedIndexes();

      // assert
      expect(allMemorizedIndexes.length, 0);
    });
  });

  // group(
  //   "allRecentlyShownIndexes",
  //   () {
  //     final tWordDetailsModel = getTWordDetails().sublist(1, 7);
  //     final mapOfDateTimeToWord =
  //         <String, List<int>>{}; // dateFormat: dd-MM-yyyy
  //
  //     setUp(
  //       () async {
  //         // await isarLocalDataSource.saveAllWords(tAllWords);
  //
  //         // for (int i = 0; i < tWordDetailsModel.length; i++) {
  //         //   final word = tWordDetailsModel[i].word.value.getOrCrash();
  //         //   fakeAsync((async) async {
  //         //     if (i % 2 == 0) {
  //         //       async.elapse(const Duration(days: 1));
  //         //     } else {
  //         //       async.elapse(const Duration(days: 2));
  //         //     }
  //         //     final now = clock.now();
  //         //     final dateFormat = "${now.day}-${now.month}-${now.year}";
  //         //     if (mapOfDateTimeToWord.containsKey(dateFormat)) {
  //         //       mapOfDateTimeToWord[dateFormat]!.add(i);
  //         //     } else {
  //         //       mapOfDateTimeToWord[dateFormat] = [i];
  //         //     }
  //         //
  //         //     await isarLocalDataSource.markWordAsShown(word: word);
  //         //   });
  //         // }
  //       },
  //     );
  //
  //     test(
  //       "should return all recently shown indexes ",
  //       () async {
  //         await isarLocalDataSource.saveAllWords(tAllWords);
  //         final res = await fakeAsync((async) async {
  //           final length = tWordDetailsModel.length;
  //           var iList = <int>[];
  //
  //           Future.delayed(const Duration(days: 1, seconds: 5), () async {
  //             for (int i = 0; i < (length / 2).round(); i++) {
  //               final word = tWordDetailsModel[i].word.value.getOrCrash();
  //
  //               await isarLocalDataSource.markWordAsShown(word: word);
  //               iList.add(i);
  //             }
  //             var now = clock.now();
  //             String dateFormat = "${now.day}-${now.month}-${now.year}";
  //             mapOfDateTimeToWord[dateFormat] = iList;
  //             iList = [];
  //           });
  //           async.elapse(const Duration(days: 1, seconds: 5));
  //
  //           Future.delayed(const Duration(days: 1, seconds: 5), () async {
  //             for (int i = (length / 2).round(); i < length; i++) {
  //               final word = tWordDetailsModel[i].word.value.getOrCrash();
  //
  //               await isarLocalDataSource.markWordAsShown(word: word);
  //               iList.add(i);
  //             }
  //
  //             final now = clock.now();
  //
  //             final dateFormat = "${now.day}-${now.month}-${now.year}";
  //             mapOfDateTimeToWord[dateFormat] = iList;
  //           });
  //
  //           async.elapse(const Duration(days: 1, seconds: 5));
  //           // act
  //           final allRecentlyShownIndexesInDay1 = await isarLocalDataSource
  //               .allRecentlyShownIndexes(const Duration(days: 1));
  //
  //           final allRecentlyShownIndexesInDay2 = await isarLocalDataSource
  //               .allRecentlyShownIndexes(const Duration(days: 2));
  //
  //           return [
  //             allRecentlyShownIndexesInDay1,
  //             allRecentlyShownIndexesInDay2
  //           ];
  //         }, initialTime: clock.now().subtract(const Duration(days: 3)));
  //
  //         // assert
  //         expect(res[0].length, 3);
  //         expect(res[1].length, 3);
  //         expect(res[0], [5, 3, 1]);
  //         expect(res[1], [6, 4, 2]);
  //       },
  //     );

  // test(
  //   "should return empty list when no recently shown words",
  //   () async {
  //     // arrange
  //     await isarLocalDataSource.saveAllWords(tAllWords);
  //
  //     // act
  //     final allRecentlyShownIndexes =
  //         await isarLocalDataSource.allRecentlyShownIndexes();
  //     final allRecentlyShownWords =
  //         await isarLocalDataSource.getAllRecentlyShownWords(
  //       limit: 100,
  //       offset: 0,
  //     );
  //
  //     // assert
  //     expect(allRecentlyShownIndexes.length,
  //         allRecentlyShownWords.words.length);
  //     expect(allRecentlyShownIndexes, []);
  //   },
  // );
  //   },
  // );

  test("clearWordShowHistory", () async {
    final tList = getTWordDetails().sublist(0, 3);
    // arrange
    await isarLocalDataSource.saveAllWords(tAllWords);
    // mark as shown and memorized
    for (final wordDetails in tList) {
      final word = wordDetails.word.value.getOrCrash();
      await isarLocalDataSource.markWordAsShown(word: word);
      await isarLocalDataSource.markWordAsShown(word: word);
    }

    // act

    for (final wordDetails in tList) {
      final word = wordDetails.word.value.getOrCrash();
      // get the word details to verify the word is marked as shown
      final wordDetailsBeforeClear = await isarLocalDataSource.getWordDetails(
        word: word,
      );
      // clear the word show history
      await isarLocalDataSource.clearWordShowHistory(word: word);

      // get the word details to verify the word is not marked as shown
      final wordDetailsAfterClear = await isarLocalDataSource.getWordDetails(
        word: word,
      );

      // assert
      expect(wordDetailsBeforeClear.word.value.getOrCrash(), word);
      expect(wordDetailsBeforeClear.shownCount, 2);
      expect(wordDetailsBeforeClear.isMemorized, false);

      expect(wordDetailsAfterClear.word.value.getOrCrash(), word);
      expect(wordDetailsAfterClear.shownCount, 0);
      expect(wordDetailsAfterClear.isMemorized, false);
    }
  });

  test("markWordAsToBeRemembered should mark the word as to be remembered",
      () async {
    // arrange
    await isarLocalDataSource.saveAllWords(tAllWords);
    final word = getTWordDetails()[0].word.value.getOrCrash();

    // act
    await isarLocalDataSource.markWordAsToBeRemembered(word: word);

    // assert
    final wordDetails = await isarLocalDataSource.getWordDetails(word: word);
    expect(wordDetails.word.value.getOrCrash(), word);
    expect(wordDetails.isToBeRemembered, true);
  });

  test("removeWordFromToBeRemembered", () async {
    // arrange
    await isarLocalDataSource.saveAllWords(tAllWords);
    final word = getTWordDetails()[0].word.value.getOrCrash();

    // act
    await isarLocalDataSource.markWordAsToBeRemembered(word: word);
    final wordDetailsBeforeRemove =
        await isarLocalDataSource.getWordDetails(word: word);
    await isarLocalDataSource.removeWordFromToBeRemembered(word: word);
    final wordDetailsAfterRemove =
        await isarLocalDataSource.getWordDetails(word: word);

    // assert
    expect(wordDetailsBeforeRemove.word.value.getOrCrash(), word);
    expect(wordDetailsBeforeRemove.isToBeRemembered, true);
    expect(wordDetailsAfterRemove.word.value.getOrCrash(), word);
    expect(wordDetailsAfterRemove.isToBeRemembered, false);
  });

  group("getAllToBeRememberedWords", () {
    test(
        "should return all words to be remembered with the correct offset and limit",
        () async {
      // arrange
      await isarLocalDataSource.saveAllWords(tAllWords);

      final tList = getTWordDetails().sublist(0, 7);
      const firstOffset = 0;
      const tLimit = 3;
      const secondOffset = 3;

      // sort tList in descending order of lastShownDate
      tList.sort((a, b) => b.lastShownDate.compareTo(a.lastShownDate));

      // mark as to be remembered
      for (final wordDetails in tList) {
        final word = wordDetails.word.value.getOrCrash();
        await isarLocalDataSource.markWordAsToBeRemembered(word: word);
      }

      final tLastShown = DateTime.now();

      // act
      final allToBeRememberedWordsFirstOffset =
          await isarLocalDataSource.getAllToBeRememberedWords(
        limit: tLimit,
        offset: firstOffset,
      );

      final allToBeRememberedWordsSecondOffset =
          await isarLocalDataSource.getAllToBeRememberedWords(
        limit: tLimit,
        offset: secondOffset,
      );

      final areAllWordsToBeRemembered = allToBeRememberedWordsFirstOffset.words
          .every((element) => element.isToBeRemembered);
      final areAllWordsToBeRemembered2 = allToBeRememberedWordsSecondOffset
          .words
          .every((element) => element.isToBeRemembered);

      // assert
      expect(allToBeRememberedWordsFirstOffset.words.length, tLimit);
      expect(allToBeRememberedWordsSecondOffset.words.length, tLimit);

      expect(
        allToBeRememberedWordsFirstOffset.words
            .map((e) => e.copyWith(lastShownDate: tLastShown))
            .toList(),
        tList.reversed
            .map((e) =>
                e.copyWith(isToBeRemembered: true, lastShownDate: tLastShown))
            .toList()
            .sublist(0, 3),
      );
      expect(areAllWordsToBeRemembered, true);
      expect(areAllWordsToBeRemembered2, true);
      expect(
        allToBeRememberedWordsSecondOffset.words
            .map((e) => e.copyWith(lastShownDate: tLastShown))
            .toList(),
        tList.reversed
            .map(
              (e) =>
                  e.copyWith(isToBeRemembered: true, lastShownDate: tLastShown),
            )
            .toList()
            .sublist(3, 6),
      );
    });

    test("should return result in descending lastShownDate order", () async {
      // arrange
      await isarLocalDataSource.saveAllWords(tAllWords);
      final tList = getTWordDetails().sublist(0, 7);

      // sort tList in descending order of lastShownDate
      tList.sort((a, b) => b.lastShownDate.compareTo(a.lastShownDate));

      // mark as to be remembered
      for (final wordDetails in tList) {
        final word = wordDetails.word.value.getOrCrash();
        await isarLocalDataSource.markWordAsToBeRemembered(word: word);
      }

      final tLastShown = DateTime.now();

      // act
      final wordsToBeRemembered =
          await isarLocalDataSource.getAllToBeRememberedWords(
        limit: tList.length,
        offset: 0,
      );

      // assert
      expect(
        wordsToBeRemembered.words
            .map((e) => e.copyWith(lastShownDate: tLastShown))
            .toList(),
        tList.reversed
            .map(
              (e) =>
                  e.copyWith(isToBeRemembered: true, lastShownDate: tLastShown),
            )
            .toList(),
      );
    });

    test("should return empty response when no words to be remembered",
        () async {
      // arrange

      await isarLocalDataSource.saveAllWords(tAllWords);

      // act
      final allToBeRememberedWords = await isarLocalDataSource
          .getAllToBeRememberedWords(limit: 10, offset: 0);

      // assert
      expect(allToBeRememberedWords,
          GetWordsResponseModel<WordDetailsModel>.empty());
    });
  });

  group("getAllWordsForSource", () {
    test("should return all words for a source", () async {
      // arrange
      final wordPerSource = <WordsListKey, List<WordModel>>{};
      final allWords = <WordModel>[];

      for (int i = 0; i < tAllWords.length; i++) {
        final rem = i % 3;
        final source = "source$rem";
        final word = tAllWords[i].copyWith(
          source: source,
        );
        allWords.add(word);
        final list = wordPerSource[source] ??= [];
        list.add(word);
        wordPerSource[source] = list;
      }

      await isarLocalDataSource.saveAllWords(allWords);

      // act
      for (WordsListKey key in wordPerSource.keys) {
        final allWordsForSource =
            await isarLocalDataSource.getAllWordsForSource(
          source: key,
          limit: 10,
          offset: 0,
        );

        // assert
        expect(allWordsForSource.words.length, wordPerSource[key]?.length);
        expect(allWordsForSource.words, wordPerSource[key]);
      }
    });

    test(
      "should return words with the correct limit and offset",
      () async {
        // arrange
        final wordPerSource = <WordsListKey, List<WordModel>>{};
        final allWords = <WordModel>[];

        for (int i = 0; i < tAllWords.length; i++) {
          final rem = i % 2;
          final source = "source$rem";
          final word = tAllWords[i].copyWith(
            source: source,
          );
          allWords.add(word);
          final list = wordPerSource[source] ??= [];
          list.add(word);
          wordPerSource[source] = list;
        }

        await isarLocalDataSource.saveAllWords(allWords);

        // act
        for (WordsListKey key in wordPerSource.keys) {
          final allWordsForSource =
              await isarLocalDataSource.getAllWordsForSource(
            source: key,
            limit: 3,
            offset: 0,
          );

          final allWordsForSource2 =
              await isarLocalDataSource.getAllWordsForSource(
            source: key,
            limit: 3,
            offset: 3,
          );

          // assert
          expect(allWordsForSource.words.length, 3);
          expect(allWordsForSource2.words.length, 2);
          expect(allWordsForSource.words, wordPerSource[key]?.sublist(0, 3));
          expect(allWordsForSource2.words, wordPerSource[key]?.sublist(3, 5));
        }
      },
    );

    test(
      "should throw a WordSourceNotListedException when no word for source",
      () async {
        // arrange
        await isarLocalDataSource.saveAllWords(tAllWords);

        // act
        final call = isarLocalDataSource.getAllWordsForSource;

        // assert
        expect(
          () => call(
            source: "unknownSource",
            limit: 10,
            offset: 0,
          ),
          throwsA(isA<WordSourceNotListedException>()),
        );
      },
    );
  });

  group("getAllShownWords", () {
    test(
      "should return shown words in descending order with the correct limit and offset",
      () async {
        // arrange
        await isarLocalDataSource.saveAllWords(tAllWords);

        final tList = getTWordDetails().sublist(0, 7);

        // sort tList in descending order of lastShownDate
        tList.sort((a, b) => b.lastShownDate.compareTo(a.lastShownDate));

        // mark as to be remembered
        for (final wordDetails in tList) {
          final word = wordDetails.word.value.getOrCrash();
          await isarLocalDataSource.markWordAsShown(word: word);
        }

        final tLastShown = DateTime.now();

        // act
        final allShownWordsFirstOffset =
            await isarLocalDataSource.getAllShownWords(
          limit: 3,
          offset: 0,
        );

        final allShownWordsSecondOffset =
            await isarLocalDataSource.getAllShownWords(
          limit: 3,
          offset: 3,
        );

        // assert
        expect(allShownWordsFirstOffset.words.length, 3);
        expect(allShownWordsSecondOffset.words.length, 3);

        expect(
          allShownWordsFirstOffset.words
              .map((e) => e.copyWith(lastShownDate: tLastShown))
              .toList(),
          tList.reversed
              .map(
                (e) => e.copyWith(lastShownDate: tLastShown, shownCount: 1),
              )
              .toList()
              .sublist(0, 3),
        );
        expect(
          allShownWordsSecondOffset.words
              .map((e) => e.copyWith(lastShownDate: tLastShown))
              .toList(),
          tList.reversed
              .map(
                (e) => e.copyWith(lastShownDate: tLastShown, shownCount: 1),
              )
              .toList()
              .sublist(3, 6),
        );
      },
    );
  });

  group("getHitWords", () {
    test(
      "should return all words in descending order with the correct limit and offset",
      () async {
        final allWords = tAllWords;
        // sort words on value;
        allWords.sort(
            (a, b) => a.value.getOrCrash().compareTo(b.value.getOrCrash()));
        // arrange
        await isarLocalDataSource.saveAllWords(allWords);

        // act
        final firstHitWords = await isarLocalDataSource.getHitWords(
          limit: 3,
          offset: 0,
        );

        final secondHitWords = await isarLocalDataSource.getHitWords(
          limit: 3,
          offset: 3,
        );

        final tHitWords =
            allWords.where((element) => element.isHitWord).toList();

        // assert
        expect(firstHitWords.words.length, 3);
        expect(secondHitWords.words.length, 2);
        expect(firstHitWords.words, tHitWords.sublist(0, 3));
        expect(secondHitWords.words, tHitWords.sublist(3, 5));
      },
    );

    test("should return empty response when no hit words", () async {
      // arrange
      await isarLocalDataSource.saveAllWords(
          tAllWords.map((e) => e.copyWith(isHitWord: false)).toList());

      // act
      final hitWords = await isarLocalDataSource.getHitWords(
        limit: 3,
        offset: 0,
      );

      // assert
      expect(hitWords, GetWordsResponseModel<WordModel>.empty());
    });
  });

  group(
    "getWordsByIndexes",
    () {
      test(
        "should return words with the correct indexes",
        () async {
          // arrange

          await isarLocalDataSource.saveAllWords(tAllWords);

          for (final word in tAllWords) {
            await isarLocalDataSource.markWordAsShown(
                word: word.value.getOrCrash());
          }

          final tWordsFromIsar =
              (await isarLocalDataSource.getAllWords(limit: 10, offset: 0))
                  .words;

          final firstWordSet =
              tWordsFromIsar.sublist(0, tWordsFromIsar.length ~/ 2);
          final secondWordSet =
              tWordsFromIsar.sublist(tWordsFromIsar.length ~/ 2);

          // act
          final words1 = await isarLocalDataSource.getWordsByIndexes(
            firstWordSet.map((e) => e.id ?? -1).toList(),
          );

          final words2 = await isarLocalDataSource.getWordsByIndexes(
            secondWordSet.map((e) => e.id ?? -1).toList(),
          );

          final combined = await isarLocalDataSource.getWordsByIndexes(
            tWordsFromIsar.map((e) => e.id ?? -1).toList(),
          );

          // assert
          expect(words1, firstWordSet);
          expect(words2, secondWordSet);
          expect(combined, tWordsFromIsar);
        },
      );

      test(
        "should return empty response when no words details for indexes",
        () async {
          // arrange
          await isarLocalDataSource.saveAllWords(tAllWords);
          final length = tAllWords.length;

          // act
          final words = await isarLocalDataSource
              .getWordsByIndexes([length + 1, length + 2, length + 3]);

          // assert
          expect(words, []);
        },
      );
    },
  );

  test(
    "getAllWordsShownToday should return all words shown today",
    () async {
      // arrange
      await isarLocalDataSource.saveAllWords(tAllWords);

      final tList = getTWordDetails().sublist(0, 7);

      // sort tList in descending order of lastShownDate
      tList.sort((a, b) => b.lastShownDate.compareTo(a.lastShownDate));

      // mark as to be remembered
      for (final wordDetails in tList) {
        final word = wordDetails.word.value.getOrCrash();
        await isarLocalDataSource.markWordAsShown(word: word);
      }

      final tLastShown = DateTime.now();

      // act
      final allShownWordsFirstOffset =
          await isarLocalDataSource.getAllWordsShownToday(
        limit: 3,
        offset: 0,
      );

      final allShownWordsSecondOffset =
          await isarLocalDataSource.getAllWordsShownToday(
        limit: 3,
        offset: 3,
      );

      // assert
      expect(allShownWordsFirstOffset.words.length, 3);
      expect(allShownWordsSecondOffset.words.length, 3);

      expect(
        allShownWordsFirstOffset.words
            .map((e) => e.copyWith(lastShownDate: tLastShown))
            .toList(),
        tList.reversed
            .map(
              (e) => e.copyWith(lastShownDate: tLastShown, shownCount: 1),
            )
            .toList()
            .sublist(0, 3),
      );
      expect(
        allShownWordsSecondOffset.words
            .map((e) => e.copyWith(lastShownDate: tLastShown))
            .toList(),
        tList.reversed
            .map(
              (e) => e.copyWith(lastShownDate: tLastShown, shownCount: 1),
            )
            .toList()
            .sublist(3, 6),
      );
    },
  );
}
