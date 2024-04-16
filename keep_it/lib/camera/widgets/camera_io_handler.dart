import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/folders_and_files/media_as_file.dart';
import '../providers/captured_media.dart';

class CameraIOHandler extends ConsumerWidget {
  const CameraIOHandler({
    required this.builder,
    super.key,
  });

  final Widget Function(
    void Function(String, {required bool isVideo}) onCapture,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    return GestureDetector(
      onHorizontalDragEnd: (details) async {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (capturedMedia.isNotEmpty) {
            final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmAction(
                      title: 'Discard?',
                      message: 'Do you want to discard all '
                          'the images and video captured?',
                      child: null,
                      onConfirm: ({required confirmed}) =>
                          Navigator.of(context).pop(confirmed),
                    );
                  },
                ) ??
                false;
            if (confirmed) {
              ref.read(capturedMediaProvider.notifier).onDiscard();
              if (context.mounted) {
                if (context.canPop()) {
                  context.pop();
                }
              }
            }
          } else {
            if (context.canPop()) {
              context.pop();
            }
          }
        }
      },
      child: builder((path, {required isVideo}) {
        ref.read(capturedMediaProvider.notifier).add(
              CLMedia(
                path: path,
                type: isVideo ? CLMediaType.video : CLMediaType.image,
              ),
            );
      }),
    );
  }
}
