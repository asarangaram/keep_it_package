import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:store/store.dart';

import '../collection_new/collection_view.dart';
import '../collection_new/empty_state.dart';
import '../huge_listview/events.dart';
import '../huge_listview/huge_listview.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key, this.tagId});
  final int? tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      LoadCollections(tagId: tagId, buildOnData: CollectionsView.new);
}

class CollectionsView extends ConsumerWidget {
  const CollectionsView(this.collections, {super.key});
  final Collections collections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CollectionsView(
      collections.entries,
      emptyState: const EmptyState(),
      header: Container(),
      footer: Container(),
      tagPrefix: 'collections_home',
    );
  }
}

class _CollectionsView extends ConsumerStatefulWidget {
  const _CollectionsView(
    this.collections, {
    required this.emptyState,
    required this.tagPrefix,
    this.header,
    this.footer,
  });
  final List<Collection> collections;

  final Widget? header;
  final Widget? footer;
  final Widget emptyState;
  final String tagPrefix;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsViewState();
}

class _CollectionsViewState extends ConsumerState<_CollectionsView> {
  // ignore: unused_field
  late ItemScrollController _itemScroller;
  @override
  void initState() {
    _itemScroller = ItemScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collections = widget.collections;
    return KeepItMainView(
      title: 'Label',
      onPop: context.canPop()
          ? () {
              context.pop();
            }
          : null,
      actionsBuilder: [
        (context, quickMenuScopeKey) => CLButtonIcon.standard(
              Icons.add,
              onTap: () async {
                await onPickFiles(context, ref);
              },
            ),
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        return HugeListView<List<Collection>>(
          startIndex: 0,
          totalCount: collections.length,
          labelTextBuilder: (index) => collections[index].label,
          emptyResultBuilder: (_) {
            final children = <Widget>[];
            if (widget.header != null) {
              children.add(widget.header!);
            }
            children.add(
              Expanded(
                child: widget.emptyState,
              ),
            );
            if (widget.footer != null) {
              children.add(widget.footer!);
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            );
          },
          itemBuilder: (BuildContext context, int index) => LoadItems(
            collectionID: collections[index].id!,
            buildOnData: (items) {
              return CollectionView(
                items,
                index: index,
                tagPrefix: widget.tagPrefix,
                currentIndexStream: Bus.instance
                    .on<GalleryIndexUpdatedEvent>()
                    .where((event) => event.tag == widget.tagPrefix)
                    .map((event) => event.index),
              );
            },
          ),
          firstShown: (int firstIndex) {
            Bus.instance
                .fire(GalleryIndexUpdatedEvent(widget.tagPrefix, firstIndex));
          },
        );
      },
    );
  }
}
