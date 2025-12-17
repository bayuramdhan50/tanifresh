import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';

/// Weather service for OpenWeather API integration
class WeatherService {
  DateTime? _lastFetch;
  Map<String, dynamic>? _cachedWeather;

  /// Fetch weather data
  Future<WeatherData> getWeather(
      {String city = AppConstants.defaultCity}) async {
    // Check cache
    if (_cachedWeather != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) <
            AppConstants.weatherCacheDuration) {
      return WeatherData.fromJson(_cachedWeather!);
    }

    try {
      final url = ApiConstants.openWeatherUrl(city);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedWeather = data;
        _lastFetch = DateTime.now();
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // Return default data if API fails
      return WeatherData(
        temperature: 0,
        condition: 'Clear',
        description: 'Data cuaca tidak tersedia',
        icon: '01d',
        city: city,
        isSafeForDelivery: true,
      );
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedWeather = null;
    _lastFetch = null;
  }
}

/// Weather data model
class WeatherData {
  final double temperature;
  final String condition; // Rain, Clear, Clouds, etc.
  final String description;
  final String icon;
  final String city;
  final bool isSafeForDelivery;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.icon,
    required this.city,
    required this.isSafeForDelivery,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final temp = (json['main']?['temp'] ?? 0).toDouble();
    final condition = json['weather']?[0]?['main'] ?? 'Clear';
    final description = json['weather']?[0]?['description'] ?? '';
    final icon = json['weather']?[0]?['icon'] ?? '01d';
    final city = json['name'] ?? AppConstants.defaultCity;

    // Determine if it's safe for delivery
    final isSafe = !AppConstants.badWeatherConditions.contains(condition);

    return WeatherData(
      temperature: temp,
      condition: condition,
      description: description,
      icon: icon,
      city: city,
      isSafeForDelivery: isSafe,
    );
  }
}
