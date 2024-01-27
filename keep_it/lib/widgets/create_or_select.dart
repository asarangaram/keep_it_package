import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class CreateOrSelect extends StatefulWidget {
  const CreateOrSelect({
    required this.onDone,
    this.suggestedCollections,
    this.controller,
    this.focusNode,
    super.key,
  });

  final List<CollectionBase>? suggestedCollections;
  final void Function(CollectionBase item) onDone;
  final SearchController? controller;
  final FocusNode? focusNode;

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SearchAnchor(
          searchController: widget.controller,
          isFullScreen: false,
          viewBackgroundColor: Theme.of(context).colorScheme.surface,
          dividerColor: Colors.blue,
          headerTextStyle: const TextStyle(color: Colors.blue),
          headerHintStyle: const TextStyle(color: Colors.blue),
          builder: (
            BuildContext context,
            SearchController controller,
          ) {
            return SearchBar(
              focusNode: widget.focusNode,
              controller: controller,
              padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16),
              ),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              onSubmitted: (val) {
                widget.focusNode?.unfocus();
                final c = widget.suggestedCollections
                    ?.where((element) => element.label == val)
                    .firstOrNull;
                widget.onDone(c ?? CollectionBase(label: val));
              },
              leading: const CLIcon.small(Icons.search),
              hintText: 'Collection Name',
            );
          },
          viewHintText: 'Enter Collection Name',
          suggestionsBuilder: (
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
                availableSuggestions.map((e) {
                  return ListTile(
                    title: Text(e.label),
                    onTap: () {
                      setState(() {
                        widget.focusNode?.unfocus();
                        controller.closeView(e.label);
                      });
                      widget.onDone(e);
                    },
                  );
                }),
              );
            }
            /* final list = suggestedCollections.where(
              (element) {
                if (controller.text.isEmpty) return true;
                return element.toLowerCase().contains(
                      controller.text.toLowerCase(),
                    );
              },
            ).map((e) {
              
            }).toList(); */
            if (list.isEmpty && controller.text.isNotEmpty) {
              list.add(
                ListTile(
                  title: Text('Create "${controller.text}"'),
                  onTap: () {
                    setState(() {
                      controller.closeView(controller.text);
                    });
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
          },
        ),
      ),
    );
  }
}
