import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsEmpty extends ConsumerWidget {
  const TagsEmpty({
    required this.menuItems,
    super.key,
  });
  final List<List<CLMenuItem>> menuItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CLText.large('Create your first tag'),
          const SizedBox(
            height: 32,
          ),
          CLButtonsGrid(
            children2D: menuItems,
          ),
        ],
      ),
    );
  }
}
