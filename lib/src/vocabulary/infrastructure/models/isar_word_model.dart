import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';
import 'package:isar/isar.dart';

import 'word_model.dart';

part 'isar_word_model.g.dart';

@Collection(accessor: 'words')
class IsarWordModel {
  Id? id;

  @Index()
  String value;
  String definition;
  String example;
  bool isHitWord;

  @Index()
  String source;

  IsarWordModel({
    this.id,
    required this.value,
    required this.definition,
    required this.example,
    required this.isHitWord,
    required this.source,
  });

  static IsarWordModel fromWordModel(WordModel e) {
    return IsarWordModel(
      value: e.value.getOrCrash().trim(),
      definition: e.definition,
      example: e.example,
      isHitWord: e.isHitWord,
      source: e.source,
    );
  }

  WordModel toWordModel() {
    return WordModel(
      id: id,
      value: WordObject(value),
      definition: definition.trim(),
      example: example.trim(),
      isHitWord: isHitWord,
      source: source.trim(),
    );
  }
}
