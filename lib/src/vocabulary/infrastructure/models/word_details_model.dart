import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';

import '../../domain/entities/word_details.dart';

class WordDetailsModel extends WordDetails {
  const WordDetailsModel({
    required super.word,
    required super.shownCount,
    required super.show,
    required super.isMemorized,
    required super.lastShownDate,
    super.dateMemorized,
    required super.isToBeRemembered,
  });

  factory WordDetailsModel.fromJson(Map<String, dynamic> json) {
    return WordDetailsModel(
      word: WordModel.fromJson(json['word'] as Map<String, dynamic>),
      shownCount: json['timesShown'] as int,
      show: json['show'] as bool,
      isMemorized: json['isMemorized'] as bool,
      lastShownDate: DateTime.parse(json['lastShownDate'] as String),
      dateMemorized: json['dateMemorized'] == null
          ? null
          : DateTime.parse(json['dateMemorized'] as String),
      isToBeRemembered: json['isToBeRemembered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'timesShown': shownCount,
      'show': show,
      'isMemorized': isMemorized,
      'lastShownDate': lastShownDate,
      'dateMemorized': dateMemorized,
      'isToBeRemembered': isToBeRemembered,
    };
  }

  WordDetailsModel copyWith({
    WordModel? word,
    int? shownCount,
    bool? show,
    bool? isMemorized,
    DateTime? lastShownDate,
    DateTime? dateMemorized,
    bool? isToBeRemembered,
  }) {
    return WordDetailsModel(
      word: word ?? this.word,
      shownCount: shownCount ?? this.shownCount,
      show: show ?? this.show,
      isMemorized: isMemorized ?? this.isMemorized,
      lastShownDate: lastShownDate ?? this.lastShownDate,
      dateMemorized: dateMemorized ?? this.dateMemorized,
      isToBeRemembered: isToBeRemembered ?? this.isToBeRemembered,
    );
  }

  factory WordDetailsModel.freshFromWordModel(WordModel word) {
    return WordDetailsModel(
      word: word,
      shownCount: 0,
      show: true,
      isMemorized: false,
      lastShownDate: DateTime.now(),
      dateMemorized: null,
      isToBeRemembered: false,
    );
  }
}
