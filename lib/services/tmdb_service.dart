import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmdbService {
  final Dio dio;

  TmdbService(this.dio);

  Future<Response> getPopularTvShows() async {

    final tvPopular = 'https://api.themoviedb.org/3/tv/popular';
    // final moviePopular = 'https://api.themoviedb.org/3/movie/popular';

    return await dio.get(
      tvPopular,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${dotenv.env['TMDB_ACCESS_TOKEN']}',
        },
      ),
    );
  }
}