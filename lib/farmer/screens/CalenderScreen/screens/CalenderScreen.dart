import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/Calender.dart';
import '../local_widgets/CustomAppBar.dart';
import '../../../widgets/LoadingSpinner.dart';
import '../local_widgets/CalenderListItem.dart';
import '../../../services/CropFieldProvider.dart';
import '../../../services/UserDatabaseService.dart';
import '../../../services/LocalizationProvider.dart';

class CalenderScreen extends StatelessWidget {
  final String cropName;
  final Timestamp timestamp;

  CalenderScreen(this.cropName, this.timestamp);

  @override
  Widget build(BuildContext context) {
    bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

    return Scaffold(
      appBar: customAppBar(
        context,
        isEnglish ? 'Timeline' : 'समय',
        isEnglish,
      ),
      body: StreamBuilder<Calender>(
        stream: UserDatabaseService().streamCalender(cropName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingSpinner();
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(isEnglish ? 'No Data Available' : 'कोई डेटा उपलब्ध नहीं'));
          }

          final calender = snapshot.data!;
          
          if (calender.titles.isEmpty) {
            return Center(child: Text(isEnglish ? 'No Entries Found' : 'कोई प्रविष्टियाँ नहीं मिलीं'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (ctx, index) {
              final title = calender.titles[index];
              final subtitle = calender.subtitles[index];
              final date = CropFieldProvider.getFormattedDatePlusDays(
                timestamp,
                calender.timestamps[index],
              );
              final imageUrl = calender.imageUrls[index];
              final link = calender.links[index];

              return calenderListItem(
                context,
                title: title,
                subtitle: subtitle,
                date: date,
                imageUrl: imageUrl,
                link: link,
              );
            },
            itemCount: calender.titles.length,
          );
        },
      ),
    );
  }
}
