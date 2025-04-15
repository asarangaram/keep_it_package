import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'widgets/page_manager.dart';

class BasicPageService extends StatelessWidget {
  const BasicPageService._({
    required this.message,
    required this.menuItems,
    super.key,
  });
  // Use with Page
  factory BasicPageService.withNavBar({
    required dynamic message,
    List<CLMenuItem>? menuItems,
  }) {
    return BasicPageService._(
      message: message,
      menuItems: menuItems,
      key: ValueKey('$message ${true}'),
    );
  }
  // Use as Widget
  factory BasicPageService.message({
    required dynamic message,
    List<CLMenuItem>? menuItems,
  }) {
    return BasicPageService._(
      message: message,
      menuItems: menuItems,
      key: ValueKey('$message ${false}'),
    );
  }
  factory BasicPageService.nothingToShow({
    dynamic message = 'Empty',
    List<CLMenuItem>? menuItems,
  }) {
    return BasicPageService._(
      message: message,
      menuItems: menuItems,
      key: ValueKey('$message ${false}'),
    );
  }
  final dynamic message;

  final List<CLMenuItem>? menuItems;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: (message is String)
                    ? CLText.large(
                        message as String,
                      )
                    : (message is Widget)
                        ? message as Widget
                        : throw Exception('must be either widget or a string'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (menuItems != null)
                    ...menuItems!.map((e) {
                      return CLButtonIcon.large(
                        e.icon,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: e.onTap,
                      );
                    })
                  else ...[
                    if (PageManager.of(context).canPop())
                      CLButtonIcon.large(
                        clIcons.pagePop,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: PageManager.of(context).pop,
                      ),
                    CLButtonIcon.large(
                      clIcons.navigateHome,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => PageManager.of(context).home(),
                    ),
                  ],
                ].map((e) => Expanded(child: Center(child: e))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
    /* 
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CLText.large(
          message,
        ),
      ),
    ); */
  }
}
