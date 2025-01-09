import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'appbar_icons.dart';

class CLPage extends ConsumerStatefulWidget {
  const CLPage({
    required this.children,
    required this.child,
    super.key,
    this.title,
    this.actions,
    this.popupMenuItems,
    this.leading,
    this.appBarBottom,
  });
  final List<Widget> children;
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final List<CLMenuItem>? popupMenuItems;
  final Widget? leading;
  final PreferredSizeWidget? appBarBottom;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CLPageState();
}

class _CLPageState extends ConsumerState<CLPage> {
  final ScrollController _scrollController = ScrollController();
  /* final bool _isAppBarExpanded = true; */
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title == null ? null : Text(widget.title!),
        bottom: widget.appBarBottom,
        toolbarHeight: kMinInteractiveDimension,
        leading: widget.leading,
        /* shadowColor: _isAppBarExpanded ? null : Colors.transparent,
        surfaceTintColor: _isAppBarExpanded ? null : Colors.transparent,
        backgroundColor: _isAppBarExpanded ? null : Colors.transparent, */
        automaticallyImplyLeading: false,
        actions: [
          ...(widget.actions ?? <Widget>[]).map(
            (e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: e,
            ),
          ),
          if (widget.popupMenuItems != null &&
              widget.popupMenuItems!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 32),
              child: PopupMenuButton<CLMenuItem>(
                onSelected: (CLMenuItem item) {
                  item.onTap?.call();
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<CLMenuItem>>[
                    for (final item in widget.popupMenuItems!) ...[
                      PopupMenuItem<CLMenuItem>(
                        value: item,
                        child: ListTile(
                          leading: Icon(item.icon),
                          title: Text(item.title),
                        ),
                      ),
                    ],
                  ];
                },
                child: const Icon(Icons.more_vert),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          ...widget.children,
          Expanded(child: widget.child),
        ],
      )
      /* NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              final isExpanded =
                  scrollNotification.metrics.axis == Axis.vertical &&
                      scrollNotification.metrics.extentBefore == 0;
              if (isExpanded != _isAppBarExpanded) {
                setState(() {
                  _isAppBarExpanded = isExpanded;
                });
              }
            });
          }
          return false;
        },
        child: CustomScrollView(
          // physics: const ClampingScrollPhysics(),
          controller: _scrollController,
          slivers: [
            //...widget.children.map((e) => SliverToBoxAdapter(child: e))
            SliverList(
              delegate: SliverChildListDelegate([
                ...widget.children,
              ]),
            ),

            SliverFillRemaining(
              child: widget.child,
            ),
          ],
        ),
      ) */
      ,
    );
  }
}
