import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_loader/app_loader.dart';
import 'package:store/store.dart';

class CollectionsFromDB extends ConsumerWidget {
  const CollectionsFromDB({
    super.key,
    required this.buildOnData,
  });
  final Widget Function(Collections collections) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(null));
    return collectionsAsync.when(
        loading: () => onLoad(),
        error: (err, _) => onError(context, err),
        data: (collections) => CLBackground(
            brighnessFactor: collections.isNotEmpty ? 0.25 : 0,
            child: buildOnData(collections)));
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
