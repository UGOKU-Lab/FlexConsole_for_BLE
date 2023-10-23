import 'package:flex_console_for_ble/console_widget_creator/single_value_console_widget/single_value_console_widget.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/adjuster_widget/console_adjuster_widget_property.dart';
import 'package:flex_console_for_ble/util/widget/console_widget_card.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

/// Creates a adjuster to control a value with a slider and increment/decrement
/// buttons.
class ConsoleAdjusterWidget extends SingleValueWidget {
  /// The property specialized for this widget.
  ConsoleAdjusterWidgetProperty get thisProperty =>
      property as ConsoleAdjusterWidgetProperty;

  const ConsoleAdjusterWidget({
    super.key,
    required ConsoleAdjusterWidgetProperty property,
    MultiChannelBroadcaster? broadcaster,
  }) : super(property: property, broadcaster: broadcaster);

  @override
  State<ConsoleAdjusterWidget> createState() => _ConsoleAdjusterWidgetState();
}

class _ConsoleAdjusterWidgetState
    extends SingleValueWidgetState<ConsoleAdjusterWidget> {
  /// The step of the controlled value in range 0-[widget.property.divisions].
  late int _step;

  /// The size of the step to convert [_step] to [_value].
  late double _stepSize;

  /// Whether the widget is activated.
  bool _activate = false;

  /// The cache of the [_step] broadcasted previously.
  int? _prevStep;

  /// The value determined by [_step].
  double get _value => _step * _stepSize + widget.thisProperty.minValue;

  @override
  void onPropertyChange() {
    // Update the step size.
    _stepSize = ((widget.thisProperty.maxValue - widget.thisProperty.minValue) /
        widget.thisProperty.divisions);

    // Reset the step to the initial value.
    _setStep(_valueToStep(widget.thisProperty.initialValue), broadcast: true);
  }

  @override
  void onReceive(double value) {
    // Exit when already activated.
    if (_activate) return;

    // Update the value without the broadcasting.
    // NOTE: The echo back broadcasting can causes the convergence.
    if (mounted) {
      _setStep(_valueToStep(value), broadcast: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConsoleWidgetCard(
      activate: _activate,
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: FittedBox(
              child: Text(_value
                  .toStringAsFixed(widget.thisProperty.displayFractionDigits)),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.remove,
                          color: Theme.of(context).colorScheme.primary),
                      onPressed: () => _setStep(_step - 1, broadcast: true),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Center(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.add,
                          color: Theme.of(context).colorScheme.primary),
                      onPressed: () => _setStep(_step + 1, broadcast: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: SliderTheme(
              data: const SliderThemeData(overlayColor: Colors.transparent),
              child: Slider(
                min: widget.thisProperty.minValue,
                max: widget.thisProperty.maxValue,
                value: _value,
                onChanged: (value) =>
                    _setStep(_valueToStep(value), broadcast: true),
                onChangeStart: (value) => _setActivate(true),
                onChangeEnd: (value) => _setActivate(false),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  /// Converts the value to the step.
  int _valueToStep(double value) {
    return ((value - widget.thisProperty.minValue) / _stepSize).round();
  }

  /// Set the state [_step] to [step] with the arrangement and broadcast to the
  /// stream if [broadcast] is true.
  void _setStep(int step, {required bool broadcast}) {
    // Set the value with the limitation in the property.
    setState(() {
      if (step < 0) {
        _step = 0;
      } else if (step > widget.thisProperty.divisions) {
        _step = widget.thisProperty.divisions;
      } else {
        _step = step;
      }
    });

    // Compare with the previous value to avoid the meaningless streaming.
    if (_step != _prevStep) {
      _prevStep = _step;

      if (broadcast && widget.property.channel != null) {
        widget.broadcaster?.sinkOn(widget.property.channel!)?.add(_value);
      }
    }
  }

  /// Set the state [_activate] to [activate].
  void _setActivate(bool activate) {
    setState(() {
      _activate = activate;
    });
  }
}
