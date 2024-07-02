import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/empty_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:store/store.dart';

import '../models/media_handler.dart';
import '../modules/shared_media/step4_save_collection.dart';
import '../modules/shared_media/wizard_page.dart';
import '../modules/universal_media_handler/universal_media_handler.dart';

import '../widgets/editors/collection_editor_wizard/create_collection_wizard.dart';

class StaleMediaPage extends ConsumerWidget {
  const StaleMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Unclassified Media';
    const parentIdentifier = 'Unclassified Media';
    return FullscreenLayout(
      child: GetStaleMedia(
        buildOnData: (media) {
          if (media.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CLPopScreen.onPop(context);
            });
          }
          return CLPopScreen.onSwipe(
            child: UniversalMediaHandler(
              label: label,
              parentIdentifier: parentIdentifier,
              media: media,
              emptyState: const EmptyState(),
            ),
          );
        },
      ),
    );
  }
}
