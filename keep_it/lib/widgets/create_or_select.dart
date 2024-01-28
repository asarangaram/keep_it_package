import 'dart:async';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class CreateOrSelect extends StatefulWidget {
  const CreateOrSelect({
    required this.onDone,
    required this.anchorBuilder,
    this.suggestedCollections,
    this.controller,
    this.focusNode,
    super.key,
  });

  final List<CollectionBase>? suggestedCollections;
  final void Function(CollectionBase item) onDone;
  final SearchController? controller;
  final FocusNode? focusNode;
  final Widget Function(
    BuildContext context,
    SearchController controller, {
    required void Function(CollectionBase) onDone,
  }) anchorBuilder;

  @override
  State<CreateOrSelect> createState() => CreateOrSelectState();
}

class CreateOrSelectState extends State<CreateOrSelect> {
  @override
  void initState() {
    if (!(widget.focusNode?.hasFocus ?? false)) {
      widget.focusNode?.requestFocus();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return SearchAnchor(
      searchController: widget.controller,
      isFullScreen: false,
      viewBackgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context, controller) {
        return widget.anchorBuilder(
          context,
          controller,
          onDone: widget.onDone,
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
    if (widget.suggestedCollections != null) {
      final List<CollectionBase> availableSuggestions;
      if (controller.text.isEmpty) {
        availableSuggestions = widget.suggestedCollections!;
      } else {
        availableSuggestions = widget.suggestedCollections!
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
              setState(() {
                widget.focusNode?.unfocus();
                controller.closeView(c.label);
              });
              widget.onDone(c);
            },
          );
        }),
      );
    }
    if (controller.text.isNotEmpty) {
      final c = widget.suggestedCollections
          ?.where((element) => element.label == controller.text)
          .firstOrNull;

      if (c == null) {
        list.add(
          ListTile(
            title: Text('Create "${controller.text}"'),
            onTap: () {
              if (controller.text.isNotEmpty) {
                controller.closeView(controller.text);

                widget.focusNode?.unfocus();
                final c = widget.suggestedCollections
                    ?.where((element) => element.label == controller.text)
                    .firstOrNull;
                widget.onDone(c ?? CollectionBase(label: controller.text));
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
