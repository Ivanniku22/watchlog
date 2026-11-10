
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_show.dart';

class ShowRepository {
  ShowRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Get the current user's shows collection.
  CollectionReference<Map<String, dynamic>> get _showsCollection {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not signed in.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_shows');
  }

  // Add a show to the user's library.
  Future<void> addShow({
    required int tmdbId,
    required String name,
    required String posterPath,
    String status = 'plan_to_watch',
  }) async {
    await _showsCollection.doc(tmdbId.toString()).set({
      'tmdbId': tmdbId,
      'name': name,
      'posterPath': posterPath,
      'status': status,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Listen to the user's library in real time.
  Stream<List<UserShow>> getMyShows() {
    return _showsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserShow.fromMap(doc.data());
      }).toList();
    });
  }

  // Update a show's tracking status.
  Future<void> updateStatus(int tmdbId, String status) async {
    await _showsCollection.doc(tmdbId.toString()).update({
      'status': status,
    });
  }

  // Remove a show from the user's library.
  Future<void> removeShow(int tmdbId) async {
    await _showsCollection.doc(tmdbId.toString()).delete();
  }
}
