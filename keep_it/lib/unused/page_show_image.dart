import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class PageShowImage extends ConsumerWidget {
  const PageShowImage({
    required this.imagePath,
    super.key,
  });
  final String imagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CLFullscreenBox(
      child: Center(
        child: CLErrorView(errorMessage: 'Unimplemented'),
      ),
    );

    /* assert(
      false,
      'Untested',
    ); // CLMediaInfo in stack might affect the behaviour
    return CLFullscreenBox(
      child: LoadMedia(
        mediaInfo: CLMediaImage(path: imagePath, type: CLMediaType.image),
        onMediaLoaded: (media) {
          return ImageView(
            image: (media as CLMediaImage).data!,
          );
        },
      ),
    ); */
  }
}
