// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:store/store.dart';

import '../collections_view/collection_view.dart';
import '../collections_view/empty_state.dart';
import '../modules/huge_listview/events.dart';
import '../modules/huge_listview/huge_listview.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';

class TimeLinePage extends ConsumerWidget {
  const TimeLinePage({required this.collectionID, super.key});
  final int collectionID;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadItems(
        collectionID: collectionID,
        buildOnData: (items) {
          return TimeLineView(
            Items(entries: items.images, collection: items.collection),
          );
        },
      );
}

class TimeLineView extends ConsumerWidget {
  const TimeLineView(this.items, {super.key});
  final Items items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TimeLineView(
      collection: items.collection,
      itemsMap: items.filterByDate(),
      emptyState: const EmptyState(),
      tagPrefix: 'timeline ${items.collection.id}',
    );
  }
}

class _TimeLineView extends ConsumerStatefulWidget {
  const _TimeLineView({
    required this.itemsMap,
    required this.collection,
    required this.emptyState,
    required this.tagPrefix,
    this.header,
    this.footer,
  });
  final Collection collection;
  final Map<String, Items> itemsMap;

  final Widget? header;
  final Widget? footer;
  final Widget emptyState;
  final String tagPrefix;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimeLineViewState();
}

class _TimeLineViewState extends ConsumerState<_TimeLineView> {
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
    final itemsMap = widget.itemsMap;
    final dates = itemsMap.keys.toList();
    return KeepItMainView(
      title: widget.collection.label,
      onPop: context.canPop()
          ? () {
              context.pop();
            }
          : null,
      actionsBuilder: [
        (context, quickMenuScopeKey) => CLButtonIcon.standard(
              Icons.add,
              onTap: () async {
                await onPickFiles(
                  context,
                  ref,
                  collectionId: widget.collection.id,
                );
              },
            ),
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        return HugeListView<List<Collection>>(
          startIndex: 0,
          totalCount: itemsMap.entries.length,
          labelTextBuilder: (index) => dates[index],
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
                TimeLineHeader(dates[index], itemsMap[dates[index]]!);
            // ignore: unused_local_variable
            final footerWidget =
                TimeLineFooter(dates[index], itemsMap[dates[index]]!);
            final w = Padding(
              padding: const EdgeInsets.all(8),
              child: CollectionView(
                itemsMap[dates[index]]!,
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
            if (index == 0 && widget.header != null) {
              return Column(
                children: [widget.header!, w],
              );
            }
            if (index == (itemsMap.length - 1) && widget.footer != null) {
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

class TimeLineFooter extends StatelessWidget {
  const TimeLineFooter(
    this.label,
    this.items, {
    super.key,
  });

  final String label;
  final Items items;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TimeLineHeader extends StatelessWidget {
  const TimeLineHeader(
    this.label,
    this.items, {
    super.key,
  });

  final String label;
  final Items items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: CLText.large(
              label,
              textAlign: TextAlign.start,
            ),
          ),
          TimeLineFooter(
            label,
            items,
          ),
        ],
      ),
    );
  }
}
