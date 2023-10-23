import 'dart:math';

import 'package:flex_console_for_ble/console_widget_creator/single_value_console_widget/single_value_console_widget.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/console_widget_creator/console_error_widget_creator.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/toggle_switch_widget/console_toggle_switch_widget_property.dart';
import 'package:flex_console_for_ble/util/widget/console_widget_card.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

class ConsoleToggleSwitchWidget extends SingleValueWidget {
  /// The property specialized for this widget.
  ConsoleToggleSwitchWidgetProperty get thisProperty =>
      property as ConsoleToggleSwitchWidgetProperty;

  const ConsoleToggleSwitchWidget({
    super.key,
    required ConsoleToggleSwitchWidgetProperty property,
    MultiChannelBroadcaster? broadcaster,
  }) : super(property: property, broadcaster: broadcaster);

  @override
  State<ConsoleToggleSwitchWidget> createState() =>
      _ConsoleToggleSwitchWidgetState();
}

class _ConsoleToggleSwitchWidgetState
    extends SingleValueWidgetState<ConsoleToggleSwitchWidget> {
  late double _value;
  bool _activate = false;

  @override
  void onPropertyChange() {
    _value = widget.thisProperty.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final paramError = widget.thisProperty.validate();
    if (paramError != null) {
      return ConsoleErrorWidgetCreator.createWith(
          brief: "Parameter Error", detail: paramError);
    }

    return LayoutBuilder(
      builder: (context, constraints) => ConsoleWidgetCard(
        activate: _activate,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _activate = true),
          onTapCancel: () => setState(() => _activate = false),
          onTap: () {
            setState(() {
              _activate = false;
              _toggleValue();
            });
          },
          onLongPress: () => {},
          child: Container(
            color: _value == widget.thisProperty.initialValue
                ? Theme.of(context).colorScheme.background
                : Theme.of(context).colorScheme.primary,
            child: Center(
              child: _value == widget.thisProperty.initialValue
                  ? Icon(Icons.toggle_off_outlined,
                      size:
                          min(constraints.maxHeight, constraints.maxWidth) / 2,
                      color: Theme.of(context).colorScheme.primary)
                  : Icon(Icons.toggle_on_outlined,
                      size:
                          min(constraints.maxHeight, constraints.maxWidth) / 2,
                      color: Theme.of(context).colorScheme.surface),
            ),
          ),
        ),
      ),
    );
  }

  /// Sets the delta value and adds the value to the sink.
  void _toggleValue() {
    setState(() {
      _value = _value == widget.thisProperty.initialValue
          ? widget.thisProperty.reversedValue
          : widget.thisProperty.initialValue;
    });

    if (widget.property.channel != null) {
      widget.broadcaster
          ?.sinkOn(widget.property.channel!)
          ?.add(_value.toDouble());
    }
  }
}
