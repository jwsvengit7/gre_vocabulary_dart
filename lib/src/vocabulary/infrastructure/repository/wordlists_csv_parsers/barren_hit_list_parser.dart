import 'dart:developer';

import '../../../domain/core/constants.dart';
import '../../../domain/value_objects/word.dart';
import '../../models/word_model.dart';
import 'wordlist_parser.dart';

class BarrenHitListParser extends WordListParser {
  const BarrenHitListParser();

  static const abc = [
    "a",
    "b",
    "b",
    "d",
    "e",
    "f",
    "g",
    "h",
    "i",
    "j",
    "k",
    "l",
    "m",
    "n",
    "o",
    "p",
    "q",
    "r",
    "s",
    "t",
    "u",
    "v",
    "w",
    "x",
    "y",
    "z",
  ];

  @override
  List<WordModel> getWords({
    required List<List> rawList,
    required WordsListKey wordsListKey,
  }) {
    int currentRow = 0;
    final words = <WordModel>[];
    String lastWord = '';
    String currentWord = '';
    String currentWordMeaning = '';
    for (var row in rawList) {
      try {
        final string = row.first.toString().trim().toLowerCase();
        // we just started the program, so last word is empty
        if (lastWord.isEmpty) {
          currentWord = string;
          lastWord = currentWord[0];
          currentRow++;
          continue;
        }

        // skip if row is empty
        if (string.isEmpty) {
          // debugPrint('string is empty --------------------------------------');
          currentRow++;
          continue;
        }

        if (_matchesAnExplanation(string, currentWord) ||
            (currentRow + 1 < rawList.length &&
                !_matchesAnExplanation(
                    rawList[currentRow + 1]
                        .first
                        .toString()
                        .trim()
                        .toLowerCase(),
                    currentWord) &&
                _matchesAnExplanation(
                    rawList[currentRow + 2]
                        .first
                        .toString()
                        .trim()
                        .toLowerCase(),
                    currentWord))) {
          // if (!_letterChanged(
          //     convertedCsv.getRange(currentRow, convertedCsv.length).toList(),
          //     lastWord,
          //     currentWord,
          //     count: 0)) {
          currentWordMeaning = "$currentWordMeaning $string";
          currentRow++;
          // debugPrint(
          //     'explanation string is empty -------------------------------------- $currentRow');

          continue;
          // }
        }

        words.add(
          WordModel(
            value: WordObject(currentWord),
            definition: currentWordMeaning,
            example: '',
            source: wordsListKey,
          ),
        );

        lastWord = currentWord.toString();
        currentWord = string;
        currentWordMeaning = '';
        currentRow++;
      } catch (e) {
        log("error $e");
      }
    }
    log('$currentWord: $currentWordMeaning, row: $currentRow');
    return words;
  }

  bool _matchesAnExplanation(String string, String currentWord) {
    final wordSplitList = string.split(' ');
    return wordSplitList.length > 1 ||
        string.contains(".") ||
        string.contains(";") ||
        wordSplitList.first.compareTo(currentWord) < 0 ||
        abc.indexOf(wordSplitList.first[0]) > (abc.indexOf(currentWord[0]) + 1);
  }

  bool _letterChanged(
      List<List> convertedCsv, String lastWord, String currentWord,
      {required int count}) {
    if (count > 2) {
      return false;
    }
    final index = convertedCsv.indexWhere(
      (element) =>
          element.first.toString().toLowerCase().split(' ').length == 1,
    );
    if (index < 0) {
      return true;
    }
    var text = convertedCsv[index].first.toString().toLowerCase();
    if (text.compareTo(currentWord) > 0 &&
        abc.indexOf(text[0]) == (abc.indexOf(currentWord[0]) + 1)) {
      return _letterChanged(
        convertedCsv.getRange(index, convertedCsv.length).toList(),
        lastWord,
        currentWord,
        count: count + 1,
      );
    } else {
      return true;
    }
  }
}
