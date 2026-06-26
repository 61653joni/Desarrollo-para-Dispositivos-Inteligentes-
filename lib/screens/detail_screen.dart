import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';

class DetailScreen extends StatefulWidget {
  final String city;

  const DetailScreen({Key? key, required this.city}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<WeatherProvider>(context, listen: false)
            .fetchWeather(widget.city));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city),
        centerTitle: true,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    onPressed: () =>
                        provider.fetchWeather(widget.city),
                  ),
                ],
              ),
            );
          }

          if (provider.weather == null) {
            return const Center(child: Text('Sin datos'));
          }

          final w = provider.weather!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Icono del clima
                Text(
                  WeatherUtils.getWeatherIcon(w.condition),
                  style: const TextStyle(fontSize: 80),
                ),

                const SizedBox(height: 16),

                // Ciudad
                Text(
                  w.city,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Descripción
                Text(
                  w.description,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                // Temperatura grande
                Text(
                  WeatherUtils.formatTemperature(
                    w.temperature,
                    provider.temperatureUnit,
                  ),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 32),

                // Tarjeta con detalles
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statWidget('💧 Humedad', '${w.humidity}%'),
                        _statWidget('💨 Viento', '${w.windSpeed.toStringAsFixed(1)} m/s'),
                        _statWidget('🌡️ Condición', w.condition),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botón volver
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statWidget(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}