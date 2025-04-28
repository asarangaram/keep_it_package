import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class MediaViewerCore extends StatelessWidget {
  const MediaViewerCore({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return Container(
          padding: EdgeInsets.zero,
          alignment: Alignment.center,

          /* elevation: 1,
          color: Colors.blue,
          shape: RoundedRectangleBorder(),
          margin: EdgeInsets.zero, */
          child: ExtendedImage.network(
            //  'https://picsum.photos/390/844',
            "https://picsum.photos/${constrains.maxWidth.toInt()}/${constrains.maxHeight.toInt()}",
            fit: BoxFit.fill,
          ),
        );
      },
    );
  }
}
