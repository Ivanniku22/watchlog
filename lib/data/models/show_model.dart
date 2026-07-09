class Show {
  final int id;
  final String title;
  final String poster;
  final String season;
  final String episode;
  final String episodeTitle;
  final String episodePend;
  bool watched;

  Show({
    required this.title,
    required this.poster,
    required this.season,
    required this.episode,
    required this.episodeTitle,
    this.watched = false,
    required this.id,
    required this.episodePend,
  });
}