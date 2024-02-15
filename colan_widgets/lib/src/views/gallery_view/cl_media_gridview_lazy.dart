import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cl_media_gridview.dart';
import 'placeholder_gridview.dart';

class CLMediaGridViewLazy extends ConsumerStatefulWidget {
  const CLMediaGridViewLazy({
    required this.mediaList,
    required this.currentIndexStream,
    required this.index,
    required this.onTapMedia,
    this.additionalItems,
    this.columns = 4,
    this.rows,
    this.physics = const NeverScrollableScrollPhysics(),
    this.header,
    this.footer,
    this.crossAxisSpacing = 2.0,
    this.mainAxisSpacing = 2.0,
    super.key,
  });

  final List<CLMedia> mediaList;
  final List<Widget>? additionalItems;
  final int columns;
  final int? rows;
  final ScrollPhysics? physics;
  final Widget? header;
  final Widget? footer;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final void Function(CLMedia media)? onTapMedia;

  final int index;
  final Stream<int> currentIndexStream;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CollectionViewState();
}

class _CollectionViewState extends ConsumerState<CLMediaGridViewLazy> {
  static const numberOfGroupsToRenderBeforeAndAfter = 8;
  bool _shouldRender = true;
  final bool _isVisible = false;
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
    if (_shouldRender) {
      return CLMediaGridView(
        mediaList: widget.mediaList,
        additionalItems: widget.additionalItems,
        columns: widget.columns,
        rows: widget.rows,
        physics: widget.physics,
        header: widget.header,
        footer: widget.footer,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        onTapMedia: widget.onTapMedia,
      );
    }

    if (widget.mediaList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null) widget.header!,
        PlaceHolderGridView(widget.mediaList.length),
        if (widget.footer != null) widget.footer!,
      ],
    );
  }
}
