import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/theme.dart';
import '../../../providers/db_store.dart';
import 'add_collection_form.dart';

class AddNewCollection extends ConsumerStatefulWidget {
  const AddNewCollection({
    super.key,
    required this.quickMenuScopeKey,
  });

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  ConsumerState<AddNewCollection> createState() => _AddNewCollectionState();
}

class _AddNewCollectionState extends ConsumerState<AddNewCollection> {
  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.read(collectionsProvider(null));
    final theme = ref.watch(themeProvider);
    return CLButtonIconLabelled.standard(
      Icons.add_circle_outline_outlined,
      "New Collection",
      onTap: collectionsAsync.whenOrNull(
          data: (collections) => () => showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                      backgroundColor: theme.colorTheme.backgroundColor,
                      insetPadding: const EdgeInsets.all(8.0),
                      child: UpsertCollectionForm(collections: collections));
                },
              )),
      color: theme.colorTheme.textColor,
      disabledColor: theme.colorTheme.disabledColor,
    );
  }
}
