
import 'package:flutter/material.dart';
import '../../../../data/models/user_show.dart';

class WatchCard extends StatelessWidget {
  final UserShow show;

  const WatchCard({
    super.key,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = show.posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500${show.posterPath}'
        : null;

    return Container(
      height: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade900,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: posterUrl != null
                ? Image.network(
              posterUrl,
              width: 60,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.movie, size: 40),
            )
                : const SizedBox(
              width: 60,
              height: 72,
              child: Icon(Icons.movie, size: 40),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  show.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatStatus(show.status),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            size: 22,
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'watching':
        return 'Currently Watching';
      case 'completed':
        return 'Completed';
      case 'dropped':
        return 'Dropped';
      case 'plan_to_watch':
        return 'Plan to Watch';
      default:
        return status;
    }
  }
}

