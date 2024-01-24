import 'dart:ui' as ui;
import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final List<String> imagePaths = [
  'assets/image1.jpg',
  'assets/image2.jpg',
  'assets/image3.jpg',
  'assets/image4.jpg',
];

class ImageView extends ConsumerWidget {
  const ImageView({required this.image, super.key});
  final ui.Image image;

  Future<ui.Image> getImageGrid() async {
    final images = await loadImages(imagePaths);
    // as per lint, we don't need await, haven't understood.
    return ImageGrid.imageGrid4(
      images[0],
      images[1],
      images[2],
      images[3],
    );
  }

  Future<List<ui.Image>> loadImages(List<String> imagePaths) async {
    final images = <ui.Image>[];
    for (var i = 0; i < 4; i++) {
      final data = await rootBundle.load(imagePaths[i]);
      final codec = await ui.instantiateImageCodec(Uint8List.view(data.buffer));
      final frameInfo = await codec.getNextFrame();
      images.add(frameInfo.image);
    }

    return images;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<ui.Image>(
      future: getImageGrid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading images ${snapshot.error}',
            ),
          );
        } else if (snapshot.hasData) {
          return Center(
            child: CLImageViewer(
              image: snapshot.data!,
            ),
          );
        } else {
          return Container(); // Handle other cases as needed
        }
      },
    );
  }
}
