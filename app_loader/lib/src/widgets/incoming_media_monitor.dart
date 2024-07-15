import 'package:app_loader/src/models/on_device_media.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_model/store_model.dart';

import '../models/cl_shared_media.dart';
import '../models/universal_media_source.dart';
import '../providers/incoming_media.dart';

class IncomingMediaMonitor extends ConsumerWidget {
  const IncomingMediaMonitor({
    required this.child,
    required this.onMedia,
    super.key,
  });
  final Widget child;
  final Widget Function(
    BuildContext context, {
    required CLSharedMedia incomingMedia,
    required void Function({required bool result}) onDiscard,
  }) onMedia;

  static void pushMedia(WidgetRef ref, CLSharedMedia sharedMedia) {
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
      final items = <CLMedia>[];
      for (final xfile in pickedFileList) {
        items.add(await OnDeviceMedia.create(xfile.path));
      }

      final sharedMedia = CLSharedMedia(
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
