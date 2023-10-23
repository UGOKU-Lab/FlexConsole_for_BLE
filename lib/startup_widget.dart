import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flex_console_for_ble/console_list_page.dart';
import 'package:flex_console_for_ble/console_page.dart';
import 'package:flex_console_for_ble/console_panel/generation_parameter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartupWidget extends StatelessWidget {
  /// The process to be done in the startup.
  late final _startup = SharedPreferences.getInstance().then((instance) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;

    final isAgreed = instance.getBool('agreement') ?? false;

    if (!isAgreed) {
      instance.setBool('agreement', false);
    }

    final savedVersion = instance.getString('version');

    final savedConsoles = instance
            .getStringList('consoles')
            ?.map((str) => ConsoleSaveObject.fromJson(jsonDecode(str)))
            .toList() ??
        [];

    if (savedVersion != version) {
      instance.setString('version', version);

      final newlyCreatedWidgets = [
        ConsoleSaveObject(
          'Release Notes: $version',
          ConsolePanelParameter(
            rows: 1,
            columns: 1,
            cells: [
              ConsolePanelCellParameter(
                row: 0,
                column: 0,
                creator: 'Note',
                property: {
                  'title': 'Release Notes: $version',
                  'body':
                      'Welcome to the $version of the Bluetooth Serial Console.'
                          'This offers the following key features:\n'
                          '\n'
                          '- console creation;\n'
                          '- connection to your Bluetooth devices;\n'
                          '- control of the devices using Serial Port Profile.\n'
                          '\n'
                          'For more information, search on GitHub.'
                },
              ),
            ],
          ),
        ),
        ConsoleSaveObject(
          'Sample: Simple Controller',
          ConsolePanelParameter(
            rows: 2,
            columns: 2,
            cells: [
              ConsolePanelCellParameter(
                  row: 0, column: 0, creator: 'Slider', property: {}),
              ConsolePanelCellParameter(
                  row: 0, column: 1, creator: 'Toggle Switch', property: {}),
              ConsolePanelCellParameter(
                  row: 1, column: 0, creator: 'Joystick', property: {}),
              ConsolePanelCellParameter(
                  row: 1, column: 1, creator: 'Joystick', property: {}),
            ],
          ),
        ),
        ConsoleSaveObject(
          'Sample: PID Adjuster',
          ConsolePanelParameter(
            rows: 2,
            columns: 3,
            cells: [
              ConsolePanelCellParameter(
                  row: 0,
                  column: 0,
                  width: 2,
                  creator: 'Line Chart',
                  property: {}),
              ConsolePanelCellParameter(
                  row: 0, column: 2, creator: 'Value Monitor', property: {}),
              ConsolePanelCellParameter(
                  row: 1, column: 0, creator: 'Adjuster', property: {}),
              ConsolePanelCellParameter(
                  row: 1, column: 1, creator: 'Adjuster', property: {}),
              ConsolePanelCellParameter(
                  row: 1, column: 2, creator: 'Adjuster', property: {}),
            ],
          ),
        ),
      ];

      for (final newConsole in newlyCreatedWidgets) {
        while (savedConsoles.any((c) => c.title == newConsole.title)) {
          newConsole.title = '${newConsole.title}_';
        }

        savedConsoles.add(newConsole);
      }

      await instance.setStringList('consoles',
          savedConsoles.map((c) => jsonEncode(c.toJson())).toList());
    }

    // Return the recently used console.
    final recentlyUsed = instance.getString('recentlyUsed');

    return recentlyUsed != null
        ? ConsolePanelParameter.fromJson(jsonDecode(recentlyUsed))
        : savedConsoles
            .where((c) => c.title == 'Release Notes: $version')
            .first
            .parameter;
  });

  StartupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ConsolePage(initialConsole: snapshot.data!);
          }
          if (snapshot.hasError) {
            return ConsolePage(
              initialConsole: ConsolePanelParameter.fromError(
                  "Startup Failed", "No console to be opened."),
            );
          }
        }

        return Container();
      },
    );
  }
}
