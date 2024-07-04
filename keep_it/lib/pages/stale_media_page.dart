import 'package:flutter/material.dart';

import '../modules/media_wizard/models/types.dart';
import '../modules/media_wizard/views/media_wizard.dart';

class StaleMediaPage extends StatelessWidget {
  const StaleMediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UniversalMediaWizard(type: UniversalMediaTypes.staleMedia);
  }
}
