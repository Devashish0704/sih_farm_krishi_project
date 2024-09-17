import 'package:cloud_firestore/cloud_firestore.dart';

class Calender {
  final int harvestTime;
  final List timestamps;
  final List titles;
  final List subtitles;
  final List links;
  final List imageUrls;

  const Calender({
    required this.timestamps,
    required this.titles,
    required this.subtitles,
    required this.links,
    required this.imageUrls,
    required this.harvestTime,
  });

  factory Calender.fromFirestore(DocumentSnapshot snapshot) {
    // Cast snapshot.data() to a Map<String, dynamic>
    final doc = snapshot.data() as Map<String, dynamic>?;

    if (doc == null) {
      // Handle the case where doc is null
      return Calender(
        timestamps: [],
        titles: [],
        subtitles: [],
        links: [],
        imageUrls: [],
        harvestTime: 0,
      );
    }

    return Calender(
      timestamps: doc["timestamps"] ?? [],
      titles: doc['titles'] ?? [],
      subtitles: doc['subtitles'] ?? [],
      links: doc['links'] ?? [],
      imageUrls: doc['imageUrls'] ?? [],
      harvestTime: doc['harvestTime'] ?? 0,
    );
  }
}
