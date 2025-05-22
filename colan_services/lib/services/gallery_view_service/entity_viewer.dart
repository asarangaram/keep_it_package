import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../models/platform_support.dart';
import '../basic_page_service/widgets/page_manager.dart';
import 'gallery_view_service.dart';
import 'widgets/popover_menu.dart';
import 'widgets/when_error.dart';

class EntityViewer extends ConsumerWidget {
  const EntityViewer({
    required this.parentIdentifier,
    required this.storeIdentity,
    required this.id,
    super.key,
  });
  final String parentIdentifier;
  final String storeIdentity;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = id;
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: parentId.toString(),
    );
    Widget errorBuilder(Object e, StackTrace st) => Scaffold(
          body: WhenError(
            errorMessage: e.toString(),
          ),
        );
    return AppTheme(
      child: OnSwipe(
        child: GetEntity(
          id: id,
          storeIdentity: storeIdentity,
          errorBuilder: errorBuilder,
          loadingBuilder: () =>
              Scaffold(body: CLLoader.widget(debugMessage: 'GetEntity')),
          builder: (parent) {
            return GetEntities(
              parentId: id,
              storeIdentity: storeIdentity,
              errorBuilder: errorBuilder,
              loadingBuilder: () =>
                  Scaffold(body: CLLoader.widget(debugMessage: 'GetEntities')),
              builder: (childrens) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      parent?.data.label!.capitalizeFirstLetter() ?? 'Keep It',
                      style: ShadTheme.of(context).textTheme.h1,
                    ),
                    actions: [
                      if (!ColanPlatformSupport.isMobilePlatform)
                        ShadButton.ghost(
                          onPressed: ref.read(reloadProvider.notifier).reload,
                          child: const Icon(LucideIcons.refreshCcw),
                        ),
                      if (childrens.isNotEmpty)
                        PopOverMenu(viewIdentifier: viewIdentifier)
                      else
                        ShadButton.ghost(
                          onPressed: () =>
                              PageManager.of(context).openSettings(),
                          child: const Icon(LucideIcons.settings),
                        ),
                    ],
                  ),
                  body: OnSwipe(
                    child: SafeArea(
                      bottom: false,
                      child: GalleryViewService0(
                        parentIdentifier: parentIdentifier,
                        storeIdentity: storeIdentity,
                        parent: parent,
                        entities: childrens,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
