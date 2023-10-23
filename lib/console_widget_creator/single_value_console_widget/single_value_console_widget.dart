import 'dart:async';

import 'package:flex_console_for_ble/console_widget_creator/single_value_console_widget/single_value_console_widget_property.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

/// The base of single value widget creators.
class SingleValueWidget extends StatefulWidget {
  final SingleValueWidgetProperty property;

  /// The target broadcaster.
  final MultiChannelBroadcaster? broadcaster;

  const SingleValueWidget({
    super.key,
    required this.property,
    this.broadcaster,
  });

  @override
  State<SingleValueWidget> createState() => SingleValueWidgetState();
}

class SingleValueWidgetState<T extends SingleValueWidget> extends State<T> {
  StreamSubscription? _subscription;

  @override
  @mustCallSuper
  void initState() {
    // Initialize members with the widget.
    onPropertyChange();

    // Manage the lister for the broadcasting.
    updateSubscription();

    super.initState();
  }

  @override
  @mustCallSuper
  void didUpdateWidget(oldWidget) {
    // Initialize members with the widget.
    onPropertyChange();

    // Manage the lister for the broadcasting.
    updateSubscription();

    super.didUpdateWidget(oldWidget);
  }

  @override
  @mustCallSuper
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container();

  void onPropertyChange() {}

  /// Updates the subscription.
  void updateSubscription() {
    // Cancel the subscription anyway.
    _subscription?.cancel();

    // Subscribe if required.
    if (widget.property.channel != null) {
      _subscription = widget.broadcaster
          ?.streamOn(widget.property.channel!)
          ?.listen(onReceive);
    }
  }

  void onReceive(double value) {}
}
