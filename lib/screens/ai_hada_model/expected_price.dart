import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:e_commerce_app_flutter/data/hada_state-dis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropPriceAdvisorScreen extends StatefulWidget {
  @override
  _CropPriceAdvisorScreenState createState() => _CropPriceAdvisorScreenState();
}

class _CropPriceAdvisorScreenState extends State<CropPriceAdvisorScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedState;
  String _district = '';
  String? _selectedMarket;
  String? _selectedCommodity;
  DateTime _selectedDate = DateTime.now();
  double _expectedPrice = 0.0;
  double _predictedPrice = 0.0;

  List<String> _selectedDistricts = [];
  List<String> _selectedMarkets =
      []; // List of markets based on selected district
  String _market = '';

  String? _selectedCrop; // Variable to hold the selected crop name
  String? _selectedCropVariety; // Variable to hold the selected crop variety
  String? _selectedGrade; // Variable to hold the selected crop grade

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Price Advisor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // State Dropdown
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // print(stateDistrictMarketMap["Andhra Pradesh"]![
                      //     "Anantapur"]);
                      DropDownState(
                        DropDown(
                          bottomSheetTitle: const Text(
                            'Select State',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          submitButtonChild: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          data: stateDistrictMarketMap.keys
                              .map((state) => SelectedListItem(name: state))
                              .toList(),
                          onSelected: (List<dynamic> selectedList) {
                            List<String> list = [];
                            for (var item in selectedList) {
                              if (item is SelectedListItem) {
                                list.add(item.name);
                              }
                            }
                            setState(() {
                              _selectedState =
                                  list.isNotEmpty ? list.first : '';
                              _district =
                                  ''; // Reset district when state changes
                              _selectedDistricts = stateDistrictMap[
                                      _selectedState] ??
                                  []; // Update districts based on selected state
                              _selectedMarkets =
                                  []; // Reset markets when state changes
                              _market = ''; // Reset market when state changes
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child: Text(_selectedState?.isEmpty ?? true
                        ? 'Select State'
                        : _selectedState!),
                  ),
                ),

                SizedBox(height: 16),

                // District Dropdown
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_selectedState?.isEmpty ?? true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Please select a state first')),
                        );
                        return;
                      }
                      DropDownState(
                        DropDown(
                          bottomSheetTitle: const Text(
                            'Select District',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          submitButtonChild: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          data: stateDistrictMarketMap[_selectedState]!
                              .keys
                              .map((district) =>
                                  SelectedListItem(name: district))
                              .toList(), // Fetch districts from stateDistrictMarketMap
                          onSelected: (List<dynamic> selectedList) {
                            List<String> list = [];
                            for (var item in selectedList) {
                              if (item is SelectedListItem) {
                                list.add(item.name);
                              }
                            }
                            setState(() {
                              _district = list.isNotEmpty ? list.first : '';
                              _selectedMarkets = stateDistrictMarketMap[
                                      _selectedState]?[_district] ??
                                  []; // Update markets based on selected district
                              _market =
                                  ''; // Reset market when district changes
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child:
                        Text(_district.isEmpty ? 'Select District' : _district),
                  ),
                ),
                SizedBox(height: 16),

                // Market Dropdown
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      print(stateDistrictMarketMap[_selectedState]?[_district]);
                      if (_district.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Please select a district first')),
                        );
                        return;
                      }
                      DropDownState(
                        DropDown(
                          bottomSheetTitle: const Text(
                            'Select Market',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          submitButtonChild: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          data: stateDistrictMarketMap[_selectedState]
                                      ?[_district]
                                  ?.map((market) =>
                                      SelectedListItem(name: market))
                                  .toList() ??
                              [], // Fetch markets based on selected state and district
                          onSelected: (List<dynamic> selectedList) {
                            List<String> list = [];
                            for (var item in selectedList) {
                              if (item is SelectedListItem) {
                                list.add(item.name);
                              }
                            }
                            setState(() {
                              _market = list.isNotEmpty
                                  ? list.first
                                  : ''; // Update selected market
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child: Text(_market.isEmpty ? 'Select Market' : _market),
                  ),
                ),
                SizedBox(height: 16),

                // Crop Name Dropdown
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      DropDownState(
                        DropDown(
                          bottomSheetTitle: const Text(
                            'Select Crop',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          submitButtonChild: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          data: cropVarieties.keys
                              .map((crop) => SelectedListItem(name: crop))
                              .toList(),
                          onSelected: (List<dynamic> selectedList) {
                            List<String> list = [];
                            for (var item in selectedList) {
                              if (item is SelectedListItem) {
                                list.add(item.name);
                              }
                            }
                            setState(() {
                              _selectedCrop = list.isNotEmpty ? list.first : '';
                              _selectedCropVariety =
                                  ''; // Reset crop variety when crop changes
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child: Text(_selectedCrop?.isEmpty ?? true
                        ? 'Select Crop'
                        : _selectedCrop!),
                  ),
                ),
                SizedBox(height: 16),

                // Crop Variety Dropdown
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_selectedCrop?.isEmpty ?? true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a crop first')),
                        );
                        return;
                      }
                      DropDownState(
                        DropDown(
                          bottomSheetTitle: const Text(
                            'Select Crop Variety',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          submitButtonChild: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          data: cropVarieties[_selectedCrop]!
                              .map((variety) => SelectedListItem(name: variety))
                              .toList(),
                          onSelected: (List<dynamic> selectedList) {
                            List<String> list = [];
                            for (var item in selectedList) {
                              if (item is SelectedListItem) {
                                list.add(item.name);
                              }
                            }
                            setState(() {
                              _selectedCropVariety = list.isNotEmpty
                                  ? list.first
                                  : ''; // Update selected crop variety
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child: Text(_selectedCropVariety?.isEmpty ?? true
                        ? 'Select Crop Variety'
                        : _selectedCropVariety!),
                  ),
                ),
                SizedBox(height: 16),

                // Grade Dropdown
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      DropDownState(
                        DropDown(
                          bottomSheetTitle: const Text(
                            'Select Grade',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          submitButtonChild: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          data: ['1', '2', '3'] // Example grades
                              .map((grade) => SelectedListItem(name: grade))
                              .toList(),
                          onSelected: (List<dynamic> selectedList) {
                            List<String> list = [];
                            for (var item in selectedList) {
                              if (item is SelectedListItem) {
                                list.add(item.name);
                              }
                            }
                            setState(() {
                              _selectedGrade = list.isNotEmpty
                                  ? list.first
                                  : ''; // Update selected grade
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child: Text(_selectedGrade?.isEmpty ?? true
                        ? 'Select Grade'
                        : _selectedGrade!),
                  ),
                ),
                SizedBox(height: 16),

                // Date Picker
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate; // Update selected date
                        });
                      }
                    },
                    child: Text(
                        'Select Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                  ),
                ),
                SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Format the data for submission
                      var submissionData = [
                        {
                          "state_name": _selectedState,
                          "district_name": _district,
                          "market_name": _market,
                          "commodity_name": _selectedCrop,
                          "variety": _selectedCropVariety,
                          "grade": _selectedGrade != null
                              ? int.parse(_selectedGrade!)
                              : null, // Assuming grades are stored as strings
                          "year": DateFormat('yyyy').format(_selectedDate),
                          "month": DateFormat('MM').format(_selectedDate),
                          "day": DateFormat('dd').format(_selectedDate),
                        }
                      ];

                      // Send the data to the specified URL
                      var response = await http.post(
                        Uri.parse(
                            'https://4cfa-103-232-241-223.ngrok-free.app/api/price-predictor'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(submissionData),
                      );

                      if (response.statusCode == 200) {
                        // Handle successful response
                        var responseData = jsonDecode(response.body);
                        _predictedPrice = responseData['predicted_prices']
                            [0]; // Extract the predicted price
                        print('Data submitted successfully: ${response.body}');
                      } else {
                        // Handle error response
                        print('Failed to submit data: ${response.statusCode}');
                      }

                      setState(() {}); // Update UI
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Get Expected Price'),
                  ),
                ),

                // Expected Price Output
                if (_predictedPrice != 0.0)
                  Column(
                    children: [
                      SizedBox(height: 24),
                      Text(
                        'Predicted Price for $_selectedCropVariety on ${DateFormat('yyyy-MM-dd').format(_selectedDate)}:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${_predictedPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
