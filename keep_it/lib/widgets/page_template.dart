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
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: widget.title == null ? null : Text(widget.title!),
            pinned: true,
            bottom: widget.appBarBottom,

            expandedHeight: 0, // No expanded content
            collapsedHeight: 30,
            toolbarHeight: 30,
            leading: widget.leading ?? const Icon(Icons.abc),
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,

            actions: [
              ...(widget.actions ?? <Widget>[]),
              if (widget.popupMenuItems != null &&
                  widget.popupMenuItems!.isNotEmpty)
                PopupMenuButton<CLMenuItem>(
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
            ],
          ),
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
    );
  }
}

class LeadingIcon extends ConsumerWidget {
  const LeadingIcon({required this.menuItem, super.key});
  final CLMenuItem menuItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCollection = ref.watch(activeCollectionProvider);
    if (activeCollection == null) {
      return const SizedBox.shrink();
    }
    return CLButtonIcon.standard(
      menuItem.icon,
      onTap: () {
        ref.read(activeCollectionProvider.notifier).state = null;
      },
    );
  }
}
