import 'package:flex_console_for_ble/bluetooth/ble_characteristic_broadcaster.dart';
import 'package:flex_console_for_ble/broadcaster_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_ble/bluetooth/service_provider.dart';

BleCharacteristicBroadcaster _broadcaster = BleCharacteristicBroadcaster();

/// Provides a broadcaster.
final bleCharacteristicBroadcasterProvider =
    Provider<BleCharacteristicBroadcaster>((ref) {
  final services = ref.watch(servicesProvider);
  final channels = ref
      .watch(availableChannelProvider)
      .cast<BleCharacteristicChannel>()
      .toList();

  _broadcaster.dispose();

  _broadcaster = services.when(
    loading: () => BleCharacteristicBroadcaster(),
    data: (services) =>
        BleCharacteristicBroadcaster(services: services, channels: channels),
    error: (error, trace) => BleCharacteristicBroadcaster(),
  );

  return _broadcaster;
});
