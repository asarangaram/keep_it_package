import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

class StaleMediaPage extends StatelessWidget {
  const StaleMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaWizardService(type: UniversalMediaTypes.staleMedia);
  }
}
