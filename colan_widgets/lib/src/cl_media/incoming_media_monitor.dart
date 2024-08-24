import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import 'incoming_media.dart';

class IncomingMediaMonitor extends ConsumerWidget {
  const IncomingMediaMonitor({
    required this.child,
    required this.onMedia,
    super.key,
  });
  final Widget child;
  final Widget Function(
    BuildContext context, {
    required CLMediaFileGroup incomingMedia,
    required void Function({required bool result}) onDiscard,
  }) onMedia;

  static void pushMedia(WidgetRef ref, CLMediaFileGroup sharedMedia) {
    ref.read(incomingMediaStreamProvider.notifier).push(sharedMedia);
  }

  static Future<bool> onPickFiles(
    BuildContext context,
    WidgetRef ref, {
    Collection? collection,
  }) async {
    final picker = ImagePicker();
    final pickedFileList = await picker.pickMultipleMedia();

    if (pickedFileList.isNotEmpty) {
      final items = pickedFileList
          .map(
            (xfile) => CLMediaBase(
              name: xfile.path,
              type: CLMediaType.file,
              fExt: path_handler.extension(xfile.path),
            ),
          )
          .toList();
      final sharedMedia = CLMediaFileGroup(
        entries: items,
        collection: collection,
        type: UniversalMediaSource.filePick,
      );

      if (items.isNotEmpty) {
        IncomingMediaMonitor.pushMedia(ref, sharedMedia);
      }

      return items.isNotEmpty;
    } else {
      return false;
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingMedia = ref.watch(incomingMediaStreamProvider);
    if (incomingMedia.isEmpty) {
      return child;
    }
    return onMedia(
      context,
      incomingMedia: incomingMedia[0],
      onDiscard: ({required bool result}) {
        ref.read(incomingMediaStreamProvider.notifier).pop();
      },
    );
  }
}
