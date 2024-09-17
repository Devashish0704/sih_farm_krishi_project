import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import '../widgets/CustomDarkButton.dart';
import '../widgets/CustomTextField.dart';
import '../services/UserInfoProvider.dart';
import '../widgets/LightIconButton.dart';
import '../services/LocalizationProvider.dart';

class UserInfoScreen extends StatefulWidget {
  static const routeName = '/userinfo';

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _aadharController = TextEditingController();

  // Future<Position?> _determinePosition() async {
  //   // Check if location services are enabled
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled, request the user to enable it.
  //     return Future.error('Location services are disabled.');
  //   }

  //   // Check if the app has location permission
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     // Request permission
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permission denied
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   // If permissions are granted, get the current position
  //   return await Geolocator.getCurrentPosition();
  // }

  @override
  Widget build(BuildContext context) {
    bool isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;

    return Scaffold(
        body: Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            pictureContainer(context, isEnglish),
            SizedBox(height: 40),
            CustomTextField(
              icon: LineIcons.user,
              labelText: isEnglish ? "Your Name" : "आपका नाम",
              controller: _nameController,
            ),
            CustomTextField(
              icon: Icons.near_me_outlined,
              labelText: isEnglish ? "Your Age" : "आपकी उम्र",
              controller: _ageController,
              numeric: true,
            ),
            CustomTextField(
              icon: LineIcons.home,
              labelText: isEnglish ? "Your Location" : "आपकी उम्र",
              controller: _locationController,
            ),
            CustomTextField(
              icon: Icons.credit_card,
              labelText: isEnglish ? "Your Aadhar Number" : "आपका आधार नंबर",
              controller: _aadharController,
              numeric: true,
            ),
            SizedBox(height: 30),
            customDarkButton(
                text: isEnglish ? "Submit" : "पुष्टि करें",
                icon: Icons.check_circle,
                onPress: () async {
                  UserInfoProvider.uploadUserInfo(
                      context: context,
                      name: _nameController.text,
                      age: _ageController.text,
                      aadharNumber: _aadharController.text,
                      location: _locationController.text,
                      userPosition: await Geolocator.getCurrentPosition());
                }),
          ],
        ),
      ),
    ));
  }

  showUploadDialog(BuildContext context, bool isEnglish) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        titlePadding: const EdgeInsets.all(20),
        title: Text(
          isEnglish ? "Upload Picture" : "तसवीर डालें",
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 22,
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LightIconButton(
              icon: Icons.camera_alt,
              text: isEnglish ? "Camera" : "कैमरा",
              function: () {
                UserInfoProvider.takePicture(context, () => {setState(() {})});
                Navigator.of(context).pop();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LightIconButton(
              icon: Icons.filter,
              text: isEnglish ? "Gallery" : "गेलरी",
              function: () {
                UserInfoProvider.uploadPicture(
                    context, () => {setState(() {})});
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget pictureContainer(BuildContext context, bool isEnglish) {
    return Container(
      height: 280,
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 70,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: UserInfoProvider.currentImageUrl.isEmpty
                ? Icon(
                    LineIcons.user,
                    size: 70,
                    color: Colors.green[800],
                  )
                : Container(),
            backgroundImage: UserInfoProvider.currentImageUrl.isEmpty
                ? null
                : NetworkImage(UserInfoProvider.currentImageUrl),
          ),
          InkWell(
            onTap: () {
              showUploadDialog(context, isEnglish);
            },
            child: Container(
              margin: const EdgeInsets.only(
                top: 15,
                bottom: 10,
              ),
              padding: const EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 15,
                right: 15,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 0.3,
                ),
                borderRadius: BorderRadius.circular(25),
                color: Colors.green[800],
              ),
              child: Text(
                isEnglish ? "Upload Picture" : "तसवीर डालें",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
