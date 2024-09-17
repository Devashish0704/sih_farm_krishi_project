import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Tutorial {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String videoUrl;

  const Tutorial({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.videoUrl,
  });

  factory Tutorial.fromFirestore(DocumentSnapshot snapshot) {
    // Cast snapshot.data() to Map<String, dynamic>
    final doc = snapshot.data() as Map<String, dynamic>?;

    if (doc == null) {
      throw StateError('Missing data for Tutorial: ${snapshot.id}');
    }

    return Tutorial(
      id: snapshot.id, // Use snapshot.id for document ID
      title: doc['title'] ?? '',
      subtitle: doc['subtitle'] ?? '',
      imageUrl: doc['imageUrl'] ?? '',
      videoUrl: doc['videoUrl'] ?? '',
    );
  }
}
