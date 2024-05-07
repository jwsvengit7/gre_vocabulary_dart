import 'package:gre_vocabulary/src/vocabulary/domain/core/constants.dart';

import '../wordlists_csv_parsers/wordlist_parser.dart';

class BaseWordsList {
  final WordListParser wordsParser;
  final String path;
  final WordsListKey wordsListKey;
  final String name;

  const BaseWordsList({
    required this.wordsParser,
    required this.path,
    required this.wordsListKey,
    required this.name,
  });
}
