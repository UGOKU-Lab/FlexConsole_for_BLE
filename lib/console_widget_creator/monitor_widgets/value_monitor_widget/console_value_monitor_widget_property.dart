import 'dart:async';

import 'package:flex_console_for_ble/console_widget_creator/single_value_console_widget/single_value_console_widget_property.dart';
import 'package:flex_console_for_ble/console_widget_creator/typed_console_widget/typed_console_widget_creator.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/util/form/common_form_page.dart';
import 'package:flex_console_for_ble/util/form/channel_selector.dart';
import 'package:flex_console_for_ble/util/form/integer_field.dart';

import '../../console_widget_creator.dart';

/// The property of the console widget.
class ConsoleValueMonitorProperty extends SingleValueWidgetProperty {
  final int displayFractionDigits;

  /// Creates a property.
  const ConsoleValueMonitorProperty({
    super.channel,
    this.displayFractionDigits = 0,
  });

  /// Creates a property from the untyped [property].
  ConsoleValueMonitorProperty.fromUntyped(ConsoleWidgetProperty property)
      : displayFractionDigits =
            selectAttributeAs(property, "displayFractionDigits", 0),
        super.fromUntyped(property);

  @override
  ConsoleWidgetProperty toUntyped() => {
        ...super.toUntyped(),
        "channel": channel,
        "displayFractionDigits": displayFractionDigits,
      };

  @override
  String? validate() {
    if (displayFractionDigits < 0 || displayFractionDigits > 20) {
      return "Display precision must be in the range 0-20.";
    }

    return super.validate();
  }

  /// Edits interactively to create new property.
  static Future<ConsoleValueMonitorProperty?> create(
    BuildContext context, {
    ConsoleValueMonitorProperty? oldProperty,
  }) {
    final propCompleter = Completer<ConsoleValueMonitorProperty?>();
    final initial = oldProperty ?? const ConsoleValueMonitorProperty();

    // Attributes of the property for editing.
    String? newChannel = initial.channel;
    int newDisplayPrecision = initial.displayFractionDigits;

    // Show a form to edit above attributes.
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CommonFormPage(
          title: "Property Edit",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(""),
              Text("Input Channel",
                  style: Theme.of(context).textTheme.headlineMedium),
              ChannelSelector(
                  initialValue: newChannel,
                  onChanged: (value) => newChannel = value),
              const Text(""),
              Text("Display",
                  style: Theme.of(context).textTheme.headlineMedium),
              IntInputField(
                labelText: "Fraction digits",
                initValue: newDisplayPrecision,
                // Max and min are limited by [double.toStringAsFixed].
                minValue: 0,
                maxValue: 20,
                nullable: false,
                onValueChange: (value) => newDisplayPrecision = value!,
              ),
            ],
          ),
        ),
      ),
    )
        .then((ok) {
      if (ok) {
        propCompleter.complete(ConsoleValueMonitorProperty(
          channel: newChannel,
          displayFractionDigits: newDisplayPrecision,
        ));
      } else {
        propCompleter.complete(oldProperty);
      }
    });

    return propCompleter.future;
  }
}
