import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store_tasks/src/widgets/search_collection/text_edit_box.dart';

class EntitySearchBar extends StatelessWidget implements PreferredSizeWidget {
  const EntitySearchBar(
      {required this.controller, required this.onClose, super.key});
  final TextEditingController controller;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Hero(
            tag: 'Search bar',
            child: TextEditBox(
              controller: controller,
              //onTap: () => Navigator.of(context).pop(),
              menuItem: null,
              onTap: null,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ShadButton.link(
              onPressed: onClose,
              child: Text(
                'Close',
                style: theme.textTheme.small,
              )),
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize =>
      const Size(double.infinity, kMinInteractiveDimension * 3);
}
