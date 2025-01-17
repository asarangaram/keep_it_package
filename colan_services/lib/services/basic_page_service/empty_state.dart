import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'basic_page_service.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, this.message = 'Empty', this.menuItems});
  final dynamic message;
  final List<CLMenuItem>? menuItems;
  @override
  Widget build(BuildContext context) {
    return BasicPageService.message(
      message: message,
      menuItems: menuItems,
    );
  }
}

class EmptyState extends MessageWidget {
  const EmptyState({super.key, super.message, super.menuItems});
}
