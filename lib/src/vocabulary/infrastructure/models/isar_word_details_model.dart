import 'package:clock/clock.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';
import 'package:isar/isar.dart';

import 'word_details_model.dart';

part 'isar_word_details_model.g.dart';

@Collection(accessor: 'wordDetails')
class IsarWordDetailsModel {
  Id? id;

  // we don't need to store the word itself, because we can get it from the wordId
  @Index(unique: true, replace: true)
  String word;

  int shownCount;
  bool show;

  @Index()
  bool isMemorized;

  @Index()
  bool isToBeRemembered = false;

  @Index()
  DateTime lastShownDate;
  DateTime? dateMemorized;

  IsarWordDetailsModel({
    required this.id,
    required this.word,
    required this.shownCount,
    required this.show,
    required this.isMemorized,
    required this.lastShownDate,
    this.dateMemorized,
    required this.isToBeRemembered,
  });

  IsarWordDetailsModel.fresh({
    required this.id,
    required this.word,
  })  : shownCount = 0,
        show = true,
        isMemorized = false,
        isToBeRemembered = false,
        lastShownDate = clock.now();

  static IsarWordDetailsModel fromWordDetailsModel(WordDetailsModel e) {
    return IsarWordDetailsModel(
      id: e.word.id,
      word: e.word.value.getOrCrash(),
      shownCount: e.shownCount,
      show: e.show,
      isMemorized: e.isMemorized,
      isToBeRemembered: e.isToBeRemembered,
      lastShownDate: e.lastShownDate,
      dateMemorized: e.dateMemorized,
    );
  }

  WordDetailsModel toWordDetailsModel(WordModel word) {
    return WordDetailsModel(
      word: word,
      shownCount: shownCount,
      show: show,
      isMemorized: isMemorized,
      isToBeRemembered: isToBeRemembered,
      lastShownDate: lastShownDate,
      dateMemorized: dateMemorized,
    );
  }

  IsarWordDetailsModel copyWith({
    String? word,
    int? shownCount,
    bool? show,
    bool? isMemorized,
    DateTime? lastShownDate,
    DateTime? dateMemorized,
    bool? isToBeRemembered,
  }) {
    return IsarWordDetailsModel(
      word: word ?? this.word,
      shownCount: shownCount ?? this.shownCount,
      show: show ?? this.show,
      isMemorized: isMemorized ?? this.isMemorized,
      lastShownDate: lastShownDate ?? this.lastShownDate,
      id: id,
      dateMemorized: dateMemorized ?? this.dateMemorized,
      isToBeRemembered: isToBeRemembered ?? this.isToBeRemembered,
    );
  }
}
