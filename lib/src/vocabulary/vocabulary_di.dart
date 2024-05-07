import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gre_vocabulary/gen/assets.gen.dart';
import 'package:gre_vocabulary/src/vocabulary/application/vocabulary_controller.dart';
import 'package:gre_vocabulary/src/vocabulary/application/vocabulary_state.dart';
import 'package:gre_vocabulary/src/vocabulary/domain/vocabulary_domain.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/data_source/db_keys.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/data_source/isar_local_data_source.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/data_source/local_data_source.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/isar_word_details_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/models/isar_word_model.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/repository/wordlists_csv_parsers/csv_parser.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/repository/wordlists_csv_parsers/economics_hitlist_parser.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/repository/wordlists_csv_parsers/gre_prep_list_parser.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/repository/wordlists_csv_parsers/manya_hit_list_parser.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/repository/wordlists_csv_parsers/manya_princeton_hitlist_parser.dart';
import 'package:gre_vocabulary/src/vocabulary/infrastructure/repository/wordlists_csv_parsers/online_prep_list_parser.dart';
import 'package:gre_vocabulary/src/vocabulary/presentation/words_to_be_shown_queue.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isar/isar.dart';

import 'domain/entities/word_details.dart';
import 'infrastructure/repository/vocabulary_repository.dart';
import 'infrastructure/repository/words_lists/base_words_list.dart';

final wordDetailsProvider = StateProvider<WordDetails?>((ref) => null);

final wordStackProvider =
    StateProvider.family<WordsToBeShownQueue, ValueSetter<WordDetails>>(
  (ref, callbackOnShowWord) => WordsToBeShownQueue(callbackOnShowWord),
);

final isarProvider = FutureProvider<Isar>(
  (ref) async => await Isar.open(
    [
      IsarWordModelSchema,
      IsarWordDetailsModelSchema,
    ],
    name: "isar_db",
  ),
);

final vocabularyLocalDataSourceProvider =
    FutureProvider<LocalDataSource>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return IsarLocalDataSource(
    hiveBoxes:
        DB(generalDataBox: await Hive.openBox(DBKeys.generalBox), isar: isar),
  );
});

final csvListsParserProvider = Provider<CSVListsParser>(
  (ref) => CSVListsParserImpl(
    wordsLists: [
      BaseWordsList(
        name: "economistHitList",
        path: Assets.csv.economistHitList,
        wordsListKey: 'economistHitList',
        wordsParser: const EconomicsHitListParser(),
      ),
      BaseWordsList(
        wordsParser: const ManyaHitListParser(),
        path: Assets.csv.manyaHitList,
        wordsListKey: 'manyahitlist',
        name: "manyahitlist",
      ),
      BaseWordsList(
        wordsParser: const ManyaPrincetonHitListParser(),
        path: Assets.csv.manyaPrincetonList,
        wordsListKey: 'manyaprincetonlist',
        name: "manyaprincetonlist",
      ),
      BaseWordsList(
        wordsParser: GrePreListParser(),
        path: Assets.csv.grePrepList,
        wordsListKey: 'greprepList',
        name: "greprepList",
      ),
      BaseWordsList(
        wordsParser: const OnlinePrepListParser(),
        path: Assets.csv.onlinePrepList,
        wordsListKey: 'onlineprepList',
        name: 'onlineprepList',
      ),
    ],
    csvToListConverter: const CsvToListConverter(),
  ),
);

final vocabularyServiceFacadeProvider = FutureProvider<VocabularyServiceFacade>(
  (ref) async => VocabularyRepository(
    localDataSource: await ref.watch(vocabularyLocalDataSourceProvider.future),
    csvListsParser: ref.read(csvListsParserProvider),
  ),
);

final vocabularyControllerProvider =
    StateNotifierProvider<VocabularyController, VocabularyState>((ref) {
  final serviceFacade = ref.watch(vocabularyServiceFacadeProvider);
  return serviceFacade.maybeWhen(
    data: (data) {
      return VocabularyController(
        service: data,
      );
    },
    orElse: () {
      log("Thorwing provider error");
      throw Exception("basted");
    },
  );
});
