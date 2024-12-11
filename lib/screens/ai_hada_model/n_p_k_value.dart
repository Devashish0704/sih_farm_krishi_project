import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:e_commerce_app_flutter/data/hada_state-dis.dart';
import 'package:flutter/material.dart';
import 'package:drop_down_list/drop_down_list.dart';

class NutrientAdvisorScreen extends StatefulWidget {
  @override
  _NutrientAdvisorScreenState createState() => _NutrientAdvisorScreenState();
}

class _NutrientAdvisorScreenState extends State<NutrientAdvisorScreen> {
  final _formKey = GlobalKey<FormState>();
  double _ph = 0;
  String _cropName = '';
  String _selectedCrop = '';
  List<String> _crops = crops;
  Map<String, Map<String, double>> _nutrientValues = {
    'Rice': {'N': 120, 'P': 60, 'K': 120},
    'Wheat': {'N': 100, 'P': 50, 'K': 100},
    'Maize': {'N': 150, 'P': 70, 'K': 150},
    'Soybean': {'N': 120, 'P': 60, 'K': 120},
    'Cotton': {'N': 100, 'P': 50, 'K': 100},
  };
  Map<String, double> _suggestedNutrients = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrient Advisor'),
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
                    'Get Personalized Nutrient Advice',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                // pH Input
                _inputField('Soil pH', TextInputType.number,
                    (value) => _ph = double.parse(value!)),
                SizedBox(height: 16),

                // Crop Selection with Searchable Dropdown
                GestureDetector(
                  onTap: () {
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
                        data: _crops
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
                            _selectedCrop = list.isNotEmpty
                                ? list.first
                                : ''; // Set the first selected crop
                            _cropName = _selectedCrop; // Update crop name
                          });
                        },
                        enableMultipleSelection: false,
                      ),
                    ).showModal(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedCrop.isEmpty ? 'Select Crop' : _selectedCrop,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // **GET SUGGESTED NUTRIENTS**
                      _suggestedNutrients = _nutrientValues[_cropName] ?? {};
                      setState(() {}); // Update UI
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Get Nutrient Advice'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                ),

                // Suggested Nutrients
                if (_suggestedNutrients.isNotEmpty)
                  Column(
                    children: [
                      SizedBox(height: 24),
                      Text(
                        'Suggested Nutrient Values for $_cropName (pH: $_ph):',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      _nutrientTile(
                          'N (Nitrogen)', _suggestedNutrients['N'] ?? 0),
                      _nutrientTile(
                          'P (Phosphorus)', _suggestedNutrients['P'] ?? 0),
                      _nutrientTile(
                          'K (Potassium)', _suggestedNutrients['K'] ?? 0),
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

  Widget _nutrientTile(String nutrient, double value) {
    return ListTile(
      title: Text(nutrient),
      trailing: Text(value.toString()),
    );
  }
}
