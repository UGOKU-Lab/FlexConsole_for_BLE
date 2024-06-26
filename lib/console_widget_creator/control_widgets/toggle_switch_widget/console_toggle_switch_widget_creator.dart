import 'package:flex_console_for_ble/console_widget_creator/typed_console_widget/typed_console_widget_creator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_console_for_ble/broadcaster_provider.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/toggle_switch_widget/console_toggle_switch_widget.dart';
import 'package:flex_console_for_ble/console_widget_creator/control_widgets/toggle_switch_widget/console_toggle_switch_widget_property.dart';

/// The creator of a toggle switch.
final consoleToggleSwitchWidgetCreator = TypedConsoleWidgetCreator(
  ConsoleToggleSwitchWidgetProperty.fromUntyped,
  name: "Toggle Switch",
  description: "Switches values each time you tap.",
  series: "Control Widgets",
  builder: (context, property) => Consumer(
    builder: (context, ref, _) => ConsoleToggleSwitchWidget(
      property: property,
      broadcaster: ref.watch(broadcasterProvider),
    ),
  ),
  previewBuilder: (context, property) => ConsoleToggleSwitchWidget(
    property: property,
  ),
  propertyCreator: ConsoleToggleSwitchWidgetProperty.edit,
);
