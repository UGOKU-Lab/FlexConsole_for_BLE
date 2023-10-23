import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_ble/bluetooth/target_device_provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'constants.dart';

/// Whether the connection process is on-going.
bool _negotiating = false;

/// The connection target.
BluetoothDevice? _connectionTargetDevice;

/// Provides the current target device associated with the [servicesProvider].
///
/// This filters the devices from [targetDeviceProvider] to keep the connection
/// process legal. Successors received during the connection process will be
/// ignored.
final connectionTargetDeviceProvider = Provider<BluetoothDevice?>((ref) {
  final device = ref.watch(targetDeviceProvider);

  if (!_negotiating) {
    _connectionTargetDevice = device;
  }

  return _connectionTargetDevice;
});

/// Provides the bluetooth services.
///
/// The target device of the connection can be got through the
/// [connectionTargetDeviceProvider].
final servicesProvider = FutureProvider<List<BluetoothService>>((ref) async {
  final device = ref.watch(connectionTargetDeviceProvider);
  var services = <BluetoothService>[];

  if (device == null) {
    return [];
  }

  // Start the connection process.
  _negotiating = true;

  // Try to connect the target.
  try {
    await device.connect(timeout: const Duration(seconds: 10));

    device.connectionState.listen((event) {
      if (event == BluetoothConnectionState.disconnected) {
        if (ref.read(targetDeviceProvider) == device) {
          ref.read(targetDeviceProvider.notifier).state = null;
        }
      }
    });

    // Discover the services.
    if (Platform.isAndroid) device.clearGattCache();
    services = await device.discoverServices();

    // Query the meta data.
    final descriptors = services
        .map((service) => service.characteristics)
        .expand((characteristics) => characteristics)
        .map((characteristic) => characteristic.descriptors)
        .expand((descriptors) => descriptors)
        .where((descriptor) {
      final uuid = descriptor.descriptorUuid.toString();

      // NOTE: Aggregation Format Descriptor is not used now.
      //       (Attribute Handle is not supported in the using package.)
      return DescriptorUuidPatten.userDescription.hasMatch(uuid) ||
          DescriptorUuidPatten.presentationFormat.hasMatch(uuid) ||
          DescriptorUuidPatten.aggregationFormat.hasMatch(uuid);
    });

    for (final descriptor in descriptors) {
      await descriptor.read();
    }

    // await Future.wait(services
    //     .map((service) => service.characteristics)
    //     .expand((characteristics) => characteristics)
    //     .map((characteristic) => characteristic.descriptors)
    //     .expand((descriptors) => descriptors)
    //     .where((descriptor) {
    //   final uuid = descriptor.descriptorUuid.toString();

    //   // NOTE: Aggregation Format Descriptor is not used now.
    //   //       (Attribute Handle is not supported in the using package.)
    //   return DescriptorUuidPatten.userDescription.hasMatch(uuid) ||
    //       DescriptorUuidPatten.presentationFormat.hasMatch(uuid) ||
    //       DescriptorUuidPatten.aggregationFormat.hasMatch(uuid);
    // }).map((descriptor) => descriptor.read()));
  } catch (error) {
    // Unselect the target.
    ref.read(targetDeviceProvider.notifier).state = null;
  } finally {
    _negotiating = false;
  }

  return services;
});
