import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../providers/tap_state.dart';
import 'gallery_tab.dart';

/// GalleryView has one or more tabs.
class RawCLEntityGalleryView extends ConsumerWidget {
  const RawCLEntityGalleryView({
    required this.viewIdentifier,
    required this.tabs,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    required this.numColumns,
    super.key,
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
  final int numColumns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tabs.length == 1) {
      return CLEntityGalleryTab(
        tabIdentifier:
            TabIdentifier(view: viewIdentifier, tabId: tabs.first.name),
        tab: tabs.first,
        itemBuilder: itemBuilder,
        labelBuilder: labelBuilder,
        bannersBuilder: bannersBuilder,
        columns: numColumns,
      );
    }

    final laskKnownTabName = ref.watch(currTabProvider(viewIdentifier));
    final LabelledEntityGroups currTab;
    final tempCurrTab =
        tabs.where((e) => e.name == laskKnownTabName).firstOrNull;
    if (tempCurrTab == null) {
      currTab = tabs.first;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(currTabProvider(viewIdentifier).notifier).state = currTab.name;
      });
    } else {
      currTab = tempCurrTab;
    }

    return Column(
      children: [
        ShadTabs(
          padding: EdgeInsets.zero,
          value: currTab.name,
          // tabBarConstraints: BoxConstraints(maxWidth: 400),
          //contentConstraints: BoxConstraints(maxWidth: 400),
          onChanged: (value) {
            ref.read(currTabProvider(viewIdentifier).notifier).state = value;
          },
          tabs: [
            for (final k in tabs)
              ShadTab(
                value: k.name,
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
            columns: numColumns,
          ),
        ),
      ],
    );
  }
}
