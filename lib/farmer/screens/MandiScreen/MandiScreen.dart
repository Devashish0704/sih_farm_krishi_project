// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../config.dart';
// import '../VideoScreen.dart';
// import './state/MandiState.dart';
// import './state/MandiBloc.dart';
// import './local_widgets/CropCard.dart';
// import '../../widgets/LoadingSpinner.dart';
// import '../../services/LocalizationProvider.dart';

// class MandiScreen extends StatefulWidget {
//   @override
//   _MandiScreenState createState() => _MandiScreenState();
// }

// class _MandiScreenState extends State<MandiScreen> {
//   void _goToTutorial(bool isEnglish) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (ctx) => VideoScreen(
//           isEnglish ? 'Mandi' : 'मंडी',
//           isEnglish ? TUTORIAL_URL_MANDI_ENGLISH : TUTORIAL_URL_MANDI_HINDI,
//         ),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     //  Provider.of<MandiBloc>(context).refresh();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

//     return Container(
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Theme.of(context).primaryColor,
//             Theme.of(context).colorScheme.secondary,
//           ],
//         ),
//       ),
//       child: Column(
//         children: <Widget>[
//           SizedBox(height: MediaQuery.of(context).size.height * 0.06),
//           Container(
//             width: MediaQuery.of(context).size.width,
//             child: _header(context, isEnglish),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: StreamBuilder<MandiState>(
//                 stream: Provider.of<MandiBloc>(context).state,
//                 initialData: MandiState.onRequest(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return loadingSpinner();
//                   }

//                   final state = snapshot.data;
//                   if (state?.isLoading == true) {
//                     return loadingSpinner();
//                   }

//                   if (state?.error != null) {
//                     return Center(child: Text(state!.error!));
//                   }

//                   final crops = state?.crops ?? [];
//                   return ListView.builder(
//                     padding: const EdgeInsets.all(0),
//                     itemCount: crops.length,
//                     itemBuilder: (ctx, index) => CropCard(
//                       crops[index],
//                       isEnglish,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _header(BuildContext context, bool isEnglish) {
//     return Container(
//       alignment: Alignment.center,
//       width: MediaQuery.of(context).size.width * 0.8,
//       padding: const EdgeInsets.symmetric(horizontal: 25),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Text(
//             isEnglish ? 'Mandi' : 'मंडी',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Lato',
//               fontSize: isEnglish ? 20 : 24,
//             ),
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.help,
//               color: Colors.white,
//             ),
//             onPressed: () => _goToTutorial(isEnglish),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:e_commerce_app_flutter/farmer/config.dart';
import 'package:e_commerce_app_flutter/farmer/models/Crop.dart';
import 'package:e_commerce_app_flutter/farmer/screens/MandiScreen/local_widgets/CropCard.dart';
import 'package:e_commerce_app_flutter/farmer/screens/VideoScreen.dart';
import 'package:e_commerce_app_flutter/farmer/services/LocalizationProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MandiScreen extends StatelessWidget {
  final String jsonData = '''
  [
    {
      "name": "Wheat",
      "location": "Udaipur",
      "quantity": "500 kg",
      "modal_price": "1800",
      "min_price": "1700",
      "max_price": "1900",
      "last_updated": "2024-09-01 10:00:00"
    },
    {
      "name": "Rice",
      "location": "Jaipur",
      "quantity": "800 kg",
      "modal_price": "2400",
      "min_price": "2300",
      "max_price": "2500",
      "last_updated": "2024-09-01 11:00:00"
    },
    {
      "name": "Corn",
      "location": "Kota",
      "quantity": "600 kg",
      "modal_price": "1500",
      "min_price": "1400",
      "max_price": "1600",
      "last_updated": "2024-09-01 09:00:00"
    }
  ]
  ''';

  List<Crop> parseCrops(String jsonData) {
    final List parsed = json.decode(jsonData);
    return parsed.map((json) => Crop.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;
    final crops = parseCrops(jsonData);

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
          Container(
            width: MediaQuery.of(context).size.width,
            child: _header(context, isEnglish),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: crops.length,
                itemBuilder: (ctx, index) => CropCard(
                  crops[index],
                  isEnglish,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, bool isEnglish) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            isEnglish ? 'Mandi' : 'मंडी',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lato',
              fontSize: isEnglish ? 20 : 24,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.help,
              color: Colors.white,
            ),
            onPressed: () => _goToTutorial(isEnglish, context),
          ),
        ],
      ),
    );
  }

  void _goToTutorial(bool isEnglish, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => VideoScreen(
          isEnglish ? 'Mandi' : 'मंडी',
          isEnglish ? TUTORIAL_URL_MANDI_ENGLISH : TUTORIAL_URL_MANDI_HINDI,
        ),
      ),
    );
  }
}
