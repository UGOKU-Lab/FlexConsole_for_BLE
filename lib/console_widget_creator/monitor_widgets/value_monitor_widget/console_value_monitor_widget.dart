import 'package:flex_console_for_ble/console_widget_creator/single_value_console_widget/single_value_console_widget.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/console_widget_creator/monitor_widgets/value_monitor_widget/console_value_monitor_widget_property.dart';
import 'package:flex_console_for_ble/util/widget/console_widget_card.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

/// The adjuster to control a value with a slider and increment/decrement
/// buttons.
class ConsoleValueMonitorWidget extends SingleValueWidget {
  /// The property specialized for this widget.
  ConsoleValueMonitorProperty get thisProperty =>
      property as ConsoleValueMonitorProperty;

  /// The initial value to display on preview and sample.
  final double? initialValue;

  const ConsoleValueMonitorWidget({
    super.key,
    required ConsoleValueMonitorProperty property,
    MultiChannelBroadcaster? broadcaster,
    this.initialValue,
  }) : super(property: property, broadcaster: broadcaster);

  @override
  State<ConsoleValueMonitorWidget> createState() =>
      _ConsoleValueMonitorWidgetState();
}

class _ConsoleValueMonitorWidgetState
    extends SingleValueWidgetState<ConsoleValueMonitorWidget> {
  /// The monitoring value.
  late double? _value = widget.initialValue;

  /// Whether the display value should not update.
  bool _pausing = false;

  @override
  void onReceive(double value) {
    if (mounted) {
      _setValue(value);
    }
  }

  /// Sets the state [_value] to [value].
  void _setValue(double value) {
    _value = value;

    if (!_pausing) {
      setState(() {});
    }
  }

  /// Sets the state [_pausing] to [pausing]
  void _setPausing(bool pausing) {
    if (_pausing != pausing) {
      setState(() {
        _pausing = pausing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConsoleWidgetCard(
      activate: _pausing,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: constraints.maxHeight / 2,
                  child: FittedBox(
                    child: Text(
                        _value?.toStringAsFixed(
                                widget.thisProperty.displayFractionDigits) ??
                            "-",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPausing(true),
            onPanStart: (_) => _setPausing(true),
            onTapUp: (_) => _setPausing(false),
            onPanEnd: (_) => _setPausing(false),
          ),
        ]),
      ),
    );
  }
}
