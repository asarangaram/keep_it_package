import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../models/media_handler.dart';
import '../../../providers/gallery_group_provider.dart';
import '../../../widgets/empty_state.dart';
import '../models/types.dart';
import '../providers/media_provider.dart';
import 'universal_media_handler.dart';

class UniversalMediaWatcher extends ConsumerWidget {
  const UniversalMediaWatcher({required this.type, super.key});
  final UniversalMediaTypes type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(universalMediaProvider(type));
    if (media.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return const EmptyState();
    }
    final galleryMap = ref.watch(singleGroupItemProvider(media.entries));

    return FullscreenLayout(
      child: GetDBManager(
        builder: (dbManager) {
          return CLPopScreen.onSwipe(
            child: UniversalMediaHandler(
              galleryMap: galleryMap,
              identifier: type.identifier,
              onDelete: (mediaList) async {
                final mediaHandler = MediaHandler.multiple(
                  media: mediaList,
                  dbManager: dbManager,
                );
                await mediaHandler.delete(context, ref);
                await ref
                    .read(universalMediaProvider(type).notifier)
                    .remove(mediaList);
                return true;
              },
            ),
          );
        },
      ),
    );
  }
}
