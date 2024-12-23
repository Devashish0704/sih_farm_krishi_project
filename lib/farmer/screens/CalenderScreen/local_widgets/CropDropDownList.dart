// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // import '../../../services/LocalizationProvider.dart';

// // class CropDropdownList extends StatefulWidget {
// //   final Function callback;

// //   const CropDropdownList(this.callback);

// //   @override
// //   _CropDropdownListState createState() => _CropDropdownListState();
// // }

// // class _CropDropdownListState extends State<CropDropdownList> {
// //   List crops = [];
// //   final _db = FirebaseFirestore.instance;
// //   String selectedCrop = "";

// //   @override
// //   Widget build(BuildContext context) {
// //     bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

// //     return Scaffold(
// //       backgroundColor: Colors.transparent,
// //       body: Center(
// //         child: Container(
// //           height: 360,
// //           margin: const EdgeInsets.all(20),
// //           decoration: BoxDecoration(
// //               color: Colors.white, borderRadius: BorderRadius.circular(15)),
// //           child: Column(
// //             children: <Widget>[
// //               customHeader(isEnglish),
// //               Container(
// //                 height: 300,
// //                 child: FutureBuilder<DocumentSnapshot>(
// //                     future: _db
// //                         .collection(
// //                             isEnglish ? 'configurables' : 'hindiConfigurables')
// //                         .document('crops')
// //                         .get(),
// //                     builder: (context, snapshot) {
// //                       if (snapshot.connectionState != ConnectionState.waiting &&
// //                           snapshot.hasData) {
// //                         if (snapshot.data != null) {
// //                           crops = snapshot.data['crops'] ?? [];
// //                         }
// //                       }
// //                       return ListView.builder(
// //                         itemBuilder: (ctx, index) => RadioListTile(
// //                             title: Text(crops[index].toString()),
// //                             groupValue: this.selectedCrop,
// //                             value: crops[index],
// //                             onChanged: (val) {
// //                               setState(() => selectedCrop = val);
// //                               widget.callback(val);
// //                             }),
// //                         itemCount: crops.length,
// //                       );
// //                     }),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget customHeader(bool isEnglish) {
// //     return Container(
// //       padding: const EdgeInsets.only(
// //         top: 10,
// //         left: 20,
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: <Widget>[
// //           Text(
// //             isEnglish ? 'Select a Crop' : 'फसल का चयन करें',
// //             style: TextStyle(
// //               color: Colors.black.withOpacity(0.8),
// //               fontFamily: 'Lato',
// //               fontSize: 18,
// //             ),
// //           ),
// //           IconButton(
// //             icon: Icon(
// //               Icons.cancel,
// //               color: Colors.black.withOpacity(0.8),
// //             ),
// //             onPressed: () => Navigator.of(context).pop(),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../../services/LocalizationProvider.dart';

// class CropDropdownList extends StatefulWidget {
//   final Function(String) callback;

//   const CropDropdownList(this.callback, {Key? key}) : super(key: key);

//   @override
//   _CropDropdownListState createState() => _CropDropdownListState();
// }

// class _CropDropdownListState extends State<CropDropdownList> {
//   List<String> crops = [];
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   String selectedCrop = "";

//   @override
//   Widget build(BuildContext context) {
//     bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Center(
//         child: Container(
//           height: 360,
//           margin: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Column(
//             children: <Widget>[
//               customHeader(isEnglish),
//               Container(
//                 height: 300,
//                 child: FutureBuilder<DocumentSnapshot>(
//                   future: _db
//                       .collection(
//                           isEnglish ? 'configurables' : 'hindiConfigurables')
//                       .doc('crops')
//                       .get(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (snapshot.hasData && snapshot.data != null) {
//                       var data = snapshot.data!.data() as Map<String, dynamic>;
//                       crops = List<String>.from(data['crops'] ?? []);
//                     }
//                     return ListView.builder(
//                       itemCount: crops.length,
//                       itemBuilder: (ctx, index) => RadioListTile<String>(
//                         title: Text(crops[index]),
//                         groupValue: selectedCrop,
//                         value: crops[index],
//                         onChanged: (val) {
//                           setState(() {
//                             selectedCrop = val!;
//                           });
//                           widget.callback(val!);
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget customHeader(bool isEnglish) {
//     return Container(
//       padding: const EdgeInsets.only(
//         top: 10,
//         left: 20,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Text(
//             isEnglish ? 'Select a Crop' : 'फसल का चयन करें',
//             style: TextStyle(
//               color: Colors.black.withOpacity(0.8),
//               fontFamily: 'Lato',
//               fontSize: 18,
//             ),
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.cancel,
//               color: Colors.black.withOpacity(0.8),
//             ),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CropDropdownList extends StatefulWidget {
  final Function(String) callback;

  const CropDropdownList(this.callback, {Key? key}) : super(key: key);

  @override
  _CropDropdownListState createState() => _CropDropdownListState();
}

class _CropDropdownListState extends State<CropDropdownList> {
  List<String> crops = ["Wheat", "Rice", "Maize", "Barley", "Soybean"];
  String selectedCrop = "";

  @override
  Widget build(BuildContext context) {
    bool isEnglish =
        true; // Hardcoded for demonstration. Use actual localization logic here.

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 360,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: <Widget>[
              customHeader(isEnglish),
              Container(
                height: 300,
                child: ListView.builder(
                  itemCount: crops.length,
                  itemBuilder: (ctx, index) => RadioListTile<String>(
                    title: Text(crops[index]),
                    groupValue: selectedCrop,
                    value: crops[index],
                    onChanged: (val) {
                      setState(() {
                        selectedCrop = val!;
                      });
                      widget.callback(val!);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customHeader(bool isEnglish) {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        left: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            isEnglish ? 'Select a Crop' : 'फसल का चयन करें',
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontFamily: 'Lato',
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.cancel,
              color: Colors.black.withOpacity(0.8),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

void showCropDropdown(BuildContext context, Function(String) selectValues) {
  showDialog(
    context: context,
    builder: (context) => CropDropdownList(selectValues),
  );
}
