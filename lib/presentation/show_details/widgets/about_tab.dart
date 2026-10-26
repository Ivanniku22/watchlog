
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watchlog/presentation/show_details/controller/show_details_controller.dart';

class AboutTab extends GetView<ShowDetailsController> {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final details = controller.showDetails.value;

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
