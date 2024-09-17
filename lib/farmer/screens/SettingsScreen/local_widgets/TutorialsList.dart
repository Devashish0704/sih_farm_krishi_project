import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/TutorialBloc.dart';
import '../state/TutorialState.dart';
import '../local_widgets/TutorialCard.dart';
import '../../../widgets/LoadingSpinner.dart';

class TutorialsList extends StatelessWidget {
  final bool isEnglish;

  const TutorialsList(this.isEnglish, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isEnglish ? 'Tutorial Videos' : 'ट्यूटोरियल वीडियो',
            style: TextStyle(
              fontFamily: 'Lato',
              color: Colors.black.withOpacity(0.8),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          StreamBuilder<TutorialState>(
            stream: Provider.of<TutorialBloc>(context).state,
            initialData: TutorialState.onRequest(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: loadingSpinner());
              }

              final state = snapshot.data;
              if (state == null) {
                return Center(child: Text('No data available'));
              }

              if (state.isLoading) {
                return Center(child: loadingSpinner());
              }

              if (state.tutorials!.isEmpty) {
                return Center(child: Text('No tutorials available'));
              }

              return Expanded(
                child: ListView.builder(
                  itemBuilder: (ctx, index) =>
                      tutorialCard(context, state.tutorials![index]),
                  itemCount: state.tutorials!.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
