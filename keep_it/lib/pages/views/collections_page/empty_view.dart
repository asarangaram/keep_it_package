import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/app_theme.dart';

class EmptyViewCollection extends ConsumerWidget {
  const EmptyViewCollection({
    super.key,
    required this.clMenuItems,
  });
  final List<CLMenuItem> clMenuItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppTheme(
      child: Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var menuItem in clMenuItems)
              Expanded(
                child: CLButtonElevated.large(
                  onTap: menuItem.onTap,
                  child: CLIconLabelled.large(
                    menuItem.icon,
                    menuItem.title,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/*

child: 
                     */