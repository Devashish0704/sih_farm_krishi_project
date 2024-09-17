import 'package:weather/weather.dart';

class WeatherState {
  final String? error;
  final bool isLoading;
  final Weather? currentWeather;
  final List<Weather>? forecasts;

  WeatherState._({
    this.error,
    required this.isLoading,
    this.currentWeather,
    this.forecasts,
  });

  factory WeatherState.onRequest() {
    return WeatherState._(isLoading: true);
  }

  factory WeatherState.onSuccess(
      Weather currentWeather, List<Weather> forecasts) {
    return WeatherState._(
      isLoading: false,
      currentWeather: currentWeather,
      forecasts: forecasts,
    );
  }

  factory WeatherState.onError(String error) {
    return WeatherState._(
      isLoading: false,
      error: error,
    );
  }

  String get location => currentWeather?.areaName ?? 'Unknown location';

  String get maxTemp =>
      '${currentWeather?.tempMax?.celsius?.toStringAsFixed(1) ?? 'N/A'}°C';

  String get minTemp =>
      '${currentWeather?.tempMin?.celsius?.toStringAsFixed(1) ?? 'N/A'}°C';

  String get humidity => '${currentWeather?.humidity ?? 'N/A'}%';

  String get cloudiness => '${currentWeather?.cloudiness ?? 'N/A'}%';

  String get pressure => '${currentWeather?.pressure ?? 'N/A'} Pa';

  String get windSpeed => '${currentWeather?.windSpeed ?? 'N/A'} m/s';

  String getDayNTemperature(int n) =>
      '${forecasts?[n].temperature!.celsius?.toStringAsFixed(1) ?? 'N/A'}°C';

  String getDayNCloudiness(int n) => '${forecasts?[n].cloudiness ?? 'N/A'}%';
}
