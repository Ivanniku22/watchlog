class WatchlistEpisode {
  final int showId;
  final String showTitle;
  final int seasonNumber;
  final int episodeNumber;
  final String episodeTitle;
  final String? stillPath;
  final String? posterPath;
  final DateTime? airDate;

  WatchlistEpisode({
    required this.showId,
    required this.showTitle,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.episodeTitle,
    this.stillPath,
    this.posterPath,
    this.airDate,
  });

  factory WatchlistEpisode.fromJson({
    required int showId,
    required String showTitle,
    required int seasonNumber,
    required Map<String, dynamic> json,
    String? posterPath,
  }) {
    return WatchlistEpisode(
      showId: showId,
      showTitle: showTitle,
      seasonNumber: seasonNumber,
      episodeNumber: (json['episode_number'] as num).toInt(),
      episodeTitle: json['name'] as String? ?? 'Untitled Episode',
      stillPath: json['still_path'] as String?,
      posterPath: posterPath,
      airDate: json['air_date'] != null
          ? DateTime.tryParse(json['air_date'] as String)
          : null,
    );
  }

  bool get hasAired {
    if (airDate == null) return false;

    final today = DateTime.now();

    return !airDate!.isAfter(
      DateTime(today.year, today.month, today.day),
    );
  }

  bool get isUpcoming => !hasAired;
}


