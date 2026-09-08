import 'dart:collection';

class Popular{
  final int page;
  final List<TvShow> results;
  final int totalPages;
  final int totalResults;

  Popular({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory Popular.fromJson(Map<String, dynamic> json){
    return Popular(
        page: json['page'],
        results: [],
        totalPages: json['total_pages'],
        totalResults: json['total_results']

    );
  }
}

class TvShow{
  final bool adult;
  final String? backdropPath;
  final List<int> genreIds;
  final int id;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String? posterPath;
  final String firstAirDate;
  final bool softcore;
  final String name;
  final double voteAverage;
  final int voteCount;

  TvShow({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.firstAirDate,
    required this.softcore,
    required this.name,
    required this.voteAverage,
    required this.voteCount,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      adult: json['adult'],
      backdropPath: json['backdrop_path'],
      genreIds: json['genre_ids'],
      id: json['id'],
      originCountry: json['origin_country'],
      originalLanguage: json['original_language'],
      originalName: json['original_name'],
      overview: json['overview'],
      popularity: json['popularity'],
      posterPath: json['poster_path'],
      firstAirDate: json['first_air_date'],
      softcore: json['softcore'],
      name: json['name'],
      voteAverage: json['vote_average'],
      voteCount: json['vote_count'],
    );
  }
}