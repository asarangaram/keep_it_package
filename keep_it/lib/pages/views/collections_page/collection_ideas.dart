import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/collection.dart';
import '../../../providers/theme.dart';
import '../collection_list_view.dart';

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
            return CollectionListViewDialog.fromDBSelectable(
              clusterID: null,
              onSelectionDone: (l) {
                debugPrint(l.map((e) => e.label).join(","));
                Navigator.of(context).pop();
              },
              onSelectionCancel: () {
                debugPrint("dialog cancelled");
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
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
