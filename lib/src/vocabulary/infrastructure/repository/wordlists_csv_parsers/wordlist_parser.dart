import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';

import '../../../domain/core/constants.dart';

/// Abstract class that all wordlist parsers should implement
abstract class WordListParser {
  const WordListParser();

  /// takes a list of lists of words and returns a list of words
  ///
  /// the list inside the list is similar to a row in a csv file
  List<WordModel> getWords(
      {required List<List> rawList, required WordsListKey wordsListKey});
}
