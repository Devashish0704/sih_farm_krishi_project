import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routing/Application.dart';
import '../../widgets/PrimaryButton.dart';
import '../../services/LocalizationProvider.dart';

class SetLanguageScreen extends StatelessWidget {
  void chooseLanguage(BuildContext context, bool isEnglish) async {
    print(isEnglish);
    await Provider.of<LocalizationProvider>(context, listen: false)
        .switchLanguage(isEnglish);
    Application.router!.navigateTo(context, '/', replace: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Select your preffered Language',
              style: TextStyle(
                fontFamily: 'Varela',
                color: Colors.black.withOpacity(0.8),
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            PrimaryButton(
              text: 'English',
              color: Colors.green[800]!,
              press: () => chooseLanguage(context, true),
            ),
            PrimaryButton(
              text: 'हिन्दी',
              color: Colors.amber[800]!,
              press: () => chooseLanguage(context, false),
            ),
          ],
        ),
      ),
    );
  }
}
