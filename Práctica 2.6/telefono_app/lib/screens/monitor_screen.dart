import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/metric_card.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('MONITOR DE ACTIVIDAD',
            style: TextStyle(letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
        actions: [
          Consumer<ActivityProvider>(
            builder: (ctx, ap, _) => IconButton(
              icon: Icon(ap.isConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled),
              color: ap.isConnected ? Colors.white : Colors.white38,
              onPressed: () =>
                  ap.isConnected ? ap.disconnect() : ap.connect(),
            ),
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, ap, _) {
          // Estado: escaneando
          if (ap.status == ConnectionStatus.scanning) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Buscando wearable...',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            );
          }

          // Estado: error
          if (ap.status == ConnectionStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(ap.errorMessage ?? 'Error desconocido',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: ap.connect,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Estado: desconectado
          if (!ap.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.watch, size: 80, color: Colors.white24),
                  const SizedBox(height: 24),
                  const Text('Conecta tu wearable',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Asegurate de que la app del wearable este activa',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: ap.connect,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Buscar wearable'),
                  ),
                ],
              ),
            );
          }

          // Estado: conectado — mostrar metricas
          final d = ap.data;
          final alert = d.heartRate > 120;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Alerta de ritmo cardiaco alto (inversion blanco/negro)
                if (alert)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.black),
                        const SizedBox(width: 8),
                        Text('Ritmo cardiaco alto: ${d.heartRate} bpm',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                // Estado de actividad
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(d.status.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2)),
                ),

                // Grid de 4 tarjetas 2x2
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    MetricCard(
                      label: 'PASOS',
                      value: '${d.steps}',
                      unit: 'pasos',
                      icon: Icons.directions_walk,
                    ),
                    MetricCard(
                      label: 'RITMO CARDIACO',
                      value: '${d.heartRate}',
                      unit: 'bpm',
                      icon: Icons.favorite,
                      alert: alert,
                    ),
                    MetricCard(
                      label: 'CALORIAS',
                      value: '${d.calories}',
                      unit: 'kcal',
                      icon: Icons.local_fire_department,
                    ),
                    MetricCard(
                      label: 'ZONA FC',
                      value: d.heartRateZone.split(' ').first,
                      unit: d.heartRateZone.contains(' ')
                          ? d.heartRateZone.split(' ').skip(1).join(' ')
                          : '',
                      icon: Icons.speed,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Timestamp ultima actualizacion
                Text(
                  'Ultima actualizacion: '
                  '${d.timestamp.hour.toString().padLeft(2, '0')}:'
                  '${d.timestamp.minute.toString().padLeft(2, '0')}:'
                  '${d.timestamp.second.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
