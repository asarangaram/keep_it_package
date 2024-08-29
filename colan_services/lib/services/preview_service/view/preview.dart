import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/broken_image.dart';
import '../../image_view_service/image_view.dart';

class PreviewService extends StatelessWidget {
  const PreviewService({
    required this.media,
    this.keepAspectRatio = true,
    super.key,
  });
  final CLMedia media;
  final bool keepAspectRatio;

  @override
  Widget build(BuildContext context) {
    final fit = keepAspectRatio ? BoxFit.contain : BoxFit.cover;

    return GetStoreManager(
      builder: (theStore) {
        final file = File(theStore.getMediaPath(media));
        if (media.type.isFile && !file.existsSync()) {
          //throw Exception('File not found ${media.path}');
          return const BrokenImage();
        }

        return KeepAspectRatio(
          keepAspectRatio: keepAspectRatio,
          child: switch (media.type) {
            CLMediaType.image || CLMediaType.video => FutureBuilder(
                future: AlbumManager.isPinBroken(media.pin),
                builder: (context, snapshot) {
                  return ImageViewerBasic(
                    file: file,
                    fit: fit,
                    isPinned: media.pin != null,
                    isPinBroken: snapshot.data ?? false,
                    overlayIcon: (media.type == CLMediaType.video)
                        ? Icons.play_arrow_sharp
                        : null,
                  );
                },
              ),
            _ => const BrokenImage()
          },
        );
      },
    );
  }
}

class GreyShadowShimmerContainer extends StatelessWidget {
  const GreyShadowShimmerContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Shimmering',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class KeepAspectRatio extends StatelessWidget {
  const KeepAspectRatio({
    required this.child,
    super.key,
    this.keepAspectRatio = true,
    this.aspectRatio,
  });
  final bool keepAspectRatio;
  final Widget child;
  final double? aspectRatio;
  @override
  Widget build(BuildContext context) {
    if (keepAspectRatio) return child;
    return AspectRatio(
      aspectRatio: aspectRatio ?? 1,
      child: child,
    );
  }
}
