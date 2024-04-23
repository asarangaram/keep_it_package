import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

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
    required Future<void> Function(String, {required bool isVideo}) onCapture,
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
    return GetDBManager(
      builder: (dbManager) {
        return SafeExit(
          onDone: onDone,
          child: builder(
            onError: (message, {required error}) {
              ref
                  .read(notificationMessageProvider.notifier)
                  .push('$message: $error');
            },
            onCapture: (path, {required isVideo}) async {
              final md5String = await File(path).checksum;
              CLMedia? media = CLMedia(
                path: path,
                type: isVideo ? CLMediaType.video : CLMediaType.image,
                collectionId: collection?.id,
                md5String: md5String,
              );
              if (collection != null) {
                media = await dbManager.upsertMedia(
                  collectionId: collection!.id!,
                  media: media,
                  onPrepareMedia: (m, {required targetDir}) async {
                    final updated =
                        (await m.moveFile(targetDir: targetDir)).getMetadata();
                    return updated;
                  },
                );
                if (media == null) {
                  throw Exception('Failed to store Media');
                } else if (!File(media.path).existsSync()) {
                  print('Soemthing seems wrong here!!!');
                }
              }

              ref.read(capturedMediaProvider.notifier).add(media);
            },
            previewWidget: PreviewCapturedMedia(
              sendMedia: (mediaList) async {
                if (collection == null) {
                  await onReceiveCapturedMedia(
                    context,
                    ref,
                    entries: mediaList,
                    collection: collection,
                  );
                }
                ref.read(capturedMediaProvider.notifier).clear();
                onDone();
              },
            ),
          ),
        );
      },
    );
  }
}

class SafeExit extends ConsumerWidget {
  const SafeExit({required this.onDone, required this.child, super.key});
  final VoidCallback onDone;
  final Widget child;

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
      child: child,
    );
  }
}

class PreviewCapturedMedia extends ConsumerWidget {
  const PreviewCapturedMedia({required this.sendMedia, super.key});
  final Future<void> Function(List<CLMedia>) sendMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    return InkWell(
      onTap: () => sendMedia(capturedMedia),
      child: capturedMedia.isEmpty
          ? Container()
          : CapturedMediaDecorator(
              child: PreviewService(
                media: capturedMedia.last,
                keepAspectRatio: false,
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
