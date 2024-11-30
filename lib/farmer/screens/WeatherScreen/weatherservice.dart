import 'package:e_commerce_app_flutter/farmer/config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class WeatherService {
  WeatherFactory weatherStation = new WeatherFactory(WEATHER_API_KEY);

  Future<Weather> getWeatherForecast() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final currentWeather = await weatherStation.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      final forecasts = await weatherStation.fiveDayForecastByLocation(
        position.latitude,
        position.longitude,
      );

      return currentWeather;
    } catch (e) {
      print(e);
      throw Exception('Failed to get weather forecast');
    }
  }
}
