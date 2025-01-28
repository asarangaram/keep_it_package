import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
      child: SafeArea(
        child: GetCollection(
          id: id,
          errorBuilder: (_, __) => const SizedBox.shrink(),
          loadingBuilder: () => CLLoader.hide(
            debugMessage: 'GetCollection',
          ),
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
                        const Expanded(
                          child: SizedBox.shrink(),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ShadButton(
                                icon: Icon(
                                  clIcons.insertItem,
                                  size: 30,
                                ),
                                onPressed: () {
                                  IncomingMediaMonitor.onPickFiles(
                                    context,
                                    ref,
                                    collection: collection,
                                  );
                                },
                              ),
                              if (ColanPlatformSupport.cameraSupported)
                                ShadButton(
                                  icon: Icon(
                                    clIcons.camera,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    PageManager.of(context).openCamera(
                                      collectionId: collection?.id,
                                    );
                                  },
                                ),
                            ],
                          ),
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
