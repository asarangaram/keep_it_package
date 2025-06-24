import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../pick_collection/pick_wizard.dart';
import '../pick_collection/server_label.dart';

class TextEditBox extends ConsumerWidget {
  const TextEditBox({super.key, this.collection});
  final StoreEntity? collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: kMinInteractiveDimension * 3,
      child: PickWizard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Expanded(
              flex: 13,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextFormField(
                  initialValue: collection?.label,
                  decoration: collection == null
                      ? InputDecoration(
                          hintStyle: ShadTheme.of(context).textTheme.muted,
                          hintText: 'Search here')
                      : null,
                  readOnly: true,
                  showCursor: false,
                  enableInteractiveSelection: false,
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: collection == null
                      ? null
                      : ServerLabel(
                          store: (collection!).store,
                        )),
            )
          ],
        ),
      ),
    );
  }
}
