import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';

import '../domain/vocabulary_domain.dart';
import 'vocabulary_state.dart';

class VocabularyController extends StateNotifier<VocabularyState> {
  final VocabularyServiceFacade _service;

  VocabularyController({
    required VocabularyServiceFacade service,
  })  : _service = service,
        super(const InitialVocabularyState());

  Future<void> init() async {
    await _service.loadAllWordsIntoDb();
  }

  Future<void> searchWord(String text) async {
    final result = await _service.searchWord(text);
    result.fold(
      (failure) => state = SearchErrorVocabularyState(
        error: failure.maybeWhen(
          orElse: () => "Something went wrong",
          unexpected: (message) => message,
        ),
      ),
      (words) => state = SearchSuccessVocabularyState(words: words),
    );
  }

  void clearSearch() {
    state = const SearchSuccessVocabularyState(words: []);
  }

  Future<void> loadWordsToBeShown() async {
    final result = await _service.getNextWordsToBeShown(
      noOfWords: 50,
      shownThreshold: 5, // TODO: make this configurable
    );
    result.fold(
      (failure) => state = LoadWordsToBeShownFailureState(
        error: failure.maybeWhen(
          orElse: () => "Something went wrong",
          unexpected: (message) => message,
        ),
      ),
      (words) => state = NextWordsLoadedState(words: words),
    );
  }

  Future<void> markWordAsShown(WordObject word) async {
    await _service.markWordAsShown(word: word);
  }

  Future<void> markWordAsMemorized(WordObject word) async {
    await _service.markWordAsMemorized(word: word);
  }

  Future<void> saveWordForLater(WordObject word) async {
    await _service.markWordAsToBeRemembered(word: word);
  }
}
