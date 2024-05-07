import 'package:gre_vocabulary/src/vocabulary/domain/core/constants.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';

import 'wordlist_parser.dart';

class EconomicsHitListParser extends WordListParser {
  const EconomicsHitListParser();

  @override
  List<WordModel> getWords({
    required List<List> rawList,
    required WordsListKey wordsListKey,
  }) {
    final words = <WordModel>[];
    String currentWord = '';
    String currentWordMeaning = '';
    String example = '';
    for (var row in rawList) {
      final string = row.first.toString().trim().toLowerCase();
      if (string.isEmpty) {
        continue;
      }
      final splitTexts = string.split(' ');
      if (currentWord.isEmpty) {
        currentWord = splitTexts.first.replaceAll(":", '');
        currentWordMeaning = splitTexts.skip(1).join(' ');
        continue;
      }
      if (string.startsWith('"')) {
        example = string;
        continue;
      }
      if (splitTexts.first == "Synonyms:") {
        currentWordMeaning = "$currentWordMeaning | $string ";
        continue;
      }
      if (splitTexts.first == 'source:') {
        words.add(
          WordModel(
            value: WordObject(currentWord),
            definition: currentWordMeaning,
            example: example,
            isHitWord: true,
            source: wordsListKey,
          ),
        );

        currentWord = '';
        example = '';
        continue;
      }
    }
    return words;
  }
}
