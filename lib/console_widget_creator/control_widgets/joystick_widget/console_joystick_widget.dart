import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/console_widget_creator/console_error_widget_creator.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/joystick_widget/console_joystick_widget_property.dart';
import 'package:flex_console_for_ble/util/widget/console_widget_card.dart';
import 'package:flex_console_for_ble/util/widget/handle_widget.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

class ConsoleJoystickWidget extends StatefulWidget {
  final ConsoleJoystickWidgetProperty property;
  final MultiChannelBroadcaster? broadcaster;

  const ConsoleJoystickWidget({
    super.key,
    required this.property,
    this.broadcaster,
  });

  @override
  State<ConsoleJoystickWidget> createState() => _ConsoleJoystickWidgetState();
}

class _ConsoleJoystickWidgetState extends State<ConsoleJoystickWidget> {
  late ConsoleJoystickWidgetProperty _prop;
  bool _activate = false;

  late double _rateX;
  late double _rateY;

  double? _prevValueX;
  double? _prevValueY;
  StreamSubscription? _subscriptionX;
  StreamSubscription? _subscriptionY;

  @override
  void initState() {
    // Initialize members with the widget.
    _initializeWithWidget();

    // Add a lister for the broadcasting.
    _updateBroadcastListener();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleJoystickWidget oldWidget) {
    // Initialize members with the widget.
    _initializeWithWidget();

    // Add a lister for the broadcasting.
    _updateBroadcastListener();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _subscriptionX?.cancel();
    _subscriptionY?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paramError = _prop.validate();

    if (paramError != null) {
      return ConsoleErrorWidgetCreator.createWith(
          brief: "Parameter Error", detail: paramError);
    }

    return ConsoleWidgetCard(
      activate: _activate,
      child: LayoutBuilder(
        builder: (context, constraints) =>
            Stack(fit: StackFit.expand, children: [
          Container(color: Theme.of(context).colorScheme.surface),
          Positioned(
            top: -constraints.maxHeight * (_rateY - 0.5) +
                (constraints.maxHeight / 2 - _getSquareSize(constraints) / 3),
            left: constraints.maxWidth * (_rateX - 0.5) +
                (constraints.maxWidth / 2 - _getSquareSize(constraints) / 3),
            child: Container(
                width: _getSquareSize(constraints) * 2 / 3,
                height: _getSquareSize(constraints) * 2 / 3,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: Theme.of(context).colorScheme.primary)),
          ),
          Center(
            child: Icon(
              Icons.control_camera,
              size: _getSquareSize(constraints) / 2,
              color: Color.lerp(
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.primary,
                  (_rateX - 0.5).abs() + (_rateY - 0.5).abs()),
            ),
          ),
          // Gesture handle.
          HandleWidget(
            onValueChange: (dx, dy) => _setRate(
                dx / constraints.maxWidth, -dy / constraints.maxHeight),
            onValueFix: () => _setRate(0, 0),
            onActivationChange: (act) => setState(() => _activate = act),
          ),
        ]),
      ),
    );
  }

  static double _getSquareSize(BoxConstraints constraints) =>
      min(constraints.maxHeight, constraints.maxWidth);

  /// Sets the  value and adds the value to the sink.
  void _setRate(double rateX, double rateY) {
    setState(() {
      _rateX = (rateX + 0.5).clamp(0, 1);
      _rateY = (rateY + 0.5).clamp(0, 1);
    });

    final valueX =
        (_rateX * (_prop.maxValueX - _prop.minValueX) + _prop.minValueX)
            .floorToDouble();

    final valueY =
        (_rateY * (_prop.maxValueY - _prop.minValueY) + _prop.minValueY)
            .floorToDouble();

    if (widget.property.channelX != null && _prevValueX != valueX) {
      widget.broadcaster?.sinkOn(widget.property.channelX!)?.add(valueX);
    }

    if (widget.property.channelY != null && _prevValueY != _rateY) {
      widget.broadcaster?.sinkOn(widget.property.channelY!)?.add(valueY);
    }

    _prevValueX = valueX;
    _prevValueY = valueY;
  }

  void _initializeWithWidget() {
    // Set the parameter.
    _prop = widget.property;

    // Set the values.
    _rateX = 0.5;
    _rateY = 0.5;
  }

  void _updateBroadcastListener() {
    // For dim x.
    if (widget.property.channelX != null) {
      _subscriptionX?.cancel();

      _subscriptionX = widget.broadcaster
          ?.streamOn(widget.property.channelX!)
          ?.listen((event) {
        // Exit when already activated.
        if (_activate) return;

        // Update the value.
        if (mounted) {
          setState(() {
            _rateX = ((event - _prop.minValueX) /
                    (_prop.maxValueX - _prop.minValueX))
                .clamp(0, 1);
          });
        }
      });
    }

    // For dim y.
    if (widget.property.channelY != null) {
      _subscriptionY?.cancel();

      _subscriptionY = widget.broadcaster
          ?.streamOn(widget.property.channelY!)
          ?.listen((event) {
        // Exit when already activated.
        if (_activate) return;

        // Update the value.
        if (mounted) {
          setState(() {
            _rateY = ((event - _prop.minValueY) /
                    (_prop.maxValueY - _prop.minValueY))
                .clamp(0, 1);
          });
        }
      });
    }
  }
}
