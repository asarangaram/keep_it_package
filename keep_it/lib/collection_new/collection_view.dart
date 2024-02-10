import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    //print('${widget.index} => should build? $_shouldRender');
    print('${widget.items.collection.label} => ${widget.items.entries.length}');
    if (widget.items.isEmpty) {
      return Container(
        decoration: BoxDecoration(border: Border.all()),
        child: const SizedBox.shrink(),
      );
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
          if (_shouldRender)
            ItemsGridView(
              widget.items,
            )
          else
            PlaceHolderGridView(
              widget.items.entries.length,
              4,
            ),
        ],
      ),
    );
  }
}
