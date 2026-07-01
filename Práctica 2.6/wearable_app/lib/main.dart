import 'dart:async';
import 'package:flutter/material.dart';
import 'sensor_simulator.dart';
import 'ble_server.dart';

void main() => runApp(const WearableApp());

class WearableApp extends StatefulWidget {
  const WearableApp({super.key});

  @override
  State<WearableApp> createState() => _WearableAppState();
}

class _WearableAppState extends State<WearableApp> {
  BleServer? _server;
  final List<StreamSubscription> _subs = [];

  int _steps = 0;
  int _heartRate = 72;
  int _calories = 0;
  String _status = 'reposo';
  bool _active = false;

  void _subscribeStreams(SensorSimulator sim) {
    _subs.add(sim.stepsStream.listen((v) => setState(() => _steps = v)));
    _subs.add(sim.heartRateStream.listen((v) => setState(() => _heartRate = v)));
    _subs.add(sim.caloriesStream.listen((v) => setState(() => _calories = v)));
    _subs.add(sim.statusStream.listen((v) => setState(() => _status = v)));
  }

  void _toggleActivity() {
    setState(() => _active = !_active);
    if (_active) {
      // Nueva instancia en cada arranque: los streams del ciclo anterior
      // quedan cerrados por stop() y no se pueden reutilizar.
      final sim = SensorSimulator();
      final server = BleServer(sim);
      _server = server;
      _subscribeStreams(sim);
      sim.start();
      server.startAdvertising();
    } else {
      for (final s in _subs) {
        s.cancel();
      }
      _subs.clear();
      _server?.stop();
      _server = null;
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _server?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = _heartRate > 120;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // FittedBox: el contenido siempre cabe sin desbordarse,
              // sin importar la forma redonda/cuadrada del reloj.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: alert ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text('$_heartRate',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: alert ? Colors.black : Colors.white,
                          )),
                    ),
                    const Text('BPM',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          letterSpacing: 2,
                        )),
                    const SizedBox(height: 10),
                    Text('$_steps  ·  $_calories kcal',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(_status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          letterSpacing: 1,
                        )),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 110,
                      height: 34,
                      child: OutlinedButton(
                        onPressed: _toggleActivity,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _active ? Colors.white : Colors.black,
                          side: const BorderSide(color: Colors.white),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          _active ? 'Detener' : 'Iniciar',
                          style: TextStyle(
                            color: _active ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
