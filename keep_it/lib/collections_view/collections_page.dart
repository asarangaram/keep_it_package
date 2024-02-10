// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:store/store.dart';

import '../modules/huge_listview/events.dart';
import '../modules/huge_listview/huge_listview.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';
import 'collection_view.dart';
import 'empty_state.dart';

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
      //header: const Text('This is header'),
      //footer: const Text('This is footer'),
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
      title: 'All Pictures',
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
          itemBuilder: (BuildContext context, int index) {
            final headerWidget =
                CollectionHeader(collection: collections[index]);
            // ignore: unused_local_variable
            final footerWidget =
                CollectionFooter(collection: collections[index]);
            final w = LoadItems(
              collectionID: collections[index].id!,
              buildOnData: (items) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: CollectionView(
                    items,
                    index: index,
                    tagPrefix: widget.tagPrefix,
                    currentIndexStream: Bus.instance
                        .on<GalleryIndexUpdatedEvent>()
                        .where((event) => event.tag == widget.tagPrefix)
                        .map((event) => event.index),
                    headerWidget: headerWidget,
                    //footerWidget: footerWidget,
                  ),
                );
              },
            );
            if (index == 0 && widget.header != null) {
              return Column(
                children: [widget.header!, w],
              );
            }
            if (index == (collections.length - 1) && widget.footer != null) {
              return Column(
                children: [w, widget.footer!],
              );
            }
            return w;
          },
          firstShown: (int firstIndex) {
            Bus.instance
                .fire(GalleryIndexUpdatedEvent(widget.tagPrefix, firstIndex));
          },
        );
      },
    );
  }
}

class CollectionFooter extends StatelessWidget {
  const CollectionFooter({
    required this.collection,
    super.key,
  });

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: CLButtonText.standard(
          'See All',
          onTap: () {
            context.push(
              '/items/${collection.id}',
            );
          },
        ),
      ),
    );
  }
}

class CollectionHeader extends StatelessWidget {
  const CollectionHeader({
    required this.collection,
    super.key,
  });

  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: CLText.large(
              collection.label,
              textAlign: TextAlign.start,
            ),
          ),
          CollectionFooter(
            collection: collection,
          ),
        ],
      ),
    );
  }
}
