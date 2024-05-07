import 'package:equatable/equatable.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word.dart';

/// this is a wrapper around a word so that we can add more details to it
class WordDetails extends Equatable {
  /// the word
  final Word word;

  /// the number of times the word has been shown
  final int shownCount;

  /// whether the word should be shown or not
  final bool show;

  /// whether the word has been memorized or not
  final bool isMemorized;

  /// the date the word was memorized
  final DateTime? dateMemorized;

  /// the date the word was last shown
  final DateTime lastShownDate;

  final bool isToBeRemembered;

  const WordDetails({
    required this.word,
    required this.shownCount,
    required this.show,
    required this.isMemorized,
    required this.lastShownDate,
    required this.dateMemorized,
    required this.isToBeRemembered,
  });

  @override
  List<Object?> get props => [
        word,
        shownCount,
        show,
        isMemorized,
        dateMemorized,
        lastShownDate,
        isToBeRemembered,
      ];
}
