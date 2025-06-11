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
  }) {
    return BasicPageService._(
      message: message,
      menuItems: const [],
      key: ValueKey('$message ${false}'),
    );
  }

  final dynamic message;

  final List<CLMenuItem>? menuItems;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 16,
        children: [
          Expanded(
            child: (message is String)
                ? Center(
                    child: CLText.large(
                      message as String,
                    ),
                  )
                : (message is Widget)
                    ? message as Widget
                    : throw Exception('must be either widget or a string'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 8,
            children: [
              if (menuItems == null) ...[
                if (PageManager.of(context).canPop())
                  CLButtonIconLabelled.standard(
                    clIcons.pagePop,
                    'Back',
                    onTap: PageManager.of(context).pop,
                  ),
                CLButtonIconLabelled.standard(
                  clIcons.navigateHome,
                  'Home',
                  onTap: () => PageManager.of(context).home(),
                )
              ] else
                ...menuItems!.map((e) {
                  return CLButtonIconLabelled.standard(
                    e.icon,
                    e.title,
                    onTap: e.onTap,
                  );
                }),
            ],
          ),
        ],
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
