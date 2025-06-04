import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/entity_viewer_service/widgets/when_error.dart';

abstract class CLPageWidget extends ConsumerWidget {
  const CLPageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref);
  Widget errorBuilder(Object e, StackTrace st) => WhenError(
        errorMessage: e.toString(),
      );
  Widget loadingWidget() => CLLoader.widget(
        debugMessage: widgetLabel,
      );

  String get widgetLabel;
}
