import 'package:e_commerce_app_flutter/farmer/screens/MandiScreen/local_widgets/CropCard.dart';
import 'package:e_commerce_app_flutter/farmer/services/LocalizationProvider.dart';
import 'package:e_commerce_app_flutter/farmer/services/Mandi/mandiService.dart';
import 'package:flutter/material.dart';

import 'package:e_commerce_app_flutter/farmer/models/Crop.dart';
import 'package:provider/provider.dart';

class MandiScreen extends StatefulWidget {
  @override
  _MandiScreenState createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> {
  final MandiService _mandiService = MandiService();
  List<Crop> crops = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // You can change this to your desired state
      final fetchedCrops = await _mandiService.fetchCropsByState(
        'Rajasthan',
        language:
            Provider.of<LocalizationProvider>(context, listen: false).isEnglish
                ? 'en'
                : 'hi',
      );

      print("fetchedCropsYo $fetchedCrops");

      setState(() {
        crops = fetchedCrops;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

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
            // child: _header(context, isEnglish),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      print(error);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error!,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: _loadCrops,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (crops.isEmpty) {
      return Center(
        child: Text(
          'No crops available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: crops.length,
      itemBuilder: (ctx, index) => CropCard(
        crops[index],
        Provider.of<LocalizationProvider>(context).isEnglish,
      ),
    );
  }

  // ... rest of your existing code (_header and _goToTutorial methods)
}


// class Crop {
//   final String name;
//   final String location;
//   final String quantity;
//   final String modalPrice;
//   final String minPrice;
//   final String maxPrice;
//   final String lastUpdated;

//   Crop({
//     required this.name,
//     required this.location,
//     required this.quantity,
//     required this.modalPrice,
//     required this.minPrice,
//     required this.maxPrice,
//     required this.lastUpdated,
//   });

//   factory Crop.fromJson(Map<String, dynamic> json) {
//     return Crop(
//       name: json['name'] ?? '',
//       location: json['location'] ?? '',
//       quantity: json['quantity'] ?? '',
//       modalPrice: json['modal_price']?.toString() ?? '',
//       minPrice: json['min_price']?.toString() ?? '',
//       maxPrice: json['max_price']?.toString() ?? '',
//       lastUpdated: json['last_updated'] ?? '',
//     );
//   }
// }