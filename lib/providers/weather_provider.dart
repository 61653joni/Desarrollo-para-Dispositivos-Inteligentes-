import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();
  
  Weather? _weather;
  bool _isLoading = false;
  String? _error;
  String _temperatureUnit = '°C';
  bool _isBleConnected = false;
  String _bleData = 'Desconectado';
  List<String> _devices = [];
  String _currentCity = 'Queretaro';

  // Getters
  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get temperatureUnit => _temperatureUnit;
  bool get isBleConnected => _isBleConnected;
  String get bleData => _bleData;
  List<String> get devices => _devices;
  String get currentCity => _currentCity;

  Future<void> loadWeather(String city) async {
    _currentCity = city;
    await fetchWeather(city);
  }

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _service.getWeather(city);
      _currentCity = city;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateTemperature(int newTemperature) {
    if (_weather != null) {
      _weather = Weather(
        city: _weather!.city,
        temperature: newTemperature,
        condition: _weather!.condition,
        description: _weather!.description,
        humidity: _weather!.humidity,
        windSpeed: _weather!.windSpeed,
      );
      notifyListeners();
    }
  }

  void toggleTemperatureUnit() {
    if (_temperatureUnit == '°C') {
      _temperatureUnit = '°F';
    } else {
      _temperatureUnit = '°C';
    }
    notifyListeners();
  }

  void changeCity() {
    List<String> cities = [
      'Queretaro',
      'Ciudad de Mexico',
      'Guadalajara',
      'Monterrey',
      'Puebla',
    ];
    int currentIndex = cities.indexOf(_currentCity);
    int nextIndex = (currentIndex + 1) % cities.length;
    loadWeather(cities[nextIndex]);
  }

  void startScan() {
    _devices = ['Sensor Temp-01', 'Sensor Temp-02', 'Sensor Humedad-01'];
    _isBleConnected = false;
    _bleData = 'Escaneando...';
    notifyListeners();
  }

  void connectToDevice(String deviceName) {
    _isBleConnected = true;
    _bleData = 'Conectado a $deviceName';
    _devices = [];
    notifyListeners();
  }

  void disconnectBLE() {
    _isBleConnected = false;
    _bleData = 'Desconectado';
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    if (_currentCity.isNotEmpty) {
      await loadWeather(_currentCity);
    }
  }

  String getFormattedTemperature() {
    if (_weather == null) return '--';
    int temp = _weather!.temperature;
    if (_temperatureUnit == '°F') {
      temp = ((temp * 9 / 5) + 32).toInt();
    }
    return '$temp$_temperatureUnit';
  }
}