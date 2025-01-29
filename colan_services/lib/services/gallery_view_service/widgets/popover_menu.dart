import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../basic_page_service/widgets/page_manager.dart';

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
    return GetPopOverMenuItems(
      parentIdentifier: widget.parentIdentifier,
      builder: (popOverMenuItems, {required updateCurr}) {
        return ShadPopover(
          controller: popoverController,
          popover: (_) => SizedBox(
            width: 288,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShadButton.ghost(
                      onPressed: popoverController.hide,
                      child: const Icon(LucideIcons.check, size: 25),
                    ),
                    ShadButton.ghost(
                      onPressed: () => PageManager.of(context)
                          .openSettings()
                          .then((val) => popoverController.hide()),
                      child: const Icon(LucideIcons.settings, size: 25),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShadTabs(
                        value: popOverMenuItems.currItem?.name,
                        onChanged: (value) => updateCurr(value),
                        tabs: popOverMenuItems.items
                            .map(
                              (e) => ShadTab(
                                value: e.name,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: e.name,
                                        style: ShadTheme.of(context)
                                            .textTheme
                                            .small,
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
                              filters: (popOverMenuItems.currItem!
                                      as SearchFilters<CLMedia>)
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
              ],
            ),
          ),
          child: ShadButton.ghost(
            padding: const EdgeInsets.only(right: 8),
            onPressed: popoverController.toggle,
            child: Icon(
              LucideIcons.menu,
              color: popOverMenuItems.items.any((e) => e.isActive)
                  ? ShadTheme.of(context).colorScheme.destructive
                  : null,
            ),
          ),
        );
      },
    );
  }
}
