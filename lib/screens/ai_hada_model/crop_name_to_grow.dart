import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // Import for jsonEncode
>>>>>>> 9ede0af5c20ed19950ac9b8fe74c33b3a6ee0409

class CropAdvisorScreen extends StatefulWidget {
  @override
  _CropAdvisorScreenState createState() => _CropAdvisorScreenState();
}

class _CropAdvisorScreenState extends State<CropAdvisorScreen> {
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD
  double _n = 0,
      _p = 0,
      _k = 0,
      _temperature = 0,
      _humidity = 0,
      _ph = 0,
      _rainfall = 0;
  List<String> _suggestedCrops = [];
=======
  String _nitrogen = ''; // Variable to hold nitrogen value
  String _phosphorus = ''; // Variable to hold phosphorus value
  String _potassium = ''; // Variable to hold potassium value
  String _temperature = ''; // Variable to hold temperature value
  String _humidity = ''; // Variable to hold humidity value
  String _ph = ''; // Variable to hold pH value
  String _rainfall = ''; // Variable to hold rainfall value
  String _suggestedCrop = ''; // Variable to hold the suggested crop
>>>>>>> 9ede0af5c20ed19950ac9b8fe74c33b3a6ee0409

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Advisor'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Nitrogen Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nitrogen (N)',
                    hintText: 'Enter a value between 0 and 150',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter nitrogen value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 150) {
                      return 'Value must be between 0 and 150';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _nitrogen = value,
                ),
                SizedBox(height: 16),

<<<<<<< HEAD
                // Input Fields
                _inputField('Nitrogen (N)', TextInputType.number,
                    (value) => _n = double.parse(value!)),
                SizedBox(height: 16),
                _inputField('Phosphorus (P)', TextInputType.number,
                    (value) => _p = double.parse(value!)),
                SizedBox(height: 16),
                _inputField('Potassium (K)', TextInputType.number,
                    (value) => _k = double.parse(value!)),
                SizedBox(height: 16),
                _inputField('Temperature (°C)', TextInputType.number,
                    (value) => _temperature = double.parse(value!)),
                SizedBox(height: 16),
                _inputField('Humidity (%)', TextInputType.number,
                    (value) => _humidity = double.parse(value!)),
                SizedBox(height: 16),
                _inputField('Soil pH', TextInputType.number,
                    (value) => _ph = double.parse(value!)),
                SizedBox(height: 16),
                _inputField('Rainfall (mm)', TextInputType.number,
                    (value) => _rainfall = double.parse(value!)),
=======
                // Phosphorus Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phosphorus (P)',
                    hintText: 'Enter a value between 0 and 150',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phosphorus value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 150) {
                      return 'Value must be between 0 and 150';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _phosphorus = value,
                ),
                SizedBox(height: 16),

                // Potassium Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Potassium (K)',
                    hintText: 'Enter a value between 0 and 210',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter potassium value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 210) {
                      return 'Value must be between 0 and 210';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _potassium = value,
                ),
                SizedBox(height: 16),

                // Temperature Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Temperature (°C)',
                    hintText: 'Enter a value between 0 and 60',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter temperature value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 60) {
                      return 'Value must be between 0 and 60';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _temperature = value,
                ),
                SizedBox(height: 16),

                // Humidity Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Humidity (%)',
                    hintText: 'Enter a value between 10 and 100',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter humidity value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 10 || intValue > 100) {
                      return 'Value must be between 10 and 100';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _humidity = value,
                ),
                SizedBox(height: 16),

                // pH Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Soil pH',
                    hintText: 'Enter a value between 0 and 14',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pH value';
                    }
                    final intValue = double.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 14) {
                      return 'Value must be between 0 and 14';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _ph = value,
                ),
                SizedBox(height: 16),

                // Rainfall Input Field with Constraints
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Rainfall (mm)',
                    hintText: 'Enter a value between 0 and 300',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter rainfall value';
                    }
                    final intValue = int.tryParse(value);
                    if (intValue == null || intValue < 0 || intValue > 300) {
                      return 'Value must be between 0 and 300';
                    }
                    return null; // Return null if validation passes
                  },
                  onChanged: (value) => _rainfall = value,
                ),
                SizedBox(height: 16),
>>>>>>> 9ede0af5c20ed19950ac9b8fe74c33b3a6ee0409

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Format the data for submission
                      var submissionData = [
                        {
                          "N": _nitrogen,
                          "P": _phosphorus,
                          "K": _potassium,
                          "temperature": _temperature,
                          "humidity": _humidity,
                          "ph": _ph,
                          "rainfall": _rainfall,
                        }
                      ];

                      // Send the data to the specified URL
                      var response = await http.post(
                        Uri.parse(
                            'https://4cfa-103-232-241-223.ngrok-free.app/api/crop-recommender'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(submissionData),
                      );

                      if (response.statusCode == 200) {
                        // Handle successful response
                        var responseData = jsonDecode(response.body);
                        // Check if the response is a list and extract the prediction
                        if (responseData.isNotEmpty &&
                            responseData[0]['prediction'] != null) {
                          _suggestedCrop = responseData[0]
                              ['prediction']; // Extract the predicted crop
                        } else {
                          _suggestedCrop =
                              'No prediction available'; // Handle case where prediction is null
                        }
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
                    child: Text('Get Crop Suggestions'),
                  ),
                ),

                // Suggested Crop Output
                if (_suggestedCrop.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(height: 24),
                      Text(
<<<<<<< HEAD
                        'Suggested Crops for Your Location:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ..._suggestedCrops
                          .map((crop) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Chip(
                                  label: Text(crop),
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                  labelStyle: TextStyle(color: Colors.black),
                                ),
                              ))
                          .toList(),
=======
                        'Suggested Crop for Your Location:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Chip(
                          label: Text(_suggestedCrop),
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                      ),
>>>>>>> 9ede0af5c20ed19950ac9b8fe74c33b3a6ee0409
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _inputField(
      String label, TextInputType inputType, Function(String?) onSaved) {
    return TextFormField(
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
=======
>>>>>>> 9ede0af5c20ed19950ac9b8fe74c33b3a6ee0409
}
