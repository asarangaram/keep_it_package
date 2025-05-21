import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../builders/get_view_modifiers.dart';
import '../builders/media_grouper.dart';
import '../models/filter/filters.dart';
import '../models/tab_identifier.dart';
import '../../common/models/viewer_entity_mixin.dart';
import 'filters/filters_view.dart';
import 'group_by_view.dart';

class ViewModifierSettings extends StatefulWidget {
  const ViewModifierSettings({required this.viewIdentifier, super.key});
  final ViewIdentifier viewIdentifier;

  @override
  State<StatefulWidget> createState() => _ViewModifierSettingsState();
}

class _ViewModifierSettingsState extends State<ViewModifierSettings> {
  int currIndex = 0;
  @override
  Widget build(BuildContext context) {
    return GetViewModifiers(
      viewIdentifier: widget.viewIdentifier,
      builder: (items) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadTabs(
              value: currIndex,
              onChanged: (val) => setState(() {
                currIndex = val;
              }),
              tabs: items
                  .mapIndexed(
                    (i, e) => ShadTab(
                      value: i,
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
              child: switch (currIndex) {
                0 => FiltersView(
                    parentIdentifier: widget.viewIdentifier.parentID,
                    filters:
                        (items[0] as SearchFilters<ViewerEntityMixin>).filters,
                  ),
                1 => GroupByView(
                    viewIdentifier: widget.viewIdentifier,
                    groupBy: items[1] as GroupBy,
                  ),
                _ => throw UnimplementedError(),
              },
            ),
          ],
        );
      },
    );
  }
}
