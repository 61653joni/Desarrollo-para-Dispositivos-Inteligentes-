package com.example.wearable_app

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.pm.PackageManager
import android.os.Build
import android.os.ParcelUuid
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

// Servidor GATT real: expone el servicio de actividad fisica y se anuncia
// por BLE de verdad, para que un central (telefono) pueda encontrarlo y
// suscribirse a las notificaciones de cada caracteristica.
class MainActivity : FlutterActivity() {
    private val channelName = "wearable_app/ble_peripheral"

    private val serviceUuid = UUID.fromString("12345678-1234-1234-1234-123456789abc")
    private val stepsUuid = UUID.fromString("aaaaaaaa-0001-1234-1234-123456789abc")
    private val heartRateUuid = UUID.fromString("aaaaaaaa-0002-1234-1234-123456789abc")
    private val caloriesUuid = UUID.fromString("aaaaaaaa-0003-1234-1234-123456789abc")
    private val statusUuid = UUID.fromString("aaaaaaaa-0004-1234-1234-123456789abc")
    private val cccdUuid = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")

    private var gattServer: BluetoothGattServer? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private val subscribedDevices = mutableSetOf<BluetoothDevice>()
    private val characteristics = mutableMapOf<UUID, BluetoothGattCharacteristic>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startAdvertising" -> {
                        startBleServer()
                        result.success(null)
                    }
                    "stopAdvertising" -> {
                        stopBleServer()
                        result.success(null)
                    }
                    "updateCharacteristic" -> {
                        val uuid = UUID.fromString(call.argument<String>("uuid"))
                        val value = call.argument<ByteArray>("value")!!
                        updateCharacteristicValue(uuid, value)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasPermission(perm: String): Boolean =
        ActivityCompat.checkSelfPermission(this, perm) == PackageManager.PERMISSION_GRANTED

    private fun hasBlePermissions(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        return hasPermission(android.Manifest.permission.BLUETOOTH_ADVERTISE) &&
            hasPermission(android.Manifest.permission.BLUETOOTH_CONNECT)
    }

    private fun startBleServer() {
        if (!hasBlePermissions()) return

        val bluetoothManager = getSystemService(BLUETOOTH_SERVICE) as BluetoothManager
        val adapter = bluetoothManager.adapter ?: return

        gattServer = bluetoothManager.openGattServer(this, gattServerCallback)
        val service = BluetoothGattService(serviceUuid, BluetoothGattService.SERVICE_TYPE_PRIMARY)

        for (uuid in listOf(stepsUuid, heartRateUuid, caloriesUuid, statusUuid)) {
            val characteristic = BluetoothGattCharacteristic(
                uuid,
                BluetoothGattCharacteristic.PROPERTY_READ or BluetoothGattCharacteristic.PROPERTY_NOTIFY,
                BluetoothGattCharacteristic.PERMISSION_READ,
            )
            val cccd = BluetoothGattDescriptor(
                cccdUuid,
                BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE,
            )
            characteristic.addDescriptor(cccd)
            service.addCharacteristic(characteristic)
            characteristics[uuid] = characteristic
        }

        gattServer?.addService(service)

        advertiser = adapter.bluetoothLeAdvertiser
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .build()
        // Sin nombre de dispositivo: el UUID de 128 bits ya casi llena el
        // limite de 31 bytes del paquete de advertising legacy.
        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(false)
            .addServiceUuid(ParcelUuid(serviceUuid))
            .build()
        advertiser?.startAdvertising(settings, data, advertiseCallback)
    }

    private fun stopBleServer() {
        if (hasBlePermissions()) {
            advertiser?.stopAdvertising(advertiseCallback)
            gattServer?.close()
        }
        subscribedDevices.clear()
        characteristics.clear()
        gattServer = null
        advertiser = null
    }

    private fun updateCharacteristicValue(uuid: UUID, value: ByteArray) {
        if (!hasBlePermissions()) return
        val characteristic = characteristics[uuid] ?: return
        characteristic.value = value
        for (device in subscribedDevices) {
            gattServer?.notifyCharacteristicChanged(device, characteristic, false)
        }
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartFailure(errorCode: Int) {
            super.onStartFailure(errorCode)
        }
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                subscribedDevices.remove(device)
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic,
        ) {
            if (!hasBlePermissions()) return
            gattServer?.sendResponse(
                device,
                requestId,
                BluetoothGatt.GATT_SUCCESS,
                offset,
                characteristic.value,
            )
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            descriptor: BluetoothGattDescriptor,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray,
        ) {
            if (descriptor.uuid == cccdUuid) {
                if (value.contentEquals(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)) {
                    subscribedDevices.add(device)
                } else {
                    subscribedDevices.remove(device)
                }
            }
            if (responseNeeded && hasBlePermissions()) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value)
            }
        }
    }
}
