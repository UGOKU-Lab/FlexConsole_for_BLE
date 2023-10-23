import 'dart:async';

abstract class BroadcastChannel {
  String get identifier;
  String? get name;
  String? get description;

  @override
  String toString() => identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is BroadcastChannel) {
      return identifier == other.identifier;
    }

    return false;
  }
}

abstract class MultiChannelBroadcaster {
  Stream<double>? streamOn(String channelId);

  Sink<double>? sinkOn(String channelId);
}
