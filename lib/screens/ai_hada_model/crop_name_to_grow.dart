import 'package:flutter/material.dart';

class CropAdvisorScreen extends StatefulWidget {
  @override
  _CropAdvisorScreenState createState() => _CropAdvisorScreenState();
}

class _CropAdvisorScreenState extends State<CropAdvisorScreen> {
  final _formKey = GlobalKey<FormState>();
  double _n = 0,
      _p = 0,
      _k = 0,
      _temperature = 0,
      _humidity = 0,
      _ph = 0,
      _rainfall = 0;
  List<String> _suggestedCrops = [];

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
                // Animated Header
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Enter Your Soil & Climate Conditions',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

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

                // Submit Button
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // **SIMULATED CROP SUGGESTIONS**
                      // Replace with actual logic or API call
                      if (_ph > 6 && _rainfall > 500) {
                        _suggestedCrops = ['Rice', 'Wheat', 'Pulses'];
                      } else if (_temperature < 25 && _humidity > 60) {
                        _suggestedCrops = ['Coffee', 'Tea', 'Spices'];
                      } else {
                        _suggestedCrops = ['Maize', 'Soybean', 'Cotton'];
                      }
                      setState(() {}); // Update UI
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Get Crop Suggestions'),
                  ),
                  // style: ElevatedButton.styleFrom(
                  //   primary: Theme.of(context).accentColor,
                  // ),
                ),

                // Suggested Crops
                if (_suggestedCrops.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(height: 24),
                      Text(
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
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}
