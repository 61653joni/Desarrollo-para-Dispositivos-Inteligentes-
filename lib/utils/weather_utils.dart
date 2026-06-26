class WeatherUtils {

  static double celsiusToFahrenheit(int celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static int fahrenheitToCelsius(double fahrenheit) {
    return ((fahrenheit - 32) * 5 / 9).toInt();
  }

  static String getWeatherIcon(String condition) {

    switch (condition.toLowerCase()) {

      case 'sunny':
        return '☀️';

      case 'cloudy':
        return '☁️';

      case 'rainy':
        return '🌧️';

      case 'snowy':
        return '❄️';

      default:
        return '🌤️';
    }
  }

  static bool isValidTemperature(int temp) {
    return temp >= -50 && temp <= 60;
  }

  static String formatTemperature(
    int temp,
    String unit,
  ) {
    return '$temp$unit';
  }
}