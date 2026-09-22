import 'package:dio/dio.dart';

class TmdbService {
  final Dio dio;

  TmdbService(this.dio);

  Future<Response> getPopularTvShows() async {
    return await dio.get(
      'https://api.themoviedb.org/3/tv/popular',
    );
  }
}