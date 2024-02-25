/* import 'dart:async';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CollectionCreateOrSelect extends StatelessWidget {
  const CollectionCreateOrSelect({
    required this.onDone,
    required this.anchorBuilder,
    this.suggestedCollections,
    this.controller,
    super.key,
  });

  final List<Collection>? suggestedCollections;
  final void Function(Collection item) onDone;
  final SearchController? controller;

  final Widget Function(
    BuildContext context,
    SearchController controller, {
    required void Function(Collection) onDone,
  }) anchorBuilder;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: controller,
      isFullScreen: false,
      viewBackgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context, controller) {
        return anchorBuilder(
          context,
          controller,
          onDone: onDone,
        );
      },
      viewHintText: 'Enter Collection Name',
      suggestionsBuilder: suggestionsBuilder,
    );
  }

  FutureOr<Iterable<Widget>> suggestionsBuilder(
    BuildContext context,
    SearchController controller,
  ) {
    final list = <Widget>[];
    if (suggestedCollections != null) {
      final List<Collection> availableSuggestions;
      if (controller.text.isEmpty) {
        availableSuggestions = suggestedCollections!;
      } else {
        availableSuggestions = suggestedCollections!
            .where(
              (element) => element.label.contains(controller.text),
            )
            .toList();
      }
      list.addAll(
        availableSuggestions.map((c) {
          return ListTile(
            title: Text(c.label),
            subtitle: c.description == null ? null : Text(c.description!),
            onTap: () {
              controller.closeView(c.label);

              onDone(c);
            },
          );
        }),
      );
    }
    if (controller.text.isNotEmpty) {
      final c = suggestedCollections
          ?.where((element) => element.label == controller.text)
          .firstOrNull;

      if (c == null) {
        list.add(
          ListTile(
            title: Text('Create "${controller.text}"'),
            onTap: () {
              if (controller.text.isNotEmpty) {
                controller.closeView(controller.text);

                final c = suggestedCollections
                    ?.where((element) => element.label == controller.text)
                    .firstOrNull;
                onDone(c ?? Collection(label: controller.text));
              }
            },
          ),
        );
      }
    }
    return list
      ..add(
        ListTile(
          title: SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          ),
        ),
      );
  }
}
 */
