import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateNewCollection extends StatelessWidget {
  const CreateNewCollection(
      {required this.suggestedName, required this.onSelect, super.key});

  final String suggestedName;
  final void Function(ViewerEntity) onSelect;

  @override
  Widget build(BuildContext context) {
    return FolderItem(
      name: null,
      child: SizedBox.expand(
          child: FractionallySizedBox(
        widthFactor: 0.7,
        heightFactor: 0.7,
        child: FittedBox(
            fit: BoxFit.cover,
            child: Icon(
              LucideIcons.plus,
              color: const Color(0xFFE6B65C).withValues(alpha: 0.6),
            )),
      )),
    );
  }
}
