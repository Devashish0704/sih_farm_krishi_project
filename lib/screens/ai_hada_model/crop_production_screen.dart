import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:e_commerce_app_flutter/data/hada_state-dis.dart';
import 'package:flutter/material.dart';
import 'package:drop_down_list/drop_down_list.dart'; // Import the drop_down_list package



class CropProductionScreen extends StatefulWidget {
  @override
  _CropProductionScreenState createState() => _CropProductionScreenState();
}

class _CropProductionScreenState extends State<CropProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _state = '';
  String _district = '';
  String _cropYear = '';
  String _season = '';
  String _cropName = '';
  String _area = '';
  String _cropProduction = ''; // Placeholder for output

  List<String> _selectedStates = [];
  List<String> _selectedSeasons = [];
  List<String> _selectedDistricts = [];
  List<String> _cropsAndFruits =
      cropsAndFruits; // Assuming cropsAndFruits is defined in hada_state-dis.dart

  // Predefined options for State and Season of Crop
  List<String> _states = stateDistrictMap.keys.toList();

  List<String> _seasons = [
    'Kharif',
    'Whole Year',
    'Autumn',
    'Rabi',
    'Summer',
    'Winter'
  ];

  String? _selectedSeason; // Use null safety

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Production Estimator'),
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
                  width: double.infinity, // Make the dropdown full width
                  child: OutlinedButton(
                    onPressed: () {
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
                          data: _states
                              .map((state) => SelectedListItem(name: state))
                              .toList(),
                          onSelected: (List<dynamic> selectedList) {
                            List<String> list = [];
                            for (var item in selectedList) {
                              if (item is SelectedListItem) {
                                // print("for state $item");
                                list.add(item.name);
                              }
                            }
                            setState(() {
                              _selectedStates = list; // Update selected states
                              _state = list.isNotEmpty
                                  ? list.first
                                  : ''; // Set the first selected state
                              _selectedDistricts = stateDistrictMap[_state] ??
                                  []; // Update districts based on selected state
                              _district =
                                  ''; // Reset district when state changes
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child: Text(_state.isEmpty
                        ? 'Select State'
                        : _state), // Show selected state
                  ),
                ),
                SizedBox(height: 16),

                // District Dropdown
                SizedBox(
                  width: double.infinity, // Make the dropdown full width
                  child: OutlinedButton(
                    onPressed: () {
                      if (_state.isEmpty) {
                        // Show a message if no state is selected
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
                          data: _selectedDistricts
                              .map((district) =>
                                  SelectedListItem(name: district))
                              .toList(),
                          onSelected: (List<dynamic> selectedList) {
                            // print("selectedList $selectedList");
                            List<String> list = [];
                            for (var item in selectedList) {
                              if (item is SelectedListItem) {
                                list.add(item.name);
                              }
                            }
                            setState(() {
                              _district = list.isNotEmpty
                                  ? list.first
                                  : ''; // Set the first selected district
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child: Text(_district.isEmpty
                        ? 'Select District'
                        : _district), // Show selected district
                  ),
                ),
                SizedBox(height: 16),

                // Crop Name Dropdown
                SizedBox(
                  width: double.infinity, // Make the dropdown full width
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
                          data: _cropsAndFruits
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
                              _cropName = list.isNotEmpty
                                  ? list.first
                                  : ''; // Set the first selected crop
                            });
                          },
                          enableMultipleSelection: false,
                        ),
                      ).showModal(context);
                    },
                    child: Text(_cropName.isEmpty
                        ? 'Select Crop'
                        : _cropName), // Show selected crop
                  ),
                ),
                SizedBox(height: 16),

                // Crop Year
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Crop Year',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Crop Year';
                    }
                    return null;
                  },
                  onSaved: (value) => _cropYear = value!,
                ),
                SizedBox(height: 16),

                // Season Dropdown
                OutlinedButton(
                  onPressed: () {
                    DropDownState(
                      DropDown(
                        bottomSheetTitle: const Text(
                          'Select Season',
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
                        data: _seasons
                            .map((season) => SelectedListItem(name: season))
                            .toList(),
                        onSelected: (List<dynamic> selectedList) {
                          List<String> list = [];
                          for (var item in selectedList) {
                            if (item is SelectedListItem) {
                              list.add(item.name);
                            }
                          }
                          setState(() {
                            _selectedSeasons = list; // Update selected seasons
                            _selectedSeason = list.isNotEmpty
                                ? list.first
                                : ''; // Set the first selected season
                          });
                        },
                        enableMultipleSelection:
                            false, // Set to true if you want multiple selection
                      ),
                    ).showModal(context);
                  },
                  child: Text('Select Season'),
                ),
                SizedBox(height: 16),

                // Area (Size of Land)
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Area (in hectares)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Area';
                    }
                    return null;
                  },
                  onSaved: (value) => _area = value!,
                ),
                SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity, // Make the button full width
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Calculate crop production (example logic)
                        _cropProduction =
                            calculateCropProduction(_area, _selectedSeason);
                        // Show result in a dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Crop Production Result'),
                              content:
                                  Text('Estimated Production: $_cropProduction'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      // Log the selected details
                      print('Selected State: $_state');
                      print('Selected District: $_district');
                      print('Selected Crop: $_cropName');
                      // You can also show a message to the user if needed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Details logged to console')),
                      );
                    },
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to calculate crop production
  String calculateCropProduction(String area, String? season) {
    // Example calculation logic (this can be modified as needed)
    double areaInHectares = double.tryParse(area) ?? 0;
    double productionPerHectare = (season == 'Kharif')
        ? 2000
        : (season == 'Rabi')
            ? 3000
            : 1500; // Example values
    double totalProduction = areaInHectares * productionPerHectare;
    return totalProduction.toStringAsFixed(2) +
        ' kg'; // Return production in kg
  }
}
