import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'views/collections_page/collections_view.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(null));
    return CLFullscreenBox(
      useSafeArea: false,
      child: Stack(
        children: [
          collectionsAsync.when(
              loading: () => onLoad(),
              error: (err, _) => onError(context, err),
              data: (collections) => CLBackground(
                  brighnessFactor: collections.isNotEmpty ? 0.25 : 0,
                  child: CollectionsView(collections))),
        ],
      ),
    );
  }

  onLoad() {
    return const CLBackground(brighnessFactor: 0.3, child: CLLoadingView());
  }

  onError(BuildContext context, err, {String? details}) {
    return CLBackground(
      brighnessFactor: 0.3,
      child: CLErrorView(
        errorMessage: err.toString(),
        errorDetails: details,
      ),
    );
  }
}

class CLBackground extends ConsumerWidget {
  const CLBackground({
    super.key,
    required this.child,
    this.brighnessFactor = 0,
  });
  final Widget child;
  final double brighnessFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ]
                  .map((e) => brighnessFactor < 0
                      ? e.reduceBrightness(-brighnessFactor)
                      : e.increaseBrightness(brighnessFactor))
                  .toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
