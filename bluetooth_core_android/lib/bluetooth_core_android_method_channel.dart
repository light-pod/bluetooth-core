import 'dart:async';

import 'package:bluetooth_core_android/src/bluetooth_device.dart';
import 'package:bluetooth_core_android/src/bluetooth_socket.dart';
import 'package:bluetooth_core_android/src/permissions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bluetooth_core_android_platform_interface.dart';

/// An implementation of [BluetoothCoreAndroidPlatform] that uses method channels.
class MethodChannelBluetoothCoreAndroid extends BluetoothCoreAndroidPlatform {
  static const namespace = 'dev.lightpod.bluetooth_core_android';
  @visibleForTesting
  final methodChannel = const MethodChannel(namespace);

  final EventChannel bluetoothStateEvent =
      const EventChannel('$namespace/bluetooth_state_event');

  // late final Stream<bool> _bluetoothStateStream;

  final EventChannel bluetoothDiscoveryEvent =
      const EventChannel('$namespace/bluetooth_discovery_event');

  /// Event triggered for every device found, when scanning
  final EventChannel deviceFoundEvent =
      const EventChannel('$namespace/found_device_event');

  MethodChannelBluetoothCoreAndroid() : super() {}

  @override
  Stream<bool> getBluetoothStateStream() {
    return bluetoothStateEvent.receiveBroadcastStream().cast<bool>();
  }

  @override
  Stream<bool> getBluetoothDiscoveryStream() {
    return bluetoothDiscoveryEvent.receiveBroadcastStream().cast<bool>();
  }

  @override
  Stream<BluetoothDevice> getDeviceFoundStream() {
    return deviceFoundEvent.receiveBroadcastStream().map(
          (deviceJson) => BluetoothDevice.fromJson(convertToJson(deviceJson)),
        );
  }

  @override
  Future<bool> checkPermission(AndroidBluetoothPermission permission) async {
    final result = await methodChannel.invokeMethod<bool>('checkPermission', {
      'permission': permission.value,
    });
    return result!;
  }

  @override
  Future<Map<String, bool>> requestPermissions(
    List<AndroidBluetoothPermission> permissions,
  ) async {
    final result = await methodChannel.invokeMapMethod<String, bool>(
      'requestPermissions',
      {
        'permissions':
            permissions.map((permission) => permission.value).toList(),
      },
    );
    return result!;
  }

  @override
  Future<int> getSdkVersion() async {
    return (await methodChannel.invokeMethod<int>('getSdkVersion'))!;
  }

  @override
  Future<bool> isAvailable() async {
    return (await methodChannel.invokeMethod<bool>('isAvailable'))!;
  }

  @override
  Future<bool> isEnabled() async {
    return (await methodChannel.invokeMethod<bool>('isEnabled'))!;
  }

  @override
  Future<bool> enable() async {
    return (await methodChannel.invokeMethod<bool>('enable'))!;
  }

  @override
  Future<List<BluetoothDevice>> bondedDevices() async {
    final result = await methodChannel.invokeListMethod<Map>('bondedDevices');

    return result!
        .map((device) => BluetoothDevice.fromJson(convertToJson(device)))
        .toList();
  }

  @override
  Future<bool> isDiscovering() async {
    return (await methodChannel.invokeMethod<bool>('isDiscovering'))!;
  }

  @override
  Future<bool> startDiscovery() async {
    return (await methodChannel.invokeMethod<bool>('startDiscovery'))!;
  }

  @override
  Future<bool> cancelDiscovery() async {
    return (await methodChannel.invokeMethod<bool>('cancelDiscovery'))!;
  }

  @override
  Future<BluetoothSocket> rfcommSocketConnectToServiceRecord({
    required String address,
    required bool secure,
    required String serviceRecordUuid,
  }) async {
    final result = (await methodChannel.invokeMethod<Map>(
      'rfcommSocketConnect',
      {
        'address': address,
        'secure': secure,
        'serviceRecordUuid': serviceRecordUuid,
      },
    ))!;

    return BluetoothSocket.fromJson(convertToJson(result));
  }

  @override
  Future<bool> rfcommSocketClose({required String socketId}) async {
    return (await methodChannel
        .invokeMethod<bool>('rfcommSocketClose', {'socketId': socketId}))!;
  }

  @override
  Future<bool> rfcommSocketOutputStreamWrite({
    required String socketId,
    required Uint8List bytes,
  }) async {
    return (await methodChannel.invokeMethod<bool>(
      'rfcommSocketOutputStreamWrite',
      {
        'socketId': socketId,
        'bytes': bytes,
      },
    ))!;
  }

  @override
  Future<bool> rfcommSocketOutputStreamFlush({required String socketId}) async {
    return (await methodChannel.invokeMethod<bool>(
      'rfcommSocketOutputStreamFlush',
      {'socketId': socketId},
    ))!;
  }

  @override
  Future<int> rfcommSocketInputStreamAvailable(
      {required String socketId}) async {
    return (await methodChannel.invokeMethod<int>(
      'rfcommSocketInputStreamAvailable',
      {'socketId': socketId},
    ))!;
  }

  @override
  Future<int> rfcommSocketInputStreamRead({required String socketId}) async {
    return (await methodChannel.invokeMethod<int>(
        'rfcommSocketInputStreamRead', {'socketId': socketId}))!;
  }
}

Map<String, dynamic> convertToJson(Map data) {
  Map<String, dynamic> json = {};
  data.forEach((key, value) {
    json[key as String] = value;
  });
  return json;
}
