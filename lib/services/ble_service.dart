import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;

  // UUID de la característica creada en LightBlue
  static const String climateCharacteristicUuid =
      '1600281f-dc47-4df1-8087-496b187e8643';

  /// Escanear dispositivos BLE
  Stream<List<ScanResult>> scanForDevices() {
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
    );

    return FlutterBluePlus.scanResults;
  }

  /// Detener escaneo
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// Conectar a dispositivo
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await device.connect(
        timeout: const Duration(seconds: 10),
      );

      connectedDevice = device;

      print(
        'Conectado a: ${device.platformName}',
      );

      return true;
    } catch (e) {
      print('Error al conectar: $e');
      return false;
    }
  }

  /// Desconectar
  Future<void> disconnect() async {
    try {
      await connectedDevice?.disconnect();

      connectedDevice = null;
      targetCharacteristic = null;

      print('Dispositivo desconectado');
    } catch (e) {
      print('Error al desconectar: $e');
    }
  }

  /// Descubrir servicios
  Future<List<BluetoothService>> discoverServices() async {
    if (connectedDevice == null) {
      throw Exception(
        'No hay dispositivo conectado',
      );
    }

    return await connectedDevice!
        .discoverServices();
  }

  /// Buscar específicamente la característica del clima
  Future<BluetoothCharacteristic?>
      findReadableCharacteristic() async {
    List<BluetoothService> services =
        await discoverServices();

    print('====================');
    print('SERVICIOS ENCONTRADOS');
    print('====================');

    for (BluetoothService service
        in services) {
      print(
        'SERVICIO: ${service.uuid}',
      );

      for (BluetoothCharacteristic characteristic
          in service.characteristics) {
        print(
          'CARACTERISTICA: ${characteristic.uuid}',
        );

        if (characteristic.uuid
                .toString()
                .toLowerCase() ==
            climateCharacteristicUuid) {
          targetCharacteristic =
              characteristic;

          print(
            'CARACTERISTICA DEL CLIMA ENCONTRADA',
          );

          return characteristic;
        }
      }
    }

    print(
      'NO SE ENCONTRO LA CARACTERISTICA DEL CLIMA',
    );

    return null;
  }

  /// Leer característica
  Future<String?> readCharacteristic() async {
    try {
      if (targetCharacteristic == null) {
        await findReadableCharacteristic();
      }

      if (targetCharacteristic == null) {
        return null;
      }

      List<int> value =
          await targetCharacteristic!.read();

      print(
        'VALOR RAW: $value',
      );

      String data = utf8.decode(
        value,
        allowMalformed: true,
      );

      print(
        'VALOR TEXTO: $data',
      );

      // Validaciones requeridas
      if (data.length > 50) {
        return 'Dato inválido';
      }

      return data;
    } catch (e) {
      print(
        'Error leyendo característica: $e',
      );

      return null;
    }
  }

  /// Estado de conexión
  Stream<BluetoothConnectionState>?
      get connectionState {
    return connectedDevice?.connectionState;
  }

  /// Reconectar
  Future<bool> reconnect() async {
    try {
      if (connectedDevice == null) {
        return false;
      }

      await connectedDevice!.connect(
        timeout: const Duration(seconds: 10),
      );

      print('Reconectado');

      return true;
    } catch (e) {
      print(
        'Error al reconectar: $e',
      );

      return false;
    }
  }
}