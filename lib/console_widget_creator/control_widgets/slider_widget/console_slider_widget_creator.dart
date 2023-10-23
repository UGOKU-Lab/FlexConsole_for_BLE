import 'package:flex_console_for_ble/console_widget_creator/typed_console_widget/typed_console_widget_creator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_ble/broadcaster_provider.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/slider_widget/console_slider_widget.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/slider_widget/console_slider_widget_property.dart';

/// The creator of volume slider.
final consoleSliderWidgetCreator = TypedConsoleWidgetCreator(
  ConsoleSliderWidgetProperty.fromUntyped,
  name: "Slider",
  description: "Controls a value by vertical swipes.",
  series: "Control Widgets",
  builder: (context, property) => Consumer(
    builder: (context, ref, _) => ConsoleSliderWidget(
      property: property,
      broadcaster: ref.watch(broadcasterProvider),
    ),
  ),
  propertyCreator: ConsoleSliderWidgetProperty.edit,
  previewBuilder: (context, property) => ConsoleSliderWidget(
    property: property,
  ),
  sampleProperty: const ConsoleSliderWidgetProperty(
      minValue: 0, maxValue: 255, initialValue: 64),
);
