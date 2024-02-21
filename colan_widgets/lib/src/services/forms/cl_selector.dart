import 'dart:async';

import 'package:flutter/material.dart';

import 'models.dart';

class CLSelector extends StatefulWidget {
  const CLSelector({
    required this.controller,
    required this.selector,
    super.key,
  });
  final SearchController controller;
  final CLFromFieldTypeSelector selector;

  @override
  State<StatefulWidget> createState() => _CLSelectorState();
}

class _CLSelectorState extends State<CLSelector> {
  late ScrollController scrollController;
  final GlobalKey wrapKey = GlobalKey();

  @override
  void initState() {
    scrollController = ScrollController();

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        width: double.infinity,
        height: 6 * kMinInteractiveDimension,
        decoration: BoxDecoration(border: Border.all()),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              key: wrapKey,
              spacing: 1,
              runSpacing: 1,
              children: [
                if (widget.selector.initialEntries != null)
                  ...widget.selector.initialEntries!.map(
                    (e) => Theme(
                      data: Theme.of(context).copyWith(
                        chipTheme: const ChipThemeData(
                          side: BorderSide.none,
                        ),
                        canvasColor: Colors.transparent,
                      ),
                      child: Chip(
                        label: Text(widget.selector.buildLabel(e)),
                        onDeleted: () {
                          widget.selector.removeItem(context, e);
                        },
                      ),
                    ),
                  ),
                SearchAnchor(
                  searchController: widget.controller,
                  isFullScreen: false,
                  viewBackgroundColor: Theme.of(context).colorScheme.surface,
                  builder: (context, controller) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                      ),
                      child: ActionChip(
                        avatar: const Icon(Icons.add),
                        label: Text(
                          (widget.selector.initialEntries?.isEmpty ?? false)
                              ? 'Add'
                              : 'Add another',
                        ),
                        onPressed: controller.openView,
                        shape: const ContinuousRectangleBorder(
                          side: BorderSide(),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                    );
                  },
                  suggestionsBuilder: suggestionsBuilder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FutureOr<Iterable<Widget>> suggestionsBuilder(
    BuildContext context,
    SearchController controller,
  ) {
    final list = <Widget>[];
    final availableSuggestions =
        widget.selector.getSuggestions(context, controller.text);

    if (availableSuggestions.isNotEmpty) {
      list.addAll(
        availableSuggestions.map((c) {
          final description = widget.selector.buildDescription?.call(c);
          return ListTile(
            title: Text(widget.selector.buildLabel(c)),
            subtitle: description == null
                ? null
                : Text(widget.selector.buildLabel(c)),
            onTap: () {
              //controller.closeView(widget.selector.buildLabel(c));

              widget.selector.onSelectSuggestion(context, c);
            },
          );
        }),
      );
    }
    if (!widget.selector.hasMatchingSuggestion(context, controller.text)) {
      list.add(
        ListTile(
          title: Text('Create "${controller.text}"'),
          onTap: () {
            if (controller.text.isNotEmpty) {
              controller.closeView(controller.text);

              widget.selector.onCreate(context, controller.text);
            }
          },
        ),
      );
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
