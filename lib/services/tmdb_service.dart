import 'package:dio/dio.dart';

class TmdbService {
  TmdbService(this._dio);

  final Dio _dio;

  Future<Response> getPopularTvShows() {
    return _dio.get('tv/popular');
  }


  Future<Response> getTopRatedTvShows() {
    return _dio.get('tv/top_rated');
  }


  Future<Response> getPopularAnime() {
    return _dio.get(
      'discover/tv',
      queryParameters: {
        'with_genres': '16|10765|10759|35|18|9648|10751',
        'with_original_language': 'ja',
        'sort_by': 'popularity.desc',
      },
    );
  }

  Future<Response> getTopRatedAnime() {
    return _dio.get(
      'discover/tv',
      queryParameters: {
        'with_genres': '16|10765|10759|35|18|9648|10751',
        'with_original_language': 'ja',
        'sort_by': 'vote_average.desc',
        'vote_count.gte': 100,
      },
    );
  }

  Future<Response> getNewAnime() {
    return _dio.get(
      'discover/tv',
      queryParameters: {
        'with_genres': 16,
        'with_original_language': 'ja',
        'sort_by': 'first_air_date.desc',
        'first_air_date.gte': '2026-01-01',
        'first_air_date.lte': '2026-12-31',
      },
    );
  }

  Future<Response> getTvShowDetails(int id) {
    return _dio.get(
        '/tv/$id',
    );
  }

  Future<Response> getSeasonDetails(int seriesId, int seasonNumber) {
    return _dio.get('/tv/$seriesId/season/$seasonNumber');
  }

}
