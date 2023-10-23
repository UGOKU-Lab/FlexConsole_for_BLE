import 'package:flex_console_for_ble/console_widget_creator/typed_console_widget/typed_console_widget_creator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_ble/broadcaster_provider.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/adjuster_widget/console_adjuster_widget.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/adjuster_widget/console_adjuster_widget_property.dart';

/// Creates the adjuster that adjusts a value with a slider and increments/
/// decremental buttons.
final consoleAdjusterWidgetCreator = TypedConsoleWidgetCreator(
  ConsoleAdjusterWidgetProperty.fromUntyped,
  name: "Adjuster",
  description: "Adjusts a value with a slider and increment/decrement buttons.",
  series: "Control Widgets",
  propertyCreator: ConsoleAdjusterWidgetProperty.create,
  builder: (context, property) => Consumer(
    builder: (context, ref, _) => ConsoleAdjusterWidget(
      property: property,
      broadcaster: ref.watch(broadcasterProvider),
    ),
  ),
  previewBuilder: (context, property) => ConsoleAdjusterWidget(
    property: property,
  ),
  sampleProperty: const ConsoleAdjusterWidgetProperty(initialValue: 64),
);
