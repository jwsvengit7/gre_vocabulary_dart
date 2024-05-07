import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gre_vocabulary/src/core/core.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/core/failures.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/get_words_response.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word_details.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/value_objects.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/data_source/local_data_source.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/get_words_response_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_details_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/repository/vocabulary_repository.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/repository/wordlists_csv_parsers/csv_parser.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'vocabulary_repository_test.mocks.dart';

@GenerateMocks([LocalDataSource, CSVListsParser])
void main() {
  late MockLocalDataSource localDataSource;
  late MockCSVListsParser csvListsParser;
  late VocabularyRepository vocabularyRepository;
  late List<WordModel> tCsvParsingResponse;

  final tWordModel = WordModel(
    value: WordObject('test'),
    definition: "test",
    example: "test",
    isHitWord: false,
    source: "test",
  );

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

  final tWordModels = List.generate(
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

  List<WordDetailsModel> getTWordDetails() => tWordModels
      .map((word) => WordDetailsModel(
            word: word,
            shownCount: 0,
            show: true,
            isMemorized: false,
            isToBeRemembered: false,
            lastShownDate: DateTime.now(),
          ))
      .toList();

  final tGetWordsResponseModel = GetWordsResponseModel<WordModel>(
    words: tWordModels,
    totalWords: 100,
    currentPage: 1,
    totalPages: 10,
    wordsPerPage: 10,
  );
  setUp(() {
    localDataSource = MockLocalDataSource();
    csvListsParser = MockCSVListsParser();

    tCsvParsingResponse = [];

    vocabularyRepository = VocabularyRepository(
      localDataSource: localDataSource,
      csvListsParser: csvListsParser,
    );
  });

  /// Test for loadAllWordsIntoDb()
  group('loadAllWordsIntoLocalDb', () {
    setUp(() {
      when(localDataSource.saveAllWords(any))
          .thenAnswer((_) async => const SuccessModel());
    });

    wordsLoadedState({required bool areWordsLoaded}) {
      when(localDataSource.areWordsLoaded())
          .thenAnswer((_) async => areWordsLoaded);
    }

    test(
        'should call the local data source to check if the words are already loaded',
        () async {
      // arrange
      wordsLoadedState(areWordsLoaded: true);
      // act
      await vocabularyRepository.loadAllWordsIntoDb();
      // assert
      verify(localDataSource.areWordsLoaded());
    });

    test('should return a success message when the words are already loaded',
        () async {
      // arrange
      wordsLoadedState(areWordsLoaded: true);
      // act
      final result = await vocabularyRepository.loadAllWordsIntoDb();
      // assert
      expect(result.isRight(), true);
    });

    test('should call the csv parser once to parse the csv file', () async {
      // arrange
      wordsLoadedState(areWordsLoaded: false);
      when(csvListsParser.parse())
          .thenAnswer((_) => Future.value(Right(tCsvParsingResponse)));
      // act
      await vocabularyRepository.loadAllWordsIntoDb();
      // assert
      verify(csvListsParser.parse()).called(1);
    });

    test('should return a failure when the csv parser fails', () async {
      // arrange
      wordsLoadedState(areWordsLoaded: false);
      when(csvListsParser.parse()).thenAnswer((_) =>
          Future.value(left(const VocabularyFailure.unableToParseCSV())));

      // act
      final result = await vocabularyRepository.loadAllWordsIntoDb();
      // assert
      expect(result.isLeft(), true);
    });

    test('should call the local data source to save all words', () async {
      // arrange
      wordsLoadedState(areWordsLoaded: false);
      when(csvListsParser.parse())
          .thenAnswer((_) => Future.value(Right(tCsvParsingResponse)));
      // act
      await vocabularyRepository.loadAllWordsIntoDb();
      // assert
      verify(localDataSource.saveAllWords(tCsvParsingResponse)).called(1);
    });

    test(
        'should return a failure when the local data source fails to save the words',
        () async {
      // arrange
      wordsLoadedState(areWordsLoaded: false);
      when(csvListsParser.parse())
          .thenAnswer((_) => Future.value(Right(tCsvParsingResponse)));
      when(localDataSource.saveAllWords(any))
          .thenThrow(Exception('Unable to save words'));
      // act
      final result = await vocabularyRepository.loadAllWordsIntoDb();
      // assert
      expect(result.isLeft(), true);
    });

    test('should return success when everything goes well', () async {
      // arrange
      wordsLoadedState(areWordsLoaded: false);
      when(csvListsParser.parse())
          .thenAnswer((_) => Future.value(Right(tCsvParsingResponse)));
      // act
      final result = await vocabularyRepository.loadAllWordsIntoDb();
      // assert
      expect(result.isRight(), true);
    });
  });

  group('getAllWords', () {
    test(
        'should return [VocabularyFailure] when limit is more than maxWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(101);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllWords(
        limit: tLimit,
        offset: tOffset,
      );
      // assert

      expect(result.isLeft(), true);

      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should return [VocabularyFailure] when limit is less than minWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(4);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return [VocabularyFailure] when offset is negative', () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(-1);

      // act
      final result = await vocabularyRepository.getAllWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source once to get all words', () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(0);

      when(localDataSource.getAllWords(
              limit: anyNamed('limit'), offset: anyNamed('offset')))
          .thenAnswer((_) async => tGetWordsResponseModel);

      // act
      await vocabularyRepository.getAllWords(limit: tLimit, offset: tOffset);

      // assert
      verify(
        localDataSource.getAllWords(
          limit: tLimit.getOrElse(10),
          offset: tOffset.getOrElse(0),
        ),
      ).called(1);
    });

    test('should return a failure when the local data source fails', () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(0);

      when(localDataSource.getAllWords(
              limit: anyNamed('limit'), offset: anyNamed('offset')))
          .thenThrow(Exception('Unable to get words'));

      // act
      final result = await vocabularyRepository.getAllWords(
          limit: tLimit, offset: tOffset);

      // assert
      expect(result.isLeft(), true);
    });

    test(
        'should return a GetWordsResponse<Word> of words when everything goes well',
        () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(0);

      when(localDataSource.getAllWords(
              limit: anyNamed('limit'), offset: anyNamed('offset')))
          .thenAnswer((_) async => tGetWordsResponseModel);

      // act
      final result = await vocabularyRepository.getAllWords(
          limit: tLimit, offset: tOffset);

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<GetWordsResponse<Word>>());
      expect(
          (result.fold(id, id) as GetWordsResponse<Word>).words, tWordModels);
    });
  });

  /// getAllWordsForSource
  group('getAllWordsForSource', () {
    const tSource = 'source';

    test(
        'should return [VocabularyFailure] when limit is more than maxWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(101);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllWordsForSource(
        source: tSource,
        limit: tLimit,
        offset: tOffset,
      );
      // assert

      expect(result.isLeft(), true);

      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should return [VocabularyFailure] when limit is less than minWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(4);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllWordsForSource(
        source: tSource,
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return [VocabularyFailure] when offset is negative', () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(-1);

      // act
      final result = await vocabularyRepository.getAllWordsForSource(
        source: tSource,
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source once to get all words for source',
        () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(0);

      when(
        localDataSource.getAllWordsForSource(
          source: anyNamed('source'),
          limit: anyNamed('limit'),
          offset: anyNamed(
            'offset',
          ),
        ),
      ).thenAnswer((_) async => tGetWordsResponseModel);

      // act
      await vocabularyRepository.getAllWordsForSource(
          source: tSource, limit: tLimit, offset: tOffset);

      // assert
      verify(
        localDataSource.getAllWordsForSource(
          source: tSource,
          limit: tLimit.getOrElse(10),
          offset: tOffset.getOrElse(0),
        ),
      ).called(1);
    });

    test('should return a [VocabularyFailure] when the local data source fails',
        () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(0);

      when(
        localDataSource.getAllWordsForSource(
          source: anyNamed('source'),
          limit: anyNamed('limit'),
          offset: anyNamed(
            'offset',
          ),
        ),
      ).thenThrow(Exception('Unable to get words'));

      // act
      final result = await vocabularyRepository.getAllWordsForSource(
          source: tSource, limit: tLimit, offset: tOffset);

      // assert
      expect(result.isLeft(), true);
    });

    test(
        'should return a GetWordsResponse<Word> of words when everything goes well',
        () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(0);

      when(
        localDataSource.getAllWordsForSource(
          source: anyNamed('source'),
          limit: anyNamed('limit'),
          offset: anyNamed(
            'offset',
          ),
        ),
      ).thenAnswer((_) async => tGetWordsResponseModel);

      // act
      final result = await vocabularyRepository.getAllWordsForSource(
          source: tSource, limit: tLimit, offset: tOffset);

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<GetWordsResponse<Word>>());
      expect(
          (result.fold(id, id) as GetWordsResponse<Word>).words, tWordModels);
    });
  });

  group('getAllWordDetails', () {
    final tWordDetailsModels = tWordModels
        .map(
          (e) => WordDetailsModel(
            word: e,
            shownCount: 0,
            show: false,
            isMemorized: false,
            isToBeRemembered: false,
            lastShownDate: DateTime.now(),
          ),
        )
        .toList();
    final tGetWordDetailsResponseModel =
        GetWordsResponseModel<WordDetailsModel>(
      words: tWordDetailsModels,
      totalWords: 100,
      currentPage: 1,
      totalPages: 10,
      wordsPerPage: 10,
    );

    final tLimit = PaginationLimit(10);
    final tOffset = PaginationOffSet(0);

    setUp(() {
      when(
        localDataSource.getAllWordDetails(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        ),
      ).thenAnswer((_) async => tGetWordDetailsResponseModel);
    });

    test(
        'should return [VocabularyFailure] when limit is more than maxWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(101);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllWordDetails(
        limit: tLimit,
        offset: tOffset,
      );
      // assert

      expect(result.isLeft(), true);

      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should return [VocabularyFailure] when limit is less than minWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(4);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllWordDetails(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return [VocabularyFailure] when offset is negative', () async {
      // arrange

      final tOffset = PaginationOffSet(-1);

      // act
      final result = await vocabularyRepository.getAllWordDetails(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should call local data source getAllWordDetails once to get all words details',
        () async {
      // act
      await vocabularyRepository.getAllWordDetails(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      verify(
        localDataSource.getAllWordDetails(
          limit: tLimit.getOrElse(10),
          offset: tOffset.getOrElse(0),
        ),
      ).called(1);
    });

    test('should return a failure when getAllWordDetails throws an exception',
        () async {
      // arrange
      when(
        localDataSource.getAllWordDetails(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        ),
      ).thenThrow(Exception('Unable to get words'));

      // act
      final res = await vocabularyRepository.getAllWordDetails(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should return a GetWordsResponse<WordDetails> of words when everything goes well',
        () async {
      // act
      final result = await vocabularyRepository.getAllWordDetails(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<GetWordsResponse<WordDetails>>());
      expect((result.fold(id, id) as GetWordsResponse<WordDetails>).words,
          tWordDetailsModels);
    });
  });

  group('getWordDetails', () {
    final tWordModel = WordModel(
      value: WordObject('test'),
      definition: "test",
      example: "test",
      isHitWord: false,
      source: "test",
    );

    final tWordDetailsModel = WordDetailsModel(
      word: tWordModel,
      shownCount: 0,
      show: false,
      isMemorized: false,
      isToBeRemembered: false,
      lastShownDate: DateTime.now(),
    );

    setUp(() {
      when(localDataSource.getWordDetails(word: anyNamed('word')))
          .thenAnswer((_) async => tWordDetailsModel);
    });

    test('should return a failure if word is not valid', () async {
      // act
      final t1 = await vocabularyRepository.getWordDetails(
        word: WordObject(''),
      );

      final t2 = await vocabularyRepository.getWordDetails(
        word: WordObject('a445dd'),
      );
      final t3 = await vocabularyRepository.getWordDetails(
        word: WordObject('8308_4'),
      );

      // assert
      expect(t1.isLeft(), true);
      expect(t1.fold(id, id), isA<VocabularyFailure>());
      expect(t2.isLeft(), true);
      expect(t2.fold(id, id), isA<VocabularyFailure>());
      expect(t3.isLeft(), true);
      expect(t3.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should call local data source getWordDetails once to get word details',
        () async {
      // act
      await vocabularyRepository.getWordDetails(
        word: tWordModel.value,
      );

      // assert
      verify(
        localDataSource.getWordDetails(word: "test"),
      ).called(1);
    });

    test('should return a failure when getWordDetails throws an exception',
        () async {
      // arrange

      when(localDataSource.getWordDetails(word: anyNamed('word')))
          .thenThrow(Exception('Unable to get word details'));

      // act
      final res = await vocabularyRepository.getWordDetails(
        word: tWordModel.value,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return a WordDetails when everything goes well', () async {
      // act
      final result = await vocabularyRepository.getWordDetails(
        word: tWordModel.value,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<WordDetails>());
      expect((result.fold(id, id) as WordDetails).word, tWordDetailsModel.word);
    });
  });

  group("markWordAsShown", () {
    setUp(() {
      when(localDataSource.markWordAsShown(word: anyNamed('word')))
          .thenAnswer((_) async => const SuccessModel());
    });

    test('should return a failure if word is not valid', () async {
      // act
      final t1 = await vocabularyRepository.markWordAsShown(
        word: WordObject(''),
      );

      final t2 = await vocabularyRepository.markWordAsShown(
        word: WordObject('a445dd'),
      );
      final t3 = await vocabularyRepository.markWordAsShown(
        word: WordObject('8308_4'),
      );

      // assert
      expect(t1.isLeft(), true);
      expect(t1.fold(id, id), isA<VocabularyFailure>());
      expect(t2.isLeft(), true);
      expect(t2.fold(id, id), isA<VocabularyFailure>());
      expect(t3.isLeft(), true);
      expect(t3.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should call local data source markWordAsShown once to mark word as shown',
        () async {
      // act
      await vocabularyRepository.markWordAsShown(
        word: tWordModel.value,
      );

      // assert
      verify(
        localDataSource.markWordAsShown(word: "test"),
      ).called(1);
    });

    test('should return a failure when markWordAsShown throws an exception',
        () async {
      // arrange

      when(localDataSource.markWordAsShown(word: anyNamed('word')))
          .thenThrow(Exception('Unable to mark word as shown'));

      // act
      final res = await vocabularyRepository.markWordAsShown(
        word: tWordModel.value,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return a SuccessModel when everything goes well', () async {
      // act
      final result = await vocabularyRepository.markWordAsShown(
        word: tWordModel.value,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<SuccessModel>());
    });
  });

  group("markWordAsToBeRemembered", () {
    setUp(() {
      when(localDataSource.markWordAsToBeRemembered(word: anyNamed('word')))
          .thenAnswer((_) async => const SuccessModel());
    });

    test('should return a failure if word is not valid', () async {
      // act
      final t1 = await vocabularyRepository.markWordAsToBeRemembered(
        word: WordObject(''),
      );

      final t2 = await vocabularyRepository.markWordAsToBeRemembered(
        word: WordObject('a445dd'),
      );
      final t3 = await vocabularyRepository.markWordAsToBeRemembered(
        word: WordObject('8308_4'),
      );

      // assert
      expect(t1.isLeft(), true);
      expect(t1.fold(id, id), isA<VocabularyFailure>());
      expect(t2.isLeft(), true);
      expect(t2.fold(id, id), isA<VocabularyFailure>());
      expect(t3.isLeft(), true);
      expect(t3.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source markWordAsToBeRemembered once',
        () async {
      // act
      await vocabularyRepository.markWordAsToBeRemembered(
        word: tWordModel.value,
      );

      // assert
      verify(
        localDataSource.markWordAsToBeRemembered(word: "test"),
      ).called(1);
    });

    test(
        'should return a failure when markWordAsToBeRemembered throws an exception',
        () async {
      // arrange

      when(localDataSource.markWordAsToBeRemembered(word: anyNamed('word')))
          .thenThrow(Exception('Unable to mark word as to be remembered'));

      // act
      final res = await vocabularyRepository.markWordAsToBeRemembered(
        word: tWordModel.value,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return a Success when everything goes well', () async {
      // act
      final result = await vocabularyRepository.markWordAsToBeRemembered(
        word: tWordModel.value,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<Success>());
    });
  });

  group("clearWordShowHistory", () {
    setUp(() {
      when(localDataSource.clearWordShowHistory(word: anyNamed('word')))
          .thenAnswer((_) async => const SuccessModel());
    });

    test('should return a failure if word is not valid', () async {
      // act
      final t1 = await vocabularyRepository.clearWordShowHistory(
        word: WordObject(''),
      );

      final t2 = await vocabularyRepository.clearWordShowHistory(
        word: WordObject('a445dd'),
      );
      final t3 = await vocabularyRepository.clearWordShowHistory(
        word: WordObject('8308_4'),
      );

      // assert
      expect(t1.isLeft(), true);
      expect(t1.fold(id, id), isA<VocabularyFailure>());
      expect(t2.isLeft(), true);
      expect(t2.fold(id, id), isA<VocabularyFailure>());
      expect(t3.isLeft(), true);
      expect(t3.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source clearWordShowHistory once', () async {
      // act
      await vocabularyRepository.clearWordShowHistory(
        word: tWordModel.value,
      );

      // assert
      verify(
        localDataSource.clearWordShowHistory(word: "test"),
      ).called(1);
    });

    test(
        'should return a failure when clearWordShowHistory throws an exception',
        () async {
      // arrange

      when(localDataSource.clearWordShowHistory(word: anyNamed('word')))
          .thenThrow(Exception('Unable to clear word show history'));

      // act
      final res = await vocabularyRepository.clearWordShowHistory(
        word: tWordModel.value,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return a Success when clearWordShowHistory successful',
        () async {
      // act
      final result = await vocabularyRepository.clearWordShowHistory(
        word: tWordModel.value,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<Success>());
    });
  });

  group("markWordAsMemorized", () {
    setUp(() {
      when(localDataSource.markWordAsMemorized(word: anyNamed('word')))
          .thenAnswer((_) async => const SuccessModel());
    });

    test('should return a failure if word is not valid', () async {
      // act
      final t1 = await vocabularyRepository.markWordAsMemorized(
        word: WordObject(''),
      );

      final t2 = await vocabularyRepository.markWordAsMemorized(
        word: WordObject('a445dd'),
      );
      final t3 = await vocabularyRepository.markWordAsMemorized(
        word: WordObject('8308_4'),
      );

      // assert
      expect(t1.isLeft(), true);
      expect(t1.fold(id, id), isA<VocabularyFailure>());
      expect(t2.isLeft(), true);
      expect(t2.fold(id, id), isA<VocabularyFailure>());
      expect(t3.isLeft(), true);
      expect(t3.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source markWordAsMemorized once', () async {
      // act
      await vocabularyRepository.markWordAsMemorized(
        word: tWordModel.value,
      );

      // assert
      verify(
        localDataSource.markWordAsMemorized(word: "test"),
      ).called(1);
    });

    test('should return a failure when markWordAsMemorized throws an exception',
        () async {
      // arrange

      when(localDataSource.markWordAsMemorized(word: anyNamed('word')))
          .thenThrow(Exception('Unable to mark word as memorized'));

      // act
      final res = await vocabularyRepository.markWordAsMemorized(
        word: tWordModel.value,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return a Success when markWordAsMemorized successful',
        () async {
      // act
      final result = await vocabularyRepository.markWordAsMemorized(
        word: tWordModel.value,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<Success>());
    });
  });

  group("removeWordFromMemorized", () {
    setUp(() {
      when(localDataSource.removeWordFromMemorized(word: anyNamed('word')))
          .thenAnswer((_) async => const SuccessModel());
    });

    test('should return a failure if word is not valid', () async {
      // act
      final t1 = await vocabularyRepository.removeWordFromMemorized(
        word: WordObject(''),
      );

      final t2 = await vocabularyRepository.removeWordFromMemorized(
        word: WordObject('a445dd'),
      );
      final t3 = await vocabularyRepository.removeWordFromMemorized(
        word: WordObject('8308_4'),
      );

      // assert
      expect(t1.isLeft(), true);
      expect(t1.fold(id, id), isA<VocabularyFailure>());
      expect(t2.isLeft(), true);
      expect(t2.fold(id, id), isA<VocabularyFailure>());
      expect(t3.isLeft(), true);
      expect(t3.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source removeWordFromMemorized once',
        () async {
      // act
      await vocabularyRepository.removeWordFromMemorized(
        word: tWordModel.value,
      );

      // assert
      verify(
        localDataSource.removeWordFromMemorized(word: "test"),
      ).called(1);
    });

    test(
        'should return a failure when removeWordFromMemorized throws an exception',
        () async {
      // arrange

      when(localDataSource.removeWordFromMemorized(word: anyNamed('word')))
          .thenThrow(Exception('Unable to remove word from memorized'));

      // act
      final res = await vocabularyRepository.removeWordFromMemorized(
        word: tWordModel.value,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return a Success when removeWordFromMemorized successful ',
        () async {
      // act
      final result = await vocabularyRepository.removeWordFromMemorized(
        word: tWordModel.value,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<Success>());
    });
  });

  group("removeWordFromToBeRemembered", () {
    setUp(() {
      when(localDataSource.removeWordFromToBeRemembered(word: anyNamed('word')))
          .thenAnswer((_) async => const SuccessModel());
    });

    test('should return a failure if word is not valid', () async {
      // act
      final t1 = await vocabularyRepository.removeWordFromToBeRemembered(
        word: WordObject(''),
      );

      final t2 = await vocabularyRepository.removeWordFromToBeRemembered(
        word: WordObject('a445dd'),
      );
      final t3 = await vocabularyRepository.removeWordFromToBeRemembered(
        word: WordObject('8308_4'),
      );

      // assert
      expect(t1.isLeft(), true);
      expect(t1.fold(id, id), isA<VocabularyFailure>());
      expect(t2.isLeft(), true);
      expect(t2.fold(id, id), isA<VocabularyFailure>());
      expect(t3.isLeft(), true);
      expect(t3.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source removeWordFromToBeRemembered once',
        () async {
      // act
      await vocabularyRepository.removeWordFromToBeRemembered(
        word: tWordModel.value,
      );

      // assert
      verify(
        localDataSource.removeWordFromToBeRemembered(word: "test"),
      ).called(1);
    });

    test(
        'should return a failure when removeWordFromToBeRemembered throws an exception',
        () async {
      // arrange

      when(localDataSource.removeWordFromToBeRemembered(word: anyNamed('word')))
          .thenThrow(Exception('Unable to remove word from to be remembered'));

      // act
      final res = await vocabularyRepository.removeWordFromToBeRemembered(
        word: tWordModel.value,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should return a Success when removeWordFromToBeRemembered successful ',
        () async {
      // act
      final result = await vocabularyRepository.removeWordFromToBeRemembered(
        word: tWordModel.value,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<Success>());
    });
  });

  group(
    "getAllMemorizedWords",
    () {
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(0);

      final tWordDetailsModels = tWordModels
          .map(
            (e) => WordDetailsModel(
              word: e,
              shownCount: 0,
              show: false,
              isMemorized: false,
              isToBeRemembered: false,
              lastShownDate: DateTime.now(),
            ),
          )
          .toList();
      final tGetWordDetailsResponseModel =
          GetWordsResponseModel<WordDetailsModel>(
        words: tWordDetailsModels,
        totalWords: 100,
        currentPage: 1,
        totalPages: 10,
        wordsPerPage: 10,
      );

      test(
          'should return [VocabularyFailure] when limit is more than maxWordsFetchLimit',
          () async {
        // arrange
        final tLimit = PaginationLimit(101);
        final tOffset = PaginationOffSet(0);

        // act
        final result = await vocabularyRepository.getAllMemorizedWords(
          limit: tLimit,
          offset: tOffset,
        );

        // assert

        expect(result.isLeft(), true);

        expect(result.fold(id, id), isA<VocabularyFailure>());
      });

      test(
          'should return [VocabularyFailure] when limit is less than minWordsFetchLimit',
          () async {
        // arrange
        final tLimit = PaginationLimit(4);
        final tOffset = PaginationOffSet(0);

        // act
        final result = await vocabularyRepository.getAllMemorizedWords(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        expect(result.isLeft(), true);
        expect(result.fold(id, id), isA<VocabularyFailure>());
      });

      test('should return [VocabularyFailure] when offset is negative',
          () async {
        // arrange
        final tLimit = PaginationLimit(10);
        final tOffset = PaginationOffSet(-1);

        // act
        final result = await vocabularyRepository.getAllMemorizedWords(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        expect(result.isLeft(), true);
        expect(result.fold(id, id), isA<VocabularyFailure>());
      });

      test('should call local data source getAllMemorizedWords once', () async {
        // arrange
        when(localDataSource.getAllMemorizedWords(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => tGetWordDetailsResponseModel);

        // act
        await vocabularyRepository.getAllMemorizedWords(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        verify(
          localDataSource.getAllMemorizedWords(
            limit: 10,
            offset: 0,
          ),
        ).called(1);
      });

      test(
          'should return a failure when getAllMemorizedWords throws an exception',
          () async {
        // arrange
        when(localDataSource.getAllMemorizedWords(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Unable to get all memorized words'));

        // act
        final res = await vocabularyRepository.getAllMemorizedWords(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        expect(res.isLeft(), true);
        expect(res.fold(id, id), isA<VocabularyFailure>());
      });

      test('should return a Success when getAllMemorizedWords successful ',
          () async {
        // arrange
        when(localDataSource.getAllMemorizedWords(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => tGetWordDetailsResponseModel);

        // act
        final result = await vocabularyRepository.getAllMemorizedWords(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        expect(result.isRight(), true);

        expect(result.fold(id, id), isA<GetWordsResponseModel<WordDetails>>());
      });
    },
  );

  group("getAllShownWords", () {
    final tLimit = PaginationLimit(10);
    final tOffset = PaginationOffSet(0);

    final tWordDetailsModels = tWordModels
        .map(
          (e) => WordDetailsModel(
            word: e,
            shownCount: 0,
            isToBeRemembered: false,
            show: false,
            isMemorized: false,
            lastShownDate: DateTime.now(),
          ),
        )
        .toList();
    final tGetWordDetailsResponseModel =
        GetWordsResponseModel<WordDetailsModel>(
      words: tWordDetailsModels,
      totalWords: 100,
      currentPage: 1,
      totalPages: 10,
      wordsPerPage: 10,
    );

    test(
        'should return [VocabularyFailure] when limit is more than maxWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(101);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllShownWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert

      expect(result.isLeft(), true);

      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should return [VocabularyFailure] when limit is less than minWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(4);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllShownWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return [VocabularyFailure] when offset is negative', () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(-1);

      // act
      final result = await vocabularyRepository.getAllShownWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source getAllShownWords once', () async {
      // arrange
      when(localDataSource.getAllShownWords(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => tGetWordDetailsResponseModel);

      // act
      await vocabularyRepository.getAllShownWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      verify(
        localDataSource.getAllShownWords(
          limit: 10,
          offset: 0,
        ),
      ).called(1);
    });

    test('should return a failure when getAllShownWords throws an exception',
        () async {
      // arrange
      when(localDataSource.getAllShownWords(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenThrow(Exception('Unable to get all shown words'));

      // act
      final res = await vocabularyRepository.getAllShownWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return a Success when getAllShownWords successful ', () async {
      // arrange
      when(localDataSource.getAllShownWords(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => tGetWordDetailsResponseModel);

      // act
      final result = await vocabularyRepository.getAllShownWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<GetWordsResponseModel<WordDetails>>());
    });
  });

  group("getAllToBeRememberedWords", () {
    final tLimit = PaginationLimit(10);
    final tOffset = PaginationOffSet(0);

    final tWordDetailsModels = tWordModels
        .map(
          (e) => WordDetailsModel(
            word: e,
            shownCount: 0,
            isToBeRemembered: false,
            show: false,
            isMemorized: false,
            lastShownDate: DateTime.now(),
          ),
        )
        .toList();
    final tGetWordDetailsResponseModel =
        GetWordsResponseModel<WordDetailsModel>(
      words: tWordDetailsModels,
      totalWords: 100,
      currentPage: 1,
      totalPages: 10,
      wordsPerPage: 10,
    );

    test(
        'should return [VocabularyFailure] when limit is more than maxWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(101);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllToBeRememberedWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert

      expect(result.isLeft(), true);

      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test(
        'should return [VocabularyFailure] when limit is less than minWordsFetchLimit',
        () async {
      // arrange
      final tLimit = PaginationLimit(4);
      final tOffset = PaginationOffSet(0);

      // act
      final result = await vocabularyRepository.getAllToBeRememberedWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return [VocabularyFailure] when offset is negative', () async {
      // arrange
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(-1);

      // act
      final result = await vocabularyRepository.getAllToBeRememberedWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isLeft(), true);
      expect(result.fold(id, id), isA<VocabularyFailure>());
    });

    test('should call local data source getAllToBeRememberedWords once',
        () async {
      // arrange
      when(localDataSource.getAllToBeRememberedWords(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => tGetWordDetailsResponseModel);

      // act
      await vocabularyRepository.getAllToBeRememberedWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      verify(
        localDataSource.getAllToBeRememberedWords(
          limit: 10,
          offset: 0,
        ),
      ).called(1);
    });

    test(
        'should return a failure when getAllToBeRememberedWords throws an exception',
        () async {
      // arrange
      when(localDataSource.getAllToBeRememberedWords(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenThrow(Exception('Unable to get all shown words'));

      // act
      final res = await vocabularyRepository.getAllToBeRememberedWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(res.isLeft(), true);
      expect(res.fold(id, id), isA<VocabularyFailure>());
    });

    test('should return a Success when getAllToBeRememberedWords successful ',
        () async {
      // arrange
      when(localDataSource.getAllToBeRememberedWords(
        limit: anyNamed('limit'),
        offset: anyNamed('offset'),
      )).thenAnswer((_) async => tGetWordDetailsResponseModel);

      // act
      final result = await vocabularyRepository.getAllToBeRememberedWords(
        limit: tLimit,
        offset: tOffset,
      );

      // assert
      expect(result.isRight(), true);

      expect(result.fold(id, id), isA<GetWordsResponseModel<WordDetails>>());
    });
  });

  group(
    "getAllWordsShownToday",
    () {
      final tLimit = PaginationLimit(10);
      final tOffset = PaginationOffSet(0);

      final tWordDetailsModels = tWordModels
          .map(
            (e) => WordDetailsModel(
              word: e,
              shownCount: 0,
              show: false,
              isMemorized: false,
              isToBeRemembered: false,
              lastShownDate: DateTime.now(),
            ),
          )
          .toList();
      final tGetWordDetailsResponseModel =
          GetWordsResponseModel<WordDetailsModel>(
        words: tWordDetailsModels,
        totalWords: 100,
        currentPage: 1,
        totalPages: 10,
        wordsPerPage: 10,
      );

      test(
          'should return [VocabularyFailure] when limit is more than maxWordsFetchLimit',
          () async {
        // arrange
        final tLimit = PaginationLimit(101);
        final tOffset = PaginationOffSet(0);

        // act
        final result = await vocabularyRepository.getAllWordsShownToday(
          limit: tLimit,
          offset: tOffset,
        );

        // assert

        expect(result.isLeft(), true);

        expect(result.fold(id, id), isA<VocabularyFailure>());
      });

      test(
          'should return [VocabularyFailure] when limit is less than minWordsFetchLimit',
          () async {
        // arrange
        final tLimit = PaginationLimit(4);
        final tOffset = PaginationOffSet(0);

        // act
        final result = await vocabularyRepository.getAllWordsShownToday(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        expect(result.isLeft(), true);
        expect(result.fold(id, id), isA<VocabularyFailure>());
      });

      test('should return [VocabularyFailure] when offset is negative',
          () async {
        // arrange
        final tLimit = PaginationLimit(10);
        final tOffset = PaginationOffSet(-1);

        // act
        final result = await vocabularyRepository.getAllWordsShownToday(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        expect(result.isLeft(), true);
        expect(result.fold(id, id), isA<VocabularyFailure>());
      });

      test('should call local data source getAllWordsShownToday once',
          () async {
        // arrange
        when(localDataSource.getAllWordsShownToday(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => tGetWordDetailsResponseModel);

        // act
        await vocabularyRepository.getAllWordsShownToday(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        verify(
          localDataSource.getAllWordsShownToday(
            limit: 10,
            offset: 0,
          ),
        ).called(1);
      });

      test(
          'should return a failure when getAllWordsShownToday throws an exception',
          () async {
        // arrange
        when(localDataSource.getAllWordsShownToday(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Unable to get all shown words'));

        // act
        final res = await vocabularyRepository.getAllWordsShownToday(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        expect(res.isLeft(), true);
        expect(res.fold(id, id), isA<VocabularyFailure>());
      });

      test('should return a Success when getAllWordsShownToday successful ',
          () async {
        // arrange
        when(localDataSource.getAllWordsShownToday(
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => tGetWordDetailsResponseModel);

        // act
        final result = await vocabularyRepository.getAllWordsShownToday(
          limit: tLimit,
          offset: tOffset,
        );

        // assert
        expect(result.isRight(), true);

        expect(result.fold(id, id), isA<GetWordsResponseModel<WordDetails>>());
      });
    },
  );

  group(
    "getNextWordsToBeShown",
    () {
      final memorizedWordsIndexes = [0, 1, 2];
      final recentlyShownWordsIndexes = [3, 4];
      const allWordsCount = 10;

      test('returns empty list when all words are memorized', () async {
        when(localDataSource.allMemorizedIndexes()).thenAnswer(
          (_) => Future.value([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]),
        );
        when(localDataSource.allRecentlyShownIndexes(any)).thenAnswer(
          (_) => Future.value([1, 2, 3, 4, 5]),
        );
        when(localDataSource.allWordsCount()).thenAnswer(
          (_) => Future.value(allWordsCount),
        );

        final result = await vocabularyRepository.getNextWordsToBeShown(
            noOfWords: 5, shownThreshold: 3);

        expect(result.isRight(), true);
        expect(result.fold(id, id) as List<Word>, isEmpty);
      });

      test('returns correct number of words to be shown', () async {
        when(localDataSource.allMemorizedIndexes())
            .thenAnswer((_) => Future.value(memorizedWordsIndexes));
        when(localDataSource.allRecentlyShownIndexes(any))
            .thenAnswer((_) => Future.value(recentlyShownWordsIndexes));
        when(localDataSource.allWordsCount())
            .thenAnswer((_) => Future.value(allWordsCount));
        when(localDataSource.getWordsByIndexes(any)).thenAnswer(
          (_) => Future.value(
            tWordModels.sublist(0, 5),
          ),
        );

        final result = await vocabularyRepository.getNextWordsToBeShown(
            noOfWords: 5, shownThreshold: 3);

        expect(result.isRight(), true);
        expect(result.fold(id, id), isA<List<Word>>());
        expect(result.fold(id, id), hasLength(5));
        expect(
          result.fold(id, id),
          containsAll(
            tWordModels.sublist(0, 5),
          ),
        );
      });

      test(
        "should return a non-repeating list of words to be shown",
        () async {
          when(localDataSource.allMemorizedIndexes())
              .thenAnswer((_) => Future.value(memorizedWordsIndexes));
          when(localDataSource.allRecentlyShownIndexes(any))
              .thenAnswer((_) => Future.value(recentlyShownWordsIndexes));
          when(localDataSource.allWordsCount())
              .thenAnswer((_) => Future.value(allWordsCount));
          when(localDataSource.getWordsByIndexes(any)).thenAnswer(
            (_) => Future.value(
              tWordModels.sublist(0, 10),
            ),
          );

          final result = await vocabularyRepository.getNextWordsToBeShown(
              noOfWords: 5, shownThreshold: 3);

          expect(result.isRight(), true);
          expect(result.fold(id, id), isA<List<Word>>());
          expect((result.fold(id, id) as List<Word>).toSet(), hasLength(10));
          expect(
            (result.fold(id, id) as List<Word>).toSet(),
            containsAll(
              tWordModels.sublist(0, 10),
            ),
          );
        },
      );

      test(
        "should return vocabulary failure if noOfWords or shownThreshold is less than 1",
        () async {
          // arrange
          const tNoOfWords = 0;
          const tShownThreshold = 0;

          // act
          final result = await vocabularyRepository.getNextWordsToBeShown(
            noOfWords: tNoOfWords,
            shownThreshold: tShownThreshold,
          );

          // assert
          expect(result.isLeft(), true);
          expect(result.fold(id, id), isA<VocabularyValueFailure>());
        },
      );
    },
  );

  group(
    "searchWord",
    () {
      const tSearchWord = "abs";
      const tWords = [
        'Abscess',
        'Abscessed',
        'Abscesses',
        'Abscessing',
        'Absolution',
        'Absolute',
        'Absoluteness',
        'Absolutes',
        'Absolutely',
        'Abscond',
        'Absconded',
        'Absconding',
      ];
      final tSearchWordResponseModel = tWords
          .map(
            (word) => WordModel(
              value: WordObject(word),
              definition: "Definition of $word",
              example: "Example of $word",
              source: 'Oxford',
            ),
          )
          .toList();

      test(
        "should return a failure when searchWord throws an exception",
        () async {
          // arrange
          when(localDataSource.searchWord(query: anyNamed("query"))).thenThrow(
            Exception("Unable to search word"),
          );

          // act
          final result = await vocabularyRepository.searchWord(tSearchWord);

          // assert
          expect(result.isLeft(), true);
          expect(result.fold(id, id), isA<VocabularyFailure>());
        },
      );

      test(
        "should call local data source searchWord once",
        () async {
          // arrange
          when(localDataSource.searchWord(query: anyNamed("query"))).thenAnswer(
            (_) async => tSearchWordResponseModel,
          );

          // act
          await vocabularyRepository.searchWord(tSearchWord);

          // assert
          verify(localDataSource.searchWord(query: "abs")).called(1);
        },
      );

      test(
        "should return a Success when searchWord successful",
        () async {
          // arrange
          when(localDataSource.searchWord(query: anyNamed("query"))).thenAnswer(
            (_) async => tSearchWordResponseModel,
          );

          // act
          final result = await vocabularyRepository.searchWord(tSearchWord);

          // assert
          expect(result.isRight(), true);
          expect(result.fold(id, id), isA<List<WordModel>>());
          expect(result.fold(id, id), tSearchWordResponseModel);
        },
      );
    },
  );
}
