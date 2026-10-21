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

}
