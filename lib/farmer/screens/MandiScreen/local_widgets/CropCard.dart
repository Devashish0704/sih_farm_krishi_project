import 'package:flutter/material.dart';

import './PocketContainer.dart';
import '../../../models/Crop.dart';
import '../../CalenderScreen/local_widgets/FieldDetails.dart';

class CropCard extends StatelessWidget {
  final Crop crop;
  final bool isEnglish;

  CropCard(this.crop, this.isEnglish);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      padding: const EdgeInsets.all(7.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              crop.commodity,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              pocketContainer(
                isEnglish ? 'District' : 'जिला',
                crop.apmc,
              ),
              pocketContainer(
                isEnglish ? 'Arrival' : 'पहुचना',
                crop.commodityArrivals,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              pocketData(
                isEnglish ? 'Min Price' : 'न्यूनतम मूल्य',
                '₹ ' + crop.minPrice,
              ),
              pocketData(
                isEnglish ? 'Modal Price' : 'औसत मूल्य',
                '₹ ' + crop.modalPrice,
              ),
              pocketData(
                isEnglish ? 'Max Price' : 'अधिकतम मूल्य',
                '₹ ' + crop.maxPrice,
              ),
            ],
          )
        ],
      ),
    );
  }
}
