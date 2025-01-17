import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/providers/active_collection.dart';

class KeepItBottomBar extends ConsumerWidget {
  const KeepItBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(activeCollectionProvider);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GetCollection(
        id: id,
        errorBuilder: (_, __) => const SizedBox.shrink(),
        loadingBuilder: () => const SizedBox.shrink(),
        builder: (collection) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: ColanPlatformSupport.isMobilePlatform ? 0 : 8,
            ),
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: ServerSpeedDial(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Transform.translate(
                              offset: (ColanPlatformSupport.cameraSupported)
                                  ? const Offset(-10, -20)
                                  : const Offset(0, -20),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withAlpha(200),
                                child: GestureDetector(
                                  onTap: () {
                                    IncomingMediaMonitor.onPickFiles(
                                      context,
                                      ref,
                                      collection: collection,
                                    );
                                  },
                                  child: Icon(
                                    clIcons.insertItem,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                            if (ColanPlatformSupport.cameraSupported)
                              Transform.translate(
                                offset: (ColanPlatformSupport.cameraSupported)
                                    ? const Offset(10, -20)
                                    : Offset.zero,
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withAlpha(200),
                                  child: GestureDetector(
                                    onTap: () {
                                      PageManager.of(context, ref).openCamera(
                                        collectionId: collection?.id,
                                      );
                                    },
                                    child: Icon(
                                      clIcons.camera,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                if (id == null) const StaleMediaIndicatorService(),
              ],
            ),
          );
        },
      ),
    );
  }
}
/**
 * 
const Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ,
                    ),
                  ),
                  if (ColanPlatformSupport.cameraSupported) ...[
                    const SizedBox(
                      width: 16,
                    ),
                    // Right FAB
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: ,
                      ),
                    ),
                  ],
                  const SizedBox.square(),
 */
