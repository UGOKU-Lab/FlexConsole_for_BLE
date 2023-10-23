import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flex_console_for_ble/console_widget_creator/single_value_console_widget/single_value_console_widget.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/console_widget_creator/monitor_widgets/line_chart_widget/console_line_chart_widget_property.dart';
import 'package:flex_console_for_ble/util/widget/console_widget_card.dart';
import 'package:flex_console_for_ble/util/broadcaster/multi_channel_broadcaster.dart';

/// A display widget that draws a line time chart.
class ConsoleLineChartWidget extends SingleValueWidget {
  /// The property specialized for this widget.
  ConsoleLineChartWidgetProperty get thisProperty =>
      property as ConsoleLineChartWidgetProperty;

  /// The initial values to display on preview and sample.
  final List<double>? initialValues;

  /// Whether the widget should start sampling. (for preview and sample)
  final bool start;

  /// Creates a line chart widget.
  const ConsoleLineChartWidget({
    super.key,
    required ConsoleLineChartWidgetProperty property,
    MultiChannelBroadcaster? broadcaster,
    this.initialValues,
    this.start = true,
  }) : super(property: property, broadcaster: broadcaster);

  @override
  State<ConsoleLineChartWidget> createState() => _ConsoleLineChartWidgetState();
}

class _ConsoleLineChartWidgetState
    extends SingleValueWidgetState<ConsoleLineChartWidget> {
  /// The actual values.
  final _values = List<double>.empty(growable: true);

  /// The current value.
  late double _currentValue = widget.initialValues?.lastOrNull ?? 0;

  /// Whether the display value should not update.
  bool _pausing = false;

  /// The timer to sample the value.
  Timer? _samplingTimer;

  /// Initialize members.
  @override
  void onPropertyChange() {
    // Initialize values.
    _values.clear();
    _values.addAll(List.of(
        widget.initialValues ?? List.filled(widget.thisProperty.samples, 0)));
  }

  @override
  void onReceive(double value) {
    _currentValue = value;
  }

  @override
  void dispose() {
    _samplingTimer?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    // Setup the timer to update view.
    _initTimer();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant ConsoleLineChartWidget oldWidget) {
    // Start the timer after all of other parameters have been updated.
    _initTimer();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ConsoleWidgetCard(
      activate: _pausing,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _ChartPainter(context, _values),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
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

  /// Updates the timer.
  void _initTimer() {
    // Cancel the timer anyway.
    _samplingTimer?.cancel();

    // Start periodic timer to sample the value.
    if (widget.start) {
      assert(widget.thisProperty.minValue != widget.thisProperty.maxValue);

      _samplingTimer = Timer.periodic(
          Duration(milliseconds: widget.thisProperty.period), (timer) {
        // Pop the oldest value and append the current value.
        _values.removeAt(0);
        _values.add((_currentValue - widget.thisProperty.minValue) /
            (widget.thisProperty.maxValue - widget.thisProperty.minValue));

        // Update the display.
        if (mounted && !_pausing) {
          setState(() {});
        }
      });
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
}

class _ChartPainter extends CustomPainter {
  final BuildContext context;

  /// The list of y-values between 0 and 1.
  final Iterable<double> values;

  /// Creates a chart painter.
  _ChartPainter(this.context, this.values);

  @override
  void paint(Canvas canvas, Size size) {
    assert(values.isNotEmpty);

    final paint = Paint();

    const rightPadding = 10;

    // The dynamic drawing parameters.
    final unitSize = min(size.width, size.height) / values.length;
    final double lineWidth = max(unitSize / 4, 2);
    final double pointSize = unitSize * 2 / 3;

    final drawingSize = Size(
        size.width - pointSize / 2 - rightPadding, size.height - lineWidth);

    // The value points translated to the drawing area.
    final points = values.indexed.map((indexed) {
      final (index, value) = indexed;

      return Offset(drawingSize.width * index / (values.length - 1),
          (1 - value) * drawingSize.height + lineWidth / 2);
    }).toList();

    // Draw the background.
    paint.color = Theme.of(context).splashColor;

    final path = Path()
      ..addPolygon([
        Offset(0, size.height),
        ...points,
        Offset(points.last.dx, size.height),
      ], true);

    canvas.drawPath(path, paint);

    // Draw the foreground.
    paint.color = Theme.of(context).colorScheme.primary;

    canvas.drawPoints(
        PointMode.polygon, points, paint..strokeWidth = lineWidth);

    canvas.drawPoints(
        PointMode.points,
        points,
        paint
          ..strokeWidth = pointSize
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
