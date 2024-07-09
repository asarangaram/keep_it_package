import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key, this.message = 'Empty'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      child: BasicPageService.withNavBar(
        message: message,
      ),
    );
  }
}
