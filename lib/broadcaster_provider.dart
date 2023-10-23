import 'package:flex_console_for_ble/bluetooth/ble_characteristic_broadcaster.dart';
import 'package:flex_console_for_ble/bluetooth/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_ble/bluetooth/ble_characteristic_broadcaster_provider.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

/// Provides a multi-channel broadcaster for the current connection.
final broadcasterProvider = Provider<MultiChannelBroadcaster>((ref) {
  return ref.watch(bleCharacteristicBroadcasterProvider);
});

/// Provides list of available channels on the [broadcasterProvider].
final availableChannelProvider = Provider<Iterable<BroadcastChannel>>((ref) {
  final services = ref.watch(servicesProvider);

  return services.when(
      data: (services) => services
          .map((service) => service.characteristics)
          .expand((characteristic) => characteristic)
          .map((characteristic) => BleCharacteristicChannel(characteristic)),
      error: (error, trace) => [],
      loading: () => []);
});
