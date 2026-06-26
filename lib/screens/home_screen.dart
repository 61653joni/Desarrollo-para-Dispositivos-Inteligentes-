import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).loadWeather('Santiago de Querétaro');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {

        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ← CAMBIO: muestra el error real en pantalla
        if (provider.weather == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      provider.error ?? 'Sin datos del clima',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      onPressed: () =>
                          provider.loadWeather('Santiago de Querétaro'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;

        final isLandscape = width > 600;

        Widget weatherContent = isLandscape
            ? Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [

                  Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [

                      Text(
                        WeatherUtils.formatTemperature(
                          provider.weather!.temperature,
                          provider.temperatureUnit,
                        ),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        provider.weather!.city,
                        style:
                            const TextStyle(
                          fontSize: 24,
                        ),
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  ),

                  Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [

                      Text(
                        WeatherUtils
                            .getWeatherIcon(
                          provider.weather!
                              .condition,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 80,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Text(
                        'Humedad: ${provider.weather!.humidity}%\nViento: ${provider.weather!.windSpeed.toStringAsFixed(1)} km/h',
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [

                  Text(
                    WeatherUtils.formatTemperature(
                      provider.weather!
                          .temperature,
                      provider.temperatureUnit,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 72,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Text(
                    provider.weather!.city,
                    style:
                        const TextStyle(
                      fontSize: 24,
                    ),
                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  Text(
                    WeatherUtils
                        .getWeatherIcon(
                      provider.weather!
                          .condition,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 80,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    'Humedad: ${provider.weather!.humidity}% | Viento: ${provider.weather!.windSpeed.toStringAsFixed(1)} km/h',
                    textAlign:
                        TextAlign.center,
                  ),
                ],
              );

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Clima Actual',
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    children: [

                      const SizedBox(
                        height: 30,
                      ),

                      weatherContent,
                     const SizedBox(height: 40),

Card(
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(25),
  ),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [

        const Text(
          'Controles del Clima',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.remove,
                ),
                iconSize: 35,
                onPressed: () {

                  provider.updateTemperature(
                    provider.weather!
                            .temperature -
                        1,
                  );

                },
              ),
            ),

            const SizedBox(width: 20),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                provider.getFormattedTemperature(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                ),
                iconSize: 35,
                onPressed: () {

                  provider.updateTemperature(
                    provider.weather!
                            .temperature +
                        1,
                  );

                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.swap_horiz,
            ),
            label: const Text(
              'Cambiar Unidad',
            ),
            style:
                ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.all(15),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
            ),
            onPressed: () {
              provider
                  .toggleTemperatureUnit();
            },
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.location_city,
            ),
            label: const Text(
              'Cambiar Ciudad',
            ),
            style:
                ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.all(15),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
            ),
            onPressed: () {
              provider.changeCity();
            },
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.search,
            ),
            label: const Text(
              'Buscar Ciudades',
            ),
            style:
                ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.all(15),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
            ),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SearchScreen(),
                ),
              );

            },
          ),
        ),

        const SizedBox(height: 25),

const Divider(),

const SizedBox(height: 15),

const Text(
  'Bluetooth Low Energy',
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.bluetooth_searching),
    label: const Text(
      'Buscar dispositivos BLE',
    ),
    onPressed: () {
      provider.startScan();
    },
  ),
),

const SizedBox(height: 15),

Text(
  provider.isBleConnected
      ? 'Estado BLE: Conectado'
      : 'Estado BLE: Sin conexión',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    color: provider.isBleConnected
        ? Colors.green
        : Colors.red,
  ),
),

const SizedBox(height: 10),

Text(
  'Dato BLE: ${provider.bleData}',
),

const SizedBox(height: 15),

SizedBox(
  height: 250,
  child: ListView.builder(
    itemCount: provider.devices.length,
    itemBuilder: (context, index) {
      final deviceName = provider.devices[index];

      return Card(
        child: ListTile(
          leading: const Icon(
            Icons.bluetooth,
          ),
          title: Text(
            deviceName,
          ),
          subtitle: Text(
            'Dispositivo BLE #${index + 1}',
          ),
          trailing: ElevatedButton(
            child: const Text(
              'Conectar',
            ),
            onPressed: () {
              provider.connectToDevice(
                deviceName,
              );
            },
          ),
        ),
      );
    },
  ),
),

const SizedBox(height: 10),

if (provider.isBleConnected)
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: const Icon(
        Icons.bluetooth_disabled,
      ),
      label: const Text(
        'Desconectar',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        provider.disconnectBLE();
      },
    ),
  ),
      ],
    ),
  ),
),
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}