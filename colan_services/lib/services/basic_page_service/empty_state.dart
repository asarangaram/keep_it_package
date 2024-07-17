import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key, this.message = 'Empty'});
  final String message;

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
