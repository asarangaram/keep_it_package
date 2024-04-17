import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../notification_services/provider/notify.dart';
import '../../preview_service/view/preview.dart';
import '../providers/captured_media.dart';

class CameraIOHandler extends ConsumerWidget {
  const CameraIOHandler({
    required this.builder,
    required this.collection,
    required this.onDone,
    required this.onReceiveCapturedMedia,
    super.key,
  });

  final Collection? collection;
  final Widget Function({
    required void Function(String, {required bool isVideo}) onCapture,
    required void Function(String message, {required dynamic error})? onError,
    required Widget previewWidget,
  }) builder;
  final VoidCallback onDone;
  final Future<bool> Function(
    BuildContext context,
    WidgetRef ref, {
    required List<CLMedia> entries,
    Collection? collection,
  }) onReceiveCapturedMedia;

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
                    return CLConfirmAction(
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
              onDone();
            }
          } else {
            onDone();
          }
        }
      },
      child: builder(
        onError: (message, {required error}) {
          ref
              .read(notificationMessageProvider.notifier)
              .push('$message: $error');
        },
        onCapture: (path, {required isVideo}) {
          ref.read(capturedMediaProvider.notifier).add(
                CLMedia(
                  path: path,
                  type: isVideo ? CLMediaType.video : CLMediaType.image,
                ),
              );
        },
        previewWidget: InkWell(
          onTap: () async {
            await onReceiveCapturedMedia(
              context,
              ref,
              entries: capturedMedia,
              collection: collection,
            );
            ref.read(capturedMediaProvider.notifier).clear();
            onDone();
          },
          child: capturedMedia.isEmpty
              ? Container()
              : CapturedMediaDecorator(
                  child: PreviewService(
                    media: capturedMedia.last,
                    keepAspectRatio: false,
                  ),
                ),
        ),
      ),
    );
  }
}

class CapturedMediaDecorator extends StatelessWidget {
  const CapturedMediaDecorator({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          8,
        ),
        child: child,
      ),
    );
  }
}
