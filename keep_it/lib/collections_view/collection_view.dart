import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'items_gridview.dart';
import 'placeholder_gridview.dart';

class CollectionView extends ConsumerStatefulWidget {
  const CollectionView(
    this.items, {
    required this.tagPrefix,
    required this.index,
    required this.currentIndexStream,
    super.key,
    this.headerWidget,
    this.footerWidget,
  });
  final Items items;
  final int index;
  final String tagPrefix;
  final Stream<int> currentIndexStream;
  final Widget? headerWidget;
  final Widget? footerWidget;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CollectionViewState();
}

class _CollectionViewState extends ConsumerState<CollectionView> {
  static const numberOfGroupsToRenderBeforeAndAfter = 8;
  bool _shouldRender = true;
  bool _isVisible = false;
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
            numberOfGroupsToRenderBeforeAndAfter ||
        _isVisible;
  }

  void init() {
    _shouldRender = getShouldRender(0) || mounted;

    _currentIndexSubscription =
        widget.currentIndexStream.listen((currentIndex) {
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
    return VisibilityDetector(
      key: ValueKey('VisibilityDetector ${widget.items.collection.label}'),
      onVisibilityChanged: (info) {
        if (mounted && !_shouldRender && info.visibleFraction > 0.0) {
          setState(() {
            _shouldRender = true;
            _isVisible = true;
          });
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.headerWidget != null) widget.headerWidget!,
          if (_shouldRender)
            CLMediaGridView(
              label: widget.items.collection.label,
              items: widget.items.entries,
              physics: const NeverScrollableScrollPhysics(),
              rows: 2,
            )
          else
            PlaceHolderGridView(widget.items.entries.length),
          if (widget.footerWidget != null) widget.footerWidget!,
        ],
      ),
    );
  }
}
