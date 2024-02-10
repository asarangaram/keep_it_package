import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import 'items_gridview.dart';
import 'placeholder_gridview.dart';

class CollectionView extends ConsumerStatefulWidget {
  const CollectionView(
    this.items, {
    required this.tagPrefix,
    required this.index,
    required this.currentIndexStream,
    super.key,
  });
  final Items items;
  final int index;
  final String tagPrefix;
  final Stream<int> currentIndexStream;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CollectionViewState();
}

class _CollectionViewState extends ConsumerState<CollectionView> {
  static const numberOfGroupsToRenderBeforeAndAfter = 8;
  bool _shouldRender = false;
  late StreamSubscription<int> _currentIndexSubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _currentIndexSubscription.cancel();
    super.dispose();
  }

  bool getShouldRender(int currentIndex) {
    return (currentIndex - widget.index).abs() <
        numberOfGroupsToRenderBeforeAndAfter;
  }

  void init() {
    _shouldRender = getShouldRender(0);

    _currentIndexSubscription =
        widget.currentIndexStream.listen((currentIndex) {
      //print('$currentIndex,${widget.index}');
      final shouldRender = getShouldRender(currentIndex);
      if (mounted && shouldRender != _shouldRender) {
        setState(() {
          _shouldRender = shouldRender;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: CLText.large(
                    widget.items.collection.label,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          if (_shouldRender) ...[
            CLMediaGridView(
              label: widget.items.collection.label,
              items: widget.items.entries,
              rows: 2,
              additionalItems: [
                CLButtonIcon.standard(
                  MdiIcons.fileImagePlus,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .reduceBrightness(0.7),
                  onTap: () async {
                    await onPickFiles(
                      context,
                      ref,
                      collectionId: widget.items.collection.id,
                    );
                  },
                ),
              ],
            ),
          ] else
            PlaceHolderGridView(widget.items.entries.length),
          Align(
            alignment: Alignment.centerRight,
            child: CLButtonText.standard(
              'See All',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
