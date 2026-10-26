
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/show_details/controller/show_details_controller.dart';

class AboutTab extends GetView<ShowDetailsController> {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = controller.showDetails.value;

      final nextEpisode = details?['next_episode_to_air'] as Map<String, dynamic>?;

      final episodeTitle = nextEpisode?['name'] as String?;
      final episodeImage = nextEpisode?['still_path'] as String?;
      final airDate = nextEpisode?['air_date'] as String?;

      String airingDay = '';

      if (airDate != null && airDate.isNotEmpty) {
        final date = DateTime.tryParse(airDate);

        if (date != null) {
          const weekdays = [
            'Monday', 'Tuesday', 'Wednesday', 'Thursday',
            'Friday', 'Saturday', 'Sunday',
          ];

          airingDay = weekdays[date.weekday - 1];
        }
      }

      String formatDate(String dateString) {
        final date = DateTime.tryParse(dateString);

        if (date == null) return dateString;

        final day = date.day.toString().padLeft(2, '0');
        final month = date.month.toString().padLeft(2, '0');
        final year = date.year.toString();

        return '$day-$month-$year';
      }

      if (controller.isLoadingDetails.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (details == null) {
        return const Center(
          child: Text('Unable to load show information.'),
        );
      }

      final overview = details['overview'] as String? ?? '';
      final status = details['status'] as String? ?? 'Unknown';
      final firstAirDate =
          details['first_air_date'] as String? ?? 'Unknown';
      final language =
          details['original_language'] as String? ?? 'Unknown';
      final seasons = details['number_of_seasons'];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nextEpisode != null) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (episodeImage != null && episodeImage.isNotEmpty)
                      Image.network(
                        'https://image.tmdb.org/t/p/w780$episodeImage',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(
                          height: 100,
                          child: Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NEXT EPISODE',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            episodeTitle ?? 'Episode title unavailable',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (airDate != null && airDate.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${airingDay.isNotEmpty ? '$airingDay • ' : ''}${formatDate(airDate)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              overview.isEmpty
                  ? 'No overview available.'
                  : overview,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            Text(
              'Show Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            _InfoRow(label: 'Status', value: status),
            _InfoRow(label: 'First aired', value: firstAirDate),
            _InfoRow(
              label: 'Seasons',
              value: seasons?.toString() ?? 'Unknown',
            ),
            _InfoRow(
              label: 'Original language',
              value: language.toUpperCase(),
            ),
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
