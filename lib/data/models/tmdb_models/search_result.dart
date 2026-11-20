class SearchResult {
  final int id;
  final String mediaType;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;

  SearchResult({
    required this.id,
    required this.mediaType,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final mediaType = json['media_type'] as String;

    return SearchResult(
      id: json['id'],
      mediaType: mediaType,
      title: mediaType == 'movie'
          ? json['title'] ?? ''
          : json['name'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: mediaType == 'movie'
          ? json['release_date'] ?? ''
          : json['first_air_date'] ?? '',
    );
  }

  bool get isMovie => mediaType == 'movie';
  bool get isTvShow => mediaType == 'tv';
}