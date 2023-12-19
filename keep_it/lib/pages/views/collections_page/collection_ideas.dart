import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/receive_shared/save_or_cancel.dart';

import '../../../models/collection.dart';
import '../../../providers/select_handler.dart';
import '../../../providers/theme.dart';

class TestButton extends ConsumerWidget {
  const TestButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Center(
      child: CLButtonElevatedText.large(
        "show Dialog",
        color: theme.colorTheme.textColor,
        disabledColor: theme.colorTheme.disabledColor,
        boxDecoration: BoxDecoration(border: Border.all()),
        onTap: () => showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                backgroundColor: theme.colorTheme.backgroundColor,
                insetPadding: const EdgeInsets.all(8.0),
                child: CollectionListView(
                  collectionList: defaultCollections,
                  onTab: (index) => print("index selected: $index"),
                  onSelectionDone: (l) {
                    print(l.map((e) => e.label).join(","));
                    Navigator.of(context).pop();
                  },
                  onSelectionCancel: () {
                    Navigator.of(context).pop();
                  },
                ));
          },
        ),
      ),
    );
  }
}

class CollectionListView extends ConsumerWidget {
  const CollectionListView({
    super.key,
    required this.collectionList,
    this.onTab,
    this.onSelectionDone,
    this.onSelectionCancel,
  });
  final List<Collection> collectionList;

  final Function(int index)? onTab;
  final Function(List<Collection>)? onSelectionDone;
  final Function()? onSelectionCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSelectable = onSelectionDone != null;
    final theme = ref.watch(themeProvider);

    final selectedItems =
        ref.watch(selectableItemsSelectedItemsProvider(collectionList));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (isSelectable)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CLButtonText.standard(
                  "Select All",
                  color: theme.colorTheme.buttonText,
                  disabledColor: theme.colorTheme.disabledColor,
                  onTap: () {
                    for (var c in collectionList) {
                      ref.read(selectableItemProvider(c).notifier).select();
                    }
                  },
                ),
                CLButtonText.standard(
                  "Select None",
                  color: theme.colorTheme.buttonText,
                  disabledColor: theme.colorTheme.disabledColor,
                  onTap: () {
                    for (var c in collectionList) {
                      ref.read(selectableItemProvider(c).notifier).deselect();
                    }
                  },
                )
              ],
            ),
          Expanded(
            child: ListView.builder(
              itemCount: collectionList.length,
              itemBuilder: (context, index) {
                final selectableItem =
                    ref.watch(selectableItemProvider(collectionList[index]));
                return ListTile(
                  title: Text(collectionList[index].label),
                  subtitle: Text(collectionList[index].description ?? ""),
                  leading: (isSelectable)
                      ? Checkbox(
                          value: selectableItem.isSelected,
                          onChanged: (value) {
                            // Update the isChecked property when the checkbox is toggled
                            if (value != null) {
                              ref
                                  .read(selectableItemProvider(
                                          collectionList[index])
                                      .notifier)
                                  .toggleSelection();
                            }
                          },
                        )
                      : null,
                  onTap: () => onTab?.call(index),
                );
              },
            ),
          ),
          if (isSelectable) ...[
            const Divider(
              thickness: 4,
              height: 4,
            ),
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  child: SelectedCollections(
                    collectionList: collectionList,
                  ),
                ),
              ),
            ),
            const Divider(
              thickness: 1,
              height: 4,
            ),
            SaveOrCancel(
              onSave: () => onSelectionDone
                  ?.call(selectedItems.map((e) => e as Collection).toList()),
              onDiscard: onSelectionCancel ?? () {},
              saveLabel: "Create Selected",
            )
          ]
        ],
      ),
    );
  }
}

class SelectedCollections extends ConsumerWidget {
  const SelectedCollections({super.key, required this.collectionList});
  final List<Collection> collectionList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems =
        ref.watch(selectableItemsSelectedItemsProvider(collectionList));

    return Text.rich(TextSpan(children: [
      TextSpan(
          text: selectedItems.map((e) => e.label).join(", "),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontSize: CLScaleType.small.fontSize))
    ]));
  }
}

List<Collection> defaultCollections = [
  Collection(
      label: "Memorabilia",
      description:
          "Images of sentimental items or things with emotional value"),
  Collection(
      label: "Family", description: "Special moments with family members"),
  Collection(
      label: "Quotes",
      description:
          "Images containing motivational quotes, book passages, or memorable phrases"),
  Collection(
      label: "Education",
      description:
          "Images related to educational journey, certificates, or study materials"),
  Collection(
      label: "Celebrations",
      description: "Images related to birthday, anniversary, weddings"),
  Collection(
      label: "Vacations",
      description:
          "Memorable images from vacations, trips, and travel adventures"),
  Collection(
      label: "Celebrations",
      description:
          "Special moments during celebrations like birthdays, anniversaries, and parties"),
  Collection(
      label: "Bills",
      description: "Images related to bills and financial transactions."),
  Collection(
      label: "Downloaded",
      description: "Images that are downloaded from the internet "),
  Collection(
      label: "Screenshots", description: "Screenshots from various devices"),
  Collection(
      label: "Received",
      description:
          "Images received from others, such as WhatsApp, Instagram, Emails"),
  Collection(
      label: "Documents",
      description: "Important documents, contracts, reports"),
  Collection(
      label: "Hobbies",
      description:
          "Images related to your hobbies and interests, such as hobbies, crafts, or DIY projects"),
];
