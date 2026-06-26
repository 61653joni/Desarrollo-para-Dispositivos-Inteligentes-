/// Modelo de clima para la aplicación
/// 
/// Este modelo representa los datos meteorológicos obtenidos de la API de OpenWeatherMap
/// y proporciona métodos seguros para la deserialización desde JSON.
class Weather {
  // Propiedades finales e inmutables
  final String city;
  final int temperature;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;

  /// Constructor principal
  const Weather({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
  });

  /// Crea una instancia de Weather desde un mapa JSON
  /// 
  /// [json] Mapa con la respuesta de la API de OpenWeatherMap
  /// 
  /// Lanza [FormatException] si la respuesta es inválida o está incompleta
  factory Weather.fromJson(Map<String, dynamic> json) {
    // ==========================================
    // VALIDACIONES DE SEGURIDAD - ¡CRÍTICAS!
    // ==========================================
    
    // 1. Verificar que 'main' existe
    if (!json.containsKey('main') || json['main'] == null) {
      throw const FormatException('Respuesta API incompleta: falta el objeto "main"');
    }

    // 2. Verificar que 'weather' existe y es una lista no vacía
    if (!json.containsKey('weather') || json['weather'] == null) {
      throw const FormatException('Respuesta API incompleta: falta el objeto "weather"');
    }

    final weatherList = json['weather'] as List?;
    if (weatherList == null || weatherList.isEmpty) {
      throw const FormatException('Sin datos de clima: lista "weather" vacía');
    }

    // 3. Obtener y validar el primer elemento de weather
    final weatherItem = weatherList[0] as Map<String, dynamic>?;
    if (weatherItem == null) {
      throw const FormatException('Datos de clima inválidos: primer elemento de weather es null');
    }

    // 4. Validar que los datos numéricos existen y tienen el tipo correcto
    final mainData = json['main'] as Map<String, dynamic>?;
    if (mainData == null) {
      throw const FormatException('Datos de "main" inválidos');
    }

    // 5. Validar temperatura
    final tempValue = mainData['temp'];
    if (tempValue == null) {
      throw const FormatException('Temperatura no encontrada en la respuesta');
    }
    if (tempValue is! num) {
      throw FormatException('Temperatura inválida: se esperaba un número, se obtuvo ${tempValue.runtimeType}');
    }

    // 6. Validar humedad
    final humidityValue = mainData['humidity'];
    if (humidityValue == null) {
      throw const FormatException('Humedad no encontrada en la respuesta');
    }
    if (humidityValue is! num) {
      throw FormatException('Humedad inválida: se esperaba un número, se obtuvo ${humidityValue.runtimeType}');
    }

    // 7. Validar velocidad del viento (opcional, pero validamos si existe)
    final windData = json['wind'] as Map<String, dynamic>?;
    double windSpeed = 0.0;
    if (windData != null) {
      final windSpeedValue = windData['speed'];
      if (windSpeedValue != null) {
        if (windSpeedValue is num) {
          windSpeed = windSpeedValue.toDouble();
        } else {
          // Log o advertencia, pero no lanzamos excepción porque es opcional
          print('Advertencia: Velocidad del viento inválida, usando 0.0');
        }
      }
    }

    // ==========================================
    // CONSTRUCCIÓN DEL OBJETO
    // ==========================================
    
    return Weather(
      city: json['name'] as String? ?? 'Ciudad desconocida',
      temperature: tempValue.toInt(),
      condition: weatherItem['main'] as String? ?? 'Desconocido',
      description: weatherItem['description'] as String? ?? '',
      humidity: humidityValue.toInt(),
      windSpeed: windSpeed,
    );
  }

  /// Convierte el objeto Weather a un mapa JSON
  /// 
  /// Útil para serializar datos antes de guardarlos o enviarlos
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temperature': temperature,
      'condition': condition,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
    };
  }

  /// Crea una copia de Weather con valores actualizados
  /// 
  /// Útil para actualizar parcialmente el estado
  Weather copyWith({
    String? city,
    int? temperature,
    String? condition,
    String? description,
    int? humidity,
    double? windSpeed,
  }) {
    return Weather(
      city: city ?? this.city,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
    );
  }

  // ==========================================
  // MÉTODOS DE UTILIDAD
  // ==========================================

  /// Verifica si el clima es agradable (temperatura entre 18-25°C y sin lluvia)
  bool get isPleasant {
    return temperature >= 18 && temperature <= 25 && 
           condition.toLowerCase() != 'rain' &&
           condition.toLowerCase() != 'drizzle' &&
           condition.toLowerCase() != 'thunderstorm';
  }

  /// Obtiene un emoji representativo del clima
  String get emoji {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('clear')) return '☀️';
    if (lowerCondition.contains('cloud')) return '☁️';
    if (lowerCondition.contains('rain')) return '🌧️';
    if (lowerCondition.contains('drizzle')) return '🌦️';
    if (lowerCondition.contains('thunder')) return '⛈️';
    if (lowerCondition.contains('snow')) return '❄️';
    if (lowerCondition.contains('mist') || lowerCondition.contains('fog')) return '🌫️';
    return '🌡️';
  }

  /// Obtiene un mensaje amigable según la temperatura
  String get temperatureMessage {
    if (temperature <= 0) return '🥶 ¡Hace mucho frío! Abrígate bien.';
    if (temperature <= 10) return '🥵 Hace frío, usa chamarra.';
    if (temperature <= 20) return '😊 Temperatura agradable, fresco.';
    if (temperature <= 30) return '🌡️ Clima cálido, buena temperatura.';
    if (temperature <= 35) return '🥵 Hace calor, mantente hidratado.';
    return '🔥 ¡Mucho calor! Busca sombra.';
  }

  // ==========================================
  // SOBRESCRITURA DE MÉTODOS
  // ==========================================

  @override
  String toString() {
    return 'Weather(city: $city, temperature: ${temperature}°C, '
           'condition: $condition, humidity: ${humidity}%, '
           'windSpeed: ${windSpeed}m/s)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Weather &&
        other.city == city &&
        other.temperature == temperature &&
        other.condition == condition &&
        other.description == description &&
        other.humidity == humidity &&
        other.windSpeed == windSpeed;
  }

  @override
  int get hashCode {
    return Object.hash(
      city,
      temperature,
      condition,
      description,
      humidity,
      windSpeed,
    );
  }
}