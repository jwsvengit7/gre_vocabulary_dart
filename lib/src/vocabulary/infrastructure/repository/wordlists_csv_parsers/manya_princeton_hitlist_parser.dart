import 'package:gre_vocabulary/src/vocabulary/domain/core/constants.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';

import '../../models/word_model.dart';
import 'wordlist_parser.dart';

class ManyaPrincetonHitListParser extends WordListParser {
  const ManyaPrincetonHitListParser();

  @override
  List<WordModel> getWords({
    required List<List> rawList,
    required WordsListKey wordsListKey,
  }) {
    final words = <WordModel>[];
    String currentWord = '';
    String currentWordMeaning = '';
    String pending = '';

    for (var row in rawList) {
      if (row.isEmpty) {
        continue;
      }
      final string = row.first.toString().trim().toLowerCase();
      if (string.isEmpty) {
        continue;
      }
      final splitTexts = string.split(' ');
      // toLog("length: ${splitTexts.length}: $count");
      final number = int.tryParse(splitTexts.first);

      if (number == null) {
        pending = "$pending $string ";

        continue;
      } else {
        if (currentWord.isEmpty) {
          currentWord = splitTexts[1];
          currentWordMeaning =
              "${splitTexts.skip(2).join(' ')} $pending".trim();

          continue;
        }
        words.add(
          WordModel(
            value: WordObject(currentWord),
            definition: "$currentWordMeaning $pending",
            example: '',
            isHitWord: false,
            source: wordsListKey,
          ),
        );
        pending = '';

        try {
          currentWord = splitTexts[1];
          currentWordMeaning = splitTexts.skip(2).join(' ').trim();
        } catch (_) {}
      }
    }
    if (pending.isNotEmpty) {
      words.add(
        WordModel(
          value: WordObject(currentWord),
          definition: "$currentWordMeaning $pending",
          example: '',
          isHitWord: false,
          source: wordsListKey,
        ),
      );
    }

    return words;
  }
}
