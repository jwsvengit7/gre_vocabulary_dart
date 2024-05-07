import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gre_vocabulary/src/core/extensions.dart';
import 'package:gre_vocabulary/src/core/presentation/common_presentation.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word_details.dart';
import 'package:gre_vocabulary/src/vocabulary/presentation/words_to_be_shown_queue.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../vocabulary_di.dart';

enum CurrentCardView {
  front,
  back,
}

class FlashCardState {
  final bool showWordFirst;
  final CurrentCardView currentCardView;
  final WordDetails? currentWord;

  FlashCardState({
    required this.showWordFirst,
    required this.currentCardView,
    this.currentWord,
  });

  FlashCardState copyWith({
    bool? showWordFirst,
    CurrentCardView? currentCardView,
    WordDetails? currentWord,
  }) {
    return FlashCardState(
      showWordFirst: showWordFirst ?? this.showWordFirst,
      currentCardView: currentCardView ?? this.currentCardView,
      currentWord: currentWord ?? this.currentWord,
    );
  }
}

final cardStateProvider = StateProvider<FlashCardState>(
  (ref) => FlashCardState(
    showWordFirst: true,
    currentCardView: CurrentCardView.front,
  ),
);

class FlashCardsScreen extends ConsumerStatefulWidget {
  const FlashCardsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FlashCardsScreen> createState() => _FlashCardsScreenState();
}

class _FlashCardsScreenState extends ConsumerState<FlashCardsScreen> {
  late final WordsToBeShownQueue _wordStack;

  @override
  void initState() {
    super.initState();
    _wordStack = WordsToBeShownQueue(_markWordAsShown);
    _fetchWordsToBeShown();
  }

  @override
  Widget build(BuildContext context) {
    final flashCardState = ref.watch(cardStateProvider);

    _startListeningToWordsState();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text("Flash Cards"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Switch(
                  value: flashCardState.showWordFirst,
                  activeColor: context.colorScheme.primary,
                  onChanged: (value) {
                    ref.read(cardStateProvider.notifier).update(
                          (state) => state.copyWith(showWordFirst: value),
                        );
                  },
                ),
                Text(
                  "Show word first",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Visibility(
              visible: flashCardState.currentWord != null,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 1500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) =>
                            _transitionBuilder(
                      child,
                      animation,
                      flashCardState.currentCardView,
                    ),
                    layoutBuilder: (widget, list) => Stack(
                        children: [widget ?? const SizedBox.shrink(), ...list]),
                    switchInCurve: Curves.easeInBack,
                    switchOutCurve: Curves.easeInBack.flipped,
                    child: _buildBody(
                      flashCardState,
                      context,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cardStateProvider.notifier).update(
                                (state) => state.copyWith(
                                  currentCardView: state.currentCardView ==
                                          CurrentCardView.front
                                      ? CurrentCardView.back
                                      : CurrentCardView.front,
                                ),
                              );
                        },
                        child: const Text("Flip"),
                      ),
                      const Gap(size: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_wordStack.isEmpty()) {
                            _fetchWordsToBeShown();
                            return;
                          }
                          _setNextWord();
                        },
                        child: const Text("Next"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FlashCardState cardState, BuildContext context) {
    final currentWord = cardState.currentWord;
    if (currentWord == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final word = currentWord.word.value.getOrElse("");
    final meaning = currentWord.word.definition;

    return Container(
      margin: const EdgeInsets.all(25),
      padding: const EdgeInsets.all(25),
      height: 170,
      key: ValueKey(cardState.currentCardView.toString()),
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardState.currentCardView == CurrentCardView.front
            ? context.colorScheme.primary
            : context.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.colorScheme.onBackground.withOpacity(0.4),
        ),
      ),
      child: Center(
        child: Text(
          cardState.currentCardView == CurrentCardView.front
              ? cardState.showWordFirst
                  ? word
                  : meaning
              : cardState.showWordFirst
                  ? meaning
                  : word,
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.copyWith(
            color: cardState.currentCardView == CurrentCardView.front
                ? context.colorScheme.onPrimary
                : context.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _transitionBuilder(
      Widget child, Animation<double> animation, CurrentCardView currentView) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: child,
      builder: (context, widget) {
        final isUnder = (ValueKey(currentView.toString()) != widget?.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value =
            isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          alignment: Alignment.center,
          child: widget,
        );
      },
    );
  }

  void _startListeningToWordsState() {
    ref.listen(
      vocabularyControllerProvider,
      (previous, next) {
        next.maybeWhen(
            orElse: () {},
            nextWordsLoaded: (words) {
              _wordStack.addWords(words);
              _setNextWord();
            });
      },
    );
    ref.listen(wordDetailsProvider, (previous, next) {
      ref.read(cardStateProvider.notifier).update(
            (state) => state.copyWith(
              currentCardView: CurrentCardView.front,
              currentWord: next,
            ),
          );
    });
  }

  void _setNextWord() {
    final nextWord = _wordStack.getNextWord();
    ref.read(wordDetailsProvider.notifier).state = nextWord;
  }

  void _fetchWordsToBeShown() {
    ref.read(vocabularyControllerProvider.notifier).loadWordsToBeShown();
  }

  void _markWordAsShown(WordDetails word) {
    ref
        .read(vocabularyControllerProvider.notifier)
        .markWordAsShown(word.word.value);
  }
}
