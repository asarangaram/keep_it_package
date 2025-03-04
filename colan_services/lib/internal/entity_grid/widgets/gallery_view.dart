import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../providers/tap_state.dart';
import 'gallery_tab.dart';

class RawCLEntityGalleryView extends ConsumerStatefulWidget {
  const RawCLEntityGalleryView({
    required this.viewIdentifier,
    required this.tabs,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    required this.columns,
    super.key,
    this.draggableMenuBuilder,
  });
  final ViewIdentifier viewIdentifier;
  final List<LabelledEntityGroups> tabs;

  final Widget Function(BuildContext context, CLEntity item) itemBuilder;

  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupCLEntity<CLEntity>>,
  ) bannersBuilder;
  final int columns;
  final Widget Function(
    BuildContext context, {
    required GlobalKey<State<StatefulWidget>> parentKey,
  })? draggableMenuBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RawCLEntityGalleryViewState();
}

class _RawCLEntityGalleryViewState
    extends ConsumerState<RawCLEntityGalleryView> {
  final GlobalKey parentKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    final viewIdentifier = widget.viewIdentifier;
    final itemBuilder = widget.itemBuilder;
    final labelBuilder = widget.labelBuilder;
    final bannersBuilder = widget.bannersBuilder;
    final columns = widget.columns;
    final draggableMenuBuilder = widget.draggableMenuBuilder;
    final Widget gallery;
    if (tabs.length == 1) {
      gallery = CLEntityGalleryTab(
        tabIdentifier:
            TabIdentifier(view: viewIdentifier, tabId: tabs.first.name),
        tab: tabs.first,
        itemBuilder: itemBuilder,
        labelBuilder: labelBuilder,
        bannersBuilder: bannersBuilder,
        columns: columns,
      );
    } else {
      final laskKnownTabName = ref.watch(currTabProvider(viewIdentifier));
      final LabelledEntityGroups currTab;
      final tempCurrTab =
          tabs.where((e) => e.name == laskKnownTabName).firstOrNull;
      if (tempCurrTab == null) {
        currTab = tabs.first;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          ref.read(currTabProvider(viewIdentifier).notifier).state =
              currTab.name;
        });
      } else {
        currTab = tempCurrTab;
      }
      gallery = Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ShadTabs(
            padding: EdgeInsets.zero,
            value: currTab.name,
            expandContent: false,
            // tabBarConstraints: BoxConstraints(maxWidth: 400),
            //contentConstraints: BoxConstraints(maxWidth: 400),
            onChanged: (value) {
              ref.read(currTabProvider(viewIdentifier).notifier).state = value;
            },
            tabs: [
              for (final k in tabs)
                ShadTab(
                  value: k.name,
                  padding: EdgeInsets.zero,
                  child: Text(k.name),
                ),
            ],
          ),
          Flexible(
            child: CLEntityGalleryTab(
              tabIdentifier:
                  TabIdentifier(view: viewIdentifier, tabId: currTab.name),
              tab: currTab,
              itemBuilder: itemBuilder,
              labelBuilder: labelBuilder,
              bannersBuilder: bannersBuilder,
              columns: columns,
            ),
          ),
        ],
      );
    }

    return Stack(
      key: parentKey,
      children: [
        gallery,
        if (draggableMenuBuilder != null)
          draggableMenuBuilder(context, parentKey: parentKey),
      ],
    );
  }
}
