class ShowModel {
  ShowModel({
    required this.id,
    required this.title,
    required this.totalEpisodes,
    required this.watchedEpisodes,
    required this.status,
  });

  final String id;
  final String title;
  final int totalEpisodes;
  final int watchedEpisodes;
  final String status;

  double get progress {
    if (totalEpisodes == 0) return 0;
    return watchedEpisodes / totalEpisodes;
  }

  ShowModel copyWith({
    String? id,
    String? title,
    int? totalEpisodes,
    int? watchedEpisodes,
    String? status,
  }) {
    return ShowModel(
      id: id ?? this.id,
      title: title ?? this.title,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      watchedEpisodes: watchedEpisodes ?? this.watchedEpisodes,
      status: status ?? this.status,
    );
  }
}