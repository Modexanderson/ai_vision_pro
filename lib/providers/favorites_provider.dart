// providers/favorites_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/detected_object.dart';

class FavoritesNotifier extends StateNotifier<List<DetectedObject>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loadFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      final favorites = querySnapshot.docs
          .map((doc) => DetectedObject.fromMap(doc.data()))
          .toList();

      state = favorites;
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> addFavorite(DetectedObject object) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if already in favorites
      if (state.any((fav) => fav.id == object.id)) return;

      final favoriteData = object.toMap();
      favoriteData['addedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(object.id)
          .set(favoriteData);

      state = [object, ...state];
    } catch (e) {
      debugPrint('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String objectId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(objectId)
          .delete();

      state = state.where((fav) => fav.id != objectId).toList();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  Future<void> clearFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      final collection =
          _firestore.collection('users').doc(user.uid).collection('favorites');

      final querySnapshot = await collection.get();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      state = [];
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }

  bool isFavorite(String objectId) {
    return state.any((fav) => fav.id == objectId);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<DetectedObject>>(
  (ref) => FavoritesNotifier(),
);
