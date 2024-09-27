import 'dart:developer';

import 'package:colan_services/internal/widgets/broken_image.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/widgets/shimmer.dart';
import '../models/store_model.dart';
import '../providers/store_cache.dart';
import '../providers/uri.dart';

class GetNotesByMediaId extends ConsumerWidget {
  const GetNotesByMediaId({
    required this.mediaId,
    required this.buildOnData,
    super.key,
  });

  final int mediaId;
  final Widget Function(List<CLMedia> notes) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStore(
      builder: (theStore) {
        return FutureBuilder(
          future: theStore.getNotes(mediaId),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return buildOnData(snapshot.data!);
            }
            return const CircularProgressIndicator();
          },
        );
      },
    );
  }
}

class GetStore extends ConsumerWidget {
  const GetStore({
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final Widget Function(StoreCache store) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(storeCacheProvider);

    return storeAsync.when(
      loading: loadingBuilder ??
          () {
            return const CircularProgressIndicator();
          },
      error: errorBuilder ?? (_, __) => Container(),
      data: builder,
    );
  }
}

class GetMediaUri extends ConsumerWidget {
  const GetMediaUri({
    required this.id,
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final int id;
  final Widget Function(Uri uri) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(mediaUriProvider(id))
      ..whenOrNull(data: printUri);

    return storeAsync.when(
      data: builder,
      error: errorBuilder ?? BrokenImage.show,
      loading: loadingBuilder ??
          () => Column(
                children: [
                  if (CLPopScreen.canPop(context))
                    Align(
                      alignment: Alignment.centerRight,
                      child: CLPopScreen.onTap(
                        child: CLButtonIcon.large(
                          clIcons.pagePop,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  Center(child: GreyShimmer.show()),
                ],
              ),
    );
  }

  void printUri(Uri uri) {
    log(uri.toString(), name: 'GetMediaUri');
  }
}

class GetPreviewUri extends ConsumerWidget {
  const GetPreviewUri({
    required this.id,
    required this.builder,
    super.key,
    this.errorBuilder,
    this.loadingBuilder,
  });
  final int id;
  final Widget Function(Uri uri) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(previewUriProvider(id))
      ..whenOrNull(data: printUri);
    return storeAsync.when(
      data: builder,
      error: errorBuilder ?? BrokenImage.show,
      loading: loadingBuilder ?? GreyShimmer.show,
    );
  }

  void printUri(Uri uri) {
    log(uri.toString(), name: 'GetPreviewUri');
  }
}
