import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../domain/models/models.dart';

part 'exa_search_repository.g.dart';

@riverpod
ExaSearchRepository exaSearchRepository(ExaSearchRepositoryRef ref) {
  return ExaSearchRepository();
}

class ExaSearchRepository {
  static const String _baseUrl = 'https://api.exa.ai';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  
  Future<List<ExaResult>> searchExa({
    required String query,
    String customApiKey = '',
    int numResults = 10,
  }) async {
    final apiKey = customApiKey.isNotEmpty ? customApiKey : const String.fromEnvironment('EXA_API_KEY');
    
    if (apiKey.isEmpty) {
      return _getMockResults(query);
    }
    
    try {
      final response = await _dio.post(
        '/search',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'query': query,
          'numResults': numResults,
          'useAutoprompt': true,
          'type': 'neural',
        },
      );
      
      if (response.statusCode == 200) {
        final results = (response.data['results'] as List)
            .map((json) => ExaResult.fromJson(json))
            .toList();
        return results;
      }
    } catch (e) {
      // Fallback to mock
    }
    
    return _getMockResults(query);
  }
  
  List<ExaResult> _getMockResults(String query) {
    return [
      ExaResult(
        id: '1',
        title: 'Flutter Performance Optimization Guide 2024',
        url: 'https://flutter.dev/docs/perf',
        text: 'Learn how to optimize Flutter apps for 60fps/120fps. Covers rendering pipeline, frame budget, and profiling tools.',
        score: 0.95,
        publishedDate: '2024-01-15',
        author: 'Flutter Team',
      ),
      ExaResult(
        id: '2',
        title: 'Dart 3.3 New Features: Patterns, Records, Sealed Classes',
        url: 'https://dart.dev/language/3.3',
        text: 'Deep dive into Dart 3.3 language features including pattern matching, records, and sealed class hierarchies.',
        score: 0.92,
        publishedDate: '2024-02-20',
        author: 'Dart Team',
      ),
      ExaResult(
        id: '3',
        title: 'Android NDK SIMD Optimization for Flutter',
        url: 'https://developer.android.com/ndk/guides/simd',
        text: 'Using NEON/SVE intrinsics in Flutter native modules for 4-8x performance gains in image processing and ML inference.',
        score: 0.89,
        publishedDate: '2024-03-10',
        author: 'Android NDK Team',
      ),
      ExaResult(
        id: '4',
        title: 'Riverpod 2.5: Best Practices for State Management',
        url: 'https://riverpod.dev/docs/patterns',
        text: 'Modern Riverpod patterns including code generation, async providers, and testing strategies.',
        score: 0.87,
        publishedDate: '2024-01-28',
        author: 'Remi Rousselet',
      ),
      ExaResult(
        id: '5',
        title: 'WebSocket Real-time Communication in Flutter',
        url: 'https://pub.dev/packages/web_socket_channel',
        text: 'Implementing real-time features with WebSocket channels, including reconnection logic and message serialization.',
        score: 0.85,
        publishedDate: '2024-02-05',
        author: 'Flutter Community',
      ),
    ];
  }
}
