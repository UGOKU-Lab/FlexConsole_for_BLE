import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flex_console_for_ble/bluetooth/ble_characteristic_representation_format.dart';
import 'package:flex_console_for_ble/bluetooth/constants.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleCharacteristicChannel implements BroadcastChannel {
  BluetoothCharacteristic characteristic;

  BleCharacteristicChannel(this.characteristic);

  late final presentations = characteristic.descriptors
      .where((descriptor) => DescriptorUuidPatten.presentationFormat
          .hasMatch(descriptor.descriptorUuid.toString()))
      .map((descriptor) => BleCharacteristicPresentationFormat.fromUint8List(
          Uint8List.fromList(descriptor.lastValue)));

  @override
  String get identifier => characteristic.characteristicUuid.toString();

  @override
  String? get name => characteristic.descriptors
      .where((descriptor) => DescriptorUuidPatten.userDescription
          .hasMatch(descriptor.descriptorUuid.toString()))
      .map((descriptor) => String.fromCharCodes(descriptor.lastValue))
      .firstOrNull;

  @override
  String? get description => name != null ? identifier : null;

  @override
  int get hashCode => identifier.hashCode;

  @override
  bool operator ==(Object other) {
    return other is BleCharacteristicChannel && other.hashCode == hashCode;
  }
}

class BleCharacteristicBroadcaster implements MultiChannelBroadcaster {
  final List<BluetoothService>? services;
  final List<BleCharacteristicChannel>? channels;

  /// The branches of root streams.
  late final _branches =
      <BleCharacteristicChannel, _TwoWayStreamController<double, double>>{};

  final _sendDataMap = <BleCharacteristicChannel, double>{};
  final _periodicReadChannels = <BleCharacteristicChannel>{};
  final _setNotifyChannels = Queue<BleCharacteristicChannel>();

  late Timer _timer;

  /// Creates a broadcaster using [services].
  BleCharacteristicBroadcaster({this.services, this.channels}) {
    _timer = Timer(const Duration(milliseconds: 100), _periodicReadWrite);
  }

  void dispose() {
    _timer.cancel();
  }

  Future _periodicReadWrite() async {
    await _setNotify();
    await _write();

    // Read data after a few milliseconds.
    await Future.delayed(const Duration(milliseconds: 50));
    await _read();

    _timer = Timer(const Duration(milliseconds: 50), _periodicReadWrite);
  }

  Future _setNotify() async {
    for (final channel in List.from(_setNotifyChannels)) {
      if (!channel.characteristic.properties.notify ||
          channel.characteristic.isNotifying) {
        continue;
      }

      final popped = _setNotifyChannels.removeFirst();
      var success = false;

      try {
        // NOTE: setNotifyValue API can not work concurrently.
        //       So, do not do like Future.wait([...]).
        success = await channel.characteristic.setNotifyValue(true);
      } catch (_) {}

      if (!success) {
        // Try next time.
        _setNotifyChannels.add(popped);
      }
    }
  }

  Future _read() async {
    for (final channel in _periodicReadChannels) {
      if (!channel.characteristic.properties.read) {
        continue;
      }

      try {
        final data = await channel.characteristic.read();
        if (data.isEmpty) return;

        _branches[channel]?.downward.sink.add(
            channel.presentations.firstOrNull?.formatToDouble(data) ??
                data[0].toDouble());
      } catch (_) {}
    }
  }

  Future _write() async {
    final snapshot = {..._sendDataMap};
    final retries = <BleCharacteristicChannel, double>{};

    for (final entry in snapshot.entries) {
      final channel = entry.key;
      final value = entry.value;

      if (!channel.characteristic.properties.write &&
          !channel.characteristic.properties.writeWithoutResponse) {
        continue;
      }

      // The data follows the first presentation format or single byte format.
      final presentation = channel.presentations.firstOrNull;
      final data = presentation?.formatFromDouble(value) ??
          [value.clamp(0, 255).floor()];

      final withoutResponse =
          channel.characteristic.properties.writeWithoutResponse;

      try {
        await channel.characteristic
            .write(data, withoutResponse: withoutResponse);
      } catch (_) {
        // Try next time.
        retries[channel] = value;
      }
    }

    _sendDataMap.removeWhere((key, value) => snapshot.entries
        .any((element) => element.key == key && element.value == value));

    _sendDataMap.addAll(retries);
  }

  /// Gets the stream of the [channelId].
  @override
  Stream<double>? streamOn(String channelId) {
    final channel = _getChannelOf(channelId);

    if (channel == null) return null;

    return _getBranch(channel)?.downward.stream;
  }

  /// Gets the sink of the [channelId].
  @override
  Sink<double>? sinkOn(String channelId) {
    final channel = _getChannelOf(channelId);

    if (channel == null) return null;

    return _getBranch(channel)?.upward.sink;
  }

  BleCharacteristicChannel? _getChannelOf(String channelId) {
    return channels
        ?.where((channel) => channel.identifier == channelId)
        .firstOrNull;
  }

  _TwoWayStreamController<double, double>? _getBranch(
      BleCharacteristicChannel channel) {
    if (!_branches.containsKey(channel)) {
      _createNewBranch(channel);
    }

    return _branches[channel];
  }

  void _createNewBranch(BleCharacteristicChannel channel) async {
    final upward = StreamController<double>();
    final downward = StreamController<double>.broadcast();

    // Subscribe notification or begin periodic read.
    if (channel.characteristic.properties.notify) {
      if (!channel.characteristic.isNotifying) {
        _setNotifyChannels.add(channel);
      }

      channel.characteristic.onValueReceived.listen((event) {
        if (event.isEmpty) return;

        downward.sink.add(
            channel.presentations.firstOrNull?.formatToDouble(event) ??
                event[0].toDouble());
      });
    } else if (channel.characteristic.properties.read) {
      _periodicReadChannels.add(channel);
    }

    // Pass data to the root with the channel.
    upward.stream.listen((event) {
      final value = event;

      // Echo back to downward.
      downward.sink.add(value);

      _sendDataMap[channel] = value;
    });

    _branches[channel] = (upward: upward, downward: downward);
  }
}

/// The bundle of the 2 streams.
typedef _TwoWayStreamController<T, U> = ({
  StreamController<T> upward,
  StreamController<U> downward
});
