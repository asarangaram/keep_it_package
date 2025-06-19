import 'package:example/single_selection_demo.dart';
import 'package:example/text_field_demo.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Form Factory demo',
      home: Demos(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Demos extends StatelessWidget {
  const Demos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Examples for Form factory"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 8,
            children: [
              Center(
                child: TheCard(
                  title: "Search and Select an item",
                  footerText:
                      "You can select a single item here. "
                      "Once a valid item is selected, "
                      "the forward action button become active",
                  child: const SingleSelectionDemo(title: 'FormFactory demo'),
                ),
              ),
              Center(
                child: TheCard(
                  title: "Input Text",
                  footerText:
                      "Wait for a non blank text "
                      "Once a non blank text is enterred"
                      "the forward action button become active",
                  child: const TextFieldDemo(title: 'FormFactory demo'), //,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
