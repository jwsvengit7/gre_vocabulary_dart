import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../domain/core/failures.dart';
import '../../models/word_model.dart';
import '../words_lists/base_words_list.dart';

abstract class CSVListsParser {
  final List<BaseWordsList> wordsLists;

  const CSVListsParser(
    this.wordsLists,
  );

  Future<Either<VocabularyFailure, List<WordModel>>> parse();

  Future<String> getCsvStringData(String filePath) async {
    return await rootBundle.loadString(filePath);
  }
}

class CSVListsParserImpl extends CSVListsParser {
  final CsvToListConverter csvToListConverter;
  const CSVListsParserImpl({
    required List<BaseWordsList> wordsLists,
    required this.csvToListConverter,
  }) : super(wordsLists);

  @override
  Future<Either<VocabularyFailure, List<WordModel>>> parse() async {
    final allWords = <WordModel>[];
    for (final wordsList in wordsLists) {
      try {
        final rawCsv = await getCsvStringData(wordsList.path);

        final convertedCsv = csvToListConverter.convert(rawCsv);

        final words = wordsList.wordsParser.getWords(
            rawList: convertedCsv, wordsListKey: wordsList.wordsListKey);

        allWords.addAll(words);
      } catch (_) {}
    }

    final wordsWithDuplicates = _flattenDuplicatedWords(allWords);

    return right(wordsWithDuplicates);
  }

  List<WordModel> _flattenDuplicatedWords(List<WordModel> allWords) {
    final Map<String, WordModel> allWordsMap = {};

    for (final word in allWords) {
      try {
        final wordValue = word.value.getOrCrash().trim().toLowerCase();
        if (!allWordsMap.containsKey(wordValue)) {
          allWordsMap[wordValue] = word;
          continue;
        }

        final wordInMap = allWordsMap[wordValue];
        if (wordInMap != null) {
          allWordsMap[wordValue] = wordInMap.copyWith(
            definition: "${wordInMap.definition} | ${word.definition}",
            example: "${wordInMap.example} | ${word.example}",
            isHitWord: wordInMap.isHitWord || word.isHitWord,
            source: wordInMap.isHitWord ? wordInMap.source : word.source,
          );
        }
      } catch (_) {}
    }

    return allWordsMap.values.toList();
  }
}
