import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme.dart';
import '../../../providers/db_store/db_collection.dart';
import 'add_collection_form.dart';

class AddNewCollection extends ConsumerStatefulWidget {
  const AddNewCollection({super.key});

  @override
  ConsumerState<AddNewCollection> createState() => _AddNewCollectionState();
}

class _AddNewCollectionState extends ConsumerState<AddNewCollection> {
  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.read(collectionsProvider(null));
    final theme = ref.watch(themeProvider);
    return CLButtonIcon.small(
      Icons.add,
      onTap: collectionsAsync.whenOrNull(
          data: (collections) => () => showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                      backgroundColor: theme.colorTheme.backgroundColor,
                      insetPadding: const EdgeInsets.all(8.0),
                      child: const UpsertCollectionForm());
                },
              )),
      color: theme.colorTheme.textColor,
      disabledColor: theme.colorTheme.disabledColor,
    );
  }
}
