import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

class TextEditBox extends ConsumerWidget {
  const TextEditBox(
      {required this.controller,
      required this.onTap,
      required this.serverWidget,
      super.key,
      this.collection});
  final StoreEntity? collection;

  final TextEditingController controller;
  final void Function()? onTap;
  final Widget? serverWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Expanded(
          flex: 13,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TextFormField(
              controller: controller,
              decoration: collection == null
                  ? InputDecoration(
                      hintStyle: ShadTheme.of(context).textTheme.muted,
                      hintText: 'Search here')
                  : null,
              readOnly: onTap != null,
              showCursor: onTap != null,
              enableInteractiveSelection: false,
              onTap: onTap,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Align(alignment: Alignment.centerRight, child: serverWidget),
        )
      ],
    );
  }
}
