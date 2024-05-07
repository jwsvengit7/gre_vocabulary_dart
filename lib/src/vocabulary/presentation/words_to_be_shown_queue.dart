import 'package:flutter/material.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word_details.dart';

class WordsToBeShownQueue {
  final List<WordDetails> _words = [];
  final ValueSetter<WordDetails> markWordAsShown;
  WordDetails? _lastWord;
  WordDetails? _lastShownWord;

  WordsToBeShownQueue(this.markWordAsShown);

  void addWords(List<WordDetails> words) {
    _words.addAll(words);
    final set = _words.toSet().toList();
    _words.clear();
    _words.addAll(set);
  }

  void addWord(WordDetails word) {
    _words.add(word);
  }

  int size() {
    return _words.length;
  }

  bool isEmpty() {
    return _words.isEmpty;
  }

  WordDetails getNextWord() {
    if (_words.isEmpty) {
      throw Exception('No words left');
    }
    final word = _words.removeAt(0);

    _lastWord ??= word;

    if (_lastWord != word) {
      _lastShownWord = _lastWord;
      _lastWord = word;
    }

    markWordAsShown(word);

    return word;
  }

  WordDetails? get lastShownWord => _lastShownWord;
}
