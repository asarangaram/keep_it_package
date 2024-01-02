import 'dart:math';
import 'dart:ui' as ui;

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
  final List<RandomImage> images = [];

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const int numberOfColumns = 4;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Images'),
      ),
      body: FutureBuilder<List<List<ui.Image>>>(
        future: () async {
          final allImages = await RandomImage.generateImages(30);
          return RandomImage.columnizeImages(allImages,
              numberOfColumns: numberOfColumns);
        }(), // Generate 10 images for demonstration
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No images generated.'));
          }

          final columnizedImages = snapshot.data!;
          final List<ui.Image> allImages = columnizedImages
              .expand((list) => list)
              .toList()
              .reversed
              .toList();

          // return ColumnizedMultiImageView(columnizedImages: columnizedImages);
          // final random = Random();
          //return UsingMasonryView(columnizedImages: columnizedImages);

          return StackBased(
            images: allImages,
          );
        },
      ),
    );
  }
}

class UsingMasonryView extends StatelessWidget {
  const UsingMasonryView({
    super.key,
    required this.columnizedImages,
  });

  final List<List<ui.Image>> columnizedImages;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: MasonryView(
      //listOfItem: columnizedImages,
      listOfItem: columnizedImages.expand((list) => list).toList(),

      numberOfColumn: (MediaQuery.of(context).size.width / 200).ceil(),
      itemBuilder: (item) {
        final img = item as ui.Image;
        return AspectRatio(
            aspectRatio: img.width / img.height, child: RawImage(image: img));
      },
    ));
  }
}

class ColumnizedMultiImageView extends StatelessWidget {
  const ColumnizedMultiImageView({
    super.key,
    required this.columnizedImages,
  });

  final List<List<ui.Image>> columnizedImages;

  @override
  Widget build(BuildContext context) {
    final numberOfColumns = columnizedImages.length;
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < numberOfColumns; c++)
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: columnizedImages[c]
                    .map((ui.Image e) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: AspectRatio(
                            aspectRatio:
                                e.width.toDouble() / e.height.toDouble(),
                            child: RawImage(image: e),
                          ),
                        ))
                    .toList(),
              ),
            )
        ],
      ),
    );
  }
}

class StackBased extends StatefulWidget {
  const StackBased({
    super.key,
    required this.images,
  });
  final List<ui.Image> images;

  @override
  State<StatefulWidget> createState() => _StackBasedState();
}

class _StackBasedState extends State<StackBased>
    with SingleTickerProviderStateMixin {
  late List<ui.Image> allImages;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 2000), // Change the duration as needed
    );
    _animation = Tween<double>(begin: 0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    allImages = widget.images;
    super.initState();
  }

  List<ui.Image> barrelRotateList() {
    return [allImages.last, ...allImages.sublist(0, allImages.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          allImages = barrelRotateList();
          _controller.forward();
        });
      },
      child: Stack(
          children: allImages.sublist(0, 5).asMap().entries.map((e) {
        final offset = e.key * 2.0 - _animation.value;
        print("offset is $offset");
        return Transform.translate(
          offset: Offset(offset, offset),
          child: Card(
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              side: const BorderSide(),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: RawImage(image: e.value),
              ),
            ),
          ),
        );
      }).toList()),
    );
  }
}
