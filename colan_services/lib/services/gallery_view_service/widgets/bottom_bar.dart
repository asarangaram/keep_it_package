import 'package:colan_services/colan_services.dart';
import 'package:colan_services/services/gallery_view_service/widgets/cl_banner.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/active_collection.dart';

class KeepItBottomBar extends CLBanner {
  const KeepItBottomBar({
    required this.storeIdentity,
    super.key,
  });
  final String storeIdentity;

  @override
  String get widgetLabel => 'bottom bar';

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref, {
    Color? backgroundColor,
    Color? foregroundColor,
    String msg = '',
    void Function()? onTap,
  }) {
    final activeCollection = ref.watch(activeCollectionProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: (ColanPlatformSupport.isMobilePlatform ? 0 : 8) +
            MediaQuery.of(context).padding.bottom,
        top: 4,
        left: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: ShadButton.secondary(
              icon: Icon(
                clIcons.insertItem,
                size: 30,
              ),
              onPressed: () {
                IncomingMediaMonitor.onPickFiles(
                  context,
                  ref,
                  collection: activeCollection,
                );
              },
            ),
          ),
          if (ColanPlatformSupport.cameraSupported)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: ShadButton.secondary(
                  icon: Icon(
                    clIcons.camera,
                    size: 30,
                  ),
                  onPressed: () {
                    PageManager.of(context).openCamera(
                      parentId: activeCollection?.id,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
