import 'package:flutter/material.dart';
import 'package:store_tasks/src/widgets/search_collection/text_edit_box.dart';

import 'store_selector.dart';

class EntitySearchBar extends StatelessWidget implements PreferredSizeWidget {
  const EntitySearchBar(
      {required this.controller, required this.onClose, super.key});
  final TextEditingController controller;
  final void Function() onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kMinInteractiveDimension * 3,
      child: Hero(
        tag: 'Search bar',
        child: TextEditBox(
            controller: controller,
            onTap: null,
            serverWidget: StoreSelector(onClose: onClose)),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size(double.infinity, kMinInteractiveDimension * 3);
}
