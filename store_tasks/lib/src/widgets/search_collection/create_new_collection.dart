import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateNewCollection extends StatelessWidget {
  const CreateNewCollection({
    required this.searchController,
    super.key,
  });

  final SearchController searchController;

  @override
  Widget build(BuildContext context) {
    final suggestedName = searchController.text;
    return FolderItem(
      name: suggestedName.isEmpty ? 'Create New' : "Create '$suggestedName'",
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
