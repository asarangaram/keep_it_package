import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../view_modifiers/providers/view_modifiers.dart';
import '../models/filters.dart';
import '../providers/filters.dart';
import 'filters_view.dart';

class PopOverMenu extends ConsumerStatefulWidget {
  const PopOverMenu({super.key, this.parentIdentifier = 'default'});
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
    final filters = ref.watch(filtersProvider);
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
                  SearchFilters _ => FiltersView(
                      filters: filters.filters,
                    ),
                  GroupBy _ =>
                    Text(popOverMenuItems.currItem?.name ?? 'unknown'),
                  _ => throw UnimplementedError(),
                },
              ),
            ],
          ),
        ),
      ),
      child: ShadButton.outline(
        onPressed: popoverController.toggle,
        child: const Badge(
          child: Icon(LucideIcons.menu),
        ),
      ),
    );
  }
}
