import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectVegetableScreen extends StatefulWidget {
  @override
  _SelectVegetableScreenState createState() => _SelectVegetableScreenState();
}

class _SelectVegetableScreenState extends State<SelectVegetableScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedVegetable;

  final List<String> _vegetableChoices = ['Tomato', 'Potato', 'not recognisable'];

  Future<void> _updateSelectedVegetable(String vegetable) async {
    try {
      // Update the Firestore document (replace 'your_document_id' with the actual ID)
      await _firestore.collection('fake').doc('crop').update({
        'name': vegetable,
      });
      setState(() {
        _selectedVegetable = vegetable;
      });
    } catch (e) {
      print('Error updating vegetable: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Vegetable'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a vegetable:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            ..._vegetableChoices.map((vegetable) {
              return ListTile(
                title: Text(vegetable),
                leading: Radio<String>(
                  value: vegetable,
                  groupValue: _selectedVegetable,
                  onChanged: (String? value) {
                    if (value != null) {
                      _updateSelectedVegetable(value);
                    }
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
