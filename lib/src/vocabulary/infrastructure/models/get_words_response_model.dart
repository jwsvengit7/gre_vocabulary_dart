import '../../domain/entities/get_words_response.dart';

class GetWordsResponseModel<T> extends GetWordsResponse<T> {
  const GetWordsResponseModel({
    required super.words,
    required super.totalWords,
    required super.currentPage,
    required super.totalPages,
    required super.wordsPerPage,
  });

  factory GetWordsResponseModel.fromJson(Map<String, dynamic> json) {
    return GetWordsResponseModel(
      words: json['items'] as List<T>,
      totalWords: json['total'] as int,
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      wordsPerPage: json['itemsPerPage'] as int,
    );
  }

  factory GetWordsResponseModel.empty() {
    return const GetWordsResponseModel(
      words: [],
      totalWords: 0,
      currentPage: 0,
      totalPages: 0,
      wordsPerPage: 0,
    );
  }
}
