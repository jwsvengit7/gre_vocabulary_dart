import 'package:equatable/equatable.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';

/// this is more like a value object
class Word extends Equatable {
  final WordObject value;
  final String definition;
  final String example;
  final bool isHitWord;

  /// this is a unique id for the word
  /// This enables to index and easily randomize the words later
  final int? id;
  final String source;

  Word({
    required this.value,
    required this.definition,
    required this.example,
    this.isHitWord = false,
    this.id,
    required this.source,
  }) : assert(definition.isNotEmpty);

  @override
  List<Object?> get props => [value, definition, example, isHitWord, id];
}
