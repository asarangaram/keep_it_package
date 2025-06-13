import 'package:colan_services/internal/cl_banner.dart';

import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';
import 'package:store_tasks/store_tasks.dart';

import '../../basic_page_service/widgets/page_manager.dart';

class StaleMediaBanner extends CLBanner {
  const StaleMediaBanner({
    required this.serverId,
    super.key,
  });
  final String serverId;

  @override
  String get widgetLabel => 'StaleMediaBanner';

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref, {
    Color? backgroundColor,
    Color? foregroundColor,
    String msg = '',
    void Function()? onTap,
  }) {
    return GetStoreTaskManager(
        contentOrigin: ContentOrigin.stale,
        builder: (staleTaskManager) {
          return GetEntities(
            isHidden: true,
            isCollection: false,
            parentId: 0,
            errorBuilder: errorBuilder,
            loadingBuilder: loadingBuilder,
            builder: (staleMedia) {
              return super.build(
                context,
                ref,
                msg: staleMedia.isEmpty
                    ? ''
                    : 'You have ${staleMedia.length} unclassified media. '
                        'Tap here to show',
                onTap: () async {
                  staleTaskManager.add(StoreTask(
                    items: staleMedia.entities.cast<StoreEntity>(),
                    contentOrigin: ContentOrigin.stale,
                  ));
                  await PageManager.of(context).openWizard(ContentOrigin.stale);
                },
              );
            },
          );
        });
  }
}
