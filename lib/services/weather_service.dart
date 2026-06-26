import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../config/app_config.dart';

class WeatherService {
  static const Duration _timeout = Duration(seconds: 10);
  static const String _units = 'metric';
  static const String _lang = 'es';

  Future<Weather> getWeather(String city) async {
    if (city.trim().isEmpty) {
      throw ArgumentError('❌ La ciudad no puede estar vacía');
    }

    // Normalizar acentos y caracteres especiales
    final cleanCity = city.trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N')
        .replaceAll(RegExp(r'[^\w\s]'), '');

    if (!AppConfig.isConfigured()) {
      throw Exception(
        '❌ API key no configurada. '
        'Asegúrate de tener el archivo .env con OPENWEATHER_API_KEY'
      );
    }

    final uri = Uri.parse(
      '${AppConfig.baseUrl}'
      '?q=$cleanCity'
      '&appid=${AppConfig.apiKey}'
      '&units=$_units'
      '&lang=$_lang',
    );

    try {
      final response = await http.get(uri).timeout(_timeout);
      return _handleResponse(response, city);
      
    } on SocketException {
      throw Exception('❌ Sin conexión a internet. Verifica tu red.');
      
    } on TimeoutException {
      throw Exception('❌ Tiempo de espera agotado. Intenta de nuevo.');
      
    } on FormatException catch (e) {
      throw Exception('❌ Respuesta inesperada de la API: $e');
      
    } catch (e) {
      throw Exception('❌ Error inesperado: $e');
    }
  }

  Future<List<Weather>> getWeatherForCities(List<String> cities) async {
    if (cities.isEmpty) {
      throw ArgumentError('❌ La lista de ciudades no puede estar vacía');
    }
    final futures = cities.map((city) => getWeather(city));
    return Future.wait(futures);
  }

  Weather _handleResponse(http.Response response, String city) {
    switch (response.statusCode) {
      case 200:
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          return Weather.fromJson(json);
        } catch (e) {
          throw Exception('❌ Error al procesar la respuesta del clima: $e');
        }

      case 400:
        throw Exception('❌ Solicitud inválida. Verifica el nombre de la ciudad.');
        
      case 401:
        throw Exception(
          '❌ API Key inválida o no activada aún. '
          'Verifica tu clave en OpenWeatherMap.'
        );
        
      case 404:
        throw Exception('❌ Ciudad "$city" no encontrada. Verifica el nombre.');
        
      case 429:
        throw Exception(
          '❌ Límite de llamadas excedido. '
          'Espera un momento y vuelve a intentarlo.'
        );
        
      case 500:
      case 502:
      case 503:
      case 504:
        throw Exception(
          '❌ Error del servidor de OpenWeatherMap. '
          'Intenta más tarde.'
        );
        
      default:
        throw Exception(
          '❌ Error del servidor: Código ${response.statusCode}'
        );
    }
  }

  static bool isApiKeyConfigured() {
    return AppConfig.isConfigured();
  }

  Future<bool> testConnection() async {
    try {
      await getWeather('Queretaro');
      return true;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic> getConfigStatus() {
    return {
      'apiKeyConfigured': AppConfig.isConfigured(),
      'apiKeyLength': AppConfig.apiKey?.length ?? 0,
      'baseUrl': AppConfig.baseUrl,
      'units': _units,
      'lang': _lang,
      'timeout': _timeout.inSeconds,
    };
  }
}