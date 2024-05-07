part of 'homepage.dart';

class WordShowingNowSection extends ConsumerStatefulWidget {
  const WordShowingNowSection({Key? key}) : super(key: key);

  @override
  ConsumerState<WordShowingNowSection> createState() =>
      _WordShowingNowSectionState();
}

class _WordShowingNowSectionState extends ConsumerState<WordShowingNowSection> {
  late final WordsToBeShownQueue _wordStack;
  final ValueNotifier<WordDetails?> _wordDetailsNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _wordStack = WordsToBeShownQueue(_markWordAsShown);
    _fetchWordsToBeShown();
  }

  @override
  Widget build(BuildContext context) {
    _startListeningToWordsState();
    return Container(
      margin: const EdgeInsets.all(25),
      child: ValueListenableBuilder<WordDetails?>(
        valueListenable: _wordDetailsNotifier,
        builder: (context, wordDetails, child) {
          if (wordDetails == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorScheme.onBackground.withOpacity(0.05),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          wordDetails.word.value.getOrElse("").toTitleCase ??
                              "",
                          style: context.textTheme.titleLarge?.copyWith(
                            color: context.colorScheme.primary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Visibility(
                          visible: wordDetails.word.isHitWord,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Hit Word",
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.onPrimary,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.grade,
                                  color: context.colorScheme.onPrimary,
                                  size: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      wordDetails.word.definition,
                      textAlign: TextAlign.start,
                      style: context.textTheme.bodyMedium,
                    ),
                    const Gap(size: 10),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _markCurrentWordAsMemorized,
                          style: TextButton.styleFrom(),
                          child: Text(
                            "Mark as Memorized",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _saveCurrentWordForLater,
                          style: TextButton.styleFrom(),
                          child: Text(
                            "Save for later",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _wordStack.lastShownWord != null,
                replacement: const Gap(
                  size: 5,
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: double.infinity,
                  child: Text(
                    "Last shown sord: ${_wordStack.lastShownWord?.word.value.getOrElse("").toTitleCase}",
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_wordStack.isEmpty()) {
                    _fetchWordsToBeShown();
                    return;
                  }
                  _wordDetailsNotifier.value = _wordStack.getNextWord();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Next word"),
                    Gap(size: 5),
                    Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _markCurrentWordAsMemorized() {
    if (_wordDetailsNotifier.value == null) return;
    ref.read(vocabularyControllerProvider.notifier).markWordAsMemorized(
          _wordDetailsNotifier.value!.word.value,
        );
    _setNextWord();
  }

  void _saveCurrentWordForLater() {
    if (_wordDetailsNotifier.value == null) return;
    ref.read(vocabularyControllerProvider.notifier).saveWordForLater(
          _wordDetailsNotifier.value!.word.value,
        );
    _setNextWord();
  }

  void _fetchWordsToBeShown() {
    ref.read(vocabularyControllerProvider.notifier).loadWordsToBeShown();
  }

  void _startListeningToWordsState() {
    ref.listen(
      vocabularyControllerProvider,
      (previous, next) {
        next.maybeWhen(
            orElse: () {},
            nextWordsLoaded: (words) {
              final wordLenght = _wordStack.size();
              _wordStack.addWords(words);

              if (wordLenght == 0) {
                _setNextWord();
              }
            });
      },
    );
  }

  void _setNextWord() {
    _wordDetailsNotifier.value = _wordStack.getNextWord();
  }

  void _markWordAsShown(WordDetails word) {
    ref
        .read(vocabularyControllerProvider.notifier)
        .markWordAsShown(word.word.value);
  }
}
