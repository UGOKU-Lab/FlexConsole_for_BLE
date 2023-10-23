import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_ble/bluetooth/service_provider.dart';
import 'package:flex_console_for_ble/bluetooth/target_device_provider.dart';

/// The page to connect a bluetooth device.
class DeviceConnectionPage extends StatefulWidget {
  const DeviceConnectionPage({Key? key}) : super(key: key);

  @override
  State<DeviceConnectionPage> createState() => _DeviceConnectionPageState();
}

class _DeviceConnectionPageState extends State<DeviceConnectionPage> {
  var _scanResults = <ScanResult>[];
  var _systemDevices = <BluetoothDevice>[];
  var _isScanning = false;
  late StreamSubscription _scanResultSubscription;
  late StreamSubscription _systemDevicesSubscription;
  late StreamSubscription _isScanningSubscription;

  @override
  void initState() {
    _scanResultSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;

      if (mounted) setState(() {});
    });

    _systemDevicesSubscription =
        FlutterBluePlus.systemDevices.asStream().listen((results) {
      _systemDevices = results;

      if (mounted) setState(() {});
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;

      if (mounted) setState(() {});
    });

    _startDeviceScan();

    super.initState();
  }

  @override
  void dispose() {
    _scanResultSubscription.cancel();
    _systemDevicesSubscription.cancel();
    _isScanningSubscription.cancel();

    FlutterBluePlus.stopScan();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Peripheral Devices'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isScanning ? null : _startDeviceScan,
            icon: const Icon(Icons.replay),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final listedDevices = {
            ..._systemDevices,
            ..._scanResults.map((result) => result.device)
          }.toList();

          if (listedDevices.isEmpty) {
            return Center(
              child: _isScanning
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No devices found.'),
                        const Text(''),
                        OutlinedButton(
                          onPressed: _startDeviceScan,
                          child: const Text('Scan devices'),
                        ),
                      ],
                    ),
            );
          }

          return Consumer(
            builder: (context, ref, _) {
              // The notifier of the target device for the request.
              final targetDeviceNotifier =
                  ref.watch(targetDeviceProvider.notifier);

              // The actual target device.
              final currentTargetDevice =
                  ref.watch(connectionTargetDeviceProvider);

              // The status of the connection.
              final connectionStatus = ref.watch(servicesProvider).when(
                  data: (data) => 'established',
                  loading: () => 'negotiating',
                  error: (error, trace) => 'error');

              return ListView.builder(
                itemCount: listedDevices.length,
                itemBuilder: (context, index) {
                  final BluetoothDevice device = listedDevices[index];

                  return ListTile(
                    title: _buildDeviceTitle(device),
                    subtitle: _buildDeviceSubtitle(device),
                    enabled: connectionStatus != 'negotiating',
                    trailing: currentTargetDevice == device
                        ? connectionStatus == 'established'
                            ? const Icon(Icons.bluetooth_connected)
                            : connectionStatus == 'negotiating'
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.error)
                        : null,
                    onTap: () async {
                      targetDeviceNotifier.state = null;
                      await Future.delayed(const Duration(milliseconds: 100));

                      // Request the connection to the device.
                      targetDeviceNotifier.state = device;
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future _startDeviceScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Widget _buildDeviceTitle(BluetoothDevice device) {
    final text =
        device.platformName.isEmpty ? device.remoteId.str : device.platformName;

    return Text(text);
  }

  Widget? _buildDeviceSubtitle(BluetoothDevice device) {
    return device.platformName.isEmpty ? null : Text(device.remoteId.str);
  }
}
