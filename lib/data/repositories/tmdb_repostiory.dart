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



  Future<Popular> getPopularAnime() async {
    final response = await tmdbService.getPopularAnime();
    return Popular.fromJson(response.data);
  }

  Future<Popular> getTopRatedAnime() async {
    final response = await tmdbService.getTopRatedAnime();
    return Popular.fromJson(response.data);
  }

  Future<Popular> getNewAnime() async {
    final response = await tmdbService.getNewAnime();
    return Popular.fromJson(response.data);
  }

  Future<Map<String, dynamic>> getTvShowDetails(int id) async {
    final response = await tmdbService.getTvShowDetails(id);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSeasonDetails(
      int seriesId,
      int seasonNumber,
      ) async {
    final response = await tmdbService.getSeasonDetails(
      seriesId,
      seasonNumber,
    );

    return response.data as Map<String, dynamic>;
  }

}