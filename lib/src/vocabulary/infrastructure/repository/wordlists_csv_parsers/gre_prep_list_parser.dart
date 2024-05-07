import 'package:gre_vocabulary/src/vocabulary/domain/core/constants.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';

import '../../models/word_model.dart';
import 'wordlist_parser.dart';

class GrePreListParser extends WordListParser {
  GrePreListParser();

  @override
  List<WordModel> getWords({
    required List<List> rawList,
    required WordsListKey wordsListKey,
  }) {
    final words = <WordModel>[];
    for (var row in rawList) {
      try {
        if (row.isEmpty) {
          continue;
        }
        words.add(
          WordModel(
            value: WordObject(row[0].toString().toLowerCase().trim()),
            definition: row[1].toString().toLowerCase().trim(),
            example: '',
            source: wordsListKey,
          ),
        );
      } catch (e) {
        print('error at row: $row');
        print(e);
      }
    }
    return words;
  }
}
