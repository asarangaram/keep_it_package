import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CollectionAnchor extends ConsumerWidget {
  const CollectionAnchor(
      {required this.searchController,
      required this.textEditingController,
      required this.suggestionsBuilder,
      super.key});
  final FutureOr<Iterable<Widget>> Function(BuildContext, SearchController)
      suggestionsBuilder;
  final SearchController searchController;
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchAnchor(
      searchController: searchController,
      isFullScreen: true,
      suggestionsBuilder: suggestionsBuilder,
      builder: (context, controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Expanded(
              flex: 13,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextField(
                  decoration: InputDecoration(
                      hintStyle: ShadTheme.of(context).textTheme.muted,
                      hintText: 'Tap here to select a collection'),
                  controller: textEditingController,
                  onTap: searchController.openView,
                  onChanged: (_) => searchController.openView(),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Server100@cloudonlanapps',
                    style: ShadTheme.of(context)
                        .textTheme
                        .muted
                        .copyWith(color: Colors.red),
                  )),
            )
          ],
        );
      },
    );
  }
}
