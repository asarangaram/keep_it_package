import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'views/image_view.dart';
import 'views/load_from_store/load_image.dart';

class PageShowImage extends ConsumerWidget {
  const PageShowImage({
    super.key,
    required this.imagePath,
  });
  final String imagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(
      child: LoadMediaImage(
        mediaEntry: MapEntry(imagePath, CLMediaType.image),
        onImageLoaded: (image) {
          return ImageView(
            image: image,
          );
        },
      ),
    );
  }
}
