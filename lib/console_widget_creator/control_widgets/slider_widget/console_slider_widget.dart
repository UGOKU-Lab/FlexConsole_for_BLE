import 'dart:math';

import 'package:flex_console_for_ble/console_widget_creator/single_value_console_widget/single_value_console_widget.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/console_widget_creator/console_error_widget_creator.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/slider_widget/console_slider_widget_property.dart';
import 'package:flex_console_for_ble/util/widget/console_widget_card.dart';
import 'package:flex_console_for_ble/util/widget/handle_widget.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

class ConsoleSliderWidget extends SingleValueWidget {
  /// The property specialized for this widget.
  ConsoleSliderWidgetProperty get thisProperty =>
      property as ConsoleSliderWidgetProperty;

  const ConsoleSliderWidget({
    super.key,
    required ConsoleSliderWidgetProperty property,
    MultiChannelBroadcaster? broadcaster,
  }) : super(property: property, broadcaster: broadcaster);

  @override
  State<ConsoleSliderWidget> createState() => _ConsoleSliderWidgetState();
}

class _ConsoleSliderWidgetState
    extends SingleValueWidgetState<ConsoleSliderWidget> {
  late double _rateOffset;
  double _rateDelta = 0;
  bool _activate = false;

  double? _prevValue;

  double get _rate => _rateOffset + _rateDelta;

  @override
  void onPropertyChange() {
    _rateOffset =
        ((widget.thisProperty.initialValue - widget.thisProperty.minValue) /
                (widget.thisProperty.maxValue - widget.thisProperty.minValue))
            .clamp(0, 1);
  }

  @override
  void onReceive(double value) {
    // Exit when already activated.
    if (_activate) return;

    // Update the value.
    if (mounted) {
      setState(() {
        _rateOffset = ((value - widget.thisProperty.minValue) /
                (widget.thisProperty.maxValue - widget.thisProperty.minValue))
            .clamp(0, 1);
        _rateDelta = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paramError = widget.thisProperty.validate();
    if (paramError != null) {
      return ConsoleErrorWidgetCreator.createWith(
          brief: "Parameter Error", detail: paramError);
    }

    return ConsoleWidgetCard(
      activate: _activate,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(children: [
          Column(
            children: [
              Flexible(
                flex: (constraints.maxHeight * (1 - _rate)).floor(),
                child: Container(color: Theme.of(context).colorScheme.surface),
              ),
              Flexible(
                flex: (constraints.maxHeight * _rate).floor(),
                child: Container(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          // Icon
          Center(
            child: Icon(
              Icons.arrow_upward,
              size: min(constraints.maxHeight, constraints.maxWidth) / 2,
              color: Color.lerp(Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.surface, _rate),
            ),
          ),
          // Gesture handle.
          HandleWidget(
            onValueChange: (_, dy) =>
                _setRateDelta(-dy / constraints.maxHeight),
            onValueFix: () => _fixValue(),
            onActivationChange: (act) => setState(() => _activate = act),
          ),
        ]),
      ),
    );
  }

  /// Sets the delta value and adds the value to the sink.
  void _setRateDelta(double rateDelta) {
    setState(() {
      _rateDelta = rateDelta.clamp(-_rateOffset, 1 - _rateOffset);
    });

    final value =
        ((widget.thisProperty.maxValue - widget.thisProperty.minValue) * _rate +
                widget.thisProperty.minValue)
            .floorToDouble();

    if (widget.property.channel != null && _prevValue != value) {
      widget.broadcaster?.sinkOn(widget.property.channel!)?.add(value);
    }

    _prevValue = value;
  }

  /// Adds the delta to the value and sets the delta to zero.
  void _fixValue() {
    _rateOffset = _rate.clamp(0, 1);
    _rateDelta = 0;
  }
}
