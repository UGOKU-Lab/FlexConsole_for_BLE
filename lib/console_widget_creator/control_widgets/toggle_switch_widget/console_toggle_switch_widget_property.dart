import 'dart:async';

import 'package:flex_console_for_ble/console_widget_creator/single_value_console_widget/single_value_console_widget_property.dart';
import 'package:flex_console_for_ble/console_widget_creator/typed_console_widget/typed_console_widget_creator.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/util/form/double_field.dart';
import 'package:flex_console_for_ble/util/form/common_form_page.dart';
import 'package:flex_console_for_ble/util/form/channel_selector.dart';

import '../../console_widget_creator.dart';

/// Parameter of the console widget.
class ConsoleToggleSwitchWidgetProperty extends SingleValueWidgetProperty {
  final double initialValue;
  final double reversedValue;

  /// Creates the parameter.
  const ConsoleToggleSwitchWidgetProperty({
    super.channel,
    double? initialValue,
    double? reversedValue,
  })  : initialValue = initialValue ?? 0,
        reversedValue = reversedValue ?? 1;

  /// Creates the parameter from an [property].
  ConsoleToggleSwitchWidgetProperty.fromUntyped(ConsoleWidgetProperty property)
      : initialValue = selectAttributeAs(property, "initialValue", 0),
        reversedValue = selectAttributeAs(property, "reversedValue", 1),
        super.fromUntyped(property);

  /// Creates the property of itself.
  @override
  ConsoleWidgetProperty toUntyped() => {
        ...super.toUntyped(),
        "initialValue": initialValue,
        "reversedValue": reversedValue,
      };

  @override
  String? validate() {
    if (initialValue == reversedValue) {
      return "Reversed value must not equal initial value.";
    }

    return super.validate();
  }

  static Future<ConsoleToggleSwitchWidgetProperty?> edit(BuildContext context,
      {ConsoleToggleSwitchWidgetProperty? oldProperty}) {
    final propCompleter = Completer<ConsoleToggleSwitchWidgetProperty?>();
    final initial = oldProperty ?? const ConsoleToggleSwitchWidgetProperty();

    // Attributes of the property for editing.
    String? newChannel = initial.channel;
    double newInitialValue = initial.initialValue;
    double newReversedValue = initial.reversedValue;

    // Show a form to edit above parameters.
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CommonFormPage(
          title: "Property Edit",
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(""),
              Text("Output Channel",
                  style: Theme.of(context).textTheme.headlineMedium),
              ChannelSelector(
                  initialValue: newChannel,
                  onChanged: (value) => newChannel = value),
              const Text(""),
              Text("Output Value",
                  style: Theme.of(context).textTheme.headlineMedium),
              DoubleInputField(
                  labelText: "Initial Value",
                  initValue: newInitialValue,
                  nullable: false,
                  onValueChange: (value) => newInitialValue = value!,
                  valueValidator: (value) => null),
              DoubleInputField(
                  labelText: "Reversed Value",
                  initValue: newReversedValue,
                  nullable: false,
                  onValueChange: (value) => newReversedValue = value!,
                  valueValidator: (value) {
                    if (value! == newInitialValue) {
                      return "Reversed value must not equal initial.";
                    }
                    return null;
                  }),
            ],
          ),
        ),
      ),
    )
        .then((ok) {
      if (ok) {
        propCompleter.complete(ConsoleToggleSwitchWidgetProperty(
          channel: newChannel,
          initialValue: newInitialValue.toDouble(),
          reversedValue: newReversedValue.toDouble(),
        ));
      } else {
        propCompleter.complete(oldProperty);
      }
    });

    return propCompleter.future;
  }
}
