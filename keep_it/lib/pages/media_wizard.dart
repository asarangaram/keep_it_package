import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

class MediaWizardPage extends StatelessWidget {
  const MediaWizardPage({required this.type, super.key});
  final UniversalMediaTypes type;

  @override
  Widget build(BuildContext context) {
    return MediaWizardService(type: type);
  }
}
