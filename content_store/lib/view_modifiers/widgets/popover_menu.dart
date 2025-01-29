import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../media_grouper/models/grouper.dart';
import '../../media_grouper/widgets/group_by_view.dart';
import '../../search_filters/models/filters.dart';
import '../../search_filters/widgets/filters_view.dart';
import '../providers/view_modifiers.dart';

class PopOverMenu extends ConsumerStatefulWidget {
  const PopOverMenu({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  ConsumerState<PopOverMenu> createState() => _PopoverPageState();
}

class _PopoverPageState extends ConsumerState<PopOverMenu> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popOverMenuItems =
        ref.watch(popOverMenuProvider(widget.parentIdentifier));
    return ShadPopover(
      controller: popoverController,
      popover: (_) => SizedBox(
        width: 288,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShadTabs(
                value: popOverMenuItems.currItem?.name,
                onChanged: (value) => ref
                    .read(popOverMenuProvider(widget.parentIdentifier).notifier)
                    .updateCurr(value),
                tabs: popOverMenuItems.items
                    .map(
                      (e) => ShadTab(
                        value: e.name,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: e.name,
                                style: ShadTheme.of(context).textTheme.small,
                              ),
                              if (e.isActive)
                                TextSpan(
                                  text: '*',
                                  style: ShadTheme.of(context)
                                      .textTheme
                                      .blockquote
                                      .copyWith(
                                        color: ShadTheme.of(context)
                                            .colorScheme
                                            .destructive,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 100),
                child: switch (popOverMenuItems.currItem) {
                  SearchFilters<CLMedia> _ => FiltersView(
                      parentIdentifier: widget.parentIdentifier,
                      filters:
                          (popOverMenuItems.currItem! as SearchFilters<CLMedia>)
                              .filters,
                    ),
                  GroupBy _ => GroupByView(
                      parentIdentifier: widget.parentIdentifier,
                      groupBy: popOverMenuItems.currItem! as GroupBy,
                    ),
                  _ => throw UnimplementedError(),
                },
              ),
            ],
          ),
        ),
      ),
      child: ShadButton.ghost(
        onPressed: popoverController.toggle,
        child: Icon(
          LucideIcons.menu,
          color: popOverMenuItems.items.any((e) => e.isActive)
              ? ShadTheme.of(context).colorScheme.destructive
              : null,
        ),
      ),
    );
  }
}
