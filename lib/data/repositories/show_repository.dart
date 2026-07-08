import '../models/show_model.dart';

class ShowRepository {
  Future<List<ShowModel>> getShows() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      ShowModel(
        id: '1',
        title: 'Severance',
        totalEpisodes: 19,
        watchedEpisodes: 12,
        status: 'Watching',
      ),
      ShowModel(
        id: '2',
        title: 'The Bear',
        totalEpisodes: 28,
        watchedEpisodes: 28,
        status: 'Completed',
      ),
      ShowModel(
        id: '3',
        title: 'Andor',
        totalEpisodes: 24,
        watchedEpisodes: 16,
        status: 'Watching',
      ),
    ];
  }
}