import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cl_media_info_extractor/cl_media_info_extractor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FutureBuilder(
              future: ClMediaInfoExtractor.getMediaInfo(
                "'/Users/anandasarangaram/Downloads/WhatsApp Image 2025-03-30 at 17.28.28.temp'",
              ),
              builder: (context, snapShot) {
                return SingleChildScrollView(
                  child: [
                    if (snapShot.connectionState == ConnectionState.waiting)
                      const CircularProgressIndicator()
                    else if (snapShot.hasError)
                      Text('Error: ${snapShot.error}')
                    else if (snapShot.hasData)
                      Text(prettyJson(snapShot.data!.toMap()))
                    else
                      const Text('No data')
                  ][0],
                );
              }),
        ),
      ),
    );
  }
}

String prettyJson(dynamic json) {
  var spaces = ' ' * 4;
  var encoder = JsonEncoder.withIndent(spaces);
  String output = encoder.convert(json);
  print(output);
  return output;
}
