import 'package:watchlog/data/models/tmdb_models/popular.dart';

import '../../services/tmdb_service.dart';
import '../models/tmdb_models/search_result.dart';

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

  Future<Popular> searchTvShows(String query) async {
    final response = await tmdbService.searchTvShows(query);
    return Popular.fromJson(response.data);
  }

  Future<List<SearchResult>> searchMulti(String query) async {
    final response = await tmdbService.searchMulti(query);

    final results = response.data['results'] as List;

    return results
        .where((item) =>
    item['media_type'] == 'movie' ||
        item['media_type'] == 'tv')
        .map((item) => SearchResult.fromJson(item))
        .toList();
  }

  Future<Map<String, dynamic>> getMovieDetails(int id) async {
    final response = await tmdbService.getMovieDetails(id);
    return response.data as Map<String, dynamic>;
  }

}