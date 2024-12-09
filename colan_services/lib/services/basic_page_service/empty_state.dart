import 'package:flutter/material.dart';

import '../../colan_services.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, this.message = 'Empty'});
  final dynamic message;

  @override
  Widget build(BuildContext context) {
    return BasicPageService.message(
      message: message,
    );
  }
}

class EmptyState extends MessageWidget {
  const EmptyState({super.key, super.message});
}
