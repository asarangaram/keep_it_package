import 'dart:typed_data';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_masonry_view/flutter_masonry_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generated Images',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final List<RandomImageGenerator> images = [];

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Images'),
      ),
      body: FutureBuilder<List<Uint8List>>(
        future: RandomImageGenerator.generateImages(
            100), // Generate 10 images for demonstration
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No images generated.'));
          }

          return SingleChildScrollView(
              child: MasonryView(
            listOfItem: images,
            numberOfColumn: (MediaQuery.of(context).size.width / 200).ceil(),
            itemBuilder: (item) {
              final img = item as RandomImageGenerator;
              return AspectRatio(
                  aspectRatio: img.width / img.height,
                  child: Image.memory(img.image));
            },
          ));
        },
      ),
    );
  }
}
