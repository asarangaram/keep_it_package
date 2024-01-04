import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../app_descriptor.dart';

import '../providers/incoming_media.dart';

class PageIncomingMedia extends ConsumerWidget {
  const PageIncomingMedia({
    super.key,
    required this.builder,
  });
  final IncomingMediaViewBuilder? builder;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingMedia = ref.watch(incomingMediaProvider);
    final sharedMedia = incomingMedia.data[0];
    return builder?.call(context, ref, sharedMedia: sharedMedia, onDiscard: () {
          ref.read(incomingMediaProvider.notifier).pop();
        }) ??
        IncomingMediaViewDefault(
            media: sharedMedia,
            onDiscard: () {
              ref.read(incomingMediaProvider.notifier).pop();
            });
  }
}

class IncomingMediaViewDefault extends StatelessWidget {
  const IncomingMediaViewDefault({
    super.key,
    required this.media,
    required this.onDiscard,
  });

  final Map<String, SupportedMediaType> media;
  final Function() onDiscard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final e in media.entries) ...[
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: "${e.value.name.toUpperCase()}: ",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: e.key)
            ])),
            const SizedBox(height: 16),
          ],
          TextButton(
            onPressed: onDiscard,
            child: const Text("Clear"),
          )
        ]),
      )),
    );
  }
}
