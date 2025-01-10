import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../builders/get_main_view_entities.dart';
import '../builders/grouper.dart';
import '../widgets/action_icons.dart';

import '../widgets/entity_grid.dart';
import '../widgets/utils/error_view.dart';
import '../widgets/utils/loading_view.dart';

class MainViewPage extends ConsumerWidget {
  const MainViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget errorBuilder(Object e, StackTrace st) =>
        ErrorView(error: e, stackTrace: st);
    const Widget loadingWidget = LoadingView();
    return AppTheme(
      child: Scaffold(
        appBar: AppBar(
          title: const MainViewTitle(),
          leading: const MainViewLeading(),
          automaticallyImplyLeading: false,
          actions: [
            const GroupAction(),
            const SelectControlIcon(),
            const SearchIcon(),
            const FileSelectAction(),
            if (ColanPlatformSupport.cameraSupported) const CameraAction(),
            const ExtraActions(),
          ],
        ),
        body: Column(
          children: [
            const SearchOptions(),
            Expanded(
              child: GetStore(
                builder: (store) {
                  return RefreshIndicator(
                    onRefresh: /* isSelectionMode ? null : */ () async =>
                        store.reloadStore(),
                    child: GetMainViewEntities(
                      loadingBuilder: () => loadingWidget,
                      errorBuilder: errorBuilder,
                      builder: (entities) => EntityGrid(
                        entities: entities,
                        loadingBuilder: () => loadingWidget,
                        errorBuilder: errorBuilder,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
