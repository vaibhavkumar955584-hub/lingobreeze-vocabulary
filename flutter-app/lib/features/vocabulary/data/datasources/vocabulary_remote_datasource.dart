import 'package:dio/dio.dart';
import '../models/vocabulary_word_model.dart';

/// Data Source interface for discovery API operations.
abstract class VocabularyRemoteDataSource {
  Future<List<VocabularyWordModel>> getWordsFromAPI();
}

/// Implementation using Dio for HTTP operations.
class VocabularyRemoteDataSourceImpl implements VocabularyRemoteDataSource {
  final Dio dio;

  VocabularyRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<VocabularyWordModel>> getWordsFromAPI() async {
    try {
      final response = await dio.get('/words');

      if (response.statusCode == 200) {
        // Handle both direct list and { "data": [...] } structure
        final List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data['data'] is List) {
          data = response.data['data'];
        } else {
          data = [];
        }

        return data.map((json) => VocabularyWordModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected API error occurred: $e');
    }
  }
}
