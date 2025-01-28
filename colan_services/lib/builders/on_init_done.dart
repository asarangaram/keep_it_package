import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../services/basic_page_service/widgets/cl_error_view.dart';

class OnInitDone extends ConsumerWidget {
  const OnInitDone({
    required this.app,
    required this.uri,
    required this.builder,
    super.key,
  });

  final AppDescriptor app;
  final Widget Function() builder;

  final Uri uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitAsync = ref.watch(appInitProvider(app));
    return appInitAsync.when(
      data: (done) {
        return builder();
      },
      error: (err, _) {
        return ShadApp(
          debugShowCheckedModeBanner: false,
          home: CLErrorView(errorMessage: err.toString()),
        );
      },
      loading: () {
        return ShadApp(
          debugShowCheckedModeBanner: false,
          home: CLLoader.widget(
            debugMessage: 'appInitAsync',
          ),
        );
      },
    );
  }
}
