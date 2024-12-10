

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce_app_flutter/farmer/models/Crop.dart';
import 'package:e_commerce_app_flutter/farmer/screens/MandiScreen/local_widgets/CropCard.dart';
import 'package:e_commerce_app_flutter/farmer/services/LocalizationProvider.dart';
import 'package:e_commerce_app_flutter/farmer/services/Mandi/mandiService.dart';

class MandiScreen extends StatefulWidget {
  @override
  _MandiScreenState createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> {
  final MandiService _mandiService = MandiService();

  List<Crop> crops = [];
  List<Map<String, dynamic>> states = [];
  List<Map<String, dynamic>> apmcs = [];

  String? selectedStateId;
  String? selectedStateName;
  String? selectedApmcId;
  String? selectedApmcName;

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      setState(() => isLoading = true);

      // Fetch user's location and states
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String userState = await _mandiService.getStateFromLocation(position);

      final fetchedStates = await _mandiService.fetchStates();
      final fetchedCrops = await _mandiService.fetchCropsByState(
        userState,
        language:
            Provider.of<LocalizationProvider>(context, listen: false).isEnglish
                ? 'en'
                : 'hi',
      );

      // Remove duplicates from the states list
      final uniqueStates = fetchedStates.toSet().toList();

      setState(() {
        states = uniqueStates;
        selectedStateName =
            uniqueStates.any((state) => state['state_name'] == userState)
                ? userState
                : null;
        crops = fetchedCrops;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _onStateChanged(String? state) async {
    if (state == null) return;

    try {
      setState(() {
        selectedStateId = state;
        selectedStateName = getStateNameFromId(selectedStateId);
        apmcs = [];
        selectedApmcId = null;
        isLoading = true;
      });

      print("fetched ampc yoyo stateid $state");
      final fetchedApmcs = await _mandiService.fetchAPMCs(state);
      print("fetched ampc yoyo $fetchedApmcs");

      setState(() {
        apmcs = fetchedApmcs;
        isLoading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _onApmcChanged(String? apmc) async {
    if (apmc == null) return;

    try {
      setState(() {
        selectedApmcId = apmc;
        isLoading = true;
        selectedApmcId = apmc;
        selectedApmcName = getApmcNameFromId(selectedApmcId);
      });

      final fetchedCrops = await _mandiService.fetchCropsByAPMC(
        selectedStateName!,
        selectedApmcName!,
      );

      setState(() {
        crops = fetchedCrops;
        isLoading = false;
        error = null;
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Mandi' : 'मंडी'),
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButton<String>(
                value: selectedStateId,
                hint: Text(isEnglish ? 'Select State' : 'राज्य चुनें'),
                onChanged: _onStateChanged,
                items: states.map((state) {
                  return DropdownMenuItem<String>(
                    value: state['state_id'] as String,
                    child: Text(state['state_name'] as String),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (apmcs.isNotEmpty)
                DropdownButton<String>(
                  value: selectedApmcId,
                  hint: Text(isEnglish ? 'Select APMC' : 'एपीएमसी चुनें'),
                  onChanged: _onApmcChanged,
                  items: apmcs.map((apmc) {
                    return DropdownMenuItem<String>(
                      value: apmc['apmc_id'] as String,
                      child: Text(apmc['apmc_name'] as String),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      print("error yoyo $error");
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!, textAlign: TextAlign.center),
            ElevatedButton(
                onPressed: _initializeScreen, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (crops.isEmpty) {
      return Center(child: Text('No crops available'));
    }

    return ListView.builder(
      itemCount: crops.length,
      itemBuilder: (ctx, index) => CropCard(
        crops[index],
        Provider.of<LocalizationProvider>(context).isEnglish,
      ),
    );
  }

  String? getStateNameFromId(String? stateId) {
    if (stateId == null) return null;

    try {
      var state = states.firstWhere((state) => state['state_id'] == stateId);
      return state['state_name']; // Assuming 'state_name' holds the name
    } catch (e) {
      // Handle the case where no matching state is found
      return null;
    }
  }

  String? getApmcNameFromId(String? apmcId) {
    if (apmcId == null) return null;

    try {
      var apmc = apmcs.firstWhere((apmc) => apmc['apmc_id'] == apmcId);
      return apmc['apmc_name']; // Assuming 'apmc_name' holds the name
    } catch (e) {
      // Handle the case where no matching APMC is found
      return null;
    }
  }
}
