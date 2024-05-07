import '../../domain/entities/word.dart';
import '../../domain/value_objects/word.dart';

class WordModel extends Word {
  WordModel({
    required super.value,
    required super.definition,
    required super.example,
    super.isHitWord = false,
    super.id,
    required super.source,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json["id"],
      value: WordObject(json['value']),
      definition: json['definition'],
      example: json['example'] ?? '',
      isHitWord: json['isHitWord'] ?? false,
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value.getOrCrash(),
      'definition': definition,
      'example': example,
      'isHitWord': isHitWord,
      'id': id,
      'source': source,
    };
  }

  WordModel copyWith({
    WordObject? value,
    String? definition,
    String? example,
    bool? isHitWord,
    int? id,
    String? source,
  }) {
    return WordModel(
      value: value ?? this.value,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      isHitWord: isHitWord ?? this.isHitWord,
      id: id ?? this.id,
      source: source ?? this.source,
    );
  }
}
