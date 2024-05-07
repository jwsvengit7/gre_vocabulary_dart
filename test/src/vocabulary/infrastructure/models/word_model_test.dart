import 'package:flutter_test/flutter_test.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/entities/word.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/value_objects/word.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/word_model.dart';

void main() {
  final tWordModel = WordModel(
    value: WordObject("test"),
    definition: "test definition",
    example: "test example",
    isHitWord: true,
    source: "test source",
    id: 1,
  );

  final tWordModelJson = {
    "value": "test",
    "definition": "test definition",
    "example": "test example",
    "isHitWord": true,
    "source": "test source",
    "id": 1,
  };

  final tWordModel2 = WordModel(
      value: WordObject("tester"),
      definition: "test definition 2",
      example: "test example 2",
      isHitWord: false,
      source: "test source",
      id: 2);

  final tWordModelJson2 = {
    "value": "tester",
    "definition": "test definition 2",
    "example": "test example 2",
    "isHitWord": false,
    "source": "test source",
    "id": 2,
  };

  test('should be a subclass of Word entity', () async {
    // assert
    expect(tWordModel, isA<Word>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is valid', () async {
      // act
      final result = WordModel.fromJson(tWordModelJson);
      // assert
      expect(result, tWordModel);
    });

    test('should return a valid model when the JSON is valid', () async {
      // act
      final result = WordModel.fromJson(tWordModelJson2);
      // assert
      expect(result, tWordModel2);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      // act
      final result = tWordModel.toJson();
      // assert
      expect(result, tWordModelJson);
    });

    test('should return a JSON map containing the proper data', () async {
      // act
      final result = tWordModel2.toJson();
      // assert
      expect(result, tWordModelJson2);
    });
  });
}
