
class TvTimeRecord {
  final String mediaType;
  final String title;
  final int? year;
  final int? season;
  final int? episode;
  final String? imdbId;
  final DateTime? watchedAt;
  final double? rating;

  const TvTimeRecord({
    required this.mediaType,
    required this.title,
    this.year,
    this.season,
    this.episode,
    this.imdbId,
    this.watchedAt,
    this.rating,
  });

  factory TvTimeRecord.fromCsvRow(Map<String, dynamic> row) {
    int? parseInt(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) {
        return null;
      }
      return int.tryParse(value.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) {
        return null;
      }
      return double.tryParse(value.toString());
    }

    DateTime? parseDate(dynamic value) {
      if (value == null || value.toString().trim().isEmpty) {
        return null;
      }
      return DateTime.tryParse(value.toString());
    }

    return TvTimeRecord(
      mediaType: row['media_type']?.toString() ?? '',
      title: row['title']?.toString() ?? '',
      year: parseInt(row['year']),
      season: parseInt(row['season']),
      episode: parseInt(row['episode']),
      imdbId: row['imdb_id']?.toString(),
      watchedAt: parseDate(row['watched_at']),
      rating: parseDouble(row['rating']),
    );
  }
}
