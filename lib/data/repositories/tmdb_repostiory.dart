import 'package:watchlog/data/models/tmdb_models/popular.dart';

import '../../services/tmdb_service.dart';

class TmdbRepository {
  final TmdbService tmdbService;

  TmdbRepository(this.tmdbService);

  Future<Popular> getPopularTvShows() async {
    final response = await tmdbService.getPopularTvShows();
    return Popular.fromJson(response.data);
  }


  Future<Popular> getTopRatedTvShows() async {
    final response = await tmdbService.getTopRatedTvShows();
    return Popular.fromJson(response.data);
  }

}