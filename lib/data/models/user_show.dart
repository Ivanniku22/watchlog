
import 'package:cloud_firestore/cloud_firestore.dart';

class UserShow {
  final int tmdbId;
  final String name;
  final String posterPath;
  final String status;
  final DateTime addedAt;

  UserShow({
    required this.tmdbId,
    required this.name,
    required this.posterPath,
    required this.status,
    required this.addedAt,
  });


  factory UserShow.fromMap(Map<String, dynamic> map) {
    final timestamp = map['addedAt'];

    return UserShow(
      tmdbId: map['tmdbId'] as int,
      name: map['name'] as String,
      posterPath: map['posterPath'] as String? ?? '',
      status: map['status'] as String? ?? 'plan_to_watch',
      addedAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
    );
  }

}
