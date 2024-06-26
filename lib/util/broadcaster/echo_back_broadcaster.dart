// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

// @immutable
// class EchoBackChannel implements BroadcastChannel {
//   final String value;

//   @override
//   String get identifier => value;

//   @override
//   String? get name => "Channel $value";

//   @override
//   String? get description => 'A channel named "$value".';

//   const EchoBackChannel(this.value);
// }

// @immutable
// class EchoBackData {
//   final int value;

//   const EchoBackData({required this.value});
// }

// class EchoBackBroadcaster implements MultiChannelBroadcaster {
//   late final _root = StreamController<_EchoBackRawData>.broadcast();
//   late final Map<String, _TwoWayStreamController> _branches = {};

//   @override
//   Stream<double>? streamOn(BroadcastChannel channel) {
//     if (channel is! EchoBackChannel) return null;

//     return _getBranch(channel)?.downward.stream;
//   }

//   @override
//   Sink<double>? sinkOn(BroadcastChannel channel) {
//     if (channel is! EchoBackChannel) return null;

//     return _getBranch(channel)?.upward.sink;
//   }

//   _TwoWayStreamController? _getBranch(EchoBackChannel channel) {
//     if (!_branches.containsKey(channel.value)) {
//       final upward = StreamController<double>();
//       final downward = StreamController<double>.broadcast();

//       // Distribute data to the branch by the channel.
//       _root.stream.listen((event) {
//         if (event.channel == channel.value) {
//           downward.sink.add(event.value);
//         }
//       });

//       // Pass data to the root with the channel.
//       upward.stream.listen((event) {
//         _root.sink.add(_EchoBackRawData(channel.value, event));
//       });

//       _branches[channel.value] = (upward: upward, downward: downward);
//     }

//     return _branches[channel.value];
//   }
// }

// typedef _TwoWayStreamController = ({
//   StreamController<double> upward,
//   StreamController<double> downward
// });

// @immutable
// class _EchoBackRawData {
//   final String channel;
//   final dynamic value;

//   const _EchoBackRawData(this.channel, this.value);
// }
