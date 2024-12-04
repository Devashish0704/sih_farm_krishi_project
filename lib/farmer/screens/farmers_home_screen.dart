import 'package:e_commerce_app_flutter/farmer/screens/WeatherScreen/weatherservice.dart';
import 'package:e_commerce_app_flutter/farmer/services/UserInfoProvider.dart';
import 'package:e_commerce_app_flutter/farmer/widgets/crop_inside_carousel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:weather/weather.dart';
import '../routing/Application.dart';
import '../services/LocalizationProvider.dart';
// import '../services/WeatherService.dart';
// import '../services/CropPredictionService.dart';

class FarmerHomeScreen extends StatefulWidget {
  @override
  _FarmerHomeScreenState createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  late String _greeting = '';
  // Weatherservice _weatherService = Weatherservice();
  late WeatherService _weatherService;
  // late CropPredictionService _cropPredictionService;

  @override
  void initState() {
    super.initState();
    _setGreeting();
    _weatherService = WeatherService();
    // _cropPredictionService = CropPredictionService();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        _greeting = 'Good Morning';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon';
      } else {
        _greeting = 'Good Evening';
      }
    });
  }

  Widget _buildWeatherWidget() {
    return GestureDetector(
      onTap: () => Application.router.navigateTo(context, '/weather'),
      child: FutureBuilder<Weather>(
        future: _weatherService.getWeatherForecast(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Unable to fetch weather');
          }
          final weatherData = snapshot.data;
          print(weatherData);
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Today',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${weatherData?.temperature}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(weatherData?.weatherDescription),
                      size: 40,
                      color: Colors.blue[700],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '${weatherData?.areaName} | ${weatherData?.humidity} | ${weatherData?.weatherDescription}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // New method for marquee text
  Widget _buildMarqueeWidget() {
    return Container(
      height: 40,
      color: Colors.green[50],
      // child: Marquee(
      //   text:
      //       'Latest Updates: Market prices rising | New fertilizer subsidies announced | Upcoming agricultural expo | Important rainfall predictions',
      //   style: TextStyle(
      //     fontSize: 16,
      //     color: Colors.green[800],
      //   ),
      //   scrollAxis: Axis.horizontal,
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   blankSpace: 20.0,
      //   velocity: 50.0,
      //   pauseAfterRound: Duration(seconds: 1),
      //   startPadding: 10.0,
      //   accelerationDuration: Duration(seconds: 1),
      //   accelerationCurve: Curves.linear,
      //   decelerationDuration: Duration(milliseconds: 500),
      //   decelerationCurve: Curves.easeOut,
      // ),
    );
  }

  IconData _getWeatherIcon(String? condition) {
    print(condition);
    switch (condition?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'rain':
        return Icons.pin_drop;
      case 'cloudy':
        return Icons.cloud;
      default:
        return Icons.wb_cloudy;
    }
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 251, 248),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 103, 14, 63).withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Colors.green),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    final isEnglish = Provider.of<LocalizationProvider>(context).isEnglish;
    final language = Provider.of<LocalizationProvider>(context).currentLanguage;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     user != null ? 'Welcome, ${user.displayName ?? 'Farmer'}' : 'Welcome',
      //     style: TextStyle(
      //       fontSize: 22,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.settings),
      //       onPressed: () =>
      //           Application.router.navigateTo(context, '/settings/$language'),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // // Marquee Widget at the top
                  _buildMarqueeWidget(),

                  // Rest of the existing home screen content
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Existing AppBar-like welcome
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user != null
                                  ? 'Welcome, ${user.displayName ?? 'Farmer'}'
                                  : 'Welcome',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.settings),
                              onPressed: () => Application.router
                                  .navigateTo(context, '/settings/$language'),
                            ),
                          ],
                        ),

                        // Weather Widget
                        _buildWeatherWidget(),
                        // SizedBox(height: 16),
                        // _buildFinancialInsightsWidget(),

                        SizedBox(height: 16),
                        CompactCropInsightsCarousel(),

                        // // Crop Health Widget
                        // _buildCropHealthWidget(),

                        // SizedBox(height: 16),

                        // // Government Schemes Widget
                        // _buildGovernmentSchemesWidget(),
                      ]),

                  SizedBox(height: 16),
                  //
                  // // Weather Widget
                  // _buildWeatherWidget(),
                  // SizedBox(height: 16),

                  // Quick Actions Grid
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 20,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.add_box,
                        label: isEnglish ? 'Add Product' : 'उत्पाद जोड़ें',
                        onTap: () => Application.router
                            .navigateTo(context, '/add-product'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.storage,
                        label: isEnglish ? 'My Products' : 'मेरे उत्पाद',
                        onTap: () => Application.router
                            .navigateTo(context, '/my-products/${user?.uid}'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: isEnglish ? 'Chatbot' : 'बॉट चैट करें',
                        onTap: () => Application.router
                            .navigateTo(context, '/chatbot/$language'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.calendar_today,
                        label: isEnglish ? 'Crop Calendar' : 'फसल कैलेंडर',
                        onTap: () => Application.router
                            .navigateTo(context, '/my-fields'),
                      ),
                      _buildQuickActionButton(
                        icon: Icons.shopping_cart,
                        label: isEnglish ? 'Orders' : 'आर्डर',
                        onTap: () =>
                            Application.router.navigateTo(context, '/orders'),
                      ),
                      // _buildQuickActionButton(
                      //   icon: Icons.logout,
                      //   label: isEnglish ? 'Log Out' : 'लॉग आउट',
                      //   onTap: () => Provider.of<UserInfoProvider>(
                      //     context,
                      //     listen: false
                      //   ).logOut(context),
                      // ),
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
