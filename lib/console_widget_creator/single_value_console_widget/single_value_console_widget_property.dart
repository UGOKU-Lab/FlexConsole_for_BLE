import 'dart:async';

import 'package:flex_console_for_ble/console_widget_creator/console_widget_creator.dart';
import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/console_widget_creator/typed_console_widget/typed_console_widget_creator.dart';
import 'package:flex_console_for_ble/util/form/common_form_page.dart';
import 'package:flex_console_for_ble/util/form/channel_selector.dart';

/// The property of the console widget.
@immutable
class SingleValueWidgetProperty implements TypedConsoleWidgetProperty {
  /// The identifier of the channel to broadcast the control value.
  final String? channel;

  /// Creates a property.
  const SingleValueWidgetProperty({
    this.channel,
  });

  /// Creates a property from the untyped [property].
  SingleValueWidgetProperty.fromUntyped(ConsoleWidgetProperty property)
      : channel = selectAttributeAs(property, "channel", null);

  @override
  ConsoleWidgetProperty toUntyped() => {
        "channel": channel,
      };

  @override
  String? validate() => null;

  /// Edits interactively to create new property.
  static Future<SingleValueWidgetProperty?> create(
    BuildContext context, {
    SingleValueWidgetProperty? oldProperty,
  }) {
    final propCompleter = Completer<SingleValueWidgetProperty?>();
    final initial = oldProperty ?? const SingleValueWidgetProperty();

    // Attributes of the property for editing.
    String? newChannel = initial.channel;

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
              Text("Channel",
                  style: Theme.of(context).textTheme.headlineMedium),
              ChannelSelector(
                  initialValue: newChannel,
                  onChanged: (value) => newChannel = value),
            ],
          ),
        ),
      ),
    )
        .then((ok) {
      if (ok) {
        propCompleter.complete(SingleValueWidgetProperty(
          channel: newChannel,
        ));
      } else {
        propCompleter.complete(oldProperty);
      }
    });

    return propCompleter.future;
  }
}
