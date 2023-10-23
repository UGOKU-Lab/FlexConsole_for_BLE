import 'package:flutter/material.dart';

class ContractPage extends StatefulWidget {
  const ContractPage({super.key});

  @override
  State<StatefulWidget> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Conditions"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("Enjoy!"),
            Checkbox(
              value: _agreed,
              onChanged: (value) => setState(() => _agreed = value ?? false),
              semanticLabel: "I agree.",
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Exit"),
                ),
                OutlinedButton(
                  onPressed:
                      _agreed ? () => Navigator.of(context).pop(true) : null,
                  child: const Text("Continue"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
